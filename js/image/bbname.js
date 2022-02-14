window.addEventListener('DOMContentLoaded', (event) => {

  const actionBack = document.querySelector('[data-action="back"]');
  const actionCancel = document.querySelector('[data-action="cancel"]');
  const $main = document.querySelector('main');
  const $form = document.querySelector('#bbaction-form');

  const _makeHiddenInput = function(options) {
    let inputEl = document.createElement('input');
    inputEl.setAttribute('type', 'hidden');
    inputEl.setAttribute('name', options.name);
    inputEl.setAttribute('value', options.value);
    return inputEl;
  }

  const _handleAdd = function(event) {
    if ( $main.dataset.page == 'list' ) {
      let input = document.querySelector('input[name="bbid"]:checked');
      if (input.value == '__NEW__') {
        event.preventDefault();
        event.stopPropagation();
        $main.dataset.page = 'form';
      } else {
        $form.appendChild(_makeHiddenInput({ name: 'bbdbid', value: input.value }));
        $form.submit();
      }
    } else {
      // in page=form
      let $addForm = document.querySelector('form[action="add"]');
      if ( ! $addForm.checkValidity() ) {
        $addForm.reportValidity();
        return;
      }
      let $inputName = document.querySelector('#bbnn');
      let $inputUserName = document.querySelector('#bbusername');
      let $inputShared = document.querySelector('#bbsh');
      $form.appendChild(_makeHiddenInput({ name: 'bbnn', value: $inputName.value }));
      if ( $inputUserName ) {
        $form.appendChild(_makeHiddenInput({ name: 'bbusername', value: $inputUserName.value.trim().replace(/\n/g, "::") }));
      }
      if ( $inputShared ) {
        $form.appendChild(_makeHiddenInput({ name: 'bbsh', value: ($inputShared.checked ? $inputShared.value : 0) }));
      }
      $form.submit();
    }
  }

  $main.addEventListener('click', (event) => {
    let target;
    if ( target = event.target.closest('button') ) {
      let action = target.dataset.action;
      if ( action == 'back' ) {
        $main.dataset.page = 'list';
      } else if ( action == 'cancel' ) {
        history.go(-1);
      } else if ( action == 'add' ) {
        _handleAdd(event);
      }
    }
  })

  // slightly bonkers way to activate the action buttons
  document.querySelectorAll('button[data-action][data-href]').forEach((button) => {
    button.addEventListener('click', (event) => {
      let href = button.dataset.href;
      location.href = href;
    })
  });

});