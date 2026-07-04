import { app, BrowserWindow, Menu, Tray, nativeImage, screen, shell } from "electron";
import path from "node:path";

let tray: Tray | null = null;
let overlay: BrowserWindow | null = null;

const loadRenderer = (win: BrowserWindow, route = "") => {
  const devUrl = process.env.VITE_DEV_SERVER_URL || (!app.isPackaged ? "http://localhost:5174" : undefined);
  if (devUrl) {
    win.loadURL(`${devUrl}${route}`);
  } else {
    win.loadFile(path.join(__dirname, "../../dist/index.html"), route ? { hash: route.replace("#", "") } : undefined);
  }
};

const createOverlay = () => {
  const display = screen.getPrimaryDisplay();
  const { width, height } = display.workAreaSize;

  overlay = new BrowserWindow({
    width,
    height,
    x: display.workArea.x,
    y: display.workArea.y,
    frame: false,
    transparent: true,
    resizable: false,
    movable: false,
    minimizable: false,
    maximizable: false,
    fullscreenable: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    hasShadow: false,
    title: "Cove Overlay Runtime",
    backgroundColor: "#00000000",
    vibrancy: process.platform === "darwin" ? "under-window" : undefined,
    visualEffectState: process.platform === "darwin" ? "active" : undefined,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  overlay.setAlwaysOnTop(true, "screen-saver");
  overlay.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });

  overlay.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: "deny" };
  });

  loadRenderer(overlay);

  overlay.on("closed", () => {
    overlay = null;
  });
};

app.whenReady().then(() => {
  tray = new Tray(nativeImage.createEmpty());
  tray.setToolTip("Cove simulated tray");
  tray.setContextMenu(
    Menu.buildFromTemplate([
      { label: "Cove overlay runtime", enabled: false },
      { label: "Show Cove", click: () => (overlay ? overlay.show() : createOverlay()) },
      { label: "Hide Cove", click: () => overlay?.hide() },
      { label: "Quit", role: "quit" }
    ])
  );

  createOverlay();

  app.on("activate", () => {
    if (!overlay) {
      createOverlay();
    } else {
      overlay.show();
    }
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});
