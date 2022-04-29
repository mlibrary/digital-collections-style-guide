window.addEventListener('DOMContentLoaded', (event) => {
  let downloadAction = document.querySelector('#dropdown-action');
  if (downloadAction) {
    downloadAction.addEventListener('sl-select', (event) => {

      const selectedItem = event.detail.item;

      let href = selectedItem.value + '?attachment=1';
      location.href = location.protocol + '//' + location.host + href;

      window.dispatchEvent(new CustomEvent('dlxs:trackPageView', {
        detail: {
          location: selectedItem.value,
        }
      }));
    });
  }
})