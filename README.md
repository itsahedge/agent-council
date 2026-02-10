# Agent Council

**Discord-integrated agent management for OpenClaw.**

OpenClaw has built-in multi-agent support — routing, workspaces, bindings. But spinning up a Discord-connected agent requires manual config editing, channel creation, allowlist management, and careful array merging.

Agent Council handles the full Discord integration: create the channel, bind the agent, configure permissions, and set up daily memory — all in one command.

## What OpenClaw Provides

- **Agent routing** — Messages go to the right agent based on bindings
- **Workspace loading** — Agent's files (SOUL.md, etc.) loaded into context
- **Cron jobs** — Schedule tasks to specific agents
- **Config-driven** — Everything lives in `openclaw.json`

## What Agent Council Adds

### Discord Integration (Primary Focus)

| Manual Setup | With Agent Council |
|--------------|-------------------|
| Create Discord channel via API | `--create "channel-name"` |
| Set channel topic | Auto-generated from agent specialty |
| Add to `discord.channels` allowlist | Automatic |
| Edit `bindings` array (easy to wipe) | Safe merge, prepends correctly |
| Place in category | `--category "id"` |

### Agent Lifecycle

| Manual Setup | With Agent Council |
|--------------|-------------------|
| `mkdir` + write SOUL.md + HEARTBEAT.md | One command |
| Manually edit `agents.list` JSON | Automatic, safe merge |
| Manually add memory cron | **Default** — every agent gets daily memory |
| Multi-step cleanup | `remove-agent.sh --delete-workspace --delete-channel` |

**The key value:** One command creates a Discord channel, binds an agent to it, configures permissions, and sets up persistent daily memory.

## Quick Start

```bash
# Install
git clone https://github.com/itsahedge/agent-council.git ~/.openclaw/skills/agent-council
openclaw gateway config.patch --raw '{"skills":{"entries":{"agent-council":{"enabled":true}}}}'

# Set your Discord server ID
export DISCORD_GUILD_ID="123456789012345678"

# Create agent with Discord channel + daily memory (all automatic)
~/.openclaw/skills/agent-council/scripts/create-agent.sh \
  --id watson \
  --name "Watson" \
  --emoji "🔬" \
  --specialty "Deep research" \
  --create "research" \
  --category "987654321098765432"
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
| `claim-category.sh` | Claim a Discord category for an agent |
| `sync-category.sh` | Bind all channels in a category to its owner |
| `list-categories.sh` | Show category ownership |

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

### Category Ownership
Agents can own Discord categories. When you create new channels in an owned category, run `sync-category.sh` to auto-bind them:

```bash
# Claim a category for an agent
./claim-category.sh --agent chief --category 123456789012345678 --sync

# Later, after adding channels in Discord:
./sync-category.sh --category 123456789012345678

# See all owned categories
./list-categories.sh
```

Or claim during agent creation:
```bash
./create-agent.sh --id chief --name Chief --emoji 👔 \
  --specialty Leadership --own-category 123456789012345678
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DISCORD_GUILD_ID` | For `--create` | Your Discord server ID |
| `AGENT_WORKSPACE_ROOT` | No | Agent workspace root (default: `~/clawd/agents`) |

## Documentation

See [SKILL.md](./SKILL.md) for full options, examples, and manual setup instructions.

## License

MIT
