import React from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import "./styles.css";

console.log("[Cove renderer] Renderer startup");
const coveWindow = window as Window & { __COVE_INDEX_LOADED__?: boolean };
console.log("index loaded", Boolean(coveWindow.__COVE_INDEX_LOADED__));

window.onerror = (message, source, lineno, colno, error) => {
  console.error("[Cove renderer] window.onerror", { message, source, lineno, colno, error });
};

window.onunhandledrejection = (event) => {
  console.error("[Cove renderer] window.onunhandledrejection", event.reason);
};

let root = document.getElementById("root");

if (!root) {
  console.error("[Cove renderer] Missing #root mount node; creating fallback root");
  root = document.createElement("div");
  root.id = "root";
  document.body.appendChild(root);
}

createRoot(root).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

console.log("renderer mounted");
