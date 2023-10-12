window.addEventListener('DOMContentLoaded', (event) => {

  if ( ! (
    document.documentElement.dataset.view == 'search' || 
    document.documentElement.dataset.view == 'searchgroup' || 
    document.documentElement.dataset.template == 'search'
  ) ) { return; }

  const $form = document.querySelector('#collection-search');

  // $form.querySelectorAll('input,select').forEach((input) => {
  //   input.dataset.resetValue = input.value;
  //   input.dataset.resetChecked = input.checked;
  // })

  // $form.addEventListener('change', (event) => {
  //   let target;
  //   if ( target = event.target.closest('.fieldset--clause--region select') ) {
  //     let $clause = target.closest("fieldset");
  //     let rgn = target.value;
  //     console.log("--", rgn);
  //     $clause.querySelectorAll(`select[data-active="true"]`).forEach(($select) => {
  //       $select.dataset.active = false;
  //       $select.disabled = true;
  //       console.log("--", $clause.dataset.index, rgn, $select, $select.dataset.active);
  //     });


  //     let has_query_select = false;
  //     $clause.querySelectorAll(`select[data-field="${rgn}"]`).forEach(($select) => {
  //       console.log("-- activating", rgn, $clause.dataset.index, $select);
  //       $select.dataset.active = true;
  //       $select.disabled = false;
  //       if ( $select.dataset.slot == 'query' ) {
  //         has_query_select = true;
  //       }
  //     })

  //     let $input = $clause.querySelector('input[data-slot="query"]');
  //     if ( has_query_select ) {
  //       $input.dataset.active = false;
  //       $input.disabled = true;
  //     } else {
  //       $input.dataset.active = true;
  //       $input.disabled = false;
  //     }
      
  //   } else if ( target = event.target.closest('.range-filter input[type="radio"]') ) {
  //     let $clause = target.closest("fieldset");
  //     let $control = $clause.querySelector('[data-range-type]');
  //     $control.dataset.rangeType = target.value;
  //   }
  // })

  // let _buildClause = function(qN) {
  //   const template = document.querySelector('#clause-template');
  //   const $newClause = template.content.cloneNode(true);
  //   $newClause.querySelector('.fieldset--grid').dataset.index = qN;
  //   $newClause.querySelectorAll('input,label,select').forEach((el) => {
  //     ['for', 'id', 'name', 'id'].forEach((attr) => {
  //       if (el.hasAttribute(attr)) {
  //         let value = el.getAttribute(attr);
  //         let prefix; let N = 0;
  //         if (value.match(/^q/)) { prefix = 'q'; }
  //         else if (value.match(/^rgn/)) { prefix = 'rgn'; }
  //         else if (value.match(/^op/)) { prefix = 'op'; N = 1; }
  //         else if (value.match(/^select/)) { prefix = 'select'; }
  //         el.setAttribute(attr, value.replace(`${prefix}${N}`, `${prefix}${qN}`));
  //       }
  //     })
  //   })
  //   return $newClause;
  // }

  $form.addEventListener('click', (event) => {
    let target;
    if ( target = event.target.closest(`.fieldset--grid button[data-action='reset-clause']`) ) {
      // event.preventDefault();
      // let $clause = target.closest('fieldset');
      // let $replacement = _buildClause($clause.dataset.index);
      // $clause.previousElementSibling.querySelectorAll('input[value="And"]').forEach((input) => {
      //   input.checked = true;
      // })
      // $clause.replaceWith($replacement.querySelector('.fieldset--grid'));
    } else if (target = event.target.closest(`button[data-action='reset-form']`) ) {
      event.preventDefault();
      $form.reset();
      // const clauses = [ ...$form.querySelectorAll('.fieldset--grid')];
      // for(let $clause of clauses) {
      //   if ( $clause.dataset.index == '0' ) { continue; }
      //   console.log("--", $clause, $clause.dataset.index);
      //   let $replacement = _buildClause($clause.dataset.index);
      //   $clause.previousElementSibling.querySelectorAll('input[value="And"]').forEach((input) => {
      //     input.checked = true;
      //   })
      //   $clause.replaceWith($replacement.querySelector('.fieldset--grid'));
      // }
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
    } else if ( target = event.target.closest('button[data-action="add-clause"]') ) {
      event.preventDefault();
      // const template = document.querySelector('#clause-template');
      // const $newClause = template.content.cloneNode(true);
      // let qN = parseInt($form.dataset.numQs, 10);
      // if ( qN < 10 ) { qN = 10; }
      // qN += 1;
      // $form.dataset.numQs = qN;
      // $newClause.querySelectorAll('input,label,select').forEach((el) => {
      //   [ 'for', 'id', 'name', 'id' ].forEach((attr) => {
      //     if (el.hasAttribute(attr)) {
      //       let value = el.getAttribute(attr);
      //       let prefix; let N = 0;
      //       if ( value.match(/^q/) ) { prefix = 'q'; }
      //       else if ( value.match(/^rgn/) ) { prefix = 'rgn'; }
      //       else if ( value.match(/^op/) ) { prefix = 'op'; N = 1; }
      //       else if ( value.match(/^select/) ) { prefix = 'select'; }
      //       el.setAttribute(attr, value.replace(`${prefix}${N}`, `${prefix}${qN}`));
      //     }
      //   })
      // })
      // target.parentElement.insertBefore($newClause, target);
    }
  })

  // $form.addEventListener('submit', (event) => {
  //   // clean up ranges
  //   let $clauses = $form.querySelectorAll('[data-range-type]');
  //   $clauses.forEach(($clause) => {
  //     let rangeType = $clause.dataset.rangeType;
  //     if ( rangeType == 'ic_before' || rangeType == 'ic_after' ) {
  //       let unusedRangeType = rangeType == 'ic_before' ? 'ic_after' : 'ic_before';
  //       let inputEl = $clause.querySelector(`input[data-slot*="${unusedRangeType}"]`);
  //       inputEl.value = '';
  //     } else if ( rangeType == 'ic_range' ) {
  //       let beforeEl = $clause.querySelector('input[data-slot*="ic_before"]');
  //       let afterEl = $clause.querySelector('input[data-slot*="ic_after"]');
  //       if ( beforeEl.value && afterEl.value ) {
  //         // NOP
  //       } else if ( beforeEl.value ) {
  //         rangeType = 'ic_before';
  //       } else if ( afterEl.value ) {
  //         rangeType = 'ic_after';
  //       }
  //     }

  //     let $fieldset = $clause.closest('fieldset');
  //     let inputEl = document.createElement('input');
  //     inputEl.type = 'hidden';
  //     inputEl.name = $fieldset.dataset.select;
  //     inputEl.value = `${rangeType == 'ic_range' ? 'ic_range' : rangeType}`;
  //     $fieldset.appendChild(inputEl);
  //   })
  // })

});