window.addEventListener('DOMContentLoaded', (event) => {
  let downloadAction = document.querySelector('#dropdown-action');
  console.log("-- downloadAction", downloadAction);
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

    const ro = new ResizeObserver((entries) => {
      const entry = entries[0];
      console.log("ahoy", entry);
      const contentBoxSize = entry.contentBoxSize[0];
      downloadAction.style.setProperty('--download-menu-width', `${Math.floor(contentBoxSize.inlineSize * 0.9)}px`);
    })
    ro.observe(downloadAction);
  }
})