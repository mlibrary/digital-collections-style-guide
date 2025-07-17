window.addEventListener('DOMContentLoaded', (event) => {

  const $main = document.querySelector('#search-history');
  if ( ! $main ) { return; }

  const searchHistory = JSON.parse(localStorage.getItem("dlxsSearchHistory") || '[]');

  if ( searchHistory.length == 0 ) {
    $main.insertAdjacentHTML('afterbegin', 
      `<div class="message-callout">
        <p>You have no search history.</p>
      </div>`);
    return;
  }

  searchHistory.forEach((item) => {
    console.log("== search history", item);
    if ( ! item.title ) { return ; }
    $main.insertAdjacentHTML(
      "beforeend",
      `<section class="[ results-list--small ]">
        <div class="results-card">
          <div class="[ results-list__blank ]" aria-hidden="true" data-type="history">
          </div>
          <div class="results-list__content flex flex-flow-column flex-grow-1">
            <h3>
              <a class="results-link" href="${item.url}">
                ${item.title}
              </a>
            </h3>
            <dl class="[ results ]">
              <div>
                <dt>Collections</dt>
                <dd>
                  ${item.collection}
                </dd>
              </div>
              <div>
                <dt>Total Results</dt>
                <dd>
                  ${item.results}
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </section>`
    );
  })

});