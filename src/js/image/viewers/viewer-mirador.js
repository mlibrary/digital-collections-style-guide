import { ScreenReaderMessenger } from "../../sr-messaging";

window.addEventListener('message', (event) => {
  if (event.data.event == 'canvasChange') {
    const identifier = event.data.identifier;
    const label = event.data.label;
    const section = document.querySelector('.main-panel > section');
    const link = document.querySelector('link[rel="self"]');

    let alert = section.querySelector('.alert');
    if (!alert) {
      alert = document.createElement('div');
      alert.classList.add('alert');
      section.insertBefore(alert, section.firstChild);
    }
    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

    const parts = identifier.split(':');

    // this will be different when we get to portfolios
    // let url = new URL(location.href.replace(/\;/g, "&"));
    let self_href = link.getAttribute('href').replace(/;/g, '&');
    if ( self_href.substring(0, 1) == '/' ) {
      self_href = `${location.protocol}://${location.hostname}${self_href}`;
    }
    let url = new URL(self_href);
    url.searchParams.set('viewid', parts[2]);
    let href = url.toString();

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

        let newUrl = newDocument.querySelector('.breadcrumb li:last-child a').getAttribute('href');
        history.pushState({}, newDocument.title, newUrl);
        document.querySelector('.breadcrumb li:last-child').setAttribute('href', newUrl);

        tocbot.refresh();

        ScreenReaderMessenger.getMessenger().say(`Viewing ${label || newTitle}`);
      })

  }
  // var identifier = event.identifier
})
