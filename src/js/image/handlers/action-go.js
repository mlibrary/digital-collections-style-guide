// slightly bonkers way to activate the action buttons
document.addEventListener('click', (event) => {
  let target;
  if ( target = event.target.closest('button[data-href]') ) {
    if (location.href.startsWith('#')) {
      let el = document.querySelector(location.href);
      el.focus();
      setTimeout(() => {
        el.scrollIntoView();
      }, 0);
    } else {
      location.href = target.dataset.href;
    }
  } else if ( target = event.target.closest('button[data-action="cancel"]') ) {
    event.preventDefault();
    history.go(-1);
  }
})