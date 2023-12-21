import { ScreenReaderMessenger } from "../../sr-messaging";

window.DLXS = window.DLXS || {};
DLXS.manifestsData = {};
DLXS.manifestsIndex = {};
DLXS.totalManifests = 0;

let plaintextViewer = null;
let plaintextUrl;


let updateDownloadMenu = function() {
  const slDropdownEl = document.querySelector('#dropdown-action');
  slDropdownEl.disabled = true;
  slDropdownEl.style.opacity = 0.5;
  let slMenuEl = slDropdownEl.querySelector('sl-menu');
  while ( slMenuEl.firstChild ) {
    slMenuEl.removeChild(slMenuEl.firstChild);
  }
  let menuHtml = '';
  for(let i = 0; i < DLXS.totalManifests; i++) {
    let manifestId = DLXS.manifestsIndex[i];
    let info = DLXS.manifestsData[manifestId];
    if ( ! info.label ) { 
      // manifest data hasn't been loaded yet
      continue; 
    }
    if ( i > 0 ) {
      menuHtml += `<sl-menu-label></sl-menu-label>`;
    }
    menuHtml += `<sl-menu-label>${info.label}</sl-menu-label>`;
    for (let ii = 0; ii < info.sizes.length; ii++) {
      let size = info.sizes[ii];
      console.log("-- updateDownload size", size.width, size.height);
      if ( size.height >= 600 || size.width >= 600 ) {
        let href = `${info.resourceId.replace('/tile/', '/image/')}/full/${size.width},${size.height}/0/default.jpg`;
        menuHtml += `<sl-menu-item data-href="${href}" value="${href}">${size.width} x ${size.height} (JPEG)</sl-menu-item>`;
      }
    }
  }
  slMenuEl.innerHTML = menuHtml;

  slDropdownEl.disabled = false;
  slDropdownEl.style.opacity = 1.0;
}

