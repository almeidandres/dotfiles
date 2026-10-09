// User-owned companion to Herdr's managed lifecycle integration.
// OMP's saved /rename is authoritative; only the first agent in a tab owns its label.
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  if (
    process.env.HERDR_ENV !== "1" ||
    !process.env.HERDR_PANE_ID ||
    !process.env.HERDR_SOCKET_PATH ||
    process.env.OMPCODE === "1"
  ) return;

  let revision = 0;
  let timer: ReturnType<typeof setTimeout> | undefined;
  let controller: AbortController | undefined;
  let queue = Promise.resolve();
  let lastWarning = "";

  function stop() {
    revision++;
    clearTimeout(timer);
    timer = undefined;
    controller?.abort();
  }

  function synchronize(ctx: ExtensionContext, name: string | undefined, explicit: boolean) {
    stop();
    if (ctx.mode !== "tui") return Promise.resolve();
    const file = ctx.sessionManager.getSessionFile();
    if (!file) return Promise.resolve();
    const version = revision;
    const abort = controller = new AbortController();
    let startupRetries = 0;
    const current = () => {
      try { return revision === version && ctx.sessionManager.getSessionFile() === file; }
      catch { return false; } // Session replacement invalidates the old context.
    };
    const warn = (message: string) => {
      if (message !== lastWarning) ctx.ui.notify(message, "warning");
      lastWarning = message;
    };
    async function herdr(...args: string[]) {
      if (!current()) throw new Error("Session changed");
      const r = await pi.exec("herdr", args, { timeout: 3000, signal: abort.signal });
      if (!current()) throw new Error("Session changed");
      const operation = args.slice(0, 2).join(" ");
      if (r.code !== 0 || r.killed) throw new Error(`Herdr ${operation} failed`);
      // Herdr report commands succeed silently. Identity is verified on the next readback.
      if (operation === "pane report-agent-session") return;
      let body;
      try { body = JSON.parse(r.stdout); }
      catch {
        throw new Error(`Herdr ${operation} returned invalid JSON (exit 0; stdout ${Buffer.byteLength(r.stdout)} bytes, stderr ${Buffer.byteLength(r.stderr || "")} bytes)`);
      }
      if (body.error || !body.result) throw new Error(`Herdr ${operation} rejected the request`);
      return body.result;
    }
    async function reconcile() {
      if (!current()) return;
      let completed = false;
      let changedAgent = false;
      let retrySoon = false;
      try {
        // Two read-only queries per 30s; resolve moved panes, never UI focus.
        const { pane } = await herdr("pane", "current", "--current");
        const { snapshot } = await herdr("api", "snapshot");
        const self = snapshot.agents.find((a: any) => a.pane_id === pane.pane_id);
        if (!self || self.agent !== "omp" || self.tab_id !== pane.tab_id) { retrySoon = true; return; }
        async function ownsForeground() {
          const { process_info: info } = await herdr("pane", "process-info", "--current");
          return info.pane_id === pane.pane_id && info.foreground_processes.some((p: any) => p.pid === process.pid);
        }
        if (!self.agent_session) {
          // A live reconnect can erase registration while an idle OMP emits no events.
          // Repair only when this exact process owns the foreground, never inherited children.
          if (!await ownsForeground()) return;
          await herdr("pane", "report-agent-session", pane.pane_id,
            "--source", "herdr:omp:name-sync", "--agent", "omp", "--agent-session-path", file);
          retrySoon = true;
          return; // Re-read and verify exact session identity before any rename.
        }
        if (self.agent_session.kind !== "path" || self.agent_session.value !== file) {
          retrySoon = true; // Native registration may still be catching up to /resume.
          if (explicit) warn("OMP name saved; Herdr session identity differs. Naming deferred.");
          return;
        }
        const layout = snapshot.layouts.find((l: any) => l.tab_id === self.tab_id);
        const tab = snapshot.tabs.find((t: any) => t.tab_id === self.tab_id);
        if (!layout || !tab) { retrySoon = true; return; }
        const owner = layout.panes.find((p: any) => snapshot.agents.some((a: any) =>
          a.tab_id === self.tab_id && a.pane_id === p.pane_id));
        let alias = name?.normalize("NFKD").replace(/\p{M}/gu, "").toLowerCase()
          .replace(/[^a-z0-9_-]+/g, "-").replace(/^-+|-+$/g, "");
        if (name) {
          alias = alias || "omp";
          if (!/^[a-z]/.test(alias)) alias = `omp-${alias}`;
          alias = alias.slice(0, 32);
          if (snapshot.agents.some((a: any) => a.name === alias && a.pane_id !== self.pane_id)) {
            warn(`OMP name saved; Herdr alias '${alias}' is occupied. Choose another /rename.`);
            return;
          }
        }
        const renameAgent = (self.name || undefined) !== alias;
        const renameTab = owner?.pane_id === self.pane_id && tab.label !== (name || "omp");
        if ((renameAgent || renameTab) && !await ownsForeground()) {
          if (explicit) warn("OMP name saved; this process does not own the Herdr foreground. Naming deferred.");
          return;
        }
        // Server-side uniqueness also prevents stealing a concurrently claimed alias.
        if (renameAgent) {
          await herdr("agent", "rename", self.pane_id, name ? alias! : "--clear");
          changedAgent = true;
        }
        if (renameTab) {
          await herdr("tab", "rename", self.tab_id, name || "omp");
        }
        completed = true;
        lastWarning = "";
      } catch (error) {
        if (current() && (explicit || changedAgent)) {
          warn(`OMP name saved; ${changedAgent ? "agent renamed, tab sync failed" : "Herdr sync unavailable"}: ${error instanceof Error ? error.message : "unknown error"}. Will retry.`);
        }
      } finally {
        // No overlapping polls or accumulated jobs. Cleared names stop once applied.
        if (current() && (name || !completed)) {
          const delay = retrySoon && startupRetries++ < 2 ? 1000 : 30000;
          timer = setTimeout(() => { queue = queue.then(reconcile); }, delay);
          timer.unref?.();
        }
      }
    }
    queue = queue.then(reconcile);
    return queue;
  }

  let observedName: string | undefined;
  let nameTimer: ReturnType<typeof setInterval> | undefined;

  function observe(ctx: ExtensionContext, explicit: boolean, force = false) {
    const name = pi.getSessionName()?.trim() || undefined;
    if (!force && name === observedName) return;
    observedName = name;
    void synchronize(ctx, name, explicit);
  }

  function startObserving(ctx: ExtensionContext) {
    if (nameTimer) clearInterval(nameTimer);
    observe(ctx, false, true);
    nameTimer = setInterval(() => observe(ctx, true), 1000);
    nameTimer.unref?.();
  }

  pi.on("session_start", (_event, ctx) => startObserving(ctx));
  pi.on("session_switch", (_event, ctx) => startObserving(ctx));
  pi.on("session_shutdown", () => {
    stop();
    if (nameTimer) clearInterval(nameTimer);
    nameTimer = undefined;
  });
}
