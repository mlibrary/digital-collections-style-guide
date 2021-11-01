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

  const $form = document.querySelector("form#collection-search");
  if ( $form) {
    const numFacets = $form.querySelectorAll(
      'input[data-role="facet"]:checked'
    ).length;
    document.querySelectorAll('input[data-action="facet"]').forEach((input) => {
      input.addEventListener("change", (event) => {
        if (!input.checked) {
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
        $form.submit();
      });
    });
  }

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
