import { ScreenReaderMessenger } from "../../sr-messaging";

// Constants
const VIEWPORT_BREAKPOINT = 800;
const GUIDE_BREAKPOINT = 500;

window.DLXS = window.DLXS || {};

const blankPage = `<section style="white-space: pre-line">
  <p  class="plaintext"></p>
</section>`;

// Main Viewer Class
class DLXSViewer {
  constructor() {
    this.state = {
      viewerWidth: 0,
      lastCanvasIndex: -1,
      totalCanvases: 0,
      canvasMap: {},
      itemEncodingLevel: null,
      dragon: null,
    };

    this.elements = {
      viewer: null,
      splitPanel: null,
      tabGroup: null,
      nav: {
        items: null,
        ranges: null,
      },
      fetching: null,
      highlightToolsToolbar: null,
      resizeObserver: null,
      buttons: {
        viewer: {},
        toolbar: {},
      },
    };
  }

  // Initialization
  async init() {
    this.initializeElements();
    await this.waitForShadowRoots();
    this.setupEventListeners();
    this.updatePanelTabsByViewerWidth(() => {
      this.elements.resizeObserver.dataset.layoutInitialized = true;
    });
    this.initializeViewer();
  }

  async waitForShadowRoots() {
    let promises = [];
    promises.push(this.waitForShadowRoot(this.elements.tabGroup));
    promises.push(this.waitForShadowRoot(this.elements.splitPanel));
    promises.push(this.waitForShadowRoot(this.elements.resizeObserver));
    return Promise.all(promises);
  }

