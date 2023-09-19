window.addEventListener('DOMContentLoaded', (event) => {
  const btn = document.querySelector('#action-toggle-highlight');
  if ( ! btn ) { return; }

  btn.addEventListener('click', (event) => {
    event.preventDefault();
    event.stopPropagation();
    let state = document.documentElement.dataset.highlightState = 
      document.documentElement.dataset.highlightState == 'off' ? 
      'on' : 
      'off';

    if ( state == 'off' ) {
      btn.innerHTML = `<span class="material-icons" aria-hidden="true">visibility_off</span> <span>Turn highlights on</span>`;
    } else {
      btn.innerHTML = `<span class="material-icons" aria-hidden="true">visibility</span> <span>Turn highlights off</span>`;
    }
    
  })

});