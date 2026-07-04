import React from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import { PresenceProvider } from "../state/presenceStore";
import "./styles.css";

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <PresenceProvider>
      <App />
    </PresenceProvider>
  </React.StrictMode>
);