const loadPlaintext = function(seq) {
  if ( seq ) {
    // update plaintextUrl...
    plaintextUrl.searchParams.set('seq', seq);
  }

  fetch(plaintextUrl, { credentials: 'include' })
    .then((response) => {
      if ( ! response.ok ) {
        console.log("-- plaintext fetch", plaintextUrl.toString(), response);
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      return response.text();
    })
    .then((response) => {
        let lines = [];
        if ( response ) {
          lines = response.split("\n");
          if ( lines[0].indexOf('DOCTYPE') > -1 ) {
              lines.shift();
          }
          response = lines.join("<br />")
        }
        plaintextViewer.innerHTML = response;
    })
}

window.addEventListener('message', (event) => {

  const section = document.querySelector('.main-panel > section');
  if ( ! section ) { return ; }
  
  let alert = section.querySelector('.alert');
  if (!alert) {
    alert = document.createElement('div');
    alert.classList.add('alert');
    section.insertBefore(alert, section.firstChild);
  }

  const labelEl = document.querySelector('span[data-key="canvas-label"]');
  console.log("-- viewer.mirador.message", event);

  if (event.data.event == 'updateMetadata') {
    const identifier = event.data.identifier;
    const label = event.data.label;
    const link = document.querySelector('link[rel="self"]');
    
    labelEl.innerText = label;

    let parts = document.title.split(' | ');
    parts[0] = label;
    document.title = parts.join(' | ');

    parts = identifier.split(':');
    const newSeq = parts.pop();
    const idno = parts.at(-1);
    const baseIdentifier = parts.join(':');

    console.log("-- viewer.mirador", identifier, label);


    const slDropdownEl = document.querySelector('#dropdown-action');
    slDropdownEl.disabled = true;
    slDropdownEl.style.opacity = 0.5;

    console.log("-- plaintext.updateMetadata", identifier);

    // this will be different when we get to portfolios
    // let url = new URL(location.href.replace(/\;/g, "&"));
    let self_href = link.getAttribute('href').replace(/;/g, '&');
    if ( self_href.substring(0, 1) == '/' ) {
      self_href = `${location.protocol}//${location.host}${self_href}`;
    }
    let url = new URL(self_href);
    if ( url.pathname.indexOf('pageviewer-idx' ) ) {
      url.searchParams.set('seq', newSeq);
    } else if ( url.pathname.indexOf('/' + idno + '/') > -1 ) {
      let re = new RegExp(`/${idno}/\\d+`);
      url.pathname = url.pathname.replace(re, `/${idno}/${newSeq}`);
    }
    let newHref = url.toString();

    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

    // update download menu
    let slMenuEl = document.querySelector('#dropdown-action sl-menu');
    slMenuEl.querySelectorAll('sl-menu-item').forEach((itemEl) => {
      let downloadHref = itemEl.dataset.href.replace(/;/g, '&');
      let downloadUrl = new URL(downloadHref);
      if ( downloadUrl.searchParams.has('seq') ) {
        downloadUrl.searchParams.set('seq', newSeq);
      } else if ( downloadUrl.pathname.indexOf(baseIdentifier) > -1 ) {
        // replace the identifier in the path
        let re = new RegExp(`${baseIdentifier}:\\d+`);
        downloadUrl.pathname = downloadUrl.pathname.replace(re, identifier);
      }
      itemEl.dataset.href = downloadUrl.toString();
      itemEl.setAttribute('value', downloadUrl.toString());

      let newSeq2 = newSeq.replace(/^0*/, '');
      let spanEl = itemEl.querySelector('.menu-label');
      let newText = (spanEl.innerText.split(' -'))[0];
      let pageData = DLXS.pageMap[newSeq2];
      if ( itemEl.dataset.chunked == 'true' ) {
        newText += ` - Pages ${pageData.chunk}`;
      } else {
        newText += ` - Page ${pageData.pageNum}`;
      }

      console.log("-- update", spanEl, DLXS.pageMap[newSeq2].pageNum, newText);
      spanEl.innerText = newText;
    })
    slDropdownEl.disabled = false;
    slDropdownEl.style.opacity = 1.0;


    history.pushState({}, document.title, newHref);
    document.querySelector('.breadcrumb li:last-child').setAttribute('href', newHref);

    const bookmarkItem = document.querySelector('dt[data-key="bookmark-item"] + dd span.url');
    if ( bookmarkItem ) {
      let itemHref = bookmarkItem.innerText.trim();
      if ( itemHref.indexOf('/cgi/') > -1 ) {
        // just use newHref
        bookmarkItem.innerText = newHref;
      } else {
        // just pop on the new seq?
        let tmp = itemHref.split('/');
        tmp[tmp.length - 1] = newSeq.replace(/^0+/, '');
        bookmarkItem.innerText = tmp.join('/');
      }
    }

    tocbot.refresh();

    ScreenReaderMessenger.getMessenger().say(`Viewing ${label}`);

    const analyticsEvent = new Event('dlxs:trackPageView');
    window.dispatchEvent(analyticsEvent);

  }

  if (event.data.event == 'configureManifests') {
    let manifestList = JSON.parse(event.data.manifestList);
    manifestList.forEach((v, idx) => {
      DLXS.manifestsIndex[idx] = v;
      DLXS.manifestsData[v] = {};
      DLXS.totalManifests += 1;
    });
  }

//   if (event.data.event == 'updateDownloadLinks') {
//     const identifier = event.data.identifier;
//     const resourceId = event.data.resourceId;
//     const manifestId = event.data.manifestId;
//     const label = event.data.label;

//     alert.innerHTML = `<p>Updating download links for: ${identifier}</p>`;

//     console.log("-- updateDownload", label, resourceId, manifestId);
//     fetch(resourceId + '/info.json')
//       .then(resp => resp.json())
//       .then((data) => {
//         DLXS.manifestsData[manifestId] = { sizes: data.sizes, resourceId: resourceId, label: label };
//         updateDownloadMenu();
//       })
//   }
})

window.addEventListener('DOMContentLoaded', (event) => {
  plaintextViewer = document.querySelector('#plaintext-viewer');
  if ( plaintextViewer ) {
    plaintextUrl = new URL(`${location.protocol}//${location.host}${plaintextViewer.dataset.href.replace(/;/g, '&')}`);
    loadPlaintext();
  }
})