let srm;

// https://github.com/jackmoore/autosize
!function (e, t) { "object" == typeof exports && "undefined" != typeof module ? module.exports = t() : "function" == typeof define && define.amd ? define(t) : (e || self).autosize = t() }(this, function () { var e, t, n = "function" == typeof Map ? new Map : (e = [], t = [], { has: function (t) { return e.indexOf(t) > -1 }, get: function (n) { return t[e.indexOf(n)] }, set: function (n, o) { -1 === e.indexOf(n) && (e.push(n), t.push(o)) }, delete: function (n) { var o = e.indexOf(n); o > -1 && (e.splice(o, 1), t.splice(o, 1)) } }), o = function (e) { return new Event(e, { bubbles: !0 }) }; try { new Event("test") } catch (e) { o = function (e) { var t = document.createEvent("Event"); return t.initEvent(e, !0, !1), t } } function r(e) { var t = n.get(e); t && t.destroy() } function i(e) { var t = n.get(e); t && t.update() } var l = null; return "undefined" == typeof window || "function" != typeof window.getComputedStyle ? ((l = function (e) { return e }).destroy = function (e) { return e }, l.update = function (e) { return e }) : ((l = function (e, t) { return e && Array.prototype.forEach.call(e.length ? e : [e], function (e) { return function (e) { if (e && e.nodeName && "TEXTAREA" === e.nodeName && !n.has(e)) { var t, r = null, i = null, l = null, d = function () { e.clientWidth !== i && c() }, u = function (t) { window.removeEventListener("resize", d, !1), e.removeEventListener("input", c, !1), e.removeEventListener("keyup", c, !1), e.removeEventListener("autosize:destroy", u, !1), e.removeEventListener("autosize:update", c, !1), Object.keys(t).forEach(function (n) { e.style[n] = t[n] }), n.delete(e) }.bind(e, { height: e.style.height, resize: e.style.resize, overflowY: e.style.overflowY, overflowX: e.style.overflowX, wordWrap: e.style.wordWrap }); e.addEventListener("autosize:destroy", u, !1), "onpropertychange" in e && "oninput" in e && e.addEventListener("keyup", c, !1), window.addEventListener("resize", d, !1), e.addEventListener("input", c, !1), e.addEventListener("autosize:update", c, !1), e.style.overflowX = "hidden", e.style.wordWrap = "break-word", n.set(e, { destroy: u, update: c }), "vertical" === (t = window.getComputedStyle(e, null)).resize ? e.style.resize = "none" : "both" === t.resize && (e.style.resize = "horizontal"), r = "content-box" === t.boxSizing ? -(parseFloat(t.paddingTop) + parseFloat(t.paddingBottom)) : parseFloat(t.borderTopWidth) + parseFloat(t.borderBottomWidth), isNaN(r) && (r = 0), c() } function a(t) { var n = e.style.width; e.style.width = "0px", e.style.width = n, e.style.overflowY = t } function s() { if (0 !== e.scrollHeight) { var t = function (e) { for (var t = []; e && e.parentNode && e.parentNode instanceof Element;)e.parentNode.scrollTop && t.push({ node: e.parentNode, scrollTop: e.parentNode.scrollTop }), e = e.parentNode; return t }(e), n = document.documentElement && document.documentElement.scrollTop; e.style.height = "", e.style.height = e.scrollHeight + r + "px", i = e.clientWidth, t.forEach(function (e) { e.node.scrollTop = e.scrollTop }), n && (document.documentElement.scrollTop = n) } } function c() { s(); var t = Math.round(parseFloat(e.style.height)), n = window.getComputedStyle(e, null), r = "content-box" === n.boxSizing ? Math.round(parseFloat(n.height)) : e.offsetHeight; if (r < t ? "hidden" === n.overflowY && (a("scroll"), s(), r = "content-box" === n.boxSizing ? Math.round(parseFloat(window.getComputedStyle(e, null).height)) : e.offsetHeight) : "hidden" !== n.overflowY && (a("hidden"), s(), r = "content-box" === n.boxSizing ? Math.round(parseFloat(window.getComputedStyle(e, null).height)) : e.offsetHeight), l !== r) { l = r; var i = o("autosize:resized"); try { e.dispatchEvent(i) } catch (e) { } } } }(e) }), e }).destroy = function (e) { return e && Array.prototype.forEach.call(e.length ? e : [e], r), e }, l.update = function (e) { return e && Array.prototype.forEach.call(e.length ? e : [e], i), e }), l });

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

  if ( location.hostname.indexOf('.netlify.app') < 0 ) {
    // login trigger
    const $actionLogin = document.querySelector('#action-login');
    $actionLogin.addEventListener('click', (event) => {
      event.preventDefault();
      const loggedIn = ! ( $actionLogin.dataset.loggedIn == "true" );
      // set the cookie
      document.cookie = `loggedIn=${loggedIn}; path=/`;
      // reload the page
      location.reload();
    })
  }

  const _handleFacetInput = function($form, input) {
    let message;
    input.addEventListener("change", (event) => {
      if (!input.checked && input.name == 'med') {
        let fInput = $form.querySelector('input[name="med"]');
        if (fInput) {
          fInput.parentElement.removeChild(fInput);
        }
        message = 'remove has digital media restriction';
      }
      else if (!input.checked) {

        let num = input.dataset.num;
        let fInput = $form.querySelector(`input[name="fn${num}"]`);
        fInput.parentElement.removeChild(fInput);
        fInput = $form.querySelector(`input[name="fq${num}"]`);
        fInput.parentElement.removeChild(fInput);

        message = `remove ${input.nextElementSibling.textContent}`;

      } else {
        // add the facet to the collection form
        if (input.name == 'med') {
          // special case
          let fInput = document.createElement("input");
          fInput.setAttribute("type", "hidden");
          fInput.setAttribute("name", 'med');
          fInput.setAttribute("value", input.value);
          $form.appendChild(fInput);

          message = 'add has digital media filter';
        } else {
          // console.log("-- click", numFacets, input.name, input.value);

          const numFacets = $form.querySelectorAll(
            'input[data-role="facet"][type="hidden"]'
          ).length;

          let fInput = document.createElement("input");
          fInput.setAttribute("type", "hidden");
          fInput.setAttribute("name", `fn${numFacets + 1}`);
          fInput.setAttribute("value", input.name);
          $form.appendChild(fInput);

          fInput = document.createElement("input");
          fInput.setAttribute("type", "hidden");
          fInput.setAttribute("name", `fq${numFacets + 1}`);
          fInput.setAttribute("value", input.value);
          $form.appendChild(fInput);

          let category = input.closest("details").querySelector('summary').textContent;
          let term = input.nextElementSibling.childNodes[0].textContent;

          message = `add ${category} > ${term} filter`;
        }
      }

      srm.say(`Submitting query to ${message}`);
      $form.submit();
    });  
  }

  const $form = document.querySelector("form#collection-search");
  if ( $form) {
    document.querySelectorAll('input[data-action="facet"]').forEach((input) => {
      _handleFacetInput($form, input);
    });
  }

  const $resultSort = document.querySelector("select#results-sort");
  if ( $resultSort ) {
    $resultSort.addEventListener('change', (event) => {
      const value = $resultSort.value;
      const $form = $resultSort.closest("form");
      const fInput = document.createElement('input');
      fInput.setAttribute("type", "hidden");
      fInput.setAttribute("name", 'sort');
      fInput.setAttribute("value", value);
      $form.appendChild(fInput);
      $form.submit();     
    })
  }

  const $actionSelectAll = document.querySelector('[data-action="select-all"]');
  const $actionAddItems = document.querySelector('[data-action="add-items"]');
  if ( $actionSelectAll ) {
    $actionSelectAll.addEventListener('click', (event) => {
      let checked = $actionSelectAll.checked;
      document.querySelectorAll('input[name="bbidno"]').forEach((input) => {
        input.checked = checked;
      })
      srm.say(checked ? 'Selecting all items' : 'Unselecting all items');
    })

    let $bbForm = document.querySelector('form#bbaction-form');
    $actionAddItems.addEventListener('click', (event) => {
      let inputs = document.querySelectorAll('input[name="bbidno"]:checked');
      if ( ! inputs.length ) { return ; }
      inputs.forEach((input) => {
        let bbInput = input.cloneNode(true);
        $bbForm.appendChild(bbInput);
      })
      let $action = $bbForm.querySelector('#bbaction-page');
      $action.setAttribute('name', 'bbactionbbname');
      $action.setAttribute('value', 'add');

      $bbForm.submit();
    })
  }

  document.querySelectorAll('[data-action="expand-filter-list"]').forEach((button) => {
    button.addEventListener('click', (event) => {
      const details = button.closest('details');
      const loadStatus = button.dataset.loadStatus || false;
      if ( ! loadStatus ) {
        // load the complete set of filters
        const nextUrl = location.href.replace(/;/g, '&') + '&tpl=listallfacets&&focus=' + details.dataset.key;
        fetch(nextUrl)
        .then((response) => {
          return response.text();
        })
        .then((text) => {
          const filtersListEl = details.querySelector('.filter-item--list');
          const newDocument = new DOMParser().parseFromString(text, "text/html");
          const valueEls = newDocument.querySelectorAll('div[data-expandable-filter]');
          filtersListEl.style.height = `${filtersListEl.offsetHeight}px`;
          valueEls.forEach((valueEl) => {
            filtersListEl.appendChild(valueEl);
            _handleFacetInput($form, valueEl.querySelector('input[type="checkbox"]'));
          })
          details.dataset.listExpanded = true;
          button.dataset.loadStatus = true;
        })
      } else {
        details.dataset.listExpanded = !(details.dataset.listExpanded == 'true');
      }
    })
  })
});
