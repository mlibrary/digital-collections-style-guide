window.addEventListener('message', (event) => {
  if ( event.data.event == 'canvasChange' ) {
    const identifier = event.data.identifier;
    const section = document.querySelector('section.record-container');
    let alert = section.querySelector('.alert');
    if ( ! alert ) {
      alert = document.createElement('div');
      alert.classList.add('alert');
      section.insertBefore(alert, section.firstChild);
    }
    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;
  }
  // var identifier = event.identifier;

})
