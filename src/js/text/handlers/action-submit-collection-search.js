window.addEventListener('DOMContentLoaded', (event) => {

  return false; // possibly not necessary

  if ( (
    document.documentElement.dataset.view == 'search' || 
    document.documentElement.dataset.view == 'searchgroup'
  ) ) { return; }

  const $form = document.querySelector('#collection-search');
  $form.addEventListener('submit', (event) => {
    const $rgn = $form.querySelector('select[name="rgn1"]');
    const $q1 = $form.querySelector('input[name="q1"]');
    if ( $rgn.value == 'simple' ) {
      $form.querySelectorAll('[data-role="search"]').forEach((el) => {
        el.removeAttribute('disabled');
      })
      $form.querySelectorAll('[data-role="browse"]').forEach((el) => {
        el.disabled = true;
      })
    } else {
      $form.querySelectorAll('[data-role="search"]').forEach((el) => {
        el.disabled = true;
      })
      $form.querySelectorAll('[data-role="browse"]').forEach((el) => {
        el.removeAttribute('disabled');
        if ( el.name == 'key' ) {
          el.value = $rgn.value;
        }
        $q1.name = 'value';
      })
    }
  });

});