
window.addEventListener('message', (event) => {
  if ( event.data.event == 'canvasChange' ) {
    const identifier = event.data.identifier;
    const label = event.data.label;
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

        let newTitle = newDocument.querySelector('h1').innerHTML;
        document.querySelector('h1').innerHTML = newTitle;
        document.title = newDocument.title;

        let paginationEl = document.querySelector('.breadcrumb .pagination');
        let newPaginationEl = newDocument.querySelector('.breadcrumb .pagination');
        if ( paginationEl && newPaginationEl ) {
          paginationEl.innerHTML = newPaginationEl.innerHTML;
        }

        history.pushState({}, newDocument.title, `${url.pathname}?${url.searchParams.toString()}`);

        tocbot.refresh();

        srm.say(`Viewing ${label || newTitle}`);
      })
    
  }
  // var identifier = event.identifier
})

window.addEventListener('DOMContentLoaded', (event) => {

  srm = ScreenReaderMessenger.getMessenger();

  let downloadAction = document.querySelector('#dropdown-action');
  if ( downloadAction ) {
    downloadAction.addEventListener('sl-select', (event) => {
      const selectedItem = event.detail.item;
      let href = selectedItem.value + '?attachment=1';
      location.href = location.protocol + '//' + location.host + href;
    });
  }

  let citeAction = document.querySelector('[data-action="cite-this-item"]');
  citeAction.addEventListener('click', (event) => {
    let target = document.querySelector('#cite-this-item');
    target.scrollIntoView();
  })

  let copyLinkAction = document.querySelector('[data-action="copy-link"]');
  copyLinkAction.addEventListener('click', (event) => {
    let target = document.querySelector('#input-bookmark');
    target.select();
    document.execCommand('copy');
  })

  var idx = 0;
  document.querySelectorAll('h2,h3,h4,h5').forEach((el) => {
    idx += 1;
    if ( ! el.id ) {
      el.setAttribute('id', `h${idx}`);
    }
  })

  const pageIndexDropdown = document.querySelector('#action-page-index');

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
    scrollSmooth: true,
    // scrollEndCallback: function(event) {
    //   pageIndexDropdown.value = document.querySelector('.is-active-link').getAttribute('href');
    // },
  });

  // seriously, do all my projects end up like this?
  let originalUpdateToc = tocbot._buildHtml.updateToc;
  tocbot._buildHtml.updateToc = function(headingsArray) {
    originalUpdateToc(headingsArray);
    let activeLink = document.querySelector('.is-active-link').getAttribute("href");
    if ( pageIndexDropdown.value != activeLink ) {
      pageIndexDropdown.value = activeLink;
    }
  }

  setTimeout(() => {
    document.querySelectorAll('.toc-list-item').forEach((li) => {
      const link = li.querySelector('.toc-link');
      let menuItem = document.createElement('option');
      let indent = -1;
      let ol = li.closest("ol.toc-list");
      while ( ol ) {
        indent += 1;
        if ( ol.parentElement.classList.contains('toc-list-item') ) {
          ol = ol.parentElement.parentElement;
        } else {
          ol = null;
        }
      }
      menuItem.innerHTML = `${'&nbsp;'.repeat(indent)} ${link.textContent}`;
      pageIndexDropdown.appendChild(menuItem);
      menuItem.value = link.getAttribute('href');
      if ( link.classList.contains('is-active-link') ) {
        pageIndexDropdown.value = menuItem.value;
      }
    })
  }, 0);

  pageIndexDropdown.addEventListener('change', (event) => {
    const target = document.querySelector(pageIndexDropdown.value);
    pageIndexDropdown.blur();
    target.focus();
    console.log("-- page index dropdown", target, event);
    setTimeout(() => {
      target.scrollIntoView();
    }, 0);
  })

  document.querySelectorAll('textarea[data-role="citation"]').forEach((textarea) => {
    textarea.style.display = 'none';
    autosize(textarea);
    textarea.style.display = '';

    setTimeout(() => {
      autosize.update(textarea);
    })
  })

  // autosize(document.querySelector('#full-citation'));
  // autosize(document.querySelector('#brief-citation'));

})

