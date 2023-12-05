window.addEventListener('DOMContentLoaded', (event) => {

  // we're focusing on series-overview
  const divEls = document.querySelectorAll('.series-overview');
  divEls.forEach((el) => {
    if (el.clientHeight / 16 > 20) {
      el.dataset.truncated = true;
      const actionDivEl = document.createElement('div');
      actionDivEl.classList.add('flex', 'flex-flow-row', 'justify-start', 'mt-1', 'mb-1');
      actionDivEl.innerHTML = `<button class="button button--ghost button--small">Show More</button>`;
      el.after(actionDivEl);
      const btn = actionDivEl.querySelector('button');
      btn.addEventListener('click', () => {
        console.log("AHOY TOGGLE TRUNCATE", el.dataset.truncated, ! ( el.dataset.truncated == 'true' ));
        el.dataset.truncated = ! ( el.dataset.truncated == 'true' );
        btn.innerText = el.dataset.truncated == 'true' ? 'Show More' : 'Show Less';
      })
      // const btn = document.createElement('button');
      // btn.classList.add('button', 'button--ghost', 'button--small');
      // btn.innerText = `Show More`;
      // el.after(btn);
    }
  })

});