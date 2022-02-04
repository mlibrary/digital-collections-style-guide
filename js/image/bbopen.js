window.addEventListener('DOMContentLoaded', (event) => {

  const $main = $(".main-panel")[0];

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
  const $state = { filter: 'all', search: '' };
  $state.counts = {};
  $state.counts.all = $("#counts-all")[0];
  $state.counts.recent = $("#counts-recent")[0];
  $state.counts.mine = $("#counts-mine")[0];
  window.$state = $state;

  const $filters = {};
  $filters.all = '.portfolio';
  $filters.mine = `.portfolio[data-owner*=':${username}:']`;
  $filters.recent = '.portfolio[data-recent="true"]';

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

    newSelector = `.portfolio--list ${parts.join('')}`;
    $styles.cssRules[0].selectorText = newSelector;
    console.log("!!", newSelector, $styles.cssRules[0].selectorText);

    // let $visible = $lists.filter((div) => div.offsetHeight > 0);
    // $state.counts.mine.innerText = `(${$visible.filter((div) => div.dataset.mine == 'true').length})`;
    // $state.counts.recent.innerText = `(${$visible.filter((div) => div.dataset.recent == 'true').length})`;
    // $state.counts.all.innerText = `(${$visible.length})`;

    $state.counts.mine.innerText = $(`${$filters.mine}${search_selector}`).length;
    $state.counts.recent.innerText = $(`${$filters.recent}${search_selector}`).length;
    $state.counts.all.innerText = $(`${$filters.all}${search_selector}`).length;

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

    $main.appendChild($container);
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

  $("select[data-action='sort']")[0].addEventListener('change', (event) => {
    const target = event.target;
    [ field, order ] = target.value.split("::");
    _sort(field, order);
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

});