import { ScreenReaderMessenger } from "../../sr-messaging";

window.DLXS = window.DLXS || {};
DLXS.manifestsData = {};
DLXS.manifestsIndex = {};
DLXS.totalManifests = 0;

let plaintextViewer = null;
let plaintextUrl;

let $viewer;
let itemEncodingLevel;
let dragon;

let viewerButtons = {};
let buttons = {};
let $splitPanel;

let $nav = {};
let $tabGroup;
let $fetching;
let $highlightToolsToolbar;
let $resizeObserver;

let panelTabs = {};
let viewerWidth;

let canvasMap = {};
let lastCanvasIndex = -1;
let totalCanvases = 0;

const toggleFullscreen = function() {
  if ( document.fullscreenElement ) {
    console.log("toggle.fullscreen exit", document.fullscreenElement);
    document.exitFullscreen();
  }
  if ($viewer.requestFullscreen) {
    console.log("toggle.fullscreen", $viewer.requestFullscreen)
    $viewer.requestFullscreen();
  }
}

const updatePageHistory = function (canvasIndex) {

  const section = document.querySelector(".main-panel > section");
  if (!section) {
    return;
  }

  let alert = section.querySelector(".alert");
  if (!alert) {
    alert = document.createElement("div");
    alert.classList.add("alert");
    section.insertBefore(alert, section.firstChild);
  }

  let data = canvasMap[canvasIndex];
  const label = data.label;

  const link = document.querySelector('link[rel="self"]');
  const labelEl = document.querySelector('span[data-key="canvas-label"]');

  const newSeq = String(canvasIndex).padStart(8, '0');

  if (labelEl) {
    labelEl.innerText = label;
  }

  let parts = document.title.split(" | ");
  parts[0] = label;
  document.title = parts.join(" | ");
    
  const slDropdownEl = document.querySelector("#dropdown-action");
  slDropdownEl.disabled = true;
  slDropdownEl.style.opacity = 0.5;

  const idno = $viewer.dataset.idno;

  let self_href = link.getAttribute("href").replace(/;/g, "&");
  if (self_href.substring(0, 1) == "/") {
    self_href = `${location.protocol}//${location.host}${self_href}`;
  }
  let pageview_href = location.href.replace(/\;/g, "&");
  let url = new URL(self_href);
  let pageviewUrl = new URL(pageview_href);
  let re1 = new RegExp(`/(${idno})/(\\d+):(\\d+)`, "i");
  let re2 = new RegExp(`/(${idno})/(\\d+)`, "i");
  let match;
  if (url.pathname.indexOf("pageviewer-idx") > -1) {
    url.searchParams.set("seq", newSeq);
  }

  if (pageviewUrl.pathname.indexOf("pageviewer-idx") > -1) {
    pageviewUrl.searchParams.set("seq", newSeq);
  } else if ((match = pageviewUrl.pathname.match(re1))) {
    // console.log("-- match d:d", match);
    match[2] = newSeq.replace(/^0+/, "");
    pageviewUrl.pathname = pageviewUrl.pathname.replace(
      re1,
      `/${match[1]}/${match[2]}:${match[3]}`
    );
  } else if ((match = pageviewUrl.pathname.match(re2))) {
    // console.log("-- match d", match);
    match[2] = newSeq.replace(/^0+/, "");
    pageviewUrl.pathname = pageviewUrl.pathname.replace(
      re2,
      `/${match[1]}/${match[2]}`
    );
  } else if (pageviewUrl.pathname.indexOf("/" + idno + "/") > -1) {
    // console.log("-- match null", pageviewUrl.pathname);
    let re = new RegExp(`/${idno}/\\d+`);
    pageviewUrl.pathname = pageviewUrl.pathname.replace(
      re,
      `/${idno}/${newSeq.replace(/^0+/, "")}`
    );
  } else {
    console.log("-- match FAIL", pageviewUrl.pathname, idno);
  }
  let newHref = url.toString();
  let newPageviewHref = pageviewUrl.toString();

  history.pushState({}, document.title, newPageviewHref);
  document.querySelector('.breadcrumb li:last-child').setAttribute('href', newPageviewHref);

  const bookmarkItem = document.querySelector('dt[data-key="bookmark-item"] + dd span.url');
  if ( bookmarkItem ) {
    let itemHref = bookmarkItem.innerText.trim();
    bookmarkItem.innerText = newPageviewHref;
  }

  // what is the itemEncodingLevel > 1 business?
  // to get the <h1> label of the page because the metadata can change
  if ( itemEncodingLevel > 1 ) {
    fetch(newPageviewHref, { credentials: 'include' })
      .then((response) => {
        if ( ! response.ok ) {
          throw new Error(`Request error: ${response.status}`);
        }
        return response.text();
      })
      .then((text) => {
        const newDocument = new DOMParser().parseFromString(text, "text/html");
        const sections = document.querySelectorAll('.main-panel > section');
        const newSections = newDocument.querySelectorAll('.main-panel > section');
        for (let i = 0; i < newSections.length; i++) {
          sections[i].innerHTML = newSections[i].innerHTML;
        }

        let newTitle = newDocument.querySelector('h1').innerHTML;
        document.querySelector('h1').innerHTML = newTitle;
        document.title = newDocument.title;        
      });
    console.log("-- update.metadata OK", itemEncodingLevel);
  } else {
    console.log("-- update.metadata PUNT", itemEncodingLevel);
  }

  const identifier = [ $viewer.dataset.cc, idno, newSeq ].join(':');
  const baseIdentifier = "${$viewer.dataset.cc}:{idno}";
  alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

  tocbot.refresh();

  // update download menu
  let slMenuEl = document.querySelector('#dropdown-action sl-menu');
  slMenuEl.querySelectorAll('sl-menu-item').forEach((itemEl) => {
    let downloadHref = itemEl.dataset.href.replace(/;/g, '&');
    let downloadUrl = new URL(downloadHref);
    if ( downloadUrl.searchParams.has('seq') ) {
      downloadUrl.searchParams.set('seq', newSeq);
    } else if ( downloadUrl.pathname.indexOf(baseIdentifier) > -1 ) {
      // replace the identifier in the path
      let re = new RegExp(`${baseIdentifier}:\\d+`);
      downloadUrl.pathname = downloadUrl.pathname.replace(re, identifier);
    }
    itemEl.dataset.href = downloadUrl.toString();
    itemEl.setAttribute('value', downloadUrl.toString());

    let newSeq2 = newSeq.replace(/^0*/, '');
    let spanEl = itemEl.querySelector('.menu-label');
    let newText = (spanEl.innerText.split(' -'))[0];
    let pageData = DLXS.pageMap[newSeq2];
    if ( itemEl.dataset.chunked == 'true' ) {
      newText += ` - Pages ${pageData.chunk}`;
    } else {
      newText += ` - Page ${pageData.pageNum}`;
    }

    console.log("-- update", spanEl, DLXS.pageMap[newSeq2].pageNum, newText);
    spanEl.innerText = newText;
  })
  slDropdownEl.disabled = false;
  slDropdownEl.style.opacity = 1.0;

  ScreenReaderMessenger.getMessenger().say(`Viewing ${label}`);
};

