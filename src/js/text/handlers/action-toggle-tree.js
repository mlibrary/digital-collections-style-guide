window.addEventListener('DOMContentLoaded', (event) => {

  const toggleDetails = function(value) {
    detailsEls.forEach((el) => {
      el.open = value;
    })
  }

  const detailsEls = document.querySelectorAll('details.tree');
  const btnExpandAll = document.querySelector('button[data-action="expand-all"]');
  const btnCollapseAll = document.querySelector('button[data-action="collapse-all"]');

  btnExpandAll.addEventListener('click', () => {
    toggleDetails(true);
  })

  btnCollapseAll.addEventListener('click', () => {
    toggleDetails(false);
  })

});