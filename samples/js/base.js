window.addEventListener('DOMContentLoaded', (event) => {
  const usingIdentifiers = document.querySelectorAll('[identifier]').length > 0;
  document.body.addEventListener("click", (event) => {
    const target = event.target.closest('a');
    if (usingIdentifiers && target && target.getAttribute("href")[0] != '#') {
      if (target.dataset.available != "true") {
        event.preventDefault();
        alert("This link is not available.");
        return;
      }
    }
  });

  if ( location.hostname.indexOf('.netlify.app') < 0 ) {
    // login trigger
    const $actionLogin = document.querySelector('#action-login');
    $actionLogin.addEventListener('click', (event) => {
      event.preventDefault();
      const loggedIn = ! ( $actionLogin.dataset.loggedIn == "true" );
      // set the cookie
      document.cookie = `loggedIn=${loggedIn}; path=/`;
      // reload the page
      location.reload();
    })
  }

  const $form = document.querySelector("form#collection-search");
  if ( $form) {
    const numFacets = $form.querySelectorAll(
      'input[data-role="facet"][type="hidden"]'
    ).length;
    document.querySelectorAll('input[data-action="facet"]').forEach((input) => {
      input.addEventListener("change", (event) => {
        if (!input.checked && input.name == 'med') {
          let fInput = $form.querySelector('input[name="med"]');
          if (fInput) {
            fInput.parentElement.removeChild(fInput);
          }
        }
        else if (!input.checked) {
          // remove the facet from the form

          let fInput = $form.querySelector(
            `input[data-role="facet"][value="${input.name}"]`
          );
          fInput.parentElement.removeChild(fInput);
          fInput = $form.querySelector(
            `input[data-role="facet-value"][data-facet-field="${input.name}"][value="${input.value}"]`
          );
          fInput.parentElement.removeChild(fInput);
        } else {
          // add the facet to the collection form
          if ( input.name == 'med' ) {
            // special case
            let fInput = document.createElement("input");
            fInput.setAttribute("type", "hidden");
            fInput.setAttribute("name", 'med');
            fInput.setAttribute("value", input.value);
            $form.appendChild(fInput);
          } else {
            let fInput = document.createElement("input");
            fInput.setAttribute("type", "hidden");
            fInput.setAttribute("name", `fn${numFacets + 1}`);
            fInput.setAttribute("value", input.name);
            $form.appendChild(fInput);

            fInput = document.createElement("input");
            fInput.setAttribute("type", "hidden");
            fInput.setAttribute("name", `fq${numFacets + 1}`);
            fInput.setAttribute("value", input.value);
            $form.appendChild(fInput);            
          }
        }
        $form.submit();
      });
    });
  }

  const $resultSort = document.querySelector("select#result-sort");
  if ( $resultSort ) {
    $resultSort.addEventListener('change', (event) => {
      const value = $resultSort.value;
      const $form = $resultSort.closest("form");
      const fInput = document.createElement('input');
      fInput.setAttribute("type", "hidden");
      fInput.setAttribute("name", 'sort');
      fInput.setAttribute("value", value);
      $form.appendChild(fInput);
      $form.submit();     
    })
  }

  document.querySelectorAll('[data-action="expand-filter-list"]').forEach((button) => {
    button.addEventListener('click', (event) => {
      const details = button.closest('details');
      const loadStatus = button.dataset.loadStatus || false;
      if ( ! loadStatus ) {
        // load the complete set of filters
        const nextUrl = location.href.replace(/;/g, '&') + '&tpl=listallfacets&&focus=' + details.dataset.key;
        fetch(nextUrl)
        .then((response) => {
          return response.text();
        })
        .then((text) => {
          const newDocument = new DOMParser().parseFromString(text, "text/html");
          const parEl = button.parentElement;
          const valueEls = newDocument.querySelectorAll('div[data-expandable-filter]');
          valueEls.forEach((valueEl) => {
            details.insertBefore(valueEl, parEl);
          })
          details.dataset.listExpanded = true;
          button.dataset.loadStatus = true;
        })
      } else {
        details.dataset.listExpanded = !(details.dataset.listExpanded == 'true');
      }
    })
  })

  if ( usingIdentifiers ) {
    const button = document.createElement("button");
    button.classList.add("button", "button--small");
    button.innerHTML = '<span class="material-icons">pets</span>';
    button.style.position = "fixed";
    button.style.bottom = "1rem";
    button.style.right = "1rem";
    document.body.appendChild(button);

    button.addEventListener("click", (event) => {
      document.documentElement.dataset.previewLinks =
        document.documentElement.dataset.previewLinks == "true" ? false : true;

      if (document.documentElement.dataset.previewLinks == "true") {
        button.style.filter = "invert(1)";
      } else {
        button.style.filter = null;
      }
    });
  }
});
