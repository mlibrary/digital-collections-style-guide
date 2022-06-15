window.addEventListener('DOMContentLoaded', (event) => {

  if ( ! (
    document.documentElement.dataset.view == 'search' || 
    document.documentElement.dataset.view == 'searchgroup'
  ) ) { return; }

  const $form = document.querySelector('#collection-search');

  $form.querySelectorAll('input,select').forEach((input) => {
    input.dataset.resetValue = input.value;
    input.dataset.resetChecked = input.checked;
  })

  $form.addEventListener('change', (event) => {
    let target;
    if ( target = event.target.closest('.fieldset--clause--region select') ) {
      let $clause = target.closest("fieldset");
      let rgn = target.value;
      console.log("--", rgn);
      let $select = $clause.querySelector('select[data-active="true"]');
      $select.dataset.active = false;
      $select.disabled = true;
      // $select = $clause.querySelector(`select[data-field="${rgn}"]`);
      // $select.dataset.active = true;
      // $select.disabled = false;

      let has_query_select = false;
      $clause.querySelectorAll(`select[data-field="${rgn}"]`).forEach(($select) => {
        $select.dataset.active = true;
        $select.disabled = false;
        if ( $select.dataset.slot == 'query' ) {
          has_query_select = true;
        }
      })

      let $input = $clause.querySelector('input[data-slot="query"]');
      if ( has_query_select ) {
        $input.dataset.active = false;
        $input.disabled = true;
      } else {
        $input.dataset.active = true;
        $input.disabled = false;
      }
      
    } else if ( target = event.target.closest('.range-filter input[type="radio"]') ) {
      let $clause = target.closest("fieldset");
      let $control = $clause.querySelector('[data-range-type]');
      $control.dataset.rangeType = target.value;
    }
  })

  $form.addEventListener('click', (event) => {
    let target;
    if ( target = event.target.closest(`.fieldset--clause button[data-action='reset-clause']`) ) {
      event.preventDefault();
      let $clause = target.closest('fieldset');
      $clause.querySelectorAll('select,input').forEach((input) => {
        input.value = input.dataset.resetValue;
        input.checked = input.dataset.resetChecked == 'true';
      })
    } else if (target = event.target.closest(`button[data-action='reset-form']`) ) {
      event.preventDefault();
      $form.querySelectorAll('input,select').forEach((input) => {
        input.value = input.dataset.resetValue;
        input.checked = input.dataset.resetChecked == 'true';
      })
    } else if ( target = event.target.closest(`button[data-action="select-all-collid"]`) ) {
      event.preventDefault();
      $form.querySelectorAll('input[type="checkbox"][name="c"]').forEach((input) => {
        input.checked = true;
      })
    } else if ( target = event.target.closest(`button[data-action="clear-all-collid"]`) ) {
      event.preventDefault();
      $form.querySelectorAll('input[type="checkbox"][name="c"]').forEach((input) => {
        input.checked = false;
      })
    }
  })

  $form.addEventListener('submit', (event) => {
    // clean up ranges
    let $clauses = $form.querySelectorAll('[data-range-type]');
    $clauses.forEach(($clause) => {
      let rangeType = $clause.dataset.rangeType;
      if ( rangeType == 'ic_before' || rangeType == 'ic_after' ) {
        let unusedRangeType = rangeType == 'ic_before' ? 'ic_after' : 'ic_before';
        let inputEl = $clause.querySelector(`input[data-slot*="${unusedRangeType}"]`);
        inputEl.value = '';
      } else if ( rangeType == 'ic_range' ) {
        let beforeEl = $clause.querySelector('input[data-slot*="ic_before"]');
        let afterEl = $clause.querySelector('input[data-slot*="ic_after"]');
        if ( beforeEl.value && afterEl.value ) {
          // NOP
        } else if ( beforeEl.value ) {
          rangeType = 'ic_before';
        } else if ( afterEl.value ) {
          rangeType = 'ic_after';
        }
      }

      let $fieldset = $clause.closest('fieldset');
      let inputEl = document.createElement('input');
      inputEl.type = 'hidden';
      inputEl.name = $fieldset.dataset.select;
      inputEl.value = `${rangeType == 'ic_range' ? 'ic_range' : rangeType}`;
      $fieldset.appendChild(inputEl);
    })
  })

});