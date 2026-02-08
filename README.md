# Agent Council

Create and manage autonomous AI agents with full Discord integration for [OpenClaw](https://openclaw.ai).

## Features

- **One-command agent setup** with workspace, Discord channel, binding, and cron
- **Discord channel creation** with auto-topic and category placement
- **Proper binding order** (prepends, so specific bindings win over catch-alls)
- **Allowlist management** (auto-adds new channels)
- **Daily memory cron** (optional, for agent continuity)

## Installation

```bash
git clone https://github.com/itsahedge/agent-council.git ~/.openclaw/skills/agent-council
openclaw gateway config.patch --raw '{"skills":{"entries":{"agent-council":{"enabled":true}}}}'
```

## Quick Start

```bash
# Create agent with new Discord channel
~/.openclaw/skills/agent-council/scripts/create-agent.sh \
  --id watson \
  --name "Watson" \
  --emoji "🔬" \
  --specialty "Deep research" \
  --create "research" \
  --cron "23:00"

# List all agents
~/.openclaw/skills/agent-council/scripts/list-agents.sh

# Bind agent to additional channel
~/.openclaw/skills/agent-council/scripts/bind-channel.sh \
  --agent watson \
  --create "analysis"

# Remove agent
~/.openclaw/skills/agent-council/scripts/remove-agent.sh \
  --id watson \
  --delete-workspace \
  --delete-channel
```

## Scripts

| Script | Purpose |
|--------|---------|
| `create-agent.sh` | Full agent setup with Discord integration |
| `bind-channel.sh` | Bind existing agent to additional channel |
| `list-agents.sh` | Show all agents and their Discord bindings |
| `remove-agent.sh` | Remove agent from config (optionally delete workspace/channel) |

## Documentation

See [SKILL.md](./SKILL.md) for full options and examples.

## License

MIT
