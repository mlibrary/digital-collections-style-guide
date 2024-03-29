import { ScreenReaderMessenger } from "./sr-messaging";

let srm;
window.debugSRM = function () {
  if (!srm.speakRegion.dataset.cssText) {
    srm.speakRegion.dataset.cssText = srm.speakRegion.style.cssText;
    srm.speakRegion.setAttribute('id', 'srm-log');
  }
  srm.speakRegion.style.cssText = '';
  document.documentElement.dataset.debuggingSrm = "true";
}

window.addEventListener('DOMContentLoaded', (event) => {

  srm = ScreenReaderMessenger.getMessenger();

  if (
    location.hostname.indexOf('.netlify.app') < 0 &&
    location.hostname.indexOf('quod.lib.umich.edu') < 0
  ) {
    // login trigger
    const $actionLogin = document.querySelector('#action-login');
    if ( $actionLogin ) {
      $actionLogin.addEventListener('click', (event) => {
        event.preventDefault();
        const loggedIn = !($actionLogin.dataset.loggedIn == "true");
        // set the cookie
        document.cookie = `loggedIn=${loggedIn}; path=/`;
        // reload the page
        location.reload();
      })
    }
  }

  const quodLink = document.querySelector('a.quod-link');
  if ( quodLink ) {
    quodLink.addEventListener('click', (event) => {
      const quodUrl = new URL(location.href.replaceAll(';', '&'));
      quodUrl.hostname = 'quod.lib.umich.edu';
      quodUrl.port = 443;
      quodUrl.protocol = 'https:';
      quodLink.href = quodUrl.toString();
      console.log("-- setting", quodLink.href);
    })
  }
});
