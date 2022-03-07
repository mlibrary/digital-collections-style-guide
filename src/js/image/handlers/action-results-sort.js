document.addEventListener('change', (event) => {
  let target = event.target.closest('select#results-sort');
  if ( target ) {
    const value = target.value;
    const $form = target.closest("form");
    const fInput = document.createElement('input');
    fInput.setAttribute("type", "hidden");
    fInput.setAttribute("name", 'sort');
    fInput.setAttribute("value", value);
    $form.appendChild(fInput);
    $form.submit();
  }
})