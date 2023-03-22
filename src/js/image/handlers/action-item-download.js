window.addEventListener('DOMContentLoaded', (event) => {
  let downloadAction = document.querySelector('#dropdown-action');
  if (downloadAction) {
    downloadAction.addEventListener('sl-select', (event) => {

      const selectedItem = event.detail.item;

      let href = selectedItem.value + '?attachment=1';
      if ( href.indexOf('https://') < 0 ) {
        href = location.protocol + '//' + location.host + href;
      }
      location.href = href;

      window.dispatchEvent(new CustomEvent('dlxs:trackPageView', {
        detail: {
          location: selectedItem.value,
        }
      }));
    });
  }
})