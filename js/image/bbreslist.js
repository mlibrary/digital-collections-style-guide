window.addEventListener('DOMContentLoaded', (event) => {


  const $actionRemoveItems = document.querySelector('[data-action="remove-items"]');
  if ( $actionRemoveItems ) {
    let $bbForm = document.querySelector('form#bbaction-form');
    $actionRemoveItems.addEventListener('click', (event) => {
      let inputs = document.querySelectorAll('input[name="bbidno"]:checked');
      if (!inputs.length) { return; }
      inputs.forEach((input) => {
        let bbInput = input.cloneNode(true);
        $bbForm.appendChild(bbInput);
      })
      let $action = $bbForm.querySelector('#bbaction-page');
      $action.setAttribute('name', 'bbactionremove');
      $action.setAttribute('value', 'remove');

      $bbForm.submit();
    })
  }

  // slightly bonkers way to activate the action buttons
  document.querySelectorAll('button[data-action][data-href]').forEach((button) => {
    button.addEventListener('click', (event) => {
      let href = button.dataset.href;
      location.href = href;
    })
  });

});