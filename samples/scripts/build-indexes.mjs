#!/usr/bin/env node

import { $, fetch } from "zx";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";

import path, { basename } from "path";
import fs from "fs";

import { DOMParser, XMLSerializer } from "@xmldom/xmldom";
import xpath from "xpath";

const argv = yargs(hideBin(process.argv)).argv;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");

import fg from "fast-glob";
import { exit } from "process";

const select = xpath.useNamespaces({
  dlxs: "http://dlxs.org",
  qui: "http://dlxs.org/quombat/ui",
  qbat: "http://dlxs.org/quombat",
  xhtml: "http://www.w3.org/1999/xhtml",
});


const qbatPath = path.join(
  rootPath,
  "samples",
  "qbat"
);

// gather all possible HTML files
let manifest = {};
const possibles = fg.sync(path.join(qbatPath, '*', '*', '*.html'));
possibles.sort();
for(let i = 0; i < possibles.length; i++) {
  let qbat_filename = possibles[i];
  const basename = path.basename(qbat_filename, ".html");
  if ( basename.match(/^S_/) && basename.match(/__xz/) ) {
    continue;
  }
  
  let xmlData = fs.readFileSync(qbat_filename, 'utf8');
  let xmlDoc = new DOMParser().parseFromString(xmlData, 'text/xml');
  let title = select("string(//xhtml:head/xhtml:title)", xmlDoc);
  let tmp = title.split(' | ');
  // console.log(title, tmp);
  tmp.pop();
  if ( tmp.length > 1 ) { tmp.pop(); }
  title = tmp.join(' | ');

  let collid = path.dirname(qbat_filename).replace(qbatPath, '').substring(3);
  if ( ! manifest[collid] ) { manifest[collid] = []; }

  // the HTML file becomes an index.html
  manifest[collid].push([ title, basename ]);
}

let html = `<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Digital Collections Workshop — Sample Preview</title>
  <link href="/static/styles.css" rel="stylesheet" />
  <link
    href="https://unpkg.com/@umich-lib/css@v1/dist/umich-lib.css"
    rel="stylesheet"
  />
  <link
    rel="stylesheet"
    href="https://fonts.googleapis.com/icon?family=Material+Icons"
  />
  <link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAOX/AD09PQA0a5EAuwD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICAgACAgACAgIAAAAAAAIDAwMCAgICAwMDAgAAAAIDAwMDAgICAgMDAwMCAAACAwMDAgICAgICAwMDAgAAAgMDAwICAgICAgMDAwIAAAIBAwMCAgICAgIDAwECAAACAQEBAQICAgIBAQEBAgAAAgEBAgEBAgIBAQIBAQIAAAACAQEBAQEBAQEBAQIAAAAAAgEBAQEBAQEBAQECAAAAAAICAQEBAQEBAQECAgAAAAACBAIBAQEBAQECBAIAAAAAAAICAgICAgICAgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AADiRwAAwAMAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAMADAADAAwAAwAMAAMADAADgBwAA//8AAP//AAA=" rel="icon" type="image/x-icon" />

  <style>
  table {
    text-align: justify;
    width: 100%;
    border-collapse: collapse; }

  td, th {
    padding: 0.5em;
    border-bottom: 1px solid #f1f1f1; }
  
  td.title {
    width: 75%;
  }
  </style>
  <script
    type="module"
    src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.esm.js"
  ></script>
  <script
    nomodule
    src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.js"
  ></script>
</head>
<body>
    <div class="border-bottom">
      <m-universal-header></m-universal-header>
      <m-website-header name="Digital Collections"> </m-website-header>
    </div>

    <main class="viewport-container">
      <div class="[ flex flex-flow-rw ]">
        <div class="main-panel">
          <h1>Sample Preview</h1>
`;

Object.keys(manifest).forEach((collid) => {
  console.log("===>", collid);
  let section = `<section class="[ border-bottom mb-3 ]"><h2>Collection: ${collid}</h2>`;
  section += `<table>
    <thead>
      <tr>
        <th>Title</th>
        <th>View</th>
        <th>DLXS XML</th>
        <th>Quombat UI XML</th>
        <th>Quombat HTML</th>
      </tr>
    </thead>
    <tbody>`;

    manifest[collid].forEach((tuple) => {
      let [ title, basename ] = tuple;
      let collid_path = `${collid[0]}/${collid}`;
      let view = basename.match(/^S_/) ? 'entry' : 'results';
      section += `<tr>`;
      section += `<td class="title">${title}</td>`;
      section += `<td>${view}</td>`;
      section += `<td><a href="/samples/data/${collid_path}/${basename}.xml">XML</a></td>`;
      section += `<td><a href="/samples/qui/${collid_path}/${basename}.xml">QUI</a></td>`;
      section += `<td><a href="/samples/qbat/${collid_path}/${basename}/">HTML</a></td>`;
      section += `</tr>`;
    })

    section += `</tbody></table></section>`;
    html += section;
})

html += `</div></div></main></body></html>`;
fs.writeFileSync(path.join(rootPath, 'samples', 'index.html'), html);

