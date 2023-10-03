const convertParamsToInput = function(form) {
  let action = form.action.replace(/;/g, '&');
  let formUrl = new URL(action);
  formUrl.searchParams.forEach((value, key) => {
    let inputEl = document.createElement('input');
    inputEl.type = 'hidden';
    inputEl.name = key;
    inputEl.value = value;
    form.appendChild(inputEl);
  });
}

window.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('form[name="bookbag"]').forEach((form) => {
    convertParamsToInput(form);

    form.addEventListener('submit', (event) => {
      form.querySelector('button[type="submit"]').disabled = true;
    })
  })

  const view = document.documentElement.dataset.view;
  const template = document.documentElement.dataset.template;
  const iframeEl = document.querySelector('iframe[name="bookbag-sink"]');
  if ( iframeEl && ( template == 'reslist' || template == 'bookbag' ) ) {
    iframeEl.addEventListener('load', (event) => {
      document.querySelectorAll('input[name="bbidno"]:checked').forEach((inputEl) => {
        inputEl.checked = false;
      })
      const btnSelectAll = document.querySelector('button[data-action="select-all"]');
      if ( btnSelectAll ) {
        btnSelectAll.dataset.checked = false;
      }
      const btnAdd = document.querySelector('button[data-action="add-items"]');
      if ( btnAdd ) {
        btnAdd.disabled = false;
      }
      const btnRemove = document.querySelector('button[data-action="remove-items"]');
      if ( btnRemove ) {
        btnRemove.disabled = false;
      }
      const divOverview = document.querySelector('#bookbag-overview');
      const iframeOverviewEl = iframeEl.contentWindow.document.querySelector(`.bookbag-overview`);
      // divOverview.querySelector('.inner').innerHTML = overviewEl.innerHTML;
      divOverview.innerHTML = `<m-callout subtle="subtle" icon="check" dismissable="dismissable" variant="success">
        <div class="inner">${iframeOverviewEl.innerHTML}</div>
      </m-callout>`;
      divOverview.style.display = null;
    })
  }
  if ( iframeEl && view != 'reslist' ) {
    iframeEl.addEventListener('load', (event) => {
      const iframeUrl = new URL(iframeEl.contentWindow.document.location.href);
      const identifier = iframeUrl.searchParams.get('bbidno').toLowerCase();
      const formEl = document.querySelector(`form[name="bookbag"][data-identifier="${identifier}"]`);
      const updatedFormEl = iframeEl.contentWindow.document.querySelector(`form[name="bookbag"][data-identifier="${identifier}"]`);
      if ( updatedFormEl ) {
        formEl.action = updatedFormEl.action;
        formEl.innerHTML = updatedFormEl.innerHTML;
      } else {
        // HA HA HA this is no longer in the bookbag list
        formEl.querySelector('input[name="bbaction"]').value = 'add';
        formEl.querySelector('span.material-icons').innerText = 'add';
        formEl.querySelector('span[data-slot="label"]').innerText = 'Add to bookbag';
      }
      // convertParamsToInput(formEl);
      formEl.querySelector('button[type="submit"]').disabled = false;
      console.log("-- iframe", event, identifier, formEl, updatedFormEl);
    })
  }

  // let bookbagForm = document.querySelector('form[');
  // let inputEl = document.querySelector('#results-pagination');
  // if (gotoAction) {
  //   gotoAction.addEventListener('click', (event) => {
  //     event.preventDefault();

  //     let start = ( ( parseInt(inputEl.value, 10) - 1 ) * 50 ) + 1;
  //     let $formEl = document.querySelector('#collection-search');
  //     let $startEl = $formEl.querySelector('input[name="start"]');
  //     if ( ! $startEl ) {
  //       $startEl = document.createElement('input');
  //       $startEl.type = 'hidden';
  //       $startEl.name = 'start';
  //       $formEl.appendChild($startEl);
  //     }
  //     $startEl.value = start;
  //     $formEl.submit();
  //   });
  // }
})