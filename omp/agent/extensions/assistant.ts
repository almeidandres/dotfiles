import { mkdirSync, readFileSync, realpathSync, renameSync, unlinkSync, writeFileSync } from "node:fs";
import { isAbsolute, join, relative } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { MCPManager } from "@oh-my-pi/pi-coding-agent/mcp";

const agentDir = getAgentDir();
const config = JSON.parse(readFileSync(join(agentDir, "mcp.json"), "utf8"));
const policy = readFileSync(join(agentDir, "mcp-policy.md"), "utf8").trim();
const servers = Object.keys(config.mcpServers ?? {});
const actions = ["enable", "disable", "status"];
let enabled = false;

const openclawActions = ["share", "status", "clear"];
const openclawStateDir = process.env.OMP_OPENCLAW_STATE_DIR;
const openclawWorktreesDir = process.env.OMP_WORKTREES_DIR;
const openclawShareFile = openclawStateDir && join(openclawStateDir, "shared-session.json");
const openclawRelocationsDir = openclawStateDir && join(openclawStateDir, "relocations");

function readSharedSession() {
  if (!openclawShareFile) return undefined;
  try {
    return JSON.parse(readFileSync(openclawShareFile, "utf8"));
  } catch (error: any) {
    if (error?.code === "ENOENT") return undefined;
    throw error;
  }
}

function writeSharedSession(session: object) {
  if (!openclawStateDir || !openclawShareFile) throw new Error("OMP_OPENCLAW_STATE_DIR is not set");
  mkdirSync(openclawStateDir, { recursive: true, mode: 0o700 });
  const temporary = openclawShareFile + "." + process.pid + ".tmp";
  writeFileSync(temporary, JSON.stringify(session) + "\n", { mode: 0o600 });
  renameSync(temporary, openclawShareFile);
}

const isAssistantTool = (name: string) =>
  servers.some((server) => name.startsWith(`mcp__${server}_`));

export default function assistant(pi: ExtensionAPI) {
  pi.registerCommand("openclaw", {
    description: "Share, inspect, or clear the canonical OMP session used for OpenClaw forks",
    getArgumentCompletions: (prefix) => {
      const matches = openclawActions.filter((action) => action.startsWith(prefix.trim().toLowerCase()));
      return matches.length ? matches.map((action) => ({ value: action, label: action })) : null;
    },
    handler: async (args, ctx) => {
      const action = args.trim().split(/\s+/, 1)[0].toLowerCase() || "status";
      if (action !== "relocate" && !openclawActions.includes(action)) {
        ctx.ui.notify("Usage: /openclaw share|status|clear", "warning");
        return;
      }
      if (!openclawShareFile || !openclawRelocationsDir) {
        ctx.ui.notify("OpenClaw sharing is available only in configured cloud OMP", "error");
        return;
      }

      if (action === "relocate") {
        if (!openclawWorktreesDir) throw new Error("OMP_WORKTREES_DIR is not set");
        const sessionId = ctx.sessionManager.getSessionId();
        if (!sessionId || !/^[a-zA-Z0-9-]+$/.test(sessionId)) throw new Error("Current OMP session has no valid ID");
        const requestFile = join(openclawRelocationsDir, sessionId + ".json");
        const request = JSON.parse(readFileSync(requestFile, "utf8"));
        const worktreesRoot = realpathSync(openclawWorktreesDir);
        const target = realpathSync(request.cwd);
        const targetRelative = relative(worktreesRoot, target);
        if (request.sessionId !== sessionId || !targetRelative || targetRelative.startsWith("..") || isAbsolute(targetRelative)) {
          throw new Error("Invalid OpenClaw child session relocation request");
        }
        await ctx.sessionManager.moveTo(target);
        unlinkSync(requestFile);
        ctx.ui.notify("OpenClaw child session moved to " + target, "info");
        return;
      }
      if (action === "status") {
        const shared = readSharedSession();
        ctx.ui.notify(
          shared ? "OpenClaw parent: " + shared.title + " (" + shared.cwd + ")" : "No OMP session shared with OpenClaw",
          "info",
        );
        return;
      }
      if (action === "clear") {
        try {
          unlinkSync(openclawShareFile);
        } catch (error: any) {
          if (error?.code !== "ENOENT") throw error;
        }
        ctx.ui.notify("OpenClaw parent cleared", "info");
        return;
      }

      const sessionId = ctx.sessionManager.getSessionId();
      if (!sessionId) {
        ctx.ui.notify("Current OMP session has no ID", "error");
        return;
      }
      const title = pi.getSessionName()?.trim() || sessionId.slice(0, 8);
      writeSharedSession({ sessionId, cwd: process.cwd(), title, sharedAt: new Date().toISOString() });
      ctx.ui.notify("Shared OMP session " + title + " with OpenClaw", "info");
    },
  });

  pi.registerCommand("assistant", {
    description: "Enable, disable, or show personal-service MCP tools for this session",
    getArgumentCompletions: (prefix) => {
      const matches = actions.filter((action) => action.startsWith(prefix.trim().toLowerCase()));
      return matches.length ? matches.map((action) => ({ value: action, label: action })) : null;
    },
    handler: async (args, ctx) => {
      const action = args.trim().toLowerCase() || "status";
      if (!actions.includes(action)) {
        ctx.ui.notify("Usage: /assistant enable|disable|status", "warning");
        return;
      }

      const manager = MCPManager.instance();
      if (!manager) {
        ctx.ui.notify("MCP runtime unavailable", "error");
        return;
      }

      if (action === "status") {
        const connected = manager.getConnectedServers().filter((name) => servers.includes(name)).length;
        ctx.ui.notify(`Assistant: ${enabled ? `enabled, ${connected}/${servers.length} services connected` : "disabled"}`, "info");
        return;
      }

      if (action === "enable") {
        const configs = Object.fromEntries(
          Object.entries(config.mcpServers).map(([name, server]: [string, any]) => [
            name,
            { ...server, enabled: true, instructions: true },
          ]),
        );
        const result = await manager.connectServers(configs, {});
        enabled = true;
        ctx.ui.setStatus("assistant", "🤖");
        await pi.setActiveTools([
          ...new Set([...pi.getActiveTools(), ...result.tools.map((tool) => tool.name)]),
        ]);
        ctx.ui.notify(
          `Assistant enabled; ${servers.length} services loading`,
          result.errors.size ? "warning" : "info",
        );
        return;
      }

      enabled = false;
      ctx.ui.setStatus("assistant", undefined);
      await pi.setActiveTools(pi.getActiveTools().filter((name) => !isAssistantTool(name)));
      await Promise.allSettled(servers.map((name) => manager.disconnectServer(name)));
      ctx.ui.notify("Assistant disabled", "info");
    },
  });

  pi.on("before_agent_start", (event) => {
    if (!enabled) return;
    return {
      systemPrompt: [
        ...event.systemPrompt,
        `Shared MCP client policy (authoritative):\n\n${policy}`,
      ],
    };
  });

  pi.on("tool_call", (event) => {
    if (!enabled && isAssistantTool(event.toolName)) {
      return { block: true, reason: "Assistant disabled. Run /assistant enable first." };
    }
  });
}
