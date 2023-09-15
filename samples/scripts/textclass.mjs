#!/usr/bin/env node

import { $, fetch } from "zx";
$.verbose = false;

import yargs from "yargs";
import { hideBin } from "yargs/helpers";

import path from "path";
import fs from "fs";

import fg from "fast-glob";

import { DOMParser, XMLSerializer } from "@xmldom/xmldom";
import xpath from "xpath";
import { JSDOM } from 'jsdom';

import colors from 'colors';
import express from "express";
import http from "http";
import morgan from "morgan";
import serveStatic from 'serve-static';
import cookieParser from 'cookie-parser';
import proxy from 'express-http-proxy';

let logger;
const log = console.log;

const select = xpath.useNamespaces({
  dlxs: "http://dlxs.org",
  qui: "http://dlxs.org/quombat/ui",
  qbat: "http://dlxs.org/quombat",
  xhtml: "http://www.w3.org/1999/xhtml",
});

const xsltBase = `<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
</xsl:stylesheet>`;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");
const configPath = `${rootPath}/templates/text/`;
const textPath = `${rootPath}/templates/text/`;
const scriptName = path.basename(moduleURL.pathname);

const argv = yargs(hideBin(process.argv)).argv;
const dlxsBase = argv.proxy ? 'dcp-proto.kubernetes.lib.umich.edu' : 'roger.quod.lib.umich.edu';
const beta1Base = 'beta1.quod.lib.umich.edu';

function start() {
  let addr = "0.0.0.0";
  let port = 5555;
  listen({ address: addr, port: port });
}

function allowCrossDomain(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE");
  res.header("Access-Control-Allow-Headers", "Content-Type");

  next();
}

