window.addEventListener('DOMContentLoaded', (event) => {

  console.log("-- wut?");

  const $item = document.querySelector('#search-history-item');
  if ( ! $item ) { return; }

  const url = $item.dataset.url;

  const searchHistory = JSON.parse(localStorage.getItem("dlxsSearchHistory") || '[]');
  const found = searchHistory.find((item) => item.url == url);
  console.log("== search history: found", found, searchHistory);

  if ( ! found ) {
    searchHistory.push({
      url: url,
      title: $item.dataset.title,
      collection: $item.dataset.collection,
      results: $item.dataset.results,
    })
    localStorage.setItem('dlxsSearchHistory', JSON.stringify(searchHistory));
    console.log("== search history: updated", searchHistory.length);
  }

});