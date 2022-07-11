import { ScreenReaderMessenger } from "../../sr-messaging";

window.DLXS = window.DLXS || {};
DLXS.manifestsData = {};
DLXS.manifestsIndex = {};
DLXS.totalManifests = 0;

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

window.addEventListener('message', (event) => {

  const section = document.querySelector('.main-panel > section');
  let alert = section.querySelector('.alert');
  if (!alert) {
    alert = document.createElement('div');
    alert.classList.add('alert');
    section.insertBefore(alert, section.firstChild);
  }

  if (event.data.event == 'updateMetadata') {
    const identifier = event.data.identifier;
    const label = event.data.label;
    const link = document.querySelector('link[rel="self"]');

    const slDropdownEl = document.querySelector('#dropdown-action');
    slDropdownEl.disabled = true;
    slDropdownEl.style.opacity = 0.5;

    const parts = identifier.split(':');

    // this will be different when we get to portfolios
    // let url = new URL(location.href.replace(/\;/g, "&"));
    let self_href = link.getAttribute('href').replace(/;/g, '&');
    if ( self_href.substring(0, 1) == '/' ) {
      self_href = `${location.protocol}//${location.hostname}${self_href}`;
    }
    let url = new URL(self_href);
    url.searchParams.set('viewid', parts[2]);
    let href = url.toString();

    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

    fetch(href, {
      credentials: 'include',
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Request error: ${response.status}`);
        }
        return response.text();
      })
      .then((text) => {
        const newDocument = new DOMParser().parseFromString(text, "text/html");
        const sections = document.querySelectorAll('.main-panel > section');
        const newSections = newDocument.querySelectorAll('.main-panel > section');
        for (let i = 0; i < newSections.length; i++) {
          sections[i].innerHTML = newSections[i].innerHTML;
        }

        let newTitle = newDocument.querySelector('h1').innerHTML;
        document.querySelector('h1').innerHTML = newTitle;
        document.title = newDocument.title;

        let paginationEl = document.querySelector('.breadcrumb .pagination');
        let newPaginationEl = newDocument.querySelector('.breadcrumb .pagination');
        if (paginationEl && newPaginationEl) {
          paginationEl.innerHTML = newPaginationEl.innerHTML;
        }

        let slMenuEl = document.querySelector('#dropdown-action sl-menu');
        let newSlMenuEl = newDocument.querySelector('#dropdown-action sl-menu');
        if ( slMenuEl && newSlMenuEl ) {
          slMenuEl.innerHTML = newSlMenuEl.innerHTML;
        }
        slDropdownEl.disabled = false;
        slDropdownEl.style.opacity = 1.0;

        let newUrl = newDocument.querySelector('.breadcrumb li:last-child a').getAttribute('href');
        history.pushState({}, newDocument.title, newUrl);
        document.querySelector('.breadcrumb li:last-child').setAttribute('href', newUrl);

        tocbot.refresh();

        ScreenReaderMessenger.getMessenger().say(`Viewing ${label || newTitle}`);

        const event = new Event('dlxs:trackPageView');
        window.dispatchEvent(event);
      })
  }

  if (event.data.event == 'configureManifests') {
    let manifestList = JSON.parse(event.data.manifestList);
    manifestList.forEach((v, idx) => {
      DLXS.manifestsIndex[idx] = v;
      DLXS.manifestsData[v] = {};
      DLXS.totalManifests += 1;
    });
  }

  if (event.data.event == 'updateDownloadLinks') {
    const identifier = event.data.identifier;
    const resourceId = event.data.resourceId;
    const manifestId = event.data.manifestId;
    const label = event.data.label;

    alert.innerHTML = `<p>Updating download links for: ${identifier}</p>`;

    console.log("-- updateDownload", label, resourceId, manifestId);
    fetch(resourceId + '/info.json')
      .then(resp => resp.json())
      .then((data) => {
        DLXS.manifestsData[manifestId] = { sizes: data.sizes, resourceId: resourceId, label: label };
        updateDownloadMenu();
      })
  }
})
