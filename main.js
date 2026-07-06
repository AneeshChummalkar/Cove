const { app, BrowserWindow, screen } = require('electron');

const WIDTH = 320;
const HEIGHT = 60;

function createOverlay() {
  const display = screen.getPrimaryDisplay();
  const { bounds, workArea } = display;
  const x = Math.round(bounds.x + (bounds.width - WIDTH) / 2);
  const y = Math.round(workArea.y + 8);

  const win = new BrowserWindow({
    width: WIDTH,
    height: HEIGHT,
    x,
    y,
    frame: false,
    transparent: true,
    titleBarStyle: 'hidden',
    resizable: false,
    movable: true,
    minimizable: false,
    maximizable: false,
    fullscreenable: false,
    skipTaskbar: true,
    hasShadow: false,
    backgroundColor: '#00000000',
    vibrancy: 'under-window',
    visualEffectState: 'active'
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  win.loadFile('index.html');
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
