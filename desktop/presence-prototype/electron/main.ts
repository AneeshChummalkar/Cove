import { app, BrowserWindow, Menu, Tray, nativeImage, shell } from "electron";
import path from "node:path";

let tray: Tray | null = null;
let overlay: BrowserWindow | null = null;

const rendererFile = () => path.join(app.getAppPath(), "dist", "index.html");

const loadRenderer = async (win: BrowserWindow, route = "") => {
  const devUrl = process.env.VITE_DEV_SERVER_URL;

  if (devUrl) {
    const target = `${devUrl}${route}`;
    console.log(`[Cove main] Loading renderer from Vite dev server: ${target}`);
    await win.loadURL(target);
    return;
  }

  const filePath = rendererFile();
  console.log(`[Cove main] Loading built renderer from file: ${filePath}`);
  await win.loadFile(filePath, route ? { hash: route.replace("#", "") } : undefined);
};

const createOverlay = () => {
  console.log("[Cove main] Creating debug renderer window", {
    platform: process.platform,
    packaged: app.isPackaged,
    devServer: process.env.VITE_DEV_SERVER_URL ?? null
  });

  overlay = new BrowserWindow({
    width: 1000,
    height: 700,
    frame: true,
    transparent: false,
    resizable: true,
    movable: true,
    minimizable: false,
    maximizable: false,
    fullscreenable: false,
    alwaysOnTop: false,
    skipTaskbar: false,
    hasShadow: true,
    title: "Cove Renderer Debug",
    backgroundColor: "#ffffff",
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    }
  });

  overlay.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: "deny" };
  });

  overlay.webContents.on("did-start-loading", () => {
    console.log("[Cove main] Renderer started loading");
  });

  overlay.webContents.on("did-finish-load", () => {
    console.log("[Cove main] Renderer finished loading", overlay?.webContents.getURL());
  });

  overlay.webContents.on("did-fail-load", (_event, errorCode, errorDescription, validatedURL) => {
    console.error("[Cove main] Renderer failed to load", { errorCode, errorDescription, validatedURL });
  });

  overlay.webContents.on("render-process-gone", (_event, details) => {
    console.error("[Cove main] Renderer process gone", details);
  });

  loadRenderer(overlay).catch((error) => {
    console.error("[Cove main] Renderer load failed", error);
  });

  overlay.webContents.openDevTools({ mode: "detach" });

  overlay.on("closed", () => {
    overlay = null;
  });
};

app.whenReady().then(() => {
  console.log("Electron started");
  console.log("[Cove main] Electron app ready");

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
