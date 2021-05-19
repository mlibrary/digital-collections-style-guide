window.addEventListener('message', (event) => {
  console.log("AHOY", event)
})

document.addEventListener('DOMContentLoaded', () => {

  // const $viewer = document.querySelector('#viewer');
  // const manifestId = $viewer.dataset.manifestId;
  // const canvasIndex = $viewer.dataset.canvasIndex;
  // const provider = $viewer.dataset.provider;
  // const mode = $viewer.dataset.mode;

  // let manifests = {};
  // manifests[manifestId] = {
  //   provider: provider
  // };

  // const allowTopMenuButton = mode != 'single';
  // const allowPanelsCanvas = mode != 'single';
  // const thumbnailNavigation = { defaultPosition: 'far-bottom' };
  // if ( mode == 'single' ) {
  //   thumbnailNavigation.defaultPosition = 'off';
  // }

  // const midrador = Mirador.viewer({
  //   id: 'viewer',
  //   manifests: manifests,
  //   windows: [
  //     {
  //       canvasIndex: canvasIndex,
  //       manifestId: manifestId
  //     }
  //   ],
  //   window: {
  //     allowClose: false,
  //     allowTopMenuButton: allowTopMenuButton,
  //     allowWindowSideBar: ( mode != 'single' ),
  //     allowMaximize: false,
  //     defaultSideBarPanel: 'canvas',
  //     panels: {
  //       info: false,
  //       attribution: false,
  //       canvas: allowPanelsCanvas,
  //       annotations: false,
  //       search: false,
  //       rights: true
  //     }
  //   },
  //   workspace: {
  //     showZoomControls: true
  //   },
  //   workspaceControlPanel: false,
  //   thumbnailNavigation: thumbnailNavigation,

  //   osdConfig: {
  //     gestureSettingsMouse: {
  //       scrollToZoom: false,
  //       clickToZoom: false,
  //       dblClickToZoom: true,
  //       flickEnabled: true,
  //       pinchRotate: true
  //     }
  //   },

  //   EOT: true

  // })


})