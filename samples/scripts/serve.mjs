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
const configPath = `${rootPath}/templates/image/`;
const imagePath = `${rootPath}/templates/image/`;
const scriptName = path.basename(moduleURL.pathname);

const argv = yargs(hideBin(process.argv)).argv;
const dlxsBase = argv.proxy ? 'dcp-proto.kubernetes.lib.umich.edu' : 'roger.quod.lib.umich.edu';

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

async function processDLXS(req, res) {
  let url = new URL(
    `https://${dlxsBase}${req.originalUrl.replace(/;/g, "&")}`
  );

  let debug = url.searchParams.get('debug');

  url.searchParams.set("debug", 'xml');
  if (url.searchParams.get("view") == "thumbnail") {
    url.searchParams.set("view", "reslist");
  }
  if (url.searchParams.get("view") == "bbthumbnail") {
    url.searchParams.set("view", "bbreslist");
  }

  const headers = {};
  // console.log("-- cookies", req.cookies);
  if ( req.cookies.loggedIn == 'true' ) {
    headers['X-DLXS-Auth'] = 'nala@monkey.nu';
  }
  const resp = await fetch(url.toString(), {
    headers: headers,
    redirect: 'follow',
    credentials: 'include'
  });
  res.setHeader("Content-Type", "text/html; charset=UTF-8");
  if (resp.ok) {
    const xmlData = await resp.text();
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

    // static check
    const staticXslFilename = xpath.select(`string(//XslFallbackFileList/Filename[last()])`, xmlDoc);
    if ( staticXslFilename == 'static.xml' ) {
      view = 'static';
    }

    console.log("AHOY COLLID", collid, view, debug);

    const valueEls = xpath.select("//Value|//Param", xmlDoc);
    valueEls.forEach((valueEl) => {
      if (valueEl.textContent.indexOf("%") > -1) {
        valueEl.textContent = unescape(valueEl.textContent);
      }
    });

    if (collid.indexOf("8lift") > -1) {
      // update the MiradorConfig
      const miradorConfigEl = xpath.select("//MiradorConfig", xmlDoc);
      if (miradorConfigEl && miradorConfigEl[0]) {
        let href = miradorConfigEl[0].getAttribute("manifest-href");
        miradorConfigEl[0].setAttribute(
          "manifest-href",
          href.replace("8lift", "")
        );

        href = miradorConfigEl[0].getAttribute("embed-href");
        miradorConfigEl[0].setAttribute(
          "embed-href",
          href.replace("8lift", "")
        );
      }

      const heroEl = xpath.select('//HeroImage', xmlDoc);
      if ( heroEl && heroEl[0] ) {
        let href = heroEl[0].getAttribute('identifier');
        heroEl[0].setAttribute('identifier', href.replace('8lift', ''));
      }

      const icCollidEls = xpath.select(
        "//Results/Result/MediaInfo/ic_collid",
        xmlDoc
      );
      if (icCollidEls && icCollidEls.length > 0) {
        for (let i = 0; i < icCollidEls.length; i++) {
          let el = icCollidEls[i];
          el.textContent = el.textContent.replace("8lift", "");
        }
      }
    }

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

    const qbatFallbackFilenames = xpath.select(
      "//XslFallbackFileList[@pipeline='qbat']/Filename",
      viewDoc
    );

    const xsltDoc = new DOMParser().parseFromString(xsltBase, "text/xml");
    fallbackFilenames.forEach((fallbackFilename) => {
      [imagePath, collidPath].forEach((xslPath) => {
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
      [imagePath, collidPath].forEach((xslPath) => {
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

  app.use('/cgi/i/image/api', proxy('https://quod.lib.umich.edu/cgi/i/image/api', {
    https: true,
    forwardPath: function(req) {
      return req.originalUrl.replace(/8lift/g, '');
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
    let pathInfo = req.path.replace('/digital-collections-style-guide/', '/');
    res.sendFile(path.join(rootPath, pathInfo));
  })

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
