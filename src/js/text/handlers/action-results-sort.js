import { ScreenReaderMessenger } from "../../sr-messaging"; 

document.addEventListener('sl-select', (event) => {
  let target = event.target.closest('#action-results-sort');
  if ( target ) {
    const item = event.detail.item;
    item.checked = !item.checked;
    const value = item.value;
    console.log("-- sort", item, value);
    const $form = document.querySelector('#form-results-sort');
    const fInput = document.createElement('input');
    fInput.setAttribute("type", "hidden");
    fInput.setAttribute("name", 'sort');
    fInput.setAttribute("value", value);
    $form.appendChild(fInput);

    ScreenReaderMessenger.getMessenger().say(`Submitting query to sort results by ${item.innerText}`);
    $form.submit();
    
  }
})