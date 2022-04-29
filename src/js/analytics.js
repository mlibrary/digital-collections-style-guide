// Universal Analytics
(function (i, s, o, g, r, a, m) {
  i['GoogleAnalyticsObject'] = r; i[r] = i[r] || function () {
    (i[r].q = i[r].q || []).push(arguments)
  }, i[r].l = 1 * new Date(); a = s.createElement(o),
    m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)
})(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');

const _visited = {};
const trackPageView = function (options) {
  if (window.ga) {

    console.log("trackPageView", options);
    options = options || {};
    options.dimension1 = 'image';
    var v;
    if (v = document.documentElement.dataset.c) {
      options.dimension2 = v;
    }
    if (v = document.documentElement.dataset.g) {
      options.dimension3 = v;
    }

    if (!options.location) {
      options.location = window.location.href;
    }

    if ( _visited[options.location] ) { return ; }
    _visited[options.location] = true;

    ga('create', 'UA-43730774-1', 'umich.edu');
    ga('send', 'pageview', options);

  }
}

// make this available globally
window.DLXS = window.DLXS || {};
window.DLXS.trackPageView = trackPageView;

window.addEventListener('DOMContentLoaded', (event) => {
  trackPageView();
});

window.addEventListener('dlxs:trackPageView', (event) => {
  trackPageView(event.detail);
})
