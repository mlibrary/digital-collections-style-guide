window.mUse = window.mUse || [];
console.log("mUse = ", window.mUse);
if (window.mUse.length > 0) {
  let promises = [];
  window.mUse.forEach((component) => {
    promises.push(customElements.whenDefined(component));
  })
  Promise.allSettled(promises)
    .then(() => {
      console.log("mUse all resolved");
      document.documentElement.dataset.initialized = true;
      document.body.style.opacity = 1;
    })
} else {
  console.log("mUse nothing to resolve");
  document.body.dataset.initialized = true;
}