window.addEventListener('DOMContentLoaded', (event) => {

  $("details a[href]").forEach((link) => {
    let href = link.href;
    if ( href.match(" & ") || href.match('%20&%20') ) {
      href = href.replace(/ & /g, ' %26 ');
      href = href.replace(/%20&%20/g, '%20%26%20');
    }
    link.setAttribute('href', href);
  })

});