const blankPage = `<section style="white-space: pre-line">
  <p  class="plaintext"></p>
</section>`;

const scrollIntoView = function ($el) {
  let $slot = $tabGroup.shadowRoot.querySelector('slot[part="body"]');
  if (
    ($el && $el.offsetTop < $slot.scrollTop) ||
    $el.offsetTop > $slot.scrollTop + $slot.clientHeight
  ) {
    let y = Math.max(0, $el.offsetTop - $slot.clientHeight * 0.25);
    // console.log("-- scroll.item.into.view.y", y);
    $slot.scrollTo(0, y);
  }
};

const fetchPlainText = async function (seq) {
  if (seq) {
    // update plaintextUrl...
    plaintextUrl.searchParams.set("seq", seq);
  }
  const resp = await fetch(plaintextUrl.toString(), { credentials: "include" });
  if (resp.status != 200) {
    return "";
  }
  return resp.text();
};

const processPlainText = function (ocrText) {
  if (!ocrText) {
    return "";
  }
  const lines = ocrText.split("\n");
  if (lines[0].indexOf("DOCTYPE") > -1) {
    lines.shift();
  }
  const parsedText = lines.join("\n").trim();
  if (parsedText == blankPage) {
    return "";
  }
  // if ( lines.length < 25 ) { return ''; }
  return parsedText;
};

