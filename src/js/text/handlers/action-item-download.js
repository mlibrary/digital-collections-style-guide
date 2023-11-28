let downloadProgress;
let cancelLink;
let isCancelled = false;
let $iframeSink;

function downloadAsync(href) {
  $iframeSink = document.querySelector('iframe.download-sink');
  if ( $iframeSink ) {
    $iframeSink.remove();
  }
  $iframeSink = document.createElement('iframe');
  $iframeSink.classList.add('download-sink');
  $iframeSink.name = 'download-sink';
  $iframeSink.setAttribute('aria-hidden', true);
  document.body.appendChild($iframeSink);
  $iframeSink.src = href;
}

function updateDownloadProgress(data) {

  if ( isCancelled && ! $iframeSink.dataset.isCancelled == 'true' ) {
    $iframeSink.src = data.cancel_href;
    $iframeSink.dataset.isCancelled = true; 
    return;
  }

  downloadProgress.querySelector('[data-slot="message"]').innerText = data.message;
  let index = parseInt(data.status.index, 10);
  let num_pages = parseInt(data.status.num_pages, 10);
  if ( index > 0 ) {
    downloadProgress.querySelector('sl-progress-bar').value = Math.ceil(index / num_pages * 100);
  }
  if ( ! downloadProgress.open ) {
    downloadProgress.querySelector('a[data-action="download"]').style.display = 'none';
    downloadProgress.querySelector('sl-progress-bar').value = 0;
    downloadProgress.querySelector('sl-progress-bar').style.display = 'block';
    downloadProgress.show();
  }
  if ( data.status.status == 'FIN' ) {
    downloadProgress.querySelector('sl-progress-bar').style.display = 'none';
    downloadProgress.querySelector('a[data-action="download"]').href = data.next_href;
    downloadProgress.querySelector('a[data-action="download"]').style.display = 'inline-flex';
  }
}

window.addEventListener('DOMContentLoaded', (event) => {
  let downloadAction = document.querySelector('#dropdown-action');
  downloadProgress = document.querySelector('#download-progress');
  console.log("-- downloadAction", downloadAction);
  if (downloadAction) {
    downloadAction.addEventListener('sl-select', (event) => {

      const selectedItem = event.detail.item;
      if ( selectedItem.dataset.transfer == 'async' ) {
        isCancelled = false;
        downloadAsync(selectedItem.value);
        return;
      }

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
      const width = window.innerWith > 400 ?
        Math.floor(contentBoxSize.inlineSize * 0.9) : 
        Math.floor(window.innerWidth * 0.9);

      downloadAction.style.setProperty('--download-menu-width', `${width}px`);
    })
    ro.observe(downloadAction);
  }

  console.log("AHOY", downloadProgress);
  if (downloadProgress) {
    downloadProgress.addEventListener('sl-request-close', event => {
      if (event.detail.source === 'overlay') {
        event.preventDefault();
      }
    });

    downloadProgress.querySelector('[data-action="cancel"]').addEventListener('click', () => {
      isCancelled = true;
      setTimeout(() => {
        downloadProgress.hide();
      }, 500);
    })

    downloadProgress.querySelector('[data-action="download"]').addEventListener('click', () => {
      setTimeout(() => {
        downloadProgress.hide();
      }, 500);
    })

    // we are going to be listening for events
    window.addEventListener('message', (event) => {
      const data = event.data;
      if ( typeof(data) != 'object' ) { return ; }
      if ( ! data.status ) { return ; }

      updateDownloadProgress(data);
      // we would be opening the modal here
    })
  }
})