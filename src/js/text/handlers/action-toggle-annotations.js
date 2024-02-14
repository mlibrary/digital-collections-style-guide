window.addEventListener('DOMContentLoaded', (event) => {
  const btn = document.querySelector('#action-toggle-annotations');
  if ( ! btn ) { return; }

  const annotatedEls = document.querySelector('.annotated') !== null;
  if ( ! annotatedEls ) { return ; }

  document.querySelector('.annotations-panel').style.display = 'block';

  btn.addEventListener('click', (event) => {
    event.preventDefault();
    event.stopPropagation();
    let state = document.documentElement.dataset.annotationsState = 
      document.documentElement.dataset.annotationsState == 'off' ? 
      'on' : 
      'off';

    if ( state == 'off' ) {
      btn.innerHTML = `<span class="material-icons" aria-hidden="true">visibility</span> <span>Show annotations</span>`;
    } else {
      btn.innerHTML = `<span class="material-icons" aria-hidden="true">visibility_off</span> <span>Hide annotations</span>`;
    }
  })
});