const updatePanelTabs = function(config) {
  console.log("-- updatePanelTabs", config);

  if ( ! viewerButtons.text ) { return ; }
  viewerButtons.image.disabled = config.disabled;
  viewerButtons.text.disabled = config.disabled;

  [ 'image', 'text' ].forEach((key) => {
    viewerButtons[key].setAttribute('aria-pressed', config[key]);
    viewerButtons[key]
      .closest("div.toggle")
      .classList.toggle("toggled", config[key]);
  })

  let collapsed = null;
  if ( config.image && config.text ) {
    $splitPanel.position = 60;
  } else if ( config.image ) {
    $splitPanel.position = 100;
    collapsed = 'text';
  } else if ( config.text ) {
    $splitPanel.position = 0;
    collapsed = 'image';
  }

  // complicated maths
  $splitPanel.dataset.collapsed = collapsed;
  let $divider = $splitPanel.shadowRoot.querySelector('div[part="divider"]');
  if ( config.image && config.text ) {
    console.log("-- updatePanelTabs.divider visible");
    $divider.style.display = null;
  } else {
    console.log("-- updatePanelTabs.divider none");
    $divider.style.display = 'none';    
  }


  // more complicated maths
  ["zoomIn", "zoomOut", "home"].forEach((key) => {
    buttons[key].disabled = ! config.image;
  });
}

const parseTileSources = function() {
  let tileSources = [];
  $viewer.querySelectorAll("li[data-tile-source]").forEach((el) => {
    if ( location.hostname == 'localhost' ) {
      tileSources.push(
        el.dataset.tileSource.replace(
          "https://quod.lib.umich.edu/",
          "http://localhost:5555/"
        )
      );
    } else if ( el.dataset.profile == 'http://iiif.io/api/image/2/level0.json' ) {
      tileSources.push({
        type: 'image',
        url: el.dataset.imageId,
        buildPyramid: false,
      })
    } else {
      tileSources.push(el.dataset.tileSource);
    }
      let $link = el.querySelector("a[data-canvas-index]");
      canvasMap[$link.dataset.canvasIndex] = { label: $link.dataset.canvasLabel };
      totalCanvases += 1;
  });
  return tileSources;    
}

const setupGuideEvents = function() {
  ["items", "ranges"].forEach((tab) => {
    if ($nav[tab]) {
      $nav[tab].addEventListener("click", (event) => {
        if (!event.target.closest("a")) {
          return;
        }
        event.preventDefault();
        let el = event.target.closest("a");
        dragon.goToPage(parseInt(el.dataset.canvasIndex, 10) - 1);
      });
    }
  });
}

const setupTabGroupEvents = function() {
  $tabGroup.addEventListener("sl-tab-show", (event) => {
    console.log("-- showing tab", event.detail.name);
    setTimeout(() => {
      let panel = event.detail.name;
      let $active = $nav[panel].querySelector(".active");
      console.log("-- switching panels", panel, $active);
      scrollIntoView($active);
    }, 10);
  });
}

const setupImageToolbarEvents = function() {
  ["zoomIn", "zoomOut", "home", "previousCanvas", "nextCanvas"].forEach(
    (key) => {
      buttons[key] = document.querySelector(`button[data-action="${key}"]`);
    }
  );

  buttons.input = document.querySelector("#jumpToSeq");
  if ( buttons.input ) {
    buttons.input.addEventListener("focus", (event) => {
      lastCanvasIndex = event.target.value;
    });
    buttons.input.addEventListener("change", (event) => {
      let newCanvasIndex = parseInt(event.target.value, 10);
      if (newCanvasIndex < 1) {
        newCanvasIndex = lastCanvasIndex;
        event.target.value = lastCanvasIndex;
      } else if (newCanvasIndex > totalCanvases) {
        newCanvasIndex = lastCanvasIndex;
        event.target.value = lastCanvasIndex;
      } else {
        dragon.goToPage(newCanvasIndex - 1);
      }
    });
  }
}

const setupPanelEvents = function() {
  if ( $splitPanel.dataset.collapsed == 'true' ) {
    $splitPanel.updateComplete.then(() => {
      let $divider = $splitPanel.shadowRoot.querySelector('div[part="divider"]');
      $divider.style.display = 'none';
    })
  }

  viewerButtons.guide = $viewer.querySelector(
    'button[data-action="toggle-guide"]'
  );
  viewerButtons.image = $viewer.querySelector(
    'button[data-action="toggle-image"]'
  );
  viewerButtons.text = $viewer.querySelector(
    'button[data-action="toggle-text"]'
  );

  document.querySelector(`button[data-action="toggle-fullscreen"]`).addEventListener('click', toggleFullscreen);

  if ( viewerButtons.guide ) {
    viewerButtons.guide.addEventListener('click', (event) => {
      let isPressed = !!!(viewerButtons.guide.getAttribute('aria-pressed') == 'true');
      console.log("-- guide clicked", isPressed);
      viewerButtons.guide.setAttribute('aria-pressed', isPressed );
      viewerButtons.guide.closest('div.toggle').classList.toggle('toggled', isPressed);
      $viewer.querySelector('[data-slot="guide"]').classList.toggle('hidden', ! isPressed);
    })
  }

  [ 'image', 'text' ].forEach((key) => {
    if ( viewerButtons[key] ) {
      viewerButtons[key].addEventListener("click", (event) => {
        let isPressed = !!!(
          viewerButtons[key].getAttribute("aria-pressed") == "true"
        );

        let otherKey = key == 'image' ? 'text' : 'image';
        let otherIsPressed = !!(viewerButtons[otherKey].getAttribute('aria-pressed') == 'true');

        if ( isPressed === false && isPressed == otherIsPressed ) {
          // toggle
          otherIsPressed = true;
        } else if ( isPressed && viewerWidth < 800 ) {
          otherIsPressed = false;
        }

        updatePanelTabs({ [key]: isPressed, [otherKey]: otherIsPressed });
      });
    }
  })
}

const setupResizeObserver = function() {
  $resizeObserver.addEventListener('sl-resize', (event) => {
    const entry = event.detail.entries.at(-1);
    if ( ! entry ) { console.log("-- punting"); return ; }
    if ($resizeObserver.dataset.layoutInitialized == 'false') {
      console.log("-- not initialized");
      return;
    }
    viewerWidth = entry.contentRect.width;
    console.log("-- on.resize", viewerWidth);
    updatePanelTabsByViewerWidth();
  })
}

const installViewer = function({tileSources, canvasIndex, buttons}) {
  let $target = $viewer.querySelector('div[data-slot="viewer"]');
  console.log("-- target:", $target);
  let imageViewer = DLXS.ui.imageViewer($target, {
    tileSources,
    canvasIndex,
    buttons,
  });

  let dragon = imageViewer.instance();

  dragon.addHandler("canvas-scroll", (event) => {
    event.preventDefaultAction = false;
    event.preventDefault = false;
  });

  dragon.addHandler("page", (event) => {
    $fetching.classList.add("visible");
    let canvasIndex = event.page + 1;
    console.log("== went to page", canvasIndex);
    if (!$tabGroup.shadowRoot) {
      return;
    }
    if (!$nav.items) {
      return;
    }
    if ($nav.items) {
      let $a = $nav.items.querySelector(
        `a[data-canvas-index="${canvasIndex}"]`
      );
      $nav.items.querySelector("li.active").classList.remove("active");
      $a.parentElement.classList.add("active");
    }
    if ($nav.ranges) {
      let $a = $nav.ranges.querySelector(
        `a[data-canvas-indexes*=":${canvasIndex}:"]`
      );
      let $li = $a.parentElement;
      if (!$li.classList.contains("active")) {
        $nav.ranges.querySelector("li.active").classList.remove("active");
        $a.parentElement.classList.add("active");
      }
    }

    console.log("-- active tab", $tabGroup, $tabGroup.activeTab);
    if ($tabGroup.activeTab) {
      setTimeout(() => {
        let $active = $nav[$tabGroup.activeTab.panel].querySelector(".active");
        scrollIntoView($active);
      }, 0);
    }

    fetchPlainText(canvasIndex)
      .then((value) => {
        let plainText = processPlainText(value);
        let $plainTextWrap = $viewer.querySelector(".plaintext-wrap");
        $viewer.querySelector("div[data-slot='content']").innerHTML = plainText;
        $highlightToolsToolbar.classList.toggle('hidden', plainText.indexOf('<mark') == -1);
        $plainTextWrap.scrollTop = 0;
        updatePanelTabs({ image: true, text: !! plainText, disabled: !! plainText === false });
        // viewerToolbarController();
        $fetching.classList.remove("visible");
        
        // panelTabs.hasPageText = plainText != '';
      })
      .catch((error) => {
        console.log("fetch.plaintext error", error);
        $fetching.classList.remove("visible");
        // panelTabs.hasPlainText = false;
        // panelTabs.plaintext = false;
        // inPageTransition = false;
      });

    updatePageHistory(canvasIndex);
    if ( buttons.input ) {
      buttons.input.value = canvasIndex;
    }
    lastCanvasIndex = canvasIndex;
  });
  return dragon;
}

