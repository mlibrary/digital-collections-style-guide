#!/usr/bin/env node

import { $, fetch } from "zx";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";

import path from "path";
import fs from "fs";

import { DOMParser, XMLSerializer } from "@xmldom/xmldom";
import xpath from "xpath";

import md5 from 'md5';

const argv = yargs(hideBin(process.argv)).argv;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");
console.log(rootPath);

const collidMap = {};
collidMap['/c/clark1ic'] = '/c/clark1ic8lift';

const queue = [ ...argv._.map((v) => [ v, null ]) ];

const hrefToUrl = function(href) {
  let url = new URL(href.replace(/\;/g, "&"));
  if ( ! url.searchParams.has('debug') ) {
    url.searchParams.set('debug', 'xml');
  }
  if ( url.searchParams.get('view') == 'thumbnail' ) {
    url.searchParams.set('view', 'reslist');
  }

  if ( collidMap[url.pathname] ) {
    url.pathname = collidMap[url.pathname];
  }

  if ( argv.dev && url.hostname.indexOf('roger.') < 0 ) {
    url.hostname = `roger.${url.hostname}`;
  }
  return url;
}

const urlToIdentifier = function(collid, url) {
  let tmp = [url.searchParams.get("rgn1")];
  tmp.push(
    unescape(url.searchParams.get("q1"))
      .replace(/\s+/g, "_")
      .replace(/[^\w_]/g, "")
  );
  let start = url.searchParams.get("start") || '1';
  tmp.push(start.padStart(4, '0'));
  let identifier = `q_${collid}_x_${tmp.join("___")}`.toUpperCase();
  return identifier;
}

let numPagesFollowed = 0;
while ( queue.length ) {
  let [ href, backIdentifier, marker ] = queue.shift();

  let url = hrefToUrl(href);
  href = url.toString();
  const resp = await fetch(href);
  if ( resp.ok ) {
    const xmlData = await resp.text();
    const xmlDoc = new DOMParser().parseFromString(xmlData, "text/xml");

    const collid = xpath.select("string(//Param[@name='cc'])", xmlDoc);
    const collidPath = path.join(
      rootPath,
      "samples",
      "data",
      collid.substr(0, 1),
      collid
    );
    if ( ! fs.existsSync(collidPath) ) {
      fs.mkdirSync(collidPath, { recursive: true, mode: 0o775 });
    }

    const view = xpath.select("string(//Param[@name='view'])", xmlDoc);
    let identifier;
    if ( view == 'entry' ) {
      // this is an entry!
      identifier = xpath.select("string(//EntryWindowName)", xmlDoc);
      if ( marker ) {
        identifier += `__xz${marker}`;
        // console.log("WTF", identifier); process.exit();
      }
      if ( backIdentifier ) {
        const backEl = xpath.select('//BackLink', xmlDoc);
        backEl[0].setAttribute('identifier', backIdentifier);
      }

      if ( marker ) {
        let paginationUrl;
        let paginationIdentifier;
        let paginationEl;
        paginationEl = xpath.select("//Prev/Url", xmlDoc)[0];
        if (paginationEl) {
          paginationEl.setAttribute('marker', marker);
        }

        paginationEl = xpath.select("//Next/Url", xmlDoc)[0];
        if (paginationEl) {
          paginationEl.setAttribute("marker", marker);
        }

      }
    } else if ( view == 'thumbnail' || view == 'reslist' ) {
      // search results! make an identifier
      identifier = urlToIdentifier(collid, url);

      // let marker_ = Date.now();
      let marker_ = md5(identifier);

      // and gather 5 <Result> elements to add to the queue
      const resultEls = xpath.select('//Results[@name="full"]/Result', xmlDoc);
      console.log(":::", resultEls.length);
      let N = resultEls.length > 5 ? 5 : resultEls.length;
      for(let i = 0; i < N; i++) {
        let resultEl = resultEls[i];
        if ( ! resultEl ) { break; }
        resultEl.setAttribute('marker', marker_);
        let entryHref = xpath.select('string(.//Url[@name="EntryLink"])', resultEl);
        queue.push([entryHref, identifier, marker_]);
      }
      let paginationUrl; let paginationIdentifier; let paginationEl;
      paginationEl = xpath.select('//Prev/Url', xmlDoc)[0];
      if ( paginationEl ) {
        paginationUrl = hrefToUrl(paginationEl.textContent);
        paginationIdentifier = urlToIdentifier(collid, paginationUrl);
        paginationEl.parentNode.setAttribute('identifier', paginationIdentifier);

        // --- do not add to queue; this should match the original download
        // queue.push(paginationUrl.toString());
      }

      paginationEl = xpath.select("//Next/Url", xmlDoc)[0];
      if (paginationEl && numPagesFollowed <= 5) {
        paginationUrl = hrefToUrl(paginationEl.textContent);
        paginationIdentifier = urlToIdentifier(collid, paginationUrl);
        paginationEl.parentNode.setAttribute(
          "identifier",
          paginationIdentifier
        );
        queue.push([paginationUrl.toString()]);
        numPagesFollowed += 1;
      }
    }
    xmlDoc.documentElement.setAttribute('identifier', identifier);

    const valueEls = xpath.select("//Value|//Param", xmlDoc);
    valueEls.forEach((valueEl) => {
      if ( valueEl.textContent.indexOf('%') > -1 ) {
        valueEl.textContent = unescape(valueEl.textContent);
      }
    })

    if ( collid.indexOf('8lift') > -1 ) {
      // update the MiradorConfig
      const miradorConfigEl = xpath.select("//MiradorConfig", xmlDoc);
      if ( miradorConfigEl && miradorConfigEl[0] ) {
        let href = miradorConfigEl[0].getAttribute('manifest-href');
        miradorConfigEl[0].setAttribute("manifest-href", href.replace("8lift", ""));

        href = miradorConfigEl[0].getAttribute("embed-href");
        miradorConfigEl[0].setAttribute(
          "embed-href",
          href.replace("8lift", "")
        );
      }

      const icCollidEls = xpath.select("//Results/Result/MediaInfo/ic_collid");
      if ( icCollidEls && icCollidEls.length > 0 ) {
        for(let i = 0; i < icCollidEls.length; i++) {
          let el = icCollidEls[i];
          el.textContent = el.textContent.replace('8lift', '')
        }
      }
    }

    console.log("==>", identifier, marker);
    let outputFilename = identifier;
    // if ( marker ) { outputFilename += (  '__xz' + marker ); }
    fs.writeFileSync(
      path.join(collidPath, `${outputFilename}.xml`),
      new XMLSerializer().serializeToString(xmlDoc)
    );

  }

}
