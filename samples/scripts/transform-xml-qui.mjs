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

const argv = yargs(hideBin(process.argv)).argv;
console.log(argv);

const xsltBase = `<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
</xsl:stylesheet>`;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");
// console.log(rootPath);

const configPath = `${rootPath}/templates/image/`;
const imagePath = `${rootPath}/templates/image/`;

await $`date`;

let dataFilePath = `${rootPath}/samples/data/`;
if ( argv.collid ) {
  dataFilePath += `${argv.collid.substr(0, 1)}/${argv.collid}/`;
}
// console.log("=>", dataFilePath);

// clear out the target path
let targetFilePath = `${rootPath}/samples/qui/`;
if ( argv.collid ) {
  targetFilePath += `${argv.collid.substr(0, 1)}/${argv.collid}/`;
}
if (!fs.existsSync(targetFilePath)) {
  fs.mkdirSync(targetFilePath);
}
await $`find ${targetFilePath} -type f | xargs rm -f`;

let dataFilenames = [...getAllFilesSync(dataFilePath)];
for(let i = 0; i < dataFilenames.length; i++) {
  let dataFilename = dataFilenames[i];
  const xmlData = fs.readFileSync(dataFilename, "utf8");
  const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");
  const view = xpath.select("string(//Param[@name='view']|//Param[@name='page'])", xmlDoc);

  if ( argv.view && argv.view != view ) { continue; }

  const collid = xpath.select("string(//Param[@name='cc'])", xmlDoc);
  const collidPath = path.join(rootPath, 'samples', 'xsl', collid.substr(0, 1), collid, 'uplift', 'qui');
  
  const viewFilename = path.join(configPath, `${view}.xml`);
  if ( fs.existsSync(viewFilename) ) {
    const compiledFilename = `/tmp/${view}.xsl`;
    const viewXmlData = fs.readFileSync(viewFilename, "utf8");
    const viewDoc = new DOMParser().parseFromString(viewXmlData, "text/xml");
    const fallbackFilenames = xpath.select("//XslFallbackFileList[@pipeline='qui']/Filename", viewDoc);

    const xsltDoc = new DOMParser().parseFromString(xsltBase, "text/xml");
    fallbackFilenames.forEach((fallbackFilename) => {
      [ imagePath, collidPath ].forEach((xslPath) => {
        // console.log("==>", fallbackFilename.textContent)
        const possibles = fg.sync(
          path.join(xslPath, fallbackFilename.textContent)
        );
        possibles.forEach((filename) => {
          const importEl = xsltDoc.createElement("xsl:import");
          // console.log(filename);
          importEl.setAttribute("href", filename);
          xsltDoc.documentElement.appendChild(importEl);
        })
        // const filename = path.join(xslPath, fallbackFilename.textContent);
        // if (fs.existsSync(filename)) {
        //   const importEl = xsltDoc.createElement("xsl:import");
        //   console.log(filename);
        //   importEl.setAttribute("href", filename);
        //   xsltDoc.documentElement.appendChild(importEl);
        // }
      })
    })

    if (!fs.existsSync(path.dirname(compiledFilename))) {
      fs.mkdirSync(path.dirname(compiledFilename), { recursive: true, mode: 0o775 });
    }
    fs.writeFileSync(compiledFilename, new XMLSerializer().serializeToString(xsltDoc));

    const outputFilename = path.join(
      rootPath,
      "samples",
      "qui",
      collid.substr(0,1),
      collid,
      path.basename(dataFilename)
    );
    if (!fs.existsSync(path.dirname(outputFilename))) {
      fs.mkdirSync(path.dirname(outputFilename), {
        recursive: true,
        mode: 0o775,
      });
    }

    await $`xsltproc ${compiledFilename} ${dataFilename}`
      .pipe(fs.createWriteStream(outputFilename));
  }

};

let quiFilenames = fg.sync(path.join(rootPath, 'samples', 'qui', '*', '*', '*.xml'))
let identifierMap = {};
for(let i = 0; i < quiFilenames.length; i++) {
  let quiFilename = quiFilenames[i];
  let key = path.dirname(quiFilename);
  let identifier = path.basename(quiFilename, '.xml');
  if ( identifierMap[key] === undefined ) { identifierMap[key] = []; }
  identifierMap[key].push(identifier);
  // const xmlData = fs.readFileSync(dataFilename, "utf8");
  // const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");
}

// console.log(identifierMap);
// Object.keys(identifierMap).forEach((key) => {
//   let identifiers = identifierMap[key];
//   let xmlData = `<root>${identifiers.map((v) => `<identifier>${v}</identifier>`).join("\n")}</root>`;
//   fs.writeFileSync(
//     `${key}/__identifiers.xml`,
//     xmlData
//   );
// })



console.log('-30-');