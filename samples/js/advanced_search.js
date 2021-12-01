window.addEventListener('DOMContentLoaded', (event) => {
  const $form = document.querySelector('#collection-search');

  // keep track of the original values
  const $inputs = $("select,input", $form);
  $inputs.forEach((input) => {
    input.dataset.resetValue = input.value;
    input.dataset.resetChecked = input.checked;
  })
  
  $(".fieldset--clause--region select").on('change', (event) => {
    let $clause = event.target.closest("fieldset");
    let rgn = event.target.value;
    console.log("--", rgn);
    let $select = $(`select[data-active="true"]`, $clause)[0];
    $select.dataset.active = false;
    $select.disabled = true;
    $select = $(`select[data-field="${rgn}"]`, $clause)[0];
    $select.dataset.active = true;
    $select.disabled = false;
  })

  $(".fieldset--clause button[data-action='reset-clause']").on('click', (event) => {
    event.preventDefault();
    let $clause = event.target.closest('fieldset');
    $("select,input", $clause).forEach((input) => {
      input.value = input.dataset.resetValue;
      input.checked = input.dataset.resetChecked;
    })
  })

  $("button[data-action='reset-form']").on('click', (event) => {
    event.preventDefault();
    $inputs.forEach((input) => {
      input.value = input.dataset.resetValue;
      input.checked = input.dataset.resetChecked == 'true';
    })
  })
  

});