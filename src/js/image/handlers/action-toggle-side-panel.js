window.addEventListener('DOMContentLoaded', (event) => {
  let toggleAction = document.querySelector('[data-action="toggle-side-panel"]');
  if (toggleAction) {
    toggleAction.addEventListener('click', (event) => {
      toggleAction.setAttribute('aria-expanded',
        ! ( toggleAction.getAttribute('aria-expanded') == 'true') );
    });
  }
})