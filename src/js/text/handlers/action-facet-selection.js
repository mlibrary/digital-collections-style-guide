import { ScreenReaderMessenger } from "../../sr-messaging"; 

let $_form;

const _getForm = function() {
  if ( ! $_form ) {
    $_form = document.querySelector("form#collection-search");
  }
  return $_form;
}

const _removeInputFilter = function(input, $form) {
  let message;
  if (!input.checked && input.name == 'med') {
    let fInput = $form.querySelector('input[name="med"]');
    if (fInput) {
      fInput.parentElement.removeChild(fInput);
      message = 'remove digital media restriction';
    }
  } else if (!input.checked && input.dataset.type == 'range') {
    let key = input.getAttribute('name');
    $form.querySelectorAll(`[data-key="${key}"]`).forEach((fInput) => {
      console.log("-- removing", fInput);
      fInput.parentElement.removeChild(fInput);
    });

    message = `remove ${input.nextElementSibling.textContent}`;
  } else if (!input.checked) {
    let num = input.dataset.num;
    let fInput = $form.querySelector(`input[name="fn${num}"]`);
    fInput.parentElement.removeChild(fInput);
    fInput = $form.querySelector(`input[name="fq${num}"]`);
    fInput.parentElement.removeChild(fInput);

    message = `remove ${input.nextElementSibling.textContent}`;
  }
  return message;
}

const _addInputFilter = function(input, $form) {
  let message;
  if (input.name == 'med') {
    // special case
    let fInput = document.createElement("input");
    fInput.setAttribute("type", "hidden");
    fInput.setAttribute("name", 'med');
    fInput.setAttribute("value", input.value);
    $form.appendChild(fInput);

    message = 'add digital media filter';
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
  return message;
}

const _handleInputFilter = function (input) {
  let message;
  console.log("-- filtering", input.value, 'to', input.checked ? 'checked' : 'empty');
  let $form = _getForm();
  if ( ! input.checked ) {
    message = _removeInputFilter(input, $form);
  } else {
    message = _addInputFilter(input, $form);
  }
  ScreenReaderMessenger.getMessenger().say(`Submitting query to ${message}`);

  // check to see if there are any query parameters left in $form
  let checkEls = $form.querySelectorAll(`input[name^="q"]`);
  if ( checkEls.length == 0 ) {
    let el = $form.querySelector('input[name="c"]');
    let inputEl = document.createElement('input');
    inputEl.setAttribute('type', 'hidden');
    inputEl.setAttribute('name', 'q1');
    inputEl.setAttribute('value', el.value);
    $form.appendChild(inputEl);

    inputEl = document.createElement('input');
    inputEl.setAttribute('type', 'hidden');
    inputEl.setAttribute('name', 'rgn1');
    inputEl.setAttribute('value', 'ic_all');
    $form.appendChild(inputEl);

    // this also means we're probably no longer an advanced search
    // so remove the "from"
    el = $form.querySelector('input[name="from"]');
    if ( el ) {
      el.value = 'index';
    }
  }
  
  $form.submit();
}

const _handleExpandingFilter = function (target) {
  const details = target.closest('details');
  const loadStatus = target.dataset.loadStatus || false;
  if (!loadStatus) {
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
        })
        details.dataset.listExpanded = true;
        target.dataset.loadStatus = true;
      })
  } else {
    details.dataset.listExpanded = !(details.dataset.listExpanded == 'true');
  }
}

let target;
document.addEventListener('change', (event) => {
  if (target = event.target.closest('[data-action="facet"]')) {
    _handleInputFilter(target);
  }
})

document.addEventListener('click', (event) => {
  if (target = event.target.closest('[data-action="expand-filter-list"]')) {
    _handleExpandingFilter(target);
  }
})