  async waitForShadowRoot(element) {
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

  initializeElements() {
    const viewer = document.querySelector(".viewer");
    this.elements.viewer = viewer;
    this.state.itemEncodingLevel = viewer.dataset.itemEncodingLevel;
    this.state.viewerWidth = viewer.clientWidth;

    // Initialize navigation elements
    this.elements.nav.items = viewer.querySelector("#nav-index");
    this.elements.nav.ranges = viewer.querySelector("#nav-ranges");
    this.elements.tabGroup = viewer.querySelector("sl-tab-group");
    this.elements.splitPanel = viewer.querySelector("sl-split-panel");
    this.elements.resizeObserver = viewer.querySelector("sl-resize-observer");
    this.elements.fetching = viewer.querySelector(".fetching");
    this.elements.highlightToolsToolbar = viewer.querySelector(
      "#highlight-tools-toolbar"
    );

    this.initializeButtons();
  }

  initializeButtons() {
    // Initialize viewer buttons
    this.elements.buttons.viewer = {
      guide: this.elements.viewer.querySelector(
        'button[data-action="toggle-guide"]'
      ),
      image: this.elements.viewer.querySelector(
        'button[data-action="toggle-image"]'
      ),
      text: this.elements.viewer.querySelector(
        'button[data-action="toggle-text"]'
      ),
    };

    // Initialize toolbar buttons
    ["zoomIn", "zoomOut", "home", "previousCanvas", "nextCanvas"].forEach(
      (key) => {
        this.elements.buttons.toolbar[key] = document.querySelector(
          `button[data-action="${key}"]`
        );
      }
    );

    this.elements.buttons.toolbar.input = document.querySelector("#jumpToSeq");
  }

  // Event Handlers
  setupEventListeners() {
    this.setupGuideEvents();
    this.setupTabGroupEvents();
    this.setupToolbarEvents();
    this.setupPanelEvents();
    this.setupResizeObserver();
  }

  setupGuideEvents() {
    ["items", "ranges"].forEach((tab) => {
      const navElement = this.elements.nav[tab];
      if (navElement) {
        navElement.addEventListener("click", (event) => {
          const link = event.target.closest("a");
          if (!link) return;

          event.preventDefault();
          this.state.dragon.goToPage(
            parseInt(link.dataset.canvasIndex, 10) - 1
          );
        });
      }
    });
  }

  setupTabGroupEvents() {
    this.elements.tabGroup.addEventListener("sl-tab-show", (event) => {
      setTimeout(() => {
        const panel = event.detail.name;
        const activeElement = this.elements.nav[panel].querySelector(".active");
        this.scrollIntoView(activeElement);
      }, 10);
    });
  }

  setupToolbarEvents() {
    if (this.elements.buttons.toolbar.input) {
      this.elements.buttons.toolbar.input.addEventListener("focus", (event) => {
        this.state.lastCanvasIndex = event.target.value;
      });

      this.elements.buttons.toolbar.input.addEventListener(
        "change",
        (event) => {
          this.handlePageInputChange(event);
        }
      );
    }

    document
      .querySelector('button[data-action="toggle-fullscreen"]')
      .addEventListener("click", this.toggleFullscreen.bind(this));
  }

  setupPanelEvents() {
    this.setupSplitPanelDivider();
    this.setupViewerButtonEvents();
  }

  setupSplitPanelDivider() {
    if (this.elements.splitPanel.dataset.collapsed == "true") {
      this.elements.splitPanel.updateComplete.then(() => {
        let $divider = this.elements.splitPanel.shadowRoot.querySelector(
          'div[part="divider"]'
        );
        $divider.style.display = "none";
      });
    }
  }

  setupViewerButtonEvents() {
    const viewerButtons = this.elements.buttons.viewer;
    if (viewerButtons.guide) {
      viewerButtons.guide.addEventListener("click", (event) => {
        let isPressed = !!!(
          viewerButtons.guide.getAttribute("aria-pressed") == "true"
        );
        viewerButtons.guide.setAttribute("aria-pressed", isPressed);
        viewerButtons.guide
          .closest("div.toggle")
          .classList.toggle("toggled", isPressed);
        this.elements.viewer
          .querySelector('[data-slot="guide"]')
          .classList.toggle("hidden", !isPressed);
      });
    }

    ["image", "text"].forEach((key) => {
      if (viewerButtons[key]) {
        viewerButtons[key].addEventListener("click", (event) => {
          let isPressed = !!!(
            viewerButtons[key].getAttribute("aria-pressed") == "true"
          );

          let otherKey = key == "image" ? "text" : "image";
          let otherIsPressed = !!(
            viewerButtons[otherKey].getAttribute("aria-pressed") == "true"
          );

          if (isPressed === false && isPressed == otherIsPressed) {
            // toggle
            otherIsPressed = true;
          } else if (
            isPressed &&
            this.state.viewerWidth < VIEWPORT_BREAKPOINT
          ) {
            otherIsPressed = false;
          }

          this.updatePanelTabs({
            [key]: isPressed,
            [otherKey]: otherIsPressed,
          });
        });
      }
    });
  }

  updatePanelTabs(config) {
    const viewerButtons = this.elements.buttons.viewer;
    const $splitPanel = this.elements.splitPanel;
    const buttons = this.elements.buttons.toolbar;

    if (!viewerButtons.text) {
      return;
    }
    viewerButtons.image.disabled = config.disabled;
    viewerButtons.text.disabled = config.disabled;

    ["guide", "image", "text"].forEach((key) => {
      viewerButtons[key].setAttribute("aria-pressed", config[key]);
      viewerButtons[key]
        .closest("div.toggle")
        .classList.toggle("toggled", config[key]);
    });

    let collapsed = null;
    if (config.image && config.text) {
      $splitPanel.position = 60;
    } else if (config.image) {
      $splitPanel.position = 100;
      collapsed = "text";
    } else if (config.text) {
      $splitPanel.position = 0;
      collapsed = "image";
    }

    if (config.guide === false) {
      this.elements.viewer
        .querySelector('[data-slot="guide"]')
        .classList.toggle("hidden", true);
    }

    // complicated maths
    $splitPanel.dataset.collapsed = collapsed;
    let $divider = $splitPanel.shadowRoot.querySelector('div[part="divider"]');
    if (config.image && config.text) {
      $divider.style.display = null;
    } else {
      $divider.style.display = "none";
    }

    // more complicated maths
    ["zoomIn", "zoomOut", "home"].forEach((key) => {
      buttons[key].disabled = !config.image;
    });
  }

  updatePanelTabsByViewerWidth(callback) {
    const viewerButtons = this.elements.buttons.viewer;    
    const _isPressed = function (btn) {
      if (!btn) {
        return false;
      }
      return btn.getAttribute("aria-pressed") == "true";
    };

    if (      
      this.state.viewerWidth < GUIDE_BREAKPOINT &&
      _isPressed(viewerButtons.guide) &&
      _isPressed(viewerButtons.image) &&
      _isPressed(viewerButtons.text)
    ) {
      this.updatePanelTabs({ guide: false, image: true, text: false });
    } else if (
      this.state.viewerWidth < VIEWPORT_BREAKPOINT &&
      _isPressed(viewerButtons.image) &&
      _isPressed(viewerButtons.text)
    ) {
      this.updatePanelTabs({ image: true, text: false });
    }

    if (callback) {
      callback();
    }
  }

  setupResizeObserver() {
    this.elements.resizeObserver.addEventListener("sl-resize", (event) => {
      const entry = event.detail.entries.at(-1);
      if (!entry) {
        console.log("-- punting");
        return;
      }
      if (this.elements.resizeObserver.dataset.layoutInitialized == "false") {
        return;
      }
      this.state.viewerWidth = entry.contentRect.width;
      this.updatePanelTabsByViewerWidth();
    });
  }

  // Viewer Initialization
  async initializeViewer() {
    const tileSources = this.parseTileSources();
    const canvasIndex = parseInt(this.elements.viewer.dataset.canvasIndex, 10);

    const viewerSizeMaxWidth = this.elements.viewer.dataset
      .viewerSizeMaxWidth
      ? `${this.elements.viewer.dataset.viewerSizeMaxWidth}px`
      : null;
    const viewerSizeMaxHeight = this.elements.viewer.dataset
      .viewerSizeMaxHeight
      ? `${this.elements.viewer.dataset.viewerSizeMaxHeight}px`
      : null;

    console.log("AHOY", viewerSizeMaxWidth, viewerSizeMaxHeight);

    this.state.dragon = this.installViewer({
      tileSources,
      canvasIndex,
      viewerSizeMaxWidth,
      viewerSizeMaxHeight,
    });

    this.handleDragonScroll();
    this.handleDragonPageChange();
    this.initializeViewerState(canvasIndex);
  }

  // Helper Methods
  scrollIntoView(element) {
    const slot =
      this.elements.tabGroup.shadowRoot.querySelector('slot[part="body"]');
    if (!element || !slot) return;

    if (
      element.offsetTop < slot.scrollTop ||
      element.offsetTop > slot.scrollTop + slot.clientHeight
    ) {
      const y = Math.max(0, element.offsetTop - slot.clientHeight * 0.25);
      slot.scrollTo(0, y);
    }
  }

  async fetchPlainText(canvasIndex) {
    // const metadata = this._getCanvasMetadata(canvasIndex);
    // const seq = metadata.seq;
    // if (seq) {
    //   this.state.plaintextUrl.searchParams.set('seq', seq);
    // }
    // try {
    //   const response = await fetch(this.state.plaintextUrl.toString(), {
    //     credentials: 'include'
    //   });
    //   if (!response.ok) return '';
    //   return response.text();
    // } catch (error) {
    //   console.error('Error fetching plaintext:', error);
    //   return '';
    // }
  }

  parseTileSources() {
    let tileSources = [];
    this.elements.viewer
      .querySelectorAll("li[data-tile-source]")
      .forEach((el) => {
        if (location.hostname == "localhost") {
          tileSources.push(
            el.dataset.tileSource.replace(
              "https://quod.lib.umich.edu/",
              "http://localhost:5555/"
            )
          );
        } else if (
          el.dataset.serviceProfile == "http://iiif.io/api/image/2/level0.json"
        ) {
          tileSources.push({
            type: "image",
            url: el.dataset.imageId,
            buildPyramid: false,
          });
        } else {
          tileSources.push(el.dataset.tileSource);
        }
        let $link = el.querySelector("a[data-canvas-index]");
        this.state.canvasMap[$link.dataset.canvasIndex] = {
          label: $link.dataset.canvasLabel,
          collid: $link.dataset.collid,
          entryid: $link.dataset.entryid,
          viewid: $link.dataset.viewid,
          height: $link.dataset.height,
          width: $link.dataset.width,
          identifier: `${$link.dataset.collid}:${$link.dataset.entryid}:${$link.dataset.viewid}`,
          href: $link.href.replaceAll(";", "&"),
        };
        this.state.totalCanvases += 1;
      });
    return tileSources;
  }

  processPlainText(text) {
    if (!text) return "";

    const lines = text.split("\n");
    if (lines[0].includes("DOCTYPE")) {
      lines.shift();
    }

    const parsedText = lines.join("\n").trim();
    return parsedText === blankPage ? "" : parsedText;
  }

  updatePageHistory(canvasIndex) {
    const section = document.querySelector(".main-panel > section");
    if (!section) {
      return;
    }

    let metadata = this._getCanvasMetadata(canvasIndex);

    let alert = section.querySelector(".alert");
    if (!alert) {
      alert = document.createElement("div");
      alert.classList.add("alert");
      section.insertBefore(alert, section.firstChild);
    }

    alert.innerHTML = `<p>Loading metadata for: ${metadata.identifier}</p>`;

    this._updatePageMetadata(metadata);
    this._updatePageTitle(metadata);

    history.pushState({}, document.title, metadata.newPageviewHref);
    tocbot.refresh();
    ScreenReaderMessenger.getMessenger().say(`Viewing ${metadata.label}`);
  }

  _getCanvasMetadata(canvasIndex) {
    const metadata = this.state.canvasMap[canvasIndex];

    // let pageview_href = document.querySelector('link[rel="self"');
    // let pageviewUrl = new URL(pageview_href);
    // pageviewUrl.searchParams.set('entryid', metdata.entryid);
    // pageviewUrl.searchParams.set('viewid', metadata.viewid);

    metadata.newPageviewHref = metadata.href;

    const canonicalUrl = new URL(metadata.href);
    canonicalUrl.searchParams.forEach((value, key) => {
      if (
        key != "entry" ||
        key != "viewid" ||
        key != "cc" ||
        key != "entryid"
      ) {
        canonicalUrl.searchParams.delete(key);
      }
    });
    metadata.newCanonicalHref = canonicalUrl.toString();
    metadata.baseIdentifier = `${metadata.collid}:${metadata.entryid}`;

    return metadata;
  }

  _updatePageMetadata(metadata) {
    const link = document.querySelector('link[rel="self"]');
    link.setAttribute("href", metadata.newPageviewHref);

    const canonicalLink = document.querySelector('link[rel="canonical"]');
    if (canonicalLink) {
      canonicalLink.setAttribute("href", metadata.newCanonicalHref);
    }

    const labelEl = document.querySelector('span[data-key="canvas-label"]');
    if (labelEl) {
      labelEl.innerText = metadata.label;
    }

    document
      .querySelector(".breadcrumb li:last-child")
      .setAttribute("href", metadata.newPageviewHref);

    const bookmarkItem = document.querySelector(
      'dt[data-key="bookmark-item"] + dd span.url'
    );
    if (bookmarkItem) {
      let itemHref = bookmarkItem.innerText.trim();
      bookmarkItem.innerText = metadata.newPageviewHref;
    }

    if (this.state.itemEncodingLevel == 1) {
      return;
    }
    this._updatePageSections(metadata);
  }

  _updatePageSections(metadata) {
    const slDropdownEl = document.querySelector("#dropdown-action");
    slDropdownEl.disabled = true;
    slDropdownEl.style.opacity = 0.5;

    fetch(metadata.newPageviewHref, { credentials: "include" })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Request error: ${response.status}`);
        }
        return response.text();
      })
      .then((text) => {
        const newDocument = new DOMParser().parseFromString(text, "text/html");
        const sections = document.querySelectorAll(".main-panel > section");
        const newSections = newDocument.querySelectorAll(
          ".main-panel > section"
        );
        for (let i = 0; i < newSections.length; i++) {
          sections[i].innerHTML = newSections[i].innerHTML;
        }

        const plaintextSection = document.querySelector(
          'div[data-slot="content"]'
        );
        const newPlaintextSection = newDocument.querySelector(
          'div[data-slot="content"]'
        );
        plaintextSection.innerHTML = newPlaintextSection.innerHTML;
        plaintextSection.closest(".plaintext-wrap").scrollTop = 0;
        let hasText = plaintextSection.innerText.trim() != "";
        this.updatePanelTabs({
          image: true,
          text: !!plainText,
          disabled: !!plainText === false,
        });

        let slMenuEl = document.querySelector("#dropdown-action sl-menu");
        let newSlMenuEl = newDocument.querySelector("#dropdown-action sl-menu");
        if (slMenuEl && newSlMenuEl) {
          slMenuEl.innerHTML = newSlMenuEl.innerHTML;
        }
        slDropdownEl.disabled = false;
        slDropdownEl.style.opacity = 1.0;

        let newTitle = newDocument.querySelector("h1").innerHTML;
        document.querySelector("h1").innerHTML = newTitle;
        document.title = newDocument.title;
      });
  }

  _updatePageTitle(metadata) {
    let parts = document.title.split(" | ");
    parts[0] = metadata.label;
    document.title = parts.join(" | ");
  }

  initializeViewerState(canvasIndex) {
    setTimeout(() => {
      // this.state.dragon.goToPage(canvasIndex - 1);
      setTimeout(() => {
        this.state.dragon.viewport.goHome(true);
        this.elements.fetching.classList.remove("visible");
        if (this.elements.nav.items) {
          const activeElement =
            this.elements.nav.items.querySelector(".active");
          this.scrollIntoView(activeElement);
        }
      }, 1000);
    }, 100);
  }

  installViewer({
    tileSources,
    canvasIndex,
    viewerSizeMaxWidth,
    viewerSizeMaxHeight,
  }) {
    let $target = this.elements.viewer.querySelector('div[data-slot="viewer"]');
    let imageViewer = DLXS.ui.imageViewer($target, {
      tileSources,
      canvasIndex,
      viewerSizeMaxWidth, 
      viewerSizeMaxHeight,
      buttons: this.elements.buttons.toolbar,
    });

    console.log(
      "-- installViewer",
      canvasIndex,
      imageViewer,
      this.elements.buttons
    );

    return imageViewer.instance();
  }

  // Events
  handleDragonScroll() {
    this.state.dragon.addHandler("canvas-scroll", (event) => {
      event.preventDefaultAction = false;
      event.preventDefault = false;
    });
  }

  handleDragonPageChange() {
    this.state.dragon.addHandler("page", (event) => {
      this.elements.fetching.classList.add("visible");
      let canvasIndex = event.page + 1;
      console.log("== went to page", canvasIndex);
      if (!this.elements.tabGroup.shadowRoot) {
        return;
      }
      if (!this.elements.nav.items) {
        return;
      }
      if (this.elements.nav.items) {
        let $a = this.elements.nav.items.querySelector(
          `a[data-canvas-index="${canvasIndex}"]`
        );
        this.elements.nav.items
          .querySelector("li.active")
          .classList.remove("active");
        $a.parentElement.classList.add("active");
      }
      if (this.elements.nav.ranges) {
        let $a = this.elements.nav.ranges.querySelector(
          `a[data-canvas-indexes*=":${canvasIndex}:"]`
        );
        let $li = $a.parentElement;
        if (!$li.classList.contains("active")) {
          this.elements.nav.ranges
            .querySelector("li.active")
            .classList.remove("active");
          $a.parentElement.classList.add("active");
        }
      }

      if (this.elements.tabGroup.activeTab) {
        setTimeout(() => {
          const panel = this.elements.tabGroup.activeTab.panel;
          let $active = this.elements.nav[panel].querySelector(".active");
          this.scrollIntoView($active);
        }, 0);
      }

      // this.fetchPlainText(canvasIndex)
      //   .then((value) => {
      //     let plainText = this.processPlainText(value);
      //     let $plainTextWrap = this.elements.viewer.querySelector(".plaintext-wrap");
      //     this.elements.viewer.querySelector("div[data-slot='content']").innerHTML = plainText;
      //     this.elements.highlightToolsToolbar.classList.toggle('hidden', plainText.indexOf('<mark') == -1);
      //     $plainTextWrap.scrollTop = 0;
      //     this.updatePanelTabs({ image: true, text: !! plainText, disabled: !! plainText === false });
      //     this.elements.fetching.classList.remove("visible");
      //   })
      //   .catch((error) => {
      //     console.log("fetch.plaintext error", error);
      //     this.elements.fetching.classList.remove("visible");
      //   });

      this.elements.fetching.classList.remove("visible");

      this.updatePageHistory(canvasIndex);
      if (this.elements.buttons.toolbar.input) {
        this.elements.buttons.toolbar.input.value = canvasIndex;
      }
      this.state.lastCanvasIndex = canvasIndex;
    });
  }

  handlePageInputChange(event) {
    let newCanvasIndex = parseInt(event.target.value, 10);
    if (newCanvasIndex < 1) {
      newCanvasIndex = this.state.lastCanvasIndex;
      event.target.value = lastCanvasIndex;
    } else if (newCanvasIndex > this.state.totalCanvases) {
      newCanvasIndex = this.state.lastCanvasIndex;
      event.target.value = lastCanvasIndex;
    } else {
      this.state.dragon.goToPage(newCanvasIndex - 1);
    }
  }

  toggleFullscreen() {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    }
    if (this.elements.viewer.requestFullscreen) {
      this.elements.viewer.requestFullscreen();
    }
  }

  // Static factory method
  static initialize() {
    const viewer = new DLXSViewer();
    DLXS._viewer = viewer;
    viewer.init();
    // window.addEventListener('DOMContentLoaded', () => viewer.init());
    return viewer;
  }
}

// Initialize the viewer
window.addEventListener('DOMContentLoaded', (event) => {
  if ( document.querySelector('.viewer[data-cc]') ) {
    DLXSViewer.initialize();
  }
})
