import { contextBridge } from "electron";

console.log("[Cove preload] Preload script executed");

contextBridge.exposeInMainWorld("covePrototype", {
  simulated: true,
  integrations: "disabled"
});
