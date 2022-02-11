let srm;

window.addEventListener('DOMContentLoaded', (event) => {

  srm = ScreenReaderMessenger.getMessenger();

  window.debugSRM = function () {
    if (!srm.speakRegion.dataset.cssText) {
      srm.speakRegion.dataset.cssText = srm.speakRegion.style.cssText;
      srm.speakRegion.setAttribute('id', 'srm-log');
    }
    srm.speakRegion.style.cssText = '';
    document.documentElement.dataset.debuggingSrm = "true";
  }

  if (location.hostname.indexOf('.netlify.app') < 0) {
    // login trigger
    const $actionLogin = document.querySelector('#action-login');
    $actionLogin.addEventListener('click', (event) => {
      event.preventDefault();
      const loggedIn = !($actionLogin.dataset.loggedIn == "true");
      // set the cookie
      document.cookie = `loggedIn=${loggedIn}; path=/`;
      // reload the page
      location.reload();
    })
  }

  const $main = $(".main-panel")[0];
  const $paginator = $("[data-action='paginate']")[0];

  // fade in after components load
  Promise.allSettled([
    customElements.whenDefined('m-universal-header'),
    customElements.whenDefined('m-website-header')
  ])
  .then(function () {
    // $body.addClass('ready');
    $main.dataset.state = 'ready'
  })

  // portfolio display management
  const $fragment = document.createDocumentFragment();
  const $container = $(".portfolio--list")[0];
  let $lists = $(".portfolio");

  let $styles;
  for (let i = 0; i < document.styleSheets.length; i++) {
    let ownerNode = document.styleSheets[i].ownerNode;
    if ( ownerNode.id == 'portfolio-filter-rules' ) {
      $styles = document.styleSheets[i];
    }
  }

  const username = document.documentElement.dataset.username;
  const $state = { filter: username ? 'mine' : 'all', search: '', page: 1 };
  $state.counts = {};
  $state.counts.all = $("#counts-all")[0];
  $state.counts.recent = $("#counts-recent")[0];
  $state.counts.mine = $("#counts-mine")[0];
  window.$state = $state;

  const $filters = {};
  $filters.all = '.portfolio';
  // $filters.mine = `.portfolio[data-owner*=':${username}:']`;
  $filters.mine = `.portfolio[data-mine='true']`;
  $filters.recent = '.portfolio[data-recent="true"]';
  window.$filters = $filters;

  const $slots = {};
  $slots.pagination = $("[data-slot='pagination-summary']")[0];
  $slots.query = $("[data-slot='query-summary']")[0];

  const _updateSelector = function() {
    let parts = [ ...$state.parts ];
    // parts.push(`[data-page="${$state.page}"]`);

    let newSelector = `.portfolio--list ${parts.join('')}`;
    $state.selector = newSelector;
    newSelector += `[data-page="${$state.page}"]`;
    $styles.cssRules[0].selectorText = newSelector;
    console.log("!!", newSelector, $styles.cssRules[0].selectorText);
  }
  
  const _updateStats = function() {
    let $visible = $($state.selector);
    $visible.forEach((div, idx) => {
      let page = Math.floor(idx / 50) + 1;
      div.dataset.page = page;
    })
    $state.totalPages = Math.ceil($visible.length / 50);
    $state.total = $visible.length;

    let message;
    if ( $state.total == 0 ) {
      message = '0 results';
    } else if ( $state.total < 50 ) {
      message = `${$state.total} result`;
      if ( $state.total > 1 ) { message += 's'; }
    } else {
      let startPage = ( ( $state.page - 1 ) * 50 )  + 1;
      let endPage = ( $state.page * 50 );
      if ( endPage > $state.total ) { endPage = $state.total; }
      message = `${startPage} to ${endPage} of ${$state.total} results`;
    }
    $slots.pagination.innerText = message;

    message = '';
    if ( $state.search ) {
      message = `"${$state.search}" in `;
    }
    let $filterEl = $(`input[type="radio"]:checked`)[0];
    message += '<strong>' + $filterEl.nextElementSibling.childNodes[0].textContent.toLowerCase() + '</strong>';
    $slots.query.innerHTML = `Showing results for ${message}`;

    srm.say($slots.pagination.innerText + "\n" + $slots.query.innerText);
  }

  window._updateSelector = _updateSelector;

  const _filter = function() {
    let newSelector = '';
    let parts = [];

    // if ( $state.filter == 'all' ) {
    //   parts.push('.portfolio');
    // } else if ( $state.filter == 'mine' ) {
    //   parts.push(`.portfolio[data-owner*=':${username}:']`);
    // } else if ( $state.filter == 'recent' ) {
    //   parts.push('.portfolio[data-recent="true"]');
    // }

    parts.push($filters[$state.filter]);

    let search_selector = '';
    if ( $state.search.length ) {
      search_selector = `.portfolio[data-collname*='${$state.search}']`;
      parts.push(search_selector);
    }

    $state.parts = parts;

    // $state.counts.mine.innerText = `(${$visible.filter((div) => div.dataset.mine == 'true').length})`;
    // $state.counts.recent.innerText = `(${$visible.filter((div) => div.dataset.recent == 'true').length})`;
    // $state.counts.all.innerText = `(${$visible.length})`;

    $state.counts.mine.innerText = '(' + $(`${$filters.mine}${search_selector}`).length + ')'
    $state.counts.recent.innerText = '(' + $(`${$filters.recent}${search_selector}`).length + ')';
    $state.counts.all.innerText = '(' + $(`${$filters.all}${search_selector}`).length + ')';

    $state.page = 1;
    _updateSelector();
    _updateStats();
    _updatePagination();

  }

  const _sort = function(field, order) {
    console.log("-- sort", field, order);

    const _fn = {};
    _fn['collname'] = function (a, b) {
      return a.dataset.collname == b.dataset.collname ? 0 :
        (a.dataset.collname < b.dataset.collname ? -1 : 1);
    }

    _fn['modified'] = function (a, b) {
      return a.dataset.modified - b.dataset.modified;
    }

    _fn['numItems'] = function (a, b) {
      return a.dataset.numItems - b.dataset.numItems;
    }

    $fragment.append($container);

    $lists.sort(_fn['collname']);

    $lists.sort(_fn[field]);
    if (order == 'desc') {
      $lists.reverse();
    }

    $lists.forEach((div) => {
      $container.appendChild(div);
    })

    // $main.appendChild($container);
    $main.insertBefore($container, $paginator);

    $state.page = 1;
    _updateStats();
    _updatePagination();
  }

  const _updatePagination = function() {
    $paginator.dataset.active = $state.totalPages > 1;

    $paginator.querySelector('[data-action="next-link"]').dataset.active = $state.page < $state.totalPages;
    $paginator.querySelector('[data-action="previous-link"]').dataset.active = $state.page > 1;

    $paginator.querySelector('input').max = $state.totalPages;
    $paginator.querySelector('input').value = $state.page;
    $paginator.querySelector('[data-slot="total-pages"]').innerText = $state.totalPages;
  }

  $("details[data-key='filter']")[0].addEventListener('click', (event) => {
    const target = event.target.closest('input[type="radio"]');
    if ( target ) {
      $state.filter = target.value;
      _filter();
    }
  });

  $("input[data-action='search']")[0].addEventListener('keyup', (event) => {
    const target = event.target;
    if (event.key == 'Escape' || target.value.length == 0) {
      target.value = '';
    }
    if ( target.value == '' || target.value.length >= 3 ) {
      $state.search = target.value;
      _filter();
    }
  })

  $("button[data-action='clear-search']")[0].addEventListener('click', (event) => {
    $("input[data-action='search']")[0].value = '';
    $state.search = '';
    _filter();
  })

  $("select[data-action='sort']")[0].addEventListener('change', (event) => {
    const target = event.target;
    [ field, order ] = target.value.split("::");
    _sort(field, order);
  })

  $paginator.querySelector("[data-action='next-link'] a").addEventListener('click', (event) => {
    $state.page += 1;
    _updateSelector();
    _updateStats();
    _updatePagination();
    window.scrollTo(0,0);
  })

  $paginator.querySelector("[data-action='previous-link'] a").addEventListener('click', (event) => {
    $state.page -= 1;
    _updateSelector();
    _updateStats();
    _updatePagination();
    window.scrollTo(0, 0);
  })

  $paginator.querySelector('input[type="number"]').addEventListener('focus', (event) => {
    event.target.dataset.value = event.target.value;
  })

  $paginator.querySelector('button[type="submit"]').addEventListener('click', (event) => {
    event.preventDefault();
    let $inputEl = $paginator.querySelector('input[type="number"]');
    let page = $inputEl.value;
    if ( page > $state.totalPages || page < 0 ) {
      // do something clever
      $inputEl.value = $inputEl.dataset.value;
    } else {
      $state.page = page;
      _updateSelector();
      _updateStats();
      _updatePagination();
      window.scrollTo(0, 0);
    }
  })

  // and initialize data elements on the portfolios
  $lists.forEach((div) => {

    const owner = [];
    div.querySelectorAll('dt[data-key="username"] + dd').forEach((dd) => {
      owner.push(dd.textContent);
    })
    div.dataset.owner = ':' + owner.join(':') + ':';

    const modifiedEl = div.querySelector('dt[data-key="modified_display"]');
    div.dataset.modified = Date.parse(modifiedEl.dataset.machineValue.replace(' ', 'T'));

    const numItemsEl = div.querySelector('dt[data-key="itemcount"] + dd');
    div.dataset.numItems = numItemsEl.textContent;

    const collnameEl = div.querySelector('[data-key="collname"]');
    div.dataset.collname = collnameEl.textContent.toLowerCase() + ' ' + div.dataset.owner.toLowerCase();
  })

  _filter();

});