window.addEventListener('DOMContentLoaded', (event) => {

  if ( ! (
    document.documentElement.dataset.view == 'search' || 
    document.documentElement.dataset.view == 'searchgroup'
  ) ) { return; }

  const $form = document.querySelector('#collection-search');

  $form.querySelectorAll('input,select').forEach((input) => {
    input.dataset.resetValue = input.value;
    input.dataset.resetChecked = input.checked;
  })

  $form.addEventListener('change', (event) => {
    let target;
    if ( target = event.target.closest('.fieldset--clause--region select') ) {
      let $clause = target.closest("fieldset");
      let rgn = target.value;
      console.log("--", rgn);
      let $select = $clause.querySelector('select[data-active="true"]');
      $select.dataset.active = false;
      $select.disabled = true;
      $select = $clause.querySelector(`select[data-field="${rgn}"]`);
      $select.dataset.active = true;
      $select.disabled = false;
    }
  })

  $form.addEventListener('click', (event) => {
    let target;
    if ( target = event.target.closest(`.fieldset--clause button[data-action='reset-clause']`) ) {
      event.preventDefault();
      let $clause = target.closest('fieldset');
      $clause.querySelectorAll('select,input').forEach((input) => {
        input.value = input.dataset.resetValue;
        input.checked = input.dataset.resetChecked == 'true';
      })
    } else if (target = event.target.closest(`button[data-action='reset-form']`) ) {
      event.preventDefault();
      $form.querySelectorAll('input,select').forEach((input) => {
        input.value = input.dataset.resetValue;
        input.checked = input.dataset.resetChecked == 'true';
      })
    } else if ( target = event.target.closest(`button[data-action="select-all-collid"]`) ) {
      event.preventDefault();
      $form.querySelectorAll('input[type="checkbox"][name="c"]').forEach((input) => {
        input.checked = true;
      })
    } else if ( target = event.target.closest(`button[data-action="clear-all-collid"]`) ) {
      event.preventDefault();
      $form.querySelectorAll('input[type="checkbox"][name="c"]').forEach((input) => {
        input.checked = false;
      })
    }
  })

});