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
| `claim-category.sh` | Claim a Discord category for an agent |
| `sync-category.sh` | Sync all channels in a category to its owner |
| `list-categories.sh` | Show category ownership

## Usage

### Create Agent with New Discord Channel

```bash
export DISCORD_GUILD_ID="123456789012345678"  # Your server ID

~/.openclaw/skills/agent-council/scripts/create-agent.sh \
  --id watson \
  --name "Watson" \
  --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --create "research" \
  --category "987654321098765432"
```

This will:
- Create `~/clawd/agents/watson/` with SOUL.md, HEARTBEAT.md
- Create Discord #research channel in the specified category
- Set channel topic: "Watson 🔬 — Deep research and competitive analysis"
- Bind watson agent to #research
- Add #research to allowlist
- **Create daily memory cron at 11:00 PM** (default, use `--no-cron` to skip)

### Create Agent with Existing Channel

```bash
./create-agent.sh \
  --id sage \
  --name "Sage" \
  --emoji "💰" \
  --specialty "Personal finance" \
  --channel "234567890123456789"
```

### Bind Agent to Additional Channel

```bash
./bind-channel.sh --agent forge --channel "345678901234567890"
./bind-channel.sh --agent forge --create "defi" --category "456789012345678901"
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

  🤖 Main (main) — anthropic/claude-opus-4-5
  👔 Chief (chief) — anthropic/claude-opus-4-5
  ⚒️ Forge (forge) — anthropic/claude-opus-4-5
  ...

───────────────────────────────────────────────────────────
  Discord Bindings
───────────────────────────────────────────────────────────

  chief → #123456789012345678
  forge → #234567890123456789
  ...

  Default (fallback): main
```

### Remove Agent

```bash
# Remove from config only (keeps workspace)
./remove-agent.sh --id test-agent

# Full removal
./remove-agent.sh --id test-agent --delete-workspace --delete-channel
```

### Category Ownership

Agents can own Discord categories. Channels in owned categories can be auto-bound.

```bash
# Claim a category for an agent
./claim-category.sh --agent chief --category 123456789012345678

# Claim and immediately sync all existing channels
./claim-category.sh --agent chief --category 123456789012345678 --sync

# List category ownership
./list-categories.sh

# Sync channels in a category to the owner (re-run after adding new channels)
./sync-category.sh --category 123456789012345678

# Dry run (preview what would be bound)
./sync-category.sh --category 123456789012345678 --dry-run
```

You can also claim a category during agent creation:

```bash
./create-agent.sh \
  --id chief \
  --name "Chief" \
  --emoji "👔" \
  --specialty "Leadership and strategy" \
  --own-category "123456789012345678"
```

This claims the category AND binds all existing channels in it to the agent.

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
| `--cron` | | Daily memory cron time (default: 23:00) |
| `--no-cron` | | Skip daily memory cron setup |
| `--tz` | | Timezone (default: America/New_York) |
| `--own-category` | | Claim a Discord category (auto-binds all channels) |

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

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DISCORD_GUILD_ID` | For `--create` | Your Discord server ID |
| `AGENT_WORKSPACE_ROOT` | No | Agent workspace root (default: `~/clawd/agents`) |

## qmd Integration (Optional)

If [qmd](https://github.com/tobi/qmd) is installed, agent-council automatically updates the index:
- **Create:** Runs `qmd update` so new agent memory is immediately searchable
- **Remove:** Runs `qmd update` to clean up removed agent files

**Note:** qmd is optional. If not installed, these steps are skipped silently.

When enabled, two-way search works:
```bash
# Main agent searches agent memory
qmd search "topic" -c agents

# Agents search brain  
qmd search "topic" -c brain
```

Set up the agents collection: `qmd collection add ~/clawd/agents/ --name agents --mask "**/*.md"`

## Finding Discord IDs

To get category/channel IDs:
1. Enable Developer Mode in Discord (User Settings → App Settings → Advanced)
2. Right-click any channel or category → "Copy ID"

Or use: `openclaw message channel-list --guildId YOUR_SERVER_ID`
