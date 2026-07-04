import { contextBridge } from "electron";

contextBridge.exposeInMainWorld("covePrototype", {
  runtime: "simulated",
  integrations: "disabled"
});