async function proxyIndex(req, res) {
  const headers = {};
  // console.log("-- cookies", req.cookies);
  if (req.cookies.loggedIn == 'true') {
    headers['X-DLXS-Auth'] = 'nala@monkey.nu';
  }
  if ( ! req.headers['x-forwarded-host'] ) {
    headers["x-forwarded-host"] = "localhost:5555";
  }

  const resp = await fetch(`https://${dlxsBase}${req.originalUrl}`, {
    headers: headers,
    redirect: 'follow',
    credentials: 'include'
  });

  let body = await resp.text();
  body = body.replace(/https?:\/\/quod.lib.umich.edu\//g, '/');

  res.setHeader("Content-Type", "text/html");
  res.send(body);
}

async function processDLXS(req, res) {
  let appBase = ( false && req.cookies.useBeta == 'true' ) ? beta1Base : dlxsBase;
  let url = new URL(
    `https://${appBase}${req.originalUrl.replace(/;/g, "&")}`
  );

  if ( req.cookies.useBeta == 'true' ) {
    // we're just proxying and sending this
    return proxyBeta(req, res);
  }

  // if ( req.originalUrl == '/cgi/i/image/image-idx' || 
  //      req.originalUrl == '/cgi/i/image/image-idx?page=groups' ) {
  //   return proxyIndex(req, res);
  // }

  let debug = url.searchParams.get('debug');

  url.searchParams.set("debug", 'xml');

  const headers = {};
  // console.log("-- cookies", req.cookies);
  if ( req.cookies.loggedIn == 'true' ) {
    headers['X-DLXS-Auth'] = 'nala@monkey.nu';
  }
  headers['X-DLXS-Uplifted'] = 'true';
  headers['x-forwarded-host'] = req.headers['x-forwarded-host'] || 'localhost:5555';

  // headers['X-DLXS-SessionID'] = `${req.socket.remoteAddress}--${(new Date).getDay()}`;
  headers['Cookie'] = `DLXSsid=${req.cookies.DLXSsid}`;
  console.log("AHOY PROXY", headers['Cookie']);


  const resp = await fetch(url.toString(), {
    headers: headers,
    redirect: 'follow',
    credentials: 'include'
  });
  res.setHeader("Content-Type", "text/html; charset=UTF-8");
  if (resp.ok) {
    const cookieValue = (resp.headers.get('set-cookie').split(/;\s*/))[0].replace('DLXSsid=','');
    res.cookie('DLXSsid', cookieValue, { path: '/' });
    console.log("AHOY AHOY cookie = ", cookieValue);
    const xmlData = (await resp.text()).replace(/https:\/\/localhost/g, 'http://localhost');
    if ( xmlData.indexOf('no hits. normally cgi redirects') > -1 ) {
      throw new Error('Query has no results');
    }

    // if ( xmlData.indexOf('xml') < 0 ) {
    //   console.log(xmlData);
    // }
    if ( xmlData.indexOf('Location: ') > -1 ) {
      let tmp = xmlData.match(/Location: (.*)$/si);
      let domain = ( req.hostname == 'localhost' ) ? 'http://' : 'https://';
      domain += req.hostname;
      let href = tmp[1].trim().replace('https://roger.quod.lib.umich.edu/', '/' ).replace('debug=xml', 'debug=noop');
      res.redirect(href);
      return;
    }
    
    const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");
    const collid = xpath.select(
      "string(//Param[@name='c']|//Param[@name='cc'])",
      xmlDoc
    );

    const possibleViews = [ 'tpl', 'page', 'view' ];
    let view;
    for(let i = 0; i < possibleViews.length; i++) {
      let name = possibleViews[i];
      view = xpath.select(`string(//Param[@name="${name}"])`, xmlDoc);
      if ( view ) { break; }
    }

    view = xpath.select('string(//TemplateName)', xmlDoc);

    // hacking around the home business
    if ( url.pathname.match(/^\/([a-z])\/(\w+)\/?$/) && url.size == 0 ) {
      url.searchParams.set('page', 'home');
    }

    if ( false && url.searchParams.get('page') == 'home' ) {
      view = 'index';
      xpath.select("//Param[@name='page']", xmlDoc)[0].textContent = 'index';

      // this actually gets more complicated
      const homeResp = await fetch(`https://${dlxsBase}/${collid.substr(0, 1)}/${collid}/index.html`);
      const htmlData = await homeResp.text();
      const htmlDom = new JSDOM(htmlData);
      let htmlDoc = htmlDom.window.document.body.querySelector('main');
      let klass = 'refresh';
      if ( ! htmlDoc ) {
        htmlDoc = htmlDom.window.document.body;
        klass = 'classic';
      }
      htmlDoc.querySelectorAll('script').forEach((el) => {
        el.remove();
      })
      const bodyHtml = `<div xmlns="http://www.w3.org/1999/xhtml">${htmlDoc.innerHTML}</div>`;
      const bodyDoc = new DOMParser().parseFromString(bodyHtml, "text/html");

      const homePageEl = xmlDoc.createElement('HomePage');
      homePageEl.setAttribute('class', klass);
      homePageEl.appendChild(bodyDoc.documentElement);
      xmlDoc.documentElement.appendChild(homePageEl);
      console.log("-- parsed index.html");
    }

    console.log("AHOY VIEW", view, url.searchParams.get('page'));
    if ( ! view ) {
      console.log(xmlData);
    }

    // static check
    const staticXslFilename = xpath.select(`string(//XslFallbackFileList/Filename[. = 'static.xsl'])`, xmlDoc);
    console.log("-- static check", staticXslFilename);
    if ( view != 'home' && staticXslFilename.indexOf('static.xsl') > -1 ) {
      view = 'staticincl';
    }

    console.log("AHOY COLLID", collid, view, debug);

    const valueEls = xpath.select("//Value|//Param", xmlDoc);
    valueEls.forEach((valueEl) => {
      if (valueEl.textContent.indexOf("%") > -1) {
        valueEl.textContent = unescape(valueEl.textContent);
      }
    });

    const collidPath = path.join(
      rootPath,
      "samples",
      "xsl",
      collid.substr(0, 1),
      collid,
      "uplift",
      "qui"
    );
    const viewFilename = path.join(configPath, `${view}.xml`);
    const baseFilename = `/tmp/${Date.now()}`;
    const quiCompiledFilename = `${baseFilename}.${view}.qui.xsl`;
    const qbatCompiledFilename = `${baseFilename}.${view}.qbat.xsl`;
    const inputFilename = `${baseFilename}.input.xml`;
    const quiOutputFilename = `${baseFilename}.qui.xml`;
    const qbatOutputFilename = `${baseFilename}.qbat.html`;
    let viewXmlData = fs.readFileSync(viewFilename, "utf8");

    // dumb hack
    if ( view == 'staticincl' ) {
      viewXmlData = '<Top>' + viewXmlData + '</Top>';
    }

    // oh, this is getting even more bonkers
    if ( viewXmlData.indexOf('<?CHUNK filename="feedback.chunk.xml" optional="0"?>') > -1 ) {
      const feedbackXmlChunk = fs.readFileSync(path.join(configPath, 'feedback.chunk.xml'));
      viewXmlData = viewXmlData.replace('<?CHUNK filename="feedback.chunk.xml" optional="0"?>', feedbackXmlChunk);
    }

    const viewDoc = new DOMParser().parseFromString(viewXmlData, "text/xml");
    const fallbackFilenames = xpath.select(
      "//XslFallbackFileList[@pipeline='qui']/Filename",
      viewDoc
    );
    if ( fallbackFilenames.length == 0 ) {
      fallbackFilenames.push({ textContent: 'qui/qui.echo.xsl' });
    }

    const qbatFallbackFilenames = xpath.select(
      "//XslFallbackFileList[@pipeline='qbat']/Filename",
      viewDoc
    );

    const xsltDoc = new DOMParser().parseFromString(xsltBase, "text/xml");
    console.log(fallbackFilenames);
    fallbackFilenames.forEach((fallbackFilename) => {
      [textPath, collidPath].forEach((xslPath) => {
        console.log("==>", fallbackFilename.textContent);
        const possibles = fg.sync(
          path.join(xslPath, fallbackFilename.textContent)
        );
        possibles.forEach((filename) => {
          const importEl = xsltDoc.createElement("xsl:import");
          console.log(filename);
          importEl.setAttribute("href", filename);
          xsltDoc.documentElement.appendChild(importEl);
        });
      });
    });

    const qbatXsltDoc = new DOMParser().parseFromString(xsltBase, "text/xml");
    qbatFallbackFilenames.forEach((fallbackFilename) => {
      [textPath, collidPath].forEach((xslPath) => {
        console.log("==>", fallbackFilename.textContent);
        const possibles = fg.sync(
          path.join(xslPath, fallbackFilename.textContent)
        );
        possibles.forEach((filename) => {
          const importEl = qbatXsltDoc.createElement("xsl:import");
          console.log(filename);
          importEl.setAttribute("href", filename);
          qbatXsltDoc.documentElement.appendChild(importEl);
        });
      });
    });

    fs.writeFileSync(
      inputFilename,
      new XMLSerializer().serializeToString(xmlDoc)
    );

    if (debug == "xml") {
      res.setHeader("Content-Type", "application/xml");
      res.sendFile(inputFilename);
      return;
    }

    if (!fs.existsSync(path.dirname(quiCompiledFilename))) {
      fs.mkdirSync(path.dirname(quiCompiledFilename), {
        recursive: true,
        mode: 0o775,
      });
    }
    fs.writeFileSync(
      quiCompiledFilename,
      new XMLSerializer().serializeToString(xsltDoc)
    );

    fs.writeFileSync(
      qbatCompiledFilename,
      new XMLSerializer().serializeToString(qbatXsltDoc)
    );

    if ( debug == 'qui' ) {
      await $`xsltproc --stringparam docroot "/" ${quiCompiledFilename} ${inputFilename}`.pipe(
        fs.createWriteStream(quiOutputFilename)
      );
    } else {
      await $`xsltproc ${quiCompiledFilename} ${inputFilename}`.pipe(
        fs.createWriteStream(quiOutputFilename)
      );
    }

    if ( debug == "qui" ) {
      // res.setHeader('Content-Type', 'application/xml');
      await $`xsltproc --stringparam docroot "/" ${rootPath}/templates/debug.qui.xsl ${quiOutputFilename}`.pipe(
        fs.createWriteStream(`${quiOutputFilename}.html`)
      );
      res.setHeader('Content-Type', 'text/html');
      res.sendFile(`${quiOutputFilename}.html`);
      return;
    }
    
    // const output =
    //   await $`xsltproc --stringparam use-local-identifiers false --stringparam identifier-filename ${identifierFilename} ${qbatCompiledFilename} ${quiOutputFilename}`;

    // weird bug: "output = await..." results in strange encoding issues
    // writing to a file and re-reading it do not
    await $`xsltproc --stringparam docroot "/" ${qbatCompiledFilename} ${quiOutputFilename}`.pipe(
      fs.createWriteStream(qbatOutputFilename)
    )

    const output = {};
    output.stdout = fs.readFileSync(qbatOutputFilename, "utf8");

    const outputData = output.stdout
      .replace(/src="https:\/\/roger.quod.lib.umich.edu\//g, 'src="/')
      .replace(/href="https:\/\/roger.quod.lib.umich.edu\//g, 'href="/')
      .replace(/debug=xml/g, 'debug=noop')
      .split("\n");
    outputData[0] = "<!DOCTYPE html>";
    res.send(outputData.join("\n"));


    fs.writeFileSync("/tmp/output.html", output.stdout);
    
    fs.unlinkSync(inputFilename);
    fs.unlinkSync(quiOutputFilename);
    fs.unlinkSync(qbatCompiledFilename);
    fs.unlinkSync(quiCompiledFilename);
    fs.unlinkSync(qbatOutputFilename);
  } else {
    res.send("OOPS");
  }
}

function handleError(req, res, error) {
  let html = fs.readFileSync(`${rootPath}/samples/500.html`, 'utf8');
  html = html.replace('<!-- URL -->', req.url);
  html = html.replace('<!-- ERROR -->', error);
  res.setHeader('Content-Type', 'text/html');
  res.send(html);
}

function listen(options) {
  const app = express();
  app.use(cookieParser());

  const staticServer = serveStatic(rootPath, {
    index: ["index.html", "index.htm"],
    // setHeaders: setHeaders,
  });

  const server = http.createServer(app);

  app.use(allowCrossDomain);
  server.listen(options.port, options.address);

  app.get("/favicon.ico", function (req, res) {
    const favicon = new Buffer.from(
      "AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAA/4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEREQAAAAAAEAAAEAAAAAEAAAABAAAAEAAAAAAQAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAEAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD//wAA//8AAP//AAD8HwAA++8AAPf3AADv+wAA7/sAAP//AAD//wAA+98AAP//AAD//wAA//8AAP//AAD//wAA",
      "base64"
    );
    res.setHeader("Content-Length", favicon.length);
    res.setHeader("Content-Type", "image/x-icon");
    res.end(favicon);
  });

  app.use('/cgi/t/text/api', proxy('https://roger.quod.lib.umich.edu/cgi/t/text/api', {
    https: true,
    proxyReqOptDecorator: function (proxyReqOpts, srcReq) {
      if ( ! srcReq.headers['x-forwarded-host'] ) {
        proxyReqOpts.headers["X-Forwarded-Host"] = "localhost:5555";
        return proxyReqOpts;        
      }
    },
    forwardPath: function(req) {
      return req.originalUrl.replace(/8lift/g, '');
    }
  }))

  app.use('/i/image', proxy('https://roger.quod.lib.umich.edu/i/image', {
    https: true,
    proxyReqOptDecorator: function (proxyReqOpts, srcReq) {
      if ( ! srcReq.headers['x-forwarded-host'] ) {
        proxyReqOpts.headers["X-Forwarded-Host"] = "localhost:5555";
      }
      return proxyReqOpts;        
    },
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }))

  app.use('/uplift-image-viewer', proxy('https://roger.quod.lib.umich.edu/uplift-image-viewer', {
    https: true,
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }))

  app.use('/t/text', proxy('https://roger.quod.lib.umich.edu/t/text', {
    https: true,
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }))

  app.use('/cache', proxy('https://roger.quod.lib.umich.edu/cache', {
    https: true,
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }))

  app.use('/lib/colllist', proxy('https://quod.lib.umich.edu/lib/colllist', {
    https: true,
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }))

  app.get("/templates/debug.qui.xsl", function (req, res) {
    res.sendFile(path.join(rootPath, "templates/debug.qui.xsl"));
  });

  app.get('/', function(req, res) {
    if ( req.query.guide !== undefined ) { return res.sendFile(path.join(rootPath, "index.html")); }
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  })

  app.get("/index.html", function (req, res) {
    if ( req.query.guide !== undefined ) { return res.sendFile(path.join(rootPath, "index.html")); }
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  });

  app.get('/samples/', function(req, res) {
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  });

  app.get('/digital-collections-style-guide/*', function(req, res) {
    // if (req.cookies.useBeta == 'true') {
    //   // we're just proxying and sending this
    //   return proxyBeta(req, res);
    // }
    let pathInfo = req.path.replace('/digital-collections-style-guide/', '/');
    res.sendFile(path.join(rootPath, pathInfo));
  })

  app.use("/([a-z])/:collid/(*).(gif|jpg|html)", proxy('https://roger.quod.lib.umich.edu/', {
    https: true,
    forwardPath: function (req) {
      console.log("-- static file?", req.originalUrl);
      return req.originalUrl;
    }
  }));

  app.use(staticServer);

  app.get("/cgi/*", async function (req, res) {
    try {
      processDLXS(req, res).catch((error) => {
        handleError(req, res, error);
      })
    } catch(error) {
      handleError(req, res, error);
    }
  });

  app.get("/[a-z]/:collid(*)", async function (req, res) {
    try {
      processDLXS(req, res).catch((error) => {
        handleError(req, res, error);
      });
    } catch (error) {
      handleError(req, res, error);
    }
  });

  if (!logger) app.use(morgan("dev"));

  if ( argv.proxy ) {
    log("Fetching XML from KUBERNETES. Huzzah!".cyan);
  }

  log(
    "Starting up Server, serving ".yellow +
      scriptName.green +
      " on port: ".yellow +
      `${options.address}:${options.port}`.cyan
  );
  log("Hit CTRL-C to stop the server");
}

process.on("SIGINT", function () {
  log("Server stopped.".red);
  process.exit();
});

start();
