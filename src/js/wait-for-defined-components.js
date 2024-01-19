window.mUse = window.mUse || [];

function patchWebsiteContaner() {
  const websiteHeader = document.querySelector('m-website-header');
  if ( websiteHeader ) {
    const container = websiteHeader.shadowRoot.querySelector('.website-header__inner-container');
    if ( container && container.style && ! container.style.rowGap ) {
      // for narrow screens before we collapse the navbar
      container.style.rowGap = '0.5rem';
    }
  }
}

if (window.mUse.length > 0) {
  let promises = [];
  window.mUse.forEach((component) => {
    promises.push(customElements.whenDefined(component));
  })
  Promise.allSettled(promises)
    .then(() => {
      // console.log("mUse all resolved");
      document.documentElement.dataset.initialized = true;
      document.body.style.opacity = 1;

      setTimeout(() => {
        patchWebsiteContaner();
      }, 100);
    })
} else {
  console.log("mUse nothing to resolve");
  document.body.dataset.initialized = true;
}