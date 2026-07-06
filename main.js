const { app, BrowserWindow, screen } = require('electron');
const path = require('path');

const WIDTH = 320;
const HEIGHT = 54;

function createOverlay() {
  console.log('RUNNING NOTCH OVERLAY CONFIG');

  const display = screen.getPrimaryDisplay();
  const { bounds } = display;
  const x = Math.round(bounds.x + (bounds.width - WIDTH) / 2);
  const y = 0;
  const target = path.resolve(__dirname, 'index.html');

  const win = new BrowserWindow({
    width: WIDTH,
    height: HEIGHT,
    x,
    y,
    frame: false,
    transparent: true,
    titleBarStyle: 'hidden',
    titleBarOverlay: false,
    movable: false,
    resizable: false,
    minimizable: false,
    maximizable: false,
    closable: false,
    fullscreenable: false,
    focusable: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    hasShadow: false,
    backgroundColor: '#00000000',
    vibrancy: 'hud',
    visualEffectState: 'active'
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  win.setIgnoreMouseEvents(true, { forward: true });

  if (process.platform === 'darwin') {
    win.setWindowButtonVisibility(false);
  }

  win.loadFile(target);
}

app.whenReady().then(() => {
  if (process.platform === 'darwin' && app.dock) {
    app.dock.hide();
  }

  createOverlay();
});

app.on('window-all-closed', () => {
  app.quit();
});
