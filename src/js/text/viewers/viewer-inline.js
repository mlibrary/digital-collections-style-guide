import { ScreenReaderMessenger } from "../../sr-messaging";

window.DLXS = window.DLXS || {};
DLXS.manifestsData = {};
DLXS.manifestsIndex = {};
DLXS.totalManifests = 0;

let plaintextViewer = null;
let plaintextUrl;

let $viewer;
let itemEncodingLevel;

let $nav = {};
let $tabGroup;
let $fetching;

let updateDownloadMenu = function () {
  const slDropdownEl = document.querySelector("#dropdown-action");
  slDropdownEl.disabled = true;
  slDropdownEl.style.opacity = 0.5;
  let slMenuEl = slDropdownEl.querySelector("sl-menu");
  while (slMenuEl.firstChild) {
    slMenuEl.removeChild(slMenuEl.firstChild);
  }
  let menuHtml = "";
  for (let i = 0; i < DLXS.totalManifests; i++) {
    let manifestId = DLXS.manifestsIndex[i];
    let info = DLXS.manifestsData[manifestId];
    if (!info.label) {
      // manifest data hasn't been loaded yet
      continue;
    }
    if (i > 0) {
      menuHtml += `<sl-menu-label></sl-menu-label>`;
    }
    menuHtml += `<sl-menu-label>${info.label}</sl-menu-label>`;
    for (let ii = 0; ii < info.sizes.length; ii++) {
      let size = info.sizes[ii];
      console.log("-- updateDownload size", size.width, size.height);
      if (size.height >= 600 || size.width >= 600) {
        let href = `${info.resourceId.replace("/tile/", "/image/")}/full/${
          size.width
        },${size.height}/0/default.jpg`;
        menuHtml += `<sl-menu-item data-href="${href}" value="${href}">${size.width} x ${size.height} (JPEG)</sl-menu-item>`;
      }
    }
  }
  slMenuEl.innerHTML = menuHtml;

  slDropdownEl.disabled = false;
  slDropdownEl.style.opacity = 1.0;
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

window.addEventListener("message", (event) => {
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

  const labelEl = document.querySelector('span[data-key="canvas-label"]');
  console.log("-- viewer.mirador.message", event);

  if (event.data.event == "updateMetadata") {
    let identifier = event.data.identifier;
    let canvasId = event.data.canvasId;
    if (identifier == "default.jpg") {
      // remote image; is there a better way to do this
      let tmp = event.data.canvasId.split("/");
      identifier = tmp.at(-3);
    }
    const label = event.data.label;
    const link = document.querySelector('link[rel="self"]');

    if (labelEl) {
      labelEl.innerText = label;
    }

    let parts = document.title.split(" | ");
    parts[0] = label;
    document.title = parts.join(" | ");

    parts = identifier.split(":");
    const newSeq = parts.pop();
    const idno = parts.at(-1);
    const baseIdentifier = parts.join(":");

    console.log(
      "-- viewer.mirador.updateMetadata",
      canvasId,
      identifier,
      label,
      newSeq
    );

    const slDropdownEl = document.querySelector("#dropdown-action");
    slDropdownEl.disabled = true;
    slDropdownEl.style.opacity = 0.5;

    console.log("-- plaintext.updateMetadata", identifier);

    // this will be different when we get to portfolios
    // let url = new URL(location.href.replace(/\;/g, "&"));
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
    // console.log("-- match new href", newHref, newPageviewHref);

    alert.innerHTML = `<p>Loading metadata for: ${identifier}</p>`;

    // update download menu
    let slMenuEl = document.querySelector("#dropdown-action sl-menu");
    slMenuEl.querySelectorAll("sl-menu-item").forEach((itemEl) => {
      let downloadHref = itemEl.dataset.href.replace(/;/g, "&");
      let downloadUrl = new URL(downloadHref);
      if (downloadUrl.searchParams.has("seq")) {
        downloadUrl.searchParams.set("seq", newSeq);
      } else if (downloadUrl.pathname.indexOf(baseIdentifier) > -1) {
        // replace the identifier in the path
        let re = new RegExp(`${baseIdentifier}:\\d+`);
        downloadUrl.pathname = downloadUrl.pathname.replace(re, identifier);
      }
      itemEl.dataset.href = downloadUrl.toString();
      itemEl.setAttribute("value", downloadUrl.toString());

      let newSeq2 = newSeq.replace(/^0*/, "");
      let spanEl = itemEl.querySelector(".menu-label");
      let newText = spanEl.innerText.split(" -")[0];
      let pageData = DLXS.pageMap[newSeq2];
      if (itemEl.dataset.chunked == "true") {
        newText += ` - Pages ${pageData.chunk}`;
      } else {
        newText += ` - Page ${pageData.pageNum}`;
      }

      console.log("-- update", spanEl, DLXS.pageMap[newSeq2].pageNum, newText);
      spanEl.innerText = newText;
    });
    slDropdownEl.disabled = false;
    slDropdownEl.style.opacity = 1.0;

    history.pushState({}, document.title, newPageviewHref);
    document
      .querySelector(".breadcrumb li:last-child")
      .setAttribute("href", newPageviewHref);

    const bookmarkItem = document.querySelector(
      'dt[data-key="bookmark-item"] + dd span.url'
    );
    if (bookmarkItem) {
      let itemHref = bookmarkItem.innerText.trim();
      bookmarkItem.innerText = newPageviewHref;
      // if ( itemHref.indexOf('/cgi/') > -1 ) {
      //   // just use newHref
      //   bookmarkItem.innerText = newHref;
      // } else {
      //   // just pop on the new seq?
      //   let tmp = itemHref.split('/');
      //   tmp[tmp.length - 1] = newSeq.replace(/^0+/, '');
      //   bookmarkItem.innerText = tmp.join('/');
      // }
    }

    if (itemEncodingLevel > 1) {
      fetch(newPageviewHref, { credentials: "include" })
        .then((response) => {
          if (!response.ok) {
            throw new Error(`Request error: ${response.status}`);
          }
          return response.text();
        })
        .then((text) => {
          const newDocument = new DOMParser().parseFromString(
            text,
            "text/html"
          );
          const sections = document.querySelectorAll(".main-panel > section");
          const newSections = newDocument.querySelectorAll(
            ".main-panel > section"
          );
          for (let i = 0; i < newSections.length; i++) {
            sections[i].innerHTML = newSections[i].innerHTML;
          }

          let newTitle = newDocument.querySelector("h1").innerHTML;
          document.querySelector("h1").innerHTML = newTitle;
          document.title = newDocument.title;
        });
      console.log("-- update.metadata OK", itemEncodingLevel);
    } else {
      console.log("-- update.metadata PUNT", itemEncodingLevel);
    }

    tocbot.refresh();

    ScreenReaderMessenger.getMessenger().say(`Viewing ${label}`);

    const analyticsEvent = new Event("dlxs:trackPageView");
    window.dispatchEvent(analyticsEvent);
  }

  if (event.data.event == "configureManifests") {
    let manifestList = JSON.parse(event.data.manifestList);
    manifestList.forEach((v, idx) => {
      DLXS.manifestsIndex[idx] = v;
      DLXS.manifestsData[v] = {};
      DLXS.totalManifests += 1;
    });
  }

  //   if (event.data.event == 'updateDownloadLinks') {
  //     const identifier = event.data.identifier;
  //     const resourceId = event.data.resourceId;
  //     const manifestId = event.data.manifestId;
  //     const label = event.data.label;

  //     alert.innerHTML = `<p>Updating download links for: ${identifier}</p>`;

  //     console.log("-- updateDownload", label, resourceId, manifestId);
  //     fetch(resourceId + '/info.json')
  //       .then(resp => resp.json())
  //       .then((data) => {
  //         DLXS.manifestsData[manifestId] = { sizes: data.sizes, resourceId: resourceId, label: label };
  //         updateDownloadMenu();
  //       })
  //   }
});

window.addEventListener("DOMContentLoaded", (event) => {

  let tileSources = [];
  $viewer = document.querySelector(".viewer");
  $viewer.querySelectorAll("li[data-tile-source]").forEach((el) => {
    tileSources.push(el.dataset.tileSource);
  });
  let canvasIndex = parseInt($viewer.dataset.canvasIndex, 10);
  if ($viewer) {
    itemEncodingLevel = $viewer.dataset.itemEncodingLevel;
  }

  $nav.items = $viewer.querySelector("#nav-index");
  $nav.ranges = $viewer.querySelector("#nav-ranges");
  $tabGroup = $viewer.querySelector("sl-tab-group");
  window.$tabGroup = $tabGroup;
  // window.$nav = $nav;

  $fetching = $viewer.querySelector(".fetching");

  [ 'items', 'ranges' ].forEach((tab) => {
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
  })

  $tabGroup.addEventListener("sl-tab-show", (event) => {
    setTimeout(() => {
      let panel = event.detail.name;
      let $active = $nav[panel].querySelector(".active");
      console.log("-- switching panels", panel, $active);
      scrollIntoView($active);
    }, 10);
  });


  let hostname = location.hostname != 'localhost' ? location.hostname : 'quod.lib.umich.edu';
  plaintextUrl = new URL(`https://${location.hostname}`);

  plaintextUrl.pathname = "/cgi/t/text/pageviewer-idx";
  plaintextUrl.searchParams.set("view", "text");
  plaintextUrl.searchParams.set("tpl", "plaintext.viewer");
  plaintextUrl.searchParams.set("cc", $viewer.dataset.cc);
  plaintextUrl.searchParams.set("idno", $viewer.dataset.idno);
  plaintextUrl.searchParams.set("seq", canvasIndex);

  let buttons = {};
  ["zoomIn", "zoomOut", "home", "previousCanvas", "nextCanvas"].forEach(
    (key) => {
      buttons[key] = document.querySelector(`button[data-action="${key}"]`);
    }
  );

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
    let $active = $nav[$tabGroup.activeTab.panel].querySelector(".active");
    scrollIntoView($active);
    fetchPlainText(canvasIndex)
      .then((value) => {
        let plainText = processPlainText(value);
        document.querySelector(".plaintext-wrap").innerHTML = plainText;
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
  });

  window.dragon = dragon;

  setTimeout(() => {
    console.log("-- goto.page", canvasIndex);
    dragon.goToPage(canvasIndex - 1);
    setTimeout(() => {
      dragon.viewport.goHome(true);
      let $active = $nav[$tabGroup.activeTab.panel].querySelector(".active");
      scrollIntoView($active);
      $fetching.classList.remove("visible");
    }, 1000);
  }, 100);  

});
