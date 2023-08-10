const _handleRemoveItems = function(target) {
  let $bbForm = document.querySelector('form#bbaction-form');
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
};

document.addEventListener('click', (event) => {
  let target;
  if (target = event.target.closest('[data-action="remove-items"]')) {
    _handleRemoveItems(target);
  }
})
