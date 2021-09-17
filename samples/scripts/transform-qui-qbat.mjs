#!/usr/bin/env node

import { $ } from "zx";
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';

import path from 'path';
import fs from 'fs';

import { getAllFilesSync } from "get-all-files";
import fg from "fast-glob";

import { DOMParser, XMLSerializer } from '@xmldom/xmldom';
import xpath from 'xpath';
const select = xpath.useNamespaces({
  dlxs: "http://dlxs.org",
  qui: "http://dlxs.org/quombat/ui",
  qbat: "http://dlxs.org/quombat",
  xhtml: "http://www.w3.org/1999/xhtml",
});


const argv = yargs(hideBin(process.argv)).argv;
console.log(argv);

const xsltBase = `<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
</xsl:stylesheet>`;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");
console.log(rootPath);

const configPath = `${rootPath}/samples/xml/i/image/uplift/`;
const imagePath = `${rootPath}/samples/xsl/i/image/uplift/`;

await $`date`;

let dataFilePath = `${rootPath}/samples/qui/`;
if ( argv.collid ) {
  dataFilePath += `${argv.collid.substr(0, 1)}/${argv.collid}/`;
}
console.log("=>", dataFilePath);

// clear out the target path
let targetFilePath = `${rootPath}/samples/qbat/`;
if ( argv.collid ) {
  targetFilePath += `${argv.collid.substr(0, 1)}/${argv.collid}/`;
}
await $`find ${targetFilePath} -type f | xargs rm`;

let dataFilenames = [...getAllFilesSync(dataFilePath)];
for(let i = 0; i < dataFilenames.length; i++) {
  let dataFilename = dataFilenames[i];
  const xmlData = fs.readFileSync(dataFilename, "utf8");
  const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");
  const view = select("string(//qui:root/@view)", xmlDoc);

  if ( argv.view && argv.view != view ) { continue; }

  const collid = select("string(//qui:root/@collid)", xmlDoc);
  const collidPath = path.join(rootPath, 'samples', 'xsl', collid.substr(0, 1), collid, 'uplift', 'qbat');
  
  const viewFilename = path.join(configPath, `${view}.xml`);
  if ( fs.existsSync(viewFilename) ) {
    const compiledFilename = `/tmp/${view}.xsl`;
    const viewXmlData = fs.readFileSync(viewFilename, "utf8");
    const viewDoc = new DOMParser().parseFromString(viewXmlData, "text/xml");
    const fallbackFilenames = xpath.select("//XslFallbackFileList[@pipeline='qbat']/Filename", viewDoc);

    const xsltDoc = new DOMParser().parseFromString(xsltBase, "text/xml");
    fallbackFilenames.forEach((fallbackFilename) => {
      [ imagePath, collidPath ].forEach((xslPath) => {
        const possibles = fg.sync(
          path.join(xslPath, fallbackFilename.textContent)
        );
        console.log("??", path.join(xslPath, fallbackFilename.textContent), possibles);
        possibles.forEach((filename) => {
          const importEl = xsltDoc.createElement("xsl:import");
          console.log(filename);
          importEl.setAttribute("href", filename);
          xsltDoc.documentElement.appendChild(importEl);
        });

        // const filename = path.join(xslPath, fallbackFilename.textContent);
        // if (fs.existsSync(filename)) {
        //   const importEl = xsltDoc.createElement("xsl:import");
        //   console.log(filename);
        //   importEl.setAttribute("href", filename);
        //   xsltDoc.documentElement.appendChild(importEl);
        // }
      })
    })

    const paramEl = xsltDoc.createElement('xsl:param');
    paramEl.setAttribute("name", "identifier-filename");
    xsltDoc.documentElement.appendChild(paramEl);

    if (!fs.existsSync(path.dirname(compiledFilename))) {
      fs.mkdirSync(path.dirname(compiledFilename), { recursive: true, mode: 0o775 });
    }
    fs.writeFileSync(compiledFilename, new XMLSerializer().serializeToString(xsltDoc));

    const outputFilename = path.join(
      rootPath,
      "samples",
      "qbat",
      collid.substr(0,1),
      collid,
      path.basename(dataFilename, ".xml") + ".html"
    );
    if (!fs.existsSync(path.dirname(outputFilename))) {
      fs.mkdirSync(path.dirname(outputFilename), {
        recursive: true,
        mode: 0o775,
      });
    }

    let identifierFilename = path.dirname(dataFilename) + "/__identifiers.xml";
    console.log("<=", identifierFilename);
    if ( ! fs.existsSync(identifierFilename) ) {
      identifierFilename = path.join(rootPath, 'samples', 'qui', 'noop.xml');
    }

    await $`xsltproc --stringparam identifier-filename ${identifierFilename} ${compiledFilename} ${dataFilename}`
      .pipe(fs.createWriteStream(outputFilename));
  }

};

let qbatFilenames = fg.sync(path.join(rootPath, 'samples', 'qbat', '*', '*', '*.xml'))

console.log('-30-');