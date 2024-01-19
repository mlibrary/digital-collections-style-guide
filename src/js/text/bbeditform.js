import "../dev.js";
import "./handlers/action-go.js";

window.addEventListener('DOMContentLoaded', (event) => {

  const $main = document.querySelector('main');
  const $form = document.querySelector('#bbaction-form');

  const _makeHiddenInput = function (options) {
    let inputEl = document.createElement('input');
    inputEl.setAttribute('type', 'hidden');
    inputEl.setAttribute('name', options.name);
    inputEl.setAttribute('value', options.value);
    return inputEl;
  }

  const _handleUpdate = function (event) {
    let $updateForm = document.querySelector('form[action="update"]');
    if (!$updateForm.checkValidity()) {
      $updateForm.reportValidity();
      return;
    }
    let $inputName = document.querySelector('#bbnn');
    let $inputUserName = document.querySelector('#newowners');
    let $inputShared = document.querySelector('input[name="newstatus"]');
    $form.appendChild(_makeHiddenInput({ name: 'bbnn', value: $inputName.value }));
    if ($inputUserName) {
      $form.appendChild(_makeHiddenInput({ name: 'newowners', value: $inputUserName.value.trim().replace(/\n/g, "|") }));
    }
    if ($inputShared) {
      $form.appendChild(_makeHiddenInput({ name: 'newstatus', value: ($inputShared.checked ? $inputShared.value : 0) }));
      $form.appendChild(_makeHiddenInput({ name: 'status', value: document.querySelector('input[name="status"]').value }));
    }
    $form.submit();
  }

  $main.addEventListener('click', (event) => {
    let target;
    if (target = event.target.closest('button[data-action="update"]')) {
      _handleUpdate(event);
    }
  })

});