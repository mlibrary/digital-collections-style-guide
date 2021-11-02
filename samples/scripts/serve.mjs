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
const configPath = `${rootPath}/samples/xml/i/image/uplift/`;
const imagePath = `${rootPath}/samples/xsl/i/image/uplift/`;
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
  const resp = await fetch(url.toString());
  res.setHeader("Content-Type", "text/html");
  if (resp.ok) {
    const xmlData = await resp.text();
    if ( xmlData.indexOf('no hits. normally cgi redirects') > -1 ) {
      throw new Error('Query has no results');
    }
    
    const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");
    const collid = xpath.select(
      "string(//Param[@name='c']|//Param[@name='cc'])",
      xmlDoc
    );
    const view = xpath.select(
      "string(//Param[@name='view']|//Param[@name='page'])",
      xmlDoc
    );
    console.log("AHOY COLLID", collid, view, debug);

    const valueEls = xpath.select("//Value|//Param", xmlDoc);
    valueEls.forEach((valueEl) => {
      if (valueEl.textContent.indexOf("%") > -1) {
        valueEl.textContent = unescape(valueEl.textContent);
      }
    });

    console.log("AHOY 8LIFT", collid, collid.indexOf("8lift"));
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
    const viewXmlData = fs.readFileSync(viewFilename, "utf8");
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

    await $`xsltproc ${quiCompiledFilename} ${inputFilename}`.pipe(
      fs.createWriteStream(quiOutputFilename)
    );

    if ( debug == "qui" ) {
      res.setHeader('Content-Type', 'application/xml');
      res.sendFile(quiOutputFilename);
      return;
    }

    const identifierFilename =
      "/Users/roger/Projects/quombat/uplift-proxy/__identifiers.xml";
    const output =
      await $`xsltproc --stringparam use-local-identifiers false --stringparam identifier-filename ${identifierFilename} ${qbatCompiledFilename} ${quiOutputFilename}`;
    const outputData = output.stdout
      .replace(/https:\/\/roger.quod.lib.umich.edu\//g, "/")
      .replace(/debug=xml/g, 'debug=noop')
      .split("\n");
    outputData[0] = "<!DOCTYPE html>";
    res.send(outputData.join("\n"));

    fs.unlinkSync(inputFilename);
    fs.unlinkSync(quiOutputFilename);
    fs.unlinkSync(qbatCompiledFilename);
    fs.unlinkSync(quiCompiledFilename);
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

  app.get("/xsl/i/image/debug.qui.xsl", function (req, res) {
    res.sendFile(path.join(rootPath, "samples/xsl/i/image/debug.qui.xsl"));
  });

  app.get('/', function(req, res) {
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  })

  app.get("/index.html", function (req, res) {
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  });

  app.get('/samples/', function(req, res) {
    res.sendFile(path.join(rootPath, "samples/index.proxy.html"));
  });

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
