import { spawn } from "node:child_process";
import http from "node:http";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import path from "node:path";
import process from "node:process";
import { createServer } from "vite";

const require = createRequire(import.meta.url);
const electronPath = require("electron");
const isWindows = process.platform === "win32";
const npmBin = isWindows ? "npm.cmd" : "npm";
const devUrl = "http://localhost:5174";
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDir, "..");
const viteConfig = path.join(projectRoot, "vite.config.ts");

const run = (command, args, options = {}) =>
  new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      stdio: "inherit",
      shell: false,
      ...options
    });

    child.on("error", reject);
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`${command} ${args.join(" ")} exited with code ${code}`));
      }
    });
  });

const server = await createServer({
  root: projectRoot,
  configFile: viteConfig,
  logLevel: "info",
  server: {
    host: "localhost",
    port: 5174,
    strictPort: true
  }
});

server.middlewares.use((request, _response, next) => {
  console.log(`[vite request] ${request.method} ${request.url}`);
  next();
});

await server.listen();
server.printUrls();
console.log("vite started");
console.log(`Vite started: ${devUrl}`);
await waitForHttp(devUrl);
console.log(`[Cove dev] Renderer HTTP ready: ${devUrl}`);

await run(npmBin, ["run", "electron:build"], { cwd: projectRoot });

const electron = spawn(electronPath, ["."], {
  stdio: "inherit",
  shell: false,
  cwd: projectRoot,
  env: {
    ...process.env,
    VITE_DEV_SERVER_URL: devUrl
  }
});

console.log("Electron started");

const shutdown = async (code = 0) => {
  electron.kill();
  await server.close();
  process.exit(code);
};

electron.on("error", async (error) => {
  console.error("[Cove dev] Electron failed to start", error);
  await shutdown(1);
});

electron.on("exit", async (code) => {
  await server.close();
  process.exit(code ?? 0);
});

process.on("SIGINT", () => {
  void shutdown(0);
});

process.on("SIGTERM", () => {
  void shutdown(0);
});

function waitForHttp(url, attempts = 80) {
  return new Promise((resolve, reject) => {
    let remaining = attempts;

    const check = () => {
      const request = http.get(url, (response) => {
        let body = "";
        response.setEncoding("utf8");
        response.on("data", (chunk) => {
          body += chunk;
        });
        response.on("end", () => {
          if (
            response.statusCode &&
            response.statusCode >= 200 &&
            response.statusCode < 500 &&
            body.includes("/src/main.tsx")
          ) {
            console.log(`[Cove dev] Vite served index.html (${body.length} bytes)`);
            resolve();
            return;
          }

          retry(new Error(`Unexpected Vite response: ${response.statusCode}, ${body.length} bytes`));
        });
      });

      request.on("error", retry);
      request.setTimeout(1000, () => {
        request.destroy(new Error("Timed out waiting for Vite"));
      });
    };

    const retry = (error) => {
      remaining -= 1;
      if (remaining <= 0) {
        reject(error);
        return;
      }
      setTimeout(check, 150);
    };

    check();
  });
}
