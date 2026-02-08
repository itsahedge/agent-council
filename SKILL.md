---
name: agent-council
description: Create autonomous AI agents with Discord bindings. Use when setting up new agents.
---

# Agent Council

Create and manage autonomous AI agents with full Discord integration.

## What It Does

1. **Creates agent workspace** (SOUL.md, HEARTBEAT.md, memory/)
2. **Creates Discord channel** (optional) with topic
3. **Binds agent to channel** (routing)
4. **Adds to allowlist** (permissions)
5. **Sets up cron jobs** (optional daily memory)

## Scripts

| Script | Purpose |
|--------|---------|
| `create-agent.sh` | Full agent setup with Discord integration |
| `bind-channel.sh` | Bind existing agent to additional channel |
| `list-agents.sh` | Show all agents and their Discord bindings |
| `remove-agent.sh` | Remove agent (config, crons, optionally workspace/channel) |

## Usage

### Create Agent with New Discord Channel

```bash
~/.openclaw/skills/agent-council/scripts/create-agent.sh \
  --id watson \
  --name "Watson" \
  --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --create "research" \
  --category "1467393991266799698" \
  --cron "23:00"
```

This will:
- Create `~/clawd/agents/watson/` with SOUL.md, HEARTBEAT.md
- Create Discord #research channel in the agents category
- Set channel topic: "Watson 🔬 — Deep research and competitive analysis"
- Bind watson agent to #research
- Add #research to allowlist
- Create daily memory cron at 11:00 PM

### Create Agent with Existing Channel

```bash
./create-agent.sh \
  --id sage \
  --name "Sage" \
  --emoji "💰" \
  --specialty "Personal finance" \
  --channel "1466184336901537897"
```

### Bind Agent to Additional Channel

```bash
./bind-channel.sh --agent forge --channel "1468805229196869747"
./bind-channel.sh --agent forge --create "defi" --category "1466653402019659839"
```

### List Current Setup

```bash
./list-agents.sh
```

Output:
```
═══════════════════════════════════════════════════════════
  Agent Council - Current Roster
═══════════════════════════════════════════════════════════

  🌙 Claire (claire) — anthropic/claude-opus-4-5
  👔 Chief (chief) — anthropic/claude-opus-4-5
  ⚒️ Forge (forge) — anthropic/claude-opus-4-5
  ...

───────────────────────────────────────────────────────────
  Discord Bindings
───────────────────────────────────────────────────────────

  chief → #1465857663702138981
  forge → #1465929800144126179
  ...

  Default (fallback): claire
```

### Remove Agent

```bash
# Remove from config only (keeps workspace)
./remove-agent.sh --id test-agent

# Full removal
./remove-agent.sh --id test-agent --delete-workspace --delete-channel
```

## Options Reference

### create-agent.sh

| Option | Required | Description |
|--------|----------|-------------|
| `--id` | ✓ | Agent ID (lowercase, no spaces) |
| `--name` | ✓ | Display name |
| `--emoji` | ✓ | Agent emoji |
| `--specialty` | ✓ | What the agent does |
| `--model` | | Model (default: claude-sonnet-4-5) |
| `--channel` | | Existing Discord channel ID |
| `--create` | | Create new channel with this name |
| `--category` | | Category ID for new channel |
| `--topic` | | Channel topic (auto-generated if not set) |
| `--cron` | | Daily memory cron time (e.g., "23:00") |
| `--tz` | | Timezone (default: America/New_York) |

## Architecture

```
Gateway receives message
       │
       ▼
Check bindings (first match wins)
       │
       ├─── match: route to bound agent
       │
       └─── no match: route to default agent
```

Bindings are **prepended** (not appended) so new specific bindings take priority over catch-all rules.

## Manual Setup

If you prefer manual setup:

```bash
# 1. Create workspace
mkdir -p ~/clawd/agents/myagent/memory
# Write SOUL.md and HEARTBEAT.md

# 2. Add to config
openclaw gateway config.patch --raw '{
  "agents": { "list": [..., {"id": "myagent", ...}] },
  "bindings": [{"agentId": "myagent", "match": {...}}, ...existing...],
  "discord": { "channels": { "CHANNEL_ID": { "allow": true } } }
}'
```

## Discord Category IDs (Don's Server)

| Category | ID |
|----------|-----|
| Claire | 1465837398989471801 |
| Agents | 1467393991266799698 |
| Crypto | 1466653402019659839 |
| Oku Money | 1467393835830214840 |
| Perpetual Stack | 1467393038371520615 |
| Main | 1467391773142941940 |
