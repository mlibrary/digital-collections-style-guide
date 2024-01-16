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

import { isbot } from "isbot";

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

async function processLandingPage(req, res) {
  let url = new URL(`https://roger.quod.lib.umich.edu/cgi/t/text/uplifted-idx`);

  const headers = {};
  // console.log("-- cookies", req.cookies);
  if ( req.cookies.loggedIn == 'true' ) {
    headers['X-DLXS-Auth'] = 'nala@monkey.nu';
  }
  headers['X-DLXS-Uplifted'] = 'true';
  headers['x-forwarded-host'] = req.headers['x-forwarded-host'] || 'localhost:5555';

  // headers['X-DLXS-SessionID'] = `${req.socket.remoteAddress}--${(new Date).getDay()}`;
  headers['Cookie'] = `DLXSsid=${req.cookies.DLXSsid}`;

  const inputFilename = `/tmp/landing.${(new Date).getHours()}.xml`;
  if ( ! fs.existsSync(inputFilename) ) {
    const resp = await fetch(url.toString(), {
      headers: headers,
      redirect: 'follow',
      credentials: 'include'
    });
    const xmlData = (await resp.text());
    fs.writeFileSync(
      inputFilename,
      xmlData
    );    
  }

  res.setHeader("Content-Type", "text/html; charset=UTF-8");
  const outputFilename = `/tmp/landing.${(new Date).getTime()}.html`;
  await $`xsltproc --stringparam docroot "/" ${path.join(rootPath, 'samples', 'xsl', 'landing.xsl')} ${inputFilename}`.pipe(
    fs.createWriteStream(outputFilename)
  );
  const output = {};
  output.stdout = fs.readFileSync(outputFilename, "utf8");

  const outputData = output.stdout
    .replace(/src="https:\/\/roger.quod.lib.umich.edu\//g, 'src="/')
    .replace(/href="https:\/\/roger.quod.lib.umich.edu\//g, 'href="/')
    .replace(/debug=xml/g, 'debug=noop')
    .split("\n");
  outputData[0] = "<!DOCTYPE html>";
  res.send(outputData.join("\n"));

  fs.unlinkSync(outputFilename);  
}

async function processDLXS(req, res) {
  const appBase = dlxsBase;
  let url = new URL(
    `https://${appBase}${req.originalUrl.replace(/;/g, "&")}`
  );

  const headers = {};
  // console.log("-- cookies", req.cookies);
  if ( req.cookies.loggedIn == 'true' ) {
    headers['X-DLXS-Auth'] = 'nala@monkey.nu';
  }
  headers['X-DLXS-Uplifted'] = 'true';
  headers['x-forwarded-host'] = req.headers['x-forwarded-host'] || 'localhost:5555';

  // headers['X-DLXS-SessionID'] = `${req.socket.remoteAddress}--${(new Date).getDay()}`;
  headers['Cookie'] = `DLXSsid=${req.cookies.DLXSsid}`;

  console.log("-- fetching", url.toString());

  const resp = await fetch(url.toString(), {
    headers: headers,
    redirect: 'follow',
    credentials: 'include'
  });
  res.setHeader("Content-Type", "text/html; charset=UTF-8");

  if(resp.ok && resp.headers.get('content-type').indexOf('application/text') > -1) {
    res.setHeader('content-type', resp.headers.get('content-type'));
    res.setHeader('content-disposition', resp.headers.get('content-disposition'));
    res.send(await resp.text());
  } else if (resp.ok) {
    if ( resp.headers.get('set-cookie') ) {
      const cookieValue = (resp.headers.get('set-cookie').split(/;\s*/))[0].replace('DLXSsid=','');
      res.cookie('DLXSsid', cookieValue, { path: '/' });
      console.log("AHOY AHOY cookie = ", cookieValue);      
    }
    let xmlData = (await resp.text()).replace(/https:\/\/localhost/g, 'http://localhost');
    if ( xmlData.indexOf('no hits. normally cgi redirects') > -1 ) {
      throw new Error('Query has no results');
    }

    if ( xmlData.indexOf('Content-Disposition') > -1 ) {
      // this is really really dumb
      const lines = xmlData.split("\n");
      for(let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if ( line == "" ) {
          // that's the end
          break;
        } else {
          let parts = line.split(": ", 2);
          res.setHeader(parts[0], parts[1]);
        }
      }
      res.send(lines.join("\n"));
      return;
    }

    xmlData = xmlData.replaceAll('roger.quod.lib.umich.edu', req.headers['x-forwarded-host'] || 'localhost:5555');    

    if ( url.searchParams.get('debug') == 'xml' ) {
        res.setHeader("Content-Type", "application/xml");
        res.send(xmlData);
        return;
    }

    // if ( xmlData.indexOf('xml') < 0 ) {
    //   console.log(xmlData);
    // }

    // console.log(xmlData);

    if ( xmlData.indexOf('Location: ') > -1 ) {
      console.log(xmlData);
      let tmp = xmlData.match(/Location: (.*)$/si);
      if ( tmp[1].startsWith('/') || tmp[1].startsWith('https://') ) {
          let domain = ( req.hostname == 'localhost' ) ? 'http://' : 'https://';
          domain += req.hostname;
          let href = tmp[1].trim().replace('https://roger.quod.lib.umich.edu/', '/' ).replace('debug=xml', 'debug=noop');
          res.redirect(href);
          return;
      }
    }
    res.send(xmlData);
  } else {
    const output = await resp.text();
    res.status(resp.status).send("OOPS\n" + '<details><summary>Stack Trace</summary><div>' + output + '</div>');
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
      }
      return proxyReqOpts;        
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
    // res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
    try {
      processLandingPage(req, res).catch((error) => {
        handleError(req, res, error);
      })
    } catch(error) {
      handleError(req, res, error);
    }    
  })

  app.get("/index.html", function (req, res) {
    if ( req.query.guide !== undefined ) { return res.sendFile(path.join(rootPath, "index.html")); }
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  });

  app.get('/samples/', function(req, res) {
    // res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
    try {
      processLandingPage(req, res).catch((error) => {
        handleError(req, res, error);
      })
    } catch(error) {
      handleError(req, res, error);
    }        
  });

  app.use('/digital-collections-style-guide/static/text', proxy('https://roger.quod.lib.umich.edu/digital-collections-style-guide/static/text', {
    https: true,
    forwardPath: function (req) {
      return req.originalUrl;
    }
  }));

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
      // console.log("-- static file?", req.originalUrl);
      return req.originalUrl;
    }
  }));

  app.use("/([a-z])/:collid/graphics/(*).(gif|jpg|html)", proxy('https://roger.quod.lib.umich.edu/', {
    https: true,
    forwardPath: function (req) {
      // console.log("-- static file?", req.originalUrl);
      return req.originalUrl;
    }
  }));

  app.use(staticServer);

  app.get("/cgi/*", async function (req, res) {
    if (isbot(req.get('user-agent'))) {
      res.send("Beep boop");
      return;
    }
    try {
      processDLXS(req, res).catch((error) => {
        handleError(req, res, error);
      })
    } catch(error) {
      handleError(req, res, error);
    }
  });

  app.get("/[a-z]/:collid(*)", async function (req, res) {
    if ( req.params['collid'].match(/^.*\/?\w+$/) ) {
      const redirectTmp = req.originalUrl.split('?');
      redirectTmp[0] += '/';
      const redirectUrl = redirectTmp.join('?');
      res.redirect(redirectUrl);
      return;
    }
    console.log("--?", req.originalUrl);
    if (isbot(req.get('user-agent'))) {
      res.send("Beep boop");
      return;
    }
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
