window.addEventListener('DOMContentLoaded', (event) => {

  document.querySelectorAll('button[data-action="confirm-viewer-advisory"]').forEach((button) => {
    button.addEventListener('click', (event) => {
      event.preventDefault();
      const container = button.closest('[data-viewer-advisory]');
      container.dataset.viewerAdvisory = false;
      container.setAttribute('tabindex', '-1');
      container.focus();
    })
  })

});