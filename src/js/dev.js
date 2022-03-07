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
    location.hostname.indexOf('.quod.lib.umich.edu') < 0
  ) {
    // login trigger
    const $actionLogin = document.querySelector('#action-login');
    $actionLogin.addEventListener('click', (event) => {
      event.preventDefault();
      const loggedIn = !($actionLogin.dataset.loggedIn == "true");
      // set the cookie
      document.cookie = `loggedIn=${loggedIn}; path=/`;
      // reload the page
      location.reload();
    })
  }
});
