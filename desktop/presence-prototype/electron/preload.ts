import { contextBridge } from "electron";

contextBridge.exposeInMainWorld("covePrototype", {
  simulated: true,
  integrations: "disabled"
});
