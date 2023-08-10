window.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('[data-behavior="focus-center"]').forEach((link) => {
    link.addEventListener('mousedown', (event) => {
      event.target.closest('a').dataset.mousedown = true;
    })

    link.addEventListener('focus', (event) => {
      // alas, block: center isn't supported in Safari. ONE DAY!
      // event.target.scrollIntoView({ block: 'center' });

      let target = event.target.closest("a");
      
      let isMousedown = target.dataset.mousedown == 'true';
      target.dataset.mousedown = false;
      if ( isMousedown ) {
        return;
      }

      const y = event.target.offsetTop - ( window.innerHeight / 2);
      window.scrollTo({
        top: y,
        left: 0
      })
    })
  })
})