---
name: agent-council
description: Complete toolkit for creating autonomous AI agents and managing Discord channels for OpenClaw. Use when setting up multi-agent systems, creating new agents, or managing Discord channel organization.
---

# Agent Council

Complete toolkit for creating and managing autonomous AI agents with Discord integration for OpenClaw.

## What This Skill Does

**Agent Creation:**
- Creates autonomous AI agents with self-contained workspaces
- Generates SOUL.md (personality) and HEARTBEAT.md (cron logic)
- Sets up memory system and gateway config automatically
- Binds agents to Discord channels (optional)
- Sets up daily memory cron jobs (optional)

**Discord Channel Management:**
- Creates/renames Discord channels via API
- Configures OpenClaw gateway allowlists
- Sets channel-specific system prompts

## Installation

```bash
# Install from ClawHub
clawhub install agent-council

# Or manual install
cp -r . ~/.openclaw/skills/agent-council/
openclaw gateway config.patch --raw '{
  "skills": { "entries": { "agent-council": {"enabled": true} } }
}'
```

## Quick Start

### Conversational (Discord/Chat) — Recommended

```bash
./scripts/conversational-agent-helper.sh --start
```

Creates agents through 6 simple questions:
1. Name → 2. Specialty → 3. Style → 4. Model → 5. Discord → 6. Memory cron

### Programmatic (Scripts/Automation)

```bash
scripts/create-agent.sh \
  --name "Watson" --id "watson" --emoji "🔬" \
  --specialty "Research and analysis" \
  --model "anthropic/claude-sonnet-4-5" \
  --workspace "$HOME/clawd/agents/watson" \
  --discord-channel "1234567890" \
  --setup-cron yes --cron-time "23:00" --cron-tz "America/New_York"
```

### Interactive Wizard (Terminal)

```bash
scripts/create-agent-interactive.sh
```

## Documentation

| Doc | Description |
|-----|-------------|
| [WORKFLOWS.md](./docs/WORKFLOWS.md) | Detailed workflow options (conversational, wizard, programmatic) |
| [COORDINATION.md](./docs/COORDINATION.md) | Multi-agent coordination patterns |
| [DISCORD.md](./docs/DISCORD.md) | Discord channel management |
| [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) | Common issues and fixes |

## Agent Architecture

```
agents/
├── watson/
│   ├── SOUL.md              # Personality and responsibilities
│   ├── HEARTBEAT.md         # Cron execution logic
│   └── memory/              # Agent-specific memory
│       └── YYYY-MM-DD.md    # Daily logs
```

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `conversational-agent-helper.sh` | Chat-based agent creation |
| `create-agent-interactive.sh` | Terminal wizard |
| `create-agent.sh` | Programmatic creation |
| `setup_channel.py` | Create Discord channels |
| `rename_channel.py` | Rename Discord channels |

## Requirements

- OpenClaw installed and configured
- Node.js/npm via nvm
- Python 3.6+ (standard library only)
- Discord bot token (for channel management)

## See Also

- OpenClaw docs: https://docs.openclaw.ai
- Multi-agent patterns: https://docs.openclaw.ai/agents
