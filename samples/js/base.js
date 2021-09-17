window.addEventListener('DOMContentLoaded', (event) => {
  document.body.addEventListener("click", (event) => {
    const target = event.target.closest('a');
    if (target) {
      if (target.dataset.available != "true") {
        event.preventDefault();
        alert("This link is not available.");
        return;
      }
    }
  });

  const button = document.createElement('button');
  button.classList.add('button', 'button--small');
  button.innerHTML = '<span class="material-icons">pets</span>';
  button.style.position = 'fixed';
  button.style.bottom = '1rem';
  button.style.right = '1rem';
  document.body.appendChild(button);

  button.addEventListener('click', (event) => {
    document.documentElement.dataset.previewLinks =
      document.documentElement.dataset.previewLinks == "true" ? false : true;

    if ( document.documentElement.dataset.previewLinks == 'true' ) {
      button.style.filter = 'invert(1)';
    } else {
      button.style.filter = null;
    }
  })


});
