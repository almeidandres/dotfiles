import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { getAgentDir, type ExtensionAPI, type ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const modes = new Set(["lite", "full", "ultra", "wenyan-lite", "wenyan-full", "wenyan-ultra", "off"]);
const defaultMode = "ultra";
const agentDir = getAgentDir();
const profile = basename(dirname(agentDir));
const account = profile === ".omp" ? "Personal" : profile[0].toUpperCase() + profile.slice(1);
const skill = readFileSync(join(agentDir, "skills/caveman/SKILL.md"), "utf8").replace(/^---\n[\s\S]*?\n---\n/, "");

export default function (pi: ExtensionAPI) {
  let mode = defaultMode;
  let lastCtx: ExtensionContext | undefined;

  const syncStatus = (ctx = lastCtx) => {
    lastCtx = ctx;
    if (!ctx) return;
    const ponytail = [...ctx.sessionManager.getBranch()]
      .reverse()
      .find((entry: any) => entry.type === "custom" && entry.customType === "ponytail-mode")?.data?.mode ?? "full";
    const status = [account, ponytail !== "off" && "🐴", mode !== "off" && "🪨"].filter(Boolean).join(" ");
    ctx.ui.setStatus("modes", status);
  };

  const setMode = (next: string, ctx?: ExtensionContext) => {
    if (!modes.has(next)) return false;
    mode = next;
    pi.appendEntry("caveman-mode", { mode });
    syncStatus(ctx);
    return true;
  };

  pi.registerCommand("caveman", {
    description: "Set Caveman mode: lite, full, ultra, wenyan-*, off, or status",
    handler: async (args, ctx) => {
      const next = args.trim().toLowerCase() || defaultMode;
      if (next === "status") {
        ctx.ui.notify(`Caveman: ${mode}`, "info");
      } else if (setMode(next, ctx)) {
        ctx.ui.notify(`Caveman mode set to ${next}.`, "info");
      } else {
        ctx.ui.notify("Unknown Caveman mode.", "warning");
      }
    },
  });

  pi.on("session_start", (_event, ctx) => {
    const saved = [...ctx.sessionManager.getBranch()]
      .reverse()
      .find((entry: any) => entry.type === "custom" && entry.customType === "caveman-mode");
    mode = modes.has(saved?.data?.mode) ? saved.data.mode : defaultMode;
    syncStatus(ctx);
  });

  pi.on("input", (event, ctx) => {
    if (/^(stop caveman|normal mode)\s*[.!]?$/i.test(event.text.trim())) setMode("off", ctx);
    ctx.setTimeout(() => syncStatus(ctx), 0);
  });

  pi.on("agent_start", (_event, ctx) => syncStatus(ctx));
  pi.on("session_tree", (_event, ctx) => syncStatus(ctx));

  pi.on("before_agent_start", (event) => {
    if (mode === "off") return;
    return { systemPrompt: [...event.systemPrompt, `CAVEMAN MODE ACTIVE — level: ${mode}\n\n${skill}`] };
  });
}
