---
name: zenith
description: Run a long-running coding or research mission through the Zenith MCP/ACP orchestration harness.
---

First read .claude/orchestrator_prompt.md and treat it as your primary role, then use Zenith to run this mission.

Treat the text after `/zenith` as the mission brief. Use the Zenith MCP tools for
the mission lifecycle and continue until the request is complete or Zenith makes
an explicit terminal decision. Do not substitute a single implementation pass
for the orchestrator workflow.

Zenith is a continuous-improvement harness for long-running work. It maintains
durable project state and can adapt its plan, worker roles, validator roles,
reusable skills, validation layers, and stopping decision as evidence changes.
Workers execute bounded tasks; validators independently check their claims; the
orchestrator integrates the evidence and decides whether to continue, replan, or
stop. Use it when the mission spans multiple files, milestones, environments,
uncertain requirements, or needs repeated verification. For a small, isolated
edit, use the normal coding workflow unless the user explicitly requests Zenith.

Runtime:

- This workspace is initialized for Claude through `.mcp.json`. The host should
  start the `zenith` stdio MCP server on demand.
- If the MCP server is unavailable, verify the installation from the Zenith
  checkout with `uv run zenith --help` and initialize the current workspace with
  `uv run zenith init --workspace-dir <workspace> --agent claude`.
- The underlying server can be started from the Zenith checkout with
  `uv run zenith-server --mode orchestrator`. Keep that stdio process attached
  to its MCP client; do not start a second copy when `.mcp.json` is already
  connected.
- Zenith workers require the relevant ACP adapter. For Claude, verify
  `command -v claude-agent-acp`; install it with
  `npm install -g @agentclientprotocol/claude-agent-acp` when missing.

Before closure, review the original brief, task state, validator evidence, open
issues, and required tests. Report any unresolved risk instead of claiming
completion by worker self-report alone.
