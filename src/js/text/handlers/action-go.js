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
    } else if ( target.dataset.target ) {
      window.open(target.dataset.href, target.dataset.target);
    } else {
      let href = target.dataset.href;
      if ( target.dataset.attachment == 'download' ) {
        let delim = '&';
        if ( href.indexOf('?') < 0 ) { delim = '?' }
        else if ( href.indexOf(';') > -1 ) { delim = ';'; }
        href += delim + 'attachment=1';
      }
      location.href = href;
    }
  } else if ( target = event.target.closest('button[data-action="cancel"]') ) {
    event.preventDefault();
    history.go(-1);
  }
})