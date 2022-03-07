document.addEventListener('click', (event) => {
  let target = event.target.closest('details a[href]');
  if (!target) { return; }

  let href = target.href;
  if (href.match(" & ") || href.match('%20&%20')) {
    href = href.replace(/ & /g, ' %26 ');
    href = href.replace(/%20&%20/g, '%20%26%20');
  }
  target.setAttribute('href', href);
})
