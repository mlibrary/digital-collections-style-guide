#!/usr/bin/env node

import { $, fetch } from "zx";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";

import path from "path";
import fs from "fs";

import { DOMParser, XMLSerializer } from "@xmldom/xmldom";
import xpath from "xpath";

const argv = yargs(hideBin(process.argv)).argv;

const moduleURL = new URL(import.meta.url);
const rootPath = path.resolve(path.dirname(moduleURL.pathname) + "/../../");
console.log(rootPath);

const collidMap = {};
collidMap['/c/clark1ic'] = '/c/clark1ic8lift';

const queue = [ ...argv._.map((v) => [ v, null ]) ];

while ( queue.length ) {
  let [ href, backIdentifier ] = queue.shift();
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
      if ( backIdentifier ) {
        const backEl = xpath.select('//BackLink', xmlDoc);
        backEl[0].setAttribute('identifier', backIdentifier);
      }
    } else if ( view == 'thumbnail' || view == 'reslist' ) {
      // search results! make an identifier
      let tmp = [url.searchParams.get('rgn1')];
      tmp.push(unescape(url.searchParams.get('q1')).replace(/\s+/g, '_').replace(/[^\w_]/g, ''));
      tmp.push(url.searchParams.get('start') || 1);
      identifier = `q_${collid}_x_${tmp.join('___')}`.toUpperCase();

      // and gather 5 <Result> elements to add to the queue
      const resultEls = xpath.select('//Results[@name="full"]/Result', xmlDoc);
      let N = resultEls.length > 5 ? 5 : resultEls.length;
      for(let i = 1; i <= N; i++) {
        let resultEl = resultEls[i - 0];
        let entryHref = xpath.select('string(.//Url[@name="EntryLink"])', resultEl);
        queue.push([ entryHref, identifier ]);
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
    }

    console.log("==>", identifier);
    fs.writeFileSync(
      path.join(collidPath, `${identifier}.xml`),
      new XMLSerializer().serializeToString(xmlDoc)
    );

  }

}
