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
  // var identifier = event.identifier
})

window.addEventListener('DOMContentLoaded', (event) => {

  var idx = 0;
  document.querySelectorAll('h2,h3,h4,h5').forEach((el) => {
    idx += 1;
    if ( ! el.id ) {
      el.setAttribute('id', `h${idx}`);
    }
  })
  
  tocbot.init({
    // Where to render the table of contents.
    tocSelector: '.js-toc',
    // Where to grab the headings to build the table of contents.
    contentSelector: 'body',
    // Which headings to grab inside of the contentSelector element.
    headingSelector: 'h2, h3, h4',
    // For headings inside relative or absolute positioned containers within content.
    hasInnerContainers: true,
    collapseDepth: 6,
  });
})

document.body.addEventListener('click', (event) => {
  if ( event.target.nodeName == 'A' ) {
    if ( event.target.dataset.available == 'false' ) {
      event.preventDefault();
      alert("This link is not available.");
      return;
    }
  }
})