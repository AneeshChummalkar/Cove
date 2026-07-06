const { app, BrowserWindow, screen } = require('electron');
const fs = require('fs');
const path = require('path');

const WIDTH = 320;
const HEIGHT = 60;

function createOverlay() {
  const display = screen.getPrimaryDisplay();
  const { bounds, workArea } = display;
  const x = Math.round(bounds.x + (bounds.width - WIDTH) / 2);
  const y = Math.round(workArea.y + 8);
  const target = path.resolve(__dirname, 'index.html');

  console.log('__dirname:', __dirname);
  console.log('process.cwd():', process.cwd());
  console.log('index.html exists:', fs.existsSync(target));
  console.log('absolute index.html path:', target);

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

  win.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL, isMainFrame) => {
    console.log('did-fail-load:', {
      errorCode,
      errorDescription,
      validatedURL,
      isMainFrame
    });
  });

  win.webContents.on('did-finish-load', () => {
    console.log('did-finish-load:', win.webContents.getURL());
  });

  win.webContents.on('console-message', (event, level, message, line, sourceId) => {
    console.log('renderer console-message:', {
      level,
      message,
      line,
      sourceId
    });
  });

  console.log('loading:', target);
  win.loadFile(target).catch((error) => {
    console.log('loadFile error:', error);
  });
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
