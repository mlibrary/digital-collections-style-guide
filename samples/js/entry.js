window.addEventListener('message', (event) => {
  if ( event.data.event == 'canvasChange' ) {
    const identifier = event.data.identifier;
    const section = document.querySelector('.main-panel > section');
    let alert = section.querySelector('.alert');
    if ( ! alert ) {
      alert = document.createElement('div');
      alert.classList.add('alert');
      section.insertBefore(alert, section.firstChild);
    }
    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

    const parts = identifier.split(':');

    // this will be different when we get to portfolios
    let url = new URL(location.href.replace(/\;/g, "&"));
    url.searchParams.set('viewid', parts[2]);
    let href = url.toString();

    fetch(href, {
      credentials: 'include',
      })
      .then((response) => {
        if ( ! response.ok ) {
          throw new Error(`Request error: ${response.status}`);
        }
        return response.text();
      })
      .then((text) => {
        const newDocument = new DOMParser().parseFromString(text, "text/html");
        const sections = document.querySelectorAll('.main-panel > section');
        const newSections = newDocument.querySelectorAll('.main-panel > section');
        for(let i = 0; i < newSections.length; i++) {
          sections[i].innerHTML = newSections[i].innerHTML;
        }
        document.querySelector('h1').innerHTML = newDocument.querySelector('h1').innerHTML;
        document.title = newDocument.title;

        let paginationEl = document.querySelector('.breadcrumb .pagination');
        let newPaginationEl = newDocument.querySelector('.breadcrumb .pagination');
        if ( paginationEl && newPaginationEl ) {
          paginationEl.innerHTML = newPaginationEl.innerHTML;
        }

        history.pushState({}, newDocument.title, `${url.pathname}?${url.searchParams.toString()}`);

        tocbot.refresh();
      })
    
  }
  // var identifier = event.identifier
})

window.addEventListener('DOMContentLoaded', (event) => {

  var idx = 0;
  document.querySelectorAll('h2,h3,h4,h5').forEach((el) => {
    idx += 1;
    if ( ! el.id ) {
      el.setAttribute('id', `h${idx}`);
    }
  })
  
  tocbot.init({
    // Where to render the table of contents.
    tocSelector: '.js-toc',
    // Where to grab the headings to build the table of contents.
    contentSelector: 'main',
    // Which headings to grab inside of the contentSelector element.
    headingSelector: 'h2, h3, h4',
    // For headings inside relative or absolute positioned containers within content.
    hasInnerContainers: true,
    collapseDepth: 6,
  });
})
