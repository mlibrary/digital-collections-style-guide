window.addEventListener('DOMContentLoaded', (event) => {

  document.querySelectorAll('button[data-action="confirm-viewer-advisory"]').forEach((button) => {
    button.addEventListener('click', (event) => {
      event.preventDefault();
      button.closest('[data-viewer-advisory]').dataset.viewerAdvisory = false;
    })
  })

});