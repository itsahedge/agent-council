# Agent Council

**Lifecycle management for OpenClaw agents.**

OpenClaw has built-in multi-agent support — routing, workspaces, bindings. But creating and managing agents requires manual config editing, careful array merging, and multiple setup steps.

Agent Council wraps all of that into simple commands.

## What OpenClaw Provides

- **Agent routing** — Messages go to the right agent based on bindings
- **Workspace loading** — Agent's files (SOUL.md, etc.) loaded into context
- **Cron jobs** — Schedule tasks to specific agents
- **Config-driven** — Everything lives in `openclaw.json`

## What Agent Council Adds

| Without Agent Council | With Agent Council |
|-----------------------|-------------------|
| `mkdir` + write SOUL.md + HEARTBEAT.md | One `--create` command |
| Manually edit `agents.list` JSON | Automatic, safe merge |
| Manually edit `bindings` array (easy to wipe) | Automatic, prepends correctly |
| Manually add to Discord allowlist | Automatic |
| Manually create Discord channel | `--create "channel-name"` |
| Manually add memory cron | **Default** — every agent gets daily memory |
| Multi-step cleanup to remove agent | `remove-agent.sh --delete-workspace --delete-channel` |

**The big one:** Agent Council makes **daily memory the default**. Every agent persists context about their work, learning from themselves over time.

## Quick Start

```bash
# Install
git clone https://github.com/itsahedge/agent-council.git ~/.openclaw/skills/agent-council
openclaw gateway config.patch --raw '{"skills":{"entries":{"agent-council":{"enabled":true}}}}'

# Create agent with Discord channel + daily memory (all automatic)
~/.openclaw/skills/agent-council/scripts/create-agent.sh \
  --id watson \
  --name "Watson" \
  --emoji "🔬" \
  --specialty "Deep research" \
  --create "research" \
  --category "1467393991266799698"
```

This creates:
- `~/clawd/agents/watson/` with SOUL.md, HEARTBEAT.md, memory/
- Discord #research channel with topic
- Binding: watson → #research
- Allowlist entry for #research
- Daily memory cron at 23:00 ET

## Scripts

| Script | Purpose |
|--------|---------|
| `create-agent.sh` | Full agent setup (workspace, Discord, binding, cron) |
| `bind-channel.sh` | Bind agent to additional channels |
| `list-agents.sh` | Show all agents and their Discord bindings |
| `remove-agent.sh` | Clean removal (config, crons, workspace, channel) |

## Key Features

### Safe Config Patching
OpenClaw's `config.patch` replaces arrays, it doesn't merge them. Agent Council:
- Fetches current config first
- Merges new entries with existing
- Validates before patching
- Aborts if config fetch fails (prevents accidental wipes)

### Binding Priority
New bindings are **prepended** (not appended), so specific channel bindings take priority over catch-all rules.

### Daily Memory by Default
Every agent gets a nightly cron that triggers memory consolidation. Agents learn from their work and build rich context over time. Use `--no-cron` to opt out.

## Documentation

See [SKILL.md](./SKILL.md) for full options, examples, and manual setup instructions.

## License

MIT
