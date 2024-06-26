// "import * as tocbot from "tocbot" -> results in a runtime error
window.global = window;
window.root = window;

const tocbot = require('tocbot');

window.addEventListener('DOMContentLoaded', (event) => {
  // if ( ! ( 
  //   ( document.documentElement.dataset.view == 'image' || 
  //   document.documentElement.dataset.view == 'static' || 
  //   document.documentElement.dataset.view == 'root' || 
  //   document.documentElement.dataset.view == 'text' ) || 
  //   document.documentElement.dataset.template == 'bookbag' ) ) {
  //   return ; 
  // }

  if ( ! document.querySelector('.js-toc') ) {
    return;
  }

  if ( document.querySelectorAll('.main-panel h2').length == 0 ) {
    return;
  }

  const pageIndexDropdown = document.querySelector('#action-page-index');

  let headingIdx = 0;
  document.querySelector('.main-panel').querySelectorAll('h2,h3,h4,h5').forEach((el) => {
    if ( el.getAttribute('id') ) { return ; }
    headingIdx += 1;
    el.setAttribute('id', `h${headingIdx}`);
  })

  const _flatten = function(node) {
    if ( node.nodeType == node.TEXT_NODE ) {
      return node.nodeValue;
    } else if ( node.nodeType == node.ELEMENT_NODE ) {
      if ( node.nodeName == 'BUTTON' ) { return ''; }
      if ( node.nodeName == 'A' ) { return ''; }
      if ( node.querySelector('a,button') ) {
        let tmp = [];
        node.childNodes.forEach((el) => {
          let value = _flatten(el);
          if ( value ) { tmp.push(value); }
        })
        return tmp.join(' ');
      } else {
        return node.innerText;
      }
    }
  }

  tocbot.init({
    // Where to render the table of contents.
    tocSelector: '.js-toc',
    // Where to grab the headings to build the table of contents.
    contentSelector: '.main-panel',
    // Which headings to grab inside of the contentSelector element.
    headingSelector: 'h2, h3, h4, h5',
    // For headings inside relative or absolute positioned containers within content.
    hasInnerContainers: true,
    ignoreHiddenElements: true,

    collapseDepth: 6,
    scrollSmooth: true,
    headingObjectCallback: function(object, el) {
      // console.log("-- tocbot", el, el.children.length);
      if ( el.classList.contains('card') ) {
        object.headingLevel = 3;
        object.textContent = el.querySelector('.card__heading').textContent;
      } else if ( el.querySelector('a,button') ) {
        let tmp = [];
        el.childNodes.forEach((node) => {
          let value = _flatten(node);
          if ( value ) {
            tmp.push(value);
          }
          // tmp.push(_flatten(node));
        })
        object.textContent = tmp.join(' ');
      }
      return object;
    }
    // scrollEndCallback: function(event) {
    //   pageIndexDropdown.value = document.querySelector('.is-active-link').getAttribute('href');
    // },
  });

  // seriously, do all my projects end up like this?
  let originalUpdateToc = tocbot._buildHtml.updateToc;
  tocbot._buildHtml.updateToc = function (headingsArray) {
    originalUpdateToc(headingsArray);
    let activeLink = document.querySelector('.is-active-link').getAttribute("href");
    if ( pageIndexDropdown && pageIndexDropdown.value != activeLink) {
      pageIndexDropdown.value = activeLink;
    }
  }

  if ( ! pageIndexDropdown ) { return; }

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