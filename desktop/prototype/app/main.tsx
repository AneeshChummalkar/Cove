import React from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import { CovePrototypeProvider } from "../state/prototypeStore";
import "./styles.css";

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <CovePrototypeProvider>
      <App />
    </CovePrototypeProvider>
  </React.StrictMode>
);
