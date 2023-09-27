import { ScreenReaderMessenger } from "../../sr-messaging";

const _handleSelectAllItems = function(target) {
  let checked = target.dataset.checked = ! ( target.dataset.checked == 'true' );
  document.querySelectorAll('input[name="bbidno"]').forEach((input) => {
    input.checked = checked;
  })
  ScreenReaderMessenger.getMessenger().say(checked ? 'Selecting all items' : 'Unselecting all items');
};

const _handleAddItems = function(target) {
  let $bbForm = document.querySelector('form#bbaction-form');
  $bbForm.querySelectorAll('input[name="bbidno"]').forEach((inputEl) => {
    inputEl.remove();
  })
  let inputs = document.querySelectorAll('input[name="bbidno"]:checked');
  if (!inputs.length) { return; }
  inputs.forEach((input) => {
    let bbInput = input.cloneNode(true);
    $bbForm.appendChild(bbInput);
  })
  let $action = $bbForm.querySelector('#bbaction-page');
  $action.setAttribute('name', 'bbaction');
  $action.setAttribute('value', 'add');

  target.disabled = true;

  $bbForm.submit();
};

document.addEventListener('click', (event) => {
  let target;
  if (target = event.target.closest('[data-action="select-all"]')) {
    _handleSelectAllItems(target);
  } else if ( target = event.target.closest('[data-action="add-items"]') ) {
    _handleAddItems(target);
  }
})
