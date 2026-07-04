import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import { fileURLToPath } from "node:url";
import path from "node:path";

const projectRoot = fileURLToPath(new URL(".", import.meta.url));

export default defineConfig({
  plugins: [
    {
      name: "cove-vite-debug",
      configResolved(config) {
        console.log("[vite config] root", config.root);
      },
      configureServer(server) {
        server.middlewares.use((request, _response, next) => {
          console.log(`[vite middleware] ${request.method} ${request.url}`);
          next();
        });
      },
      transformIndexHtml(html) {
        if (!html.includes('id="root"')) {
          throw new Error("[vite config] index.html is missing <div id=\"root\"></div>");
        }
        return html;
      }
    },
    react()
  ],
  root: projectRoot,
  base: "./",
  build: {
    outDir: path.join(projectRoot, "dist"),
    emptyOutDir: true
  },
  server: {
    host: "localhost",
    port: 5174,
    strictPort: true
  }
});