const buildPlaintextUrl = function() {
  let hostname =
    location.hostname != "localhost" ? location.hostname : "quod.lib.umich.edu";
  let plaintextUrl = new URL(`https://${hostname}`);

  plaintextUrl.pathname = "/cgi/t/text/pageviewer-idx";
  plaintextUrl.searchParams.set("view", "text");
  plaintextUrl.searchParams.set("tpl", "plaintext.viewer");
  plaintextUrl.searchParams.set("cc", $viewer.dataset.cc);
  plaintextUrl.searchParams.set("idno", $viewer.dataset.idno);
  plaintextUrl.searchParams.set("seq", $viewer.dataset.canvasIndex);

  let searchParams = new URLSearchParams(location.search.replace(/;/g, '&'));
  [ 'q1', 'q2', 'q3', 'q4', 'q5', 'q6' ].forEach((qkey, qidx) => {
    if ( searchParams.has(qkey) ) {
      plaintextUrl.searchParams.set(qkey, searchParams.get(qkey));
    }
  });
  return plaintextUrl;
}

const updatePanelTabsByViewerWidth = function(callback) {
  const _isPressed = function(btn) {
    if ( ! btn ) { return false; }
    return btn.getAttribute('aria-pressed') == 'true';
  }

  if ( viewerWidth < 800 && _isPressed(viewerButtons.image) && _isPressed(viewerButtons.text) ) {
    updatePanelTabs({ image: true, text: false });
  }

  if ( callback ) { callback(); }
}

function waitForShadowRoot(element) {
  return new Promise((resolve, reject) => {
    if (element.shadowRoot) {
      resolve(element.shadowRoot);
    } else {
      const observer = new MutationObserver((mutations) => {
        if (element.shadowRoot) {
          observer.disconnect();
          resolve(element.shadowRoot);
        }
      });

      observer.observe(element, { attributes: true, subtree: true });
    }
  });
}

window.addEventListener("DOMContentLoaded", (event) => {

  $viewer = document.querySelector(".viewer");
  itemEncodingLevel = $viewer.dataset.itemEncodingLevel;
  let canvasIndex = parseInt($viewer.dataset.canvasIndex, 10);

  viewerWidth = $viewer.clientWidth;

  $nav.items = $viewer.querySelector("#nav-index");
  $nav.ranges = $viewer.querySelector("#nav-ranges");
  $tabGroup = $viewer.querySelector("sl-tab-group");

  $splitPanel = $viewer.querySelector('sl-split-panel');
  $resizeObserver = $viewer.querySelector('sl-resize-observer')

  $fetching = $viewer.querySelector(".fetching");
  $highlightToolsToolbar = $viewer.querySelector('#highlight-tools-toolbar');

  let promises = [];
  promises.push(waitForShadowRoot($tabGroup));
  promises.push(waitForShadowRoot($resizeObserver));
  promises.push(waitForShadowRoot($splitPanel));
  Promise.all(promises).then((results) => {
    let tileSources = parseTileSources();

    setupGuideEvents();
    setupTabGroupEvents();
    setupImageToolbarEvents();
    setupPanelEvents();

    plaintextUrl = buildPlaintextUrl();

    dragon = installViewer({
      tileSources,
      canvasIndex,
      buttons
    });
    window.dragon = dragon;

    setTimeout(() => {
      console.log("-- goto.page", canvasIndex);
      dragon.goToPage(canvasIndex - 1);
      setTimeout(() => {
        dragon.viewport.goHome(true);
        $fetching.classList.remove("visible");
      }, 1000);
    }, 100);

    if ($tabGroup.activeTab) {
      let $active = $nav[$tabGroup.activeTab.panel].querySelector(".active");
      scrollIntoView($active);
    }

    setupResizeObserver();

    updatePanelTabsByViewerWidth(() => { $resizeObserver.dataset.layoutInitialized = true; });

  })


});
