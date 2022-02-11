window.addEventListener('DOMContentLoaded', (event) => {

  // slightly bonkers way to activate the action buttons
  document.querySelectorAll('button[data-action]').forEach((button) => {
    button.addEventListener('click', (event) => {
      let href = button.dataset.href;
      alert("To be implemented");
      // location.href = href;
    })
  });

});