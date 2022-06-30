window.addEventListener('DOMContentLoaded', (event) => {
  let gotoAction = document.querySelector('#action-goto-results-page');
  let inputEl = document.querySelector('#results-pagination');
  if (gotoAction) {
    gotoAction.addEventListener('click', (event) => {
      event.preventDefault();

      let start = ( ( parseInt(inputEl.value, 10) - 1 ) * 50 ) + 1;
      let $formEl = document.querySelector('#collection-search');
      let $startEl = $formEl.querySelector('input[name="start"]');
      if ( ! $startEl ) {
        $startEl = document.createElement('input');
        $startEl.type = 'hidden';
        $startEl.name = 'start';
        $formEl.appendChild($startEl);
      }
      $startEl.value = start;
      $formEl.submit();
    });
  }
})