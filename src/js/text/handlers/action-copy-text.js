import { ScreenReaderMessenger } from "../../sr-messaging";

let inputTextCopyEl;
let lastCopiedEl;
document.addEventListener('click', (event) => {
  let target = event.target.closest('button[data-action="copy-text"]');
  if (!target) { return; }

  if ( ! inputTextCopyEl ) {
    inputTextCopyEl = document.createElement('input');
    inputTextCopyEl.setAttribute('type', 'text');
    inputTextCopyEl.setAttribute('aria-hidden', true);
    inputTextCopyEl.classList.add('visually-hidden');
    inputTextCopyEl.style.bottom = 0;
    inputTextCopyEl.style.left = 0;
    inputTextCopyEl.style.width = 'auto';
    inputTextCopyEl.setAttribute('readonly', 'readonly');
    document.body.appendChild(inputTextCopyEl);
  }

  let spanEl; let text;
  if ( target.dataset.value ) {
    // the value we want to copy
    text = target.dataset.value.trim();
  } else {
    spanEl = target.previousElementSibling;
    text = spanEl.innerText.trim();
  }
  inputTextCopyEl.setAttribute('value', text);
  inputTextCopyEl.select();
  document.execCommand('copy');
  console.log("-- copy text", text);

  if ( lastCopiedEl ) {
    lastCopiedEl.classList.remove('copied');
  }

  lastCopiedEl = spanEl ? target.parentElement : target;
  ScreenReaderMessenger.getMessenger().say("Copied to clipboard");

  requestAnimationFrame(() => {
    lastCopiedEl.classList.add('copied');
  });

});