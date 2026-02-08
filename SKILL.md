---
name: agent-council
description: Create autonomous AI agents with Discord bindings. Use when setting up new agents.
---

# Agent Council

Minimal toolkit for creating autonomous agents in OpenClaw.

## Quick Start

```bash
~/.openclaw/skills/agent-council/scripts/create-agent.sh <id> <name> <emoji> <specialty> [model] [discord-channel-id]
```

**Example:**
```bash
./create-agent.sh watson Watson 🔬 "Deep research and analysis" anthropic/claude-opus-4-5 1468311503156281477
```

## What It Does

1. Creates `~/clawd/agents/<id>/` with SOUL.md, HEARTBEAT.md, memory/
2. Adds agent to gateway config (`agents.list`)
3. Optionally binds to a Discord channel

## Manual Alternative

You can also create agents manually:

```bash
# 1. Create workspace
mkdir -p ~/clawd/agents/<id>/memory

# 2. Write SOUL.md and HEARTBEAT.md (see templates below)

# 3. Patch gateway config
openclaw gateway config.patch --raw '{
  "agents": {
    "list": [...existing agents..., {
      "id": "<id>",
      "name": "<Name>",
      "workspace": "/path/to/workspace",
      "model": {"primary": "anthropic/claude-sonnet-4-5"},
      "identity": {"name": "<Name>", "emoji": "🔬"}
    }]
  }
}'
```

## Templates

### SOUL.md
```markdown
# SOUL.md - Name 🔬

## Identity
- **Name:** Name
- **Emoji:** 🔬
- **Role:** What this agent does

## Personality
Be helpful, concise, and proactive. Own your domain.

## Guidelines
- Read memory at session start
- Write to memory as you work
- Reply `HEARTBEAT_OK` when nothing needs attention
```

### HEARTBEAT.md
```markdown
# HEARTBEAT.md

Handle scheduled cron jobs and system events only.
If nothing needs attention, reply `HEARTBEAT_OK`.
```

## Adding Cron Jobs

After creating an agent, add cron jobs separately:

```bash
openclaw cron add \
  --name "Daily Memory Update" \
  --cron "0 23 * * *" \
  --tz "America/New_York" \
  --session main \
  --agent <id> \
  --system-event "Review today's activity and update memory."
```

## Deleting Agents

1. Remove from gateway config (patch with updated agents.list)
2. Remove any bindings referencing the agent
3. Remove cron jobs: `openclaw cron list` → `openclaw cron remove --id <job-id>`
4. Optionally delete workspace: `rm -rf ~/clawd/agents/<id>`
