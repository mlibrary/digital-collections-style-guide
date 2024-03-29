// "import * as tocbot from "tocbot" -> results in a runtime error
window.global = window;
window.root = window;

const tocbot = require('tocbot');

window.addEventListener('DOMContentLoaded', (event) => {
  if ( ! ( document.documentElement.dataset.view == 'entry' || document.documentElement.dataset.view == 'static' ) ) {
    return ; 
  }

  if ( document.querySelectorAll('main h2').length == 0 ) {
    return;
  }

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
  tocbot._buildHtml.updateToc = function (headingsArray) {
    originalUpdateToc(headingsArray);
    let activeLink = document.querySelector('.is-active-link').getAttribute("href");
    if (pageIndexDropdown.value != activeLink) {
      pageIndexDropdown.value = activeLink;
    }
  }

  setTimeout(() => {
    document.querySelectorAll('.toc-list-item').forEach((li) => {
      const link = li.querySelector('.toc-link');
      let menuItem = document.createElement('option');
      let indent = -1;
      let ol = li.closest("ol.toc-list");
      while (ol) {
        indent += 1;
        if (ol.parentElement.classList.contains('toc-list-item')) {
          ol = ol.parentElement.parentElement;
        } else {
          ol = null;
        }
      }
      menuItem.innerHTML = `${'&nbsp;'.repeat(indent)} ${link.textContent}`;
      pageIndexDropdown.appendChild(menuItem);
      menuItem.value = link.getAttribute('href');
      if (link.classList.contains('is-active-link')) {
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

})