#!/bin/bash
set -e

# Agent Council - Create agent with full Discord integration
# Usage: ./create-agent.sh [options]
#
# Options:
#   --id           Agent ID (required)
#   --name         Display name (required)
#   --emoji        Agent emoji (required)
#   --specialty    What the agent does (required)
#   --model        Model to use (default: anthropic/claude-sonnet-4-5)
#   --channel      Existing Discord channel ID to bind
#   --create       Create new Discord channel with this name
#   --category     Discord category ID for new channel
#   --topic        Channel topic (auto-generated if not specified)
#   --cron         Set up daily memory cron at this time (e.g., "23:00")
#   --tz           Timezone for cron (default: America/New_York)

# Defaults
MODEL="anthropic/claude-sonnet-4-6"
TZ="America/New_York"
GUILD_ID="${DISCORD_GUILD_ID:-}"
CRON_TIME="23:00"  # Default: daily memory at 11 PM
SKIP_CRON=false
SKILL_DIR="$(dirname "$0")/.."
WORKSPACE_ROOT="${AGENT_WORKSPACE_ROOT:-$HOME/clawd/agents}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --id) ID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --emoji) EMOJI="$2"; shift 2 ;;
    --specialty) SPECIALTY="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --channel) CHANNEL_ID="$2"; shift 2 ;;
    --create) CREATE_CHANNEL="$2"; shift 2 ;;
    --category) CATEGORY_ID="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --cron) CRON_TIME="$2"; shift 2 ;;
    --no-cron) SKIP_CRON=true; shift ;;
    --tz) TZ="$2"; shift 2 ;;
    --own-category) OWN_CATEGORY="$2"; shift 2 ;;
    --guild-id) GUILD_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate required args
if [[ -z "$ID" ]] || [[ -z "$NAME" ]] || [[ -z "$EMOJI" ]] || [[ -z "$SPECIALTY" ]]; then
  echo "Usage: $0 --id <id> --name <name> --emoji <emoji> --specialty <description>"
  echo ""
  echo "Required:"
  echo "  --id           Agent ID (lowercase, no spaces)"
  echo "  --name         Display name"
  echo "  --emoji        Agent emoji"
  echo "  --specialty    What the agent does"
  echo ""
  echo "Discord (pick one):"
  echo "  --channel      Bind to existing channel ID"
  echo "  --create       Create new channel with this name"
  echo "  --category     Category ID for new channel (optional)"
  echo "  --topic        Channel topic (auto-generated if not set)"
  echo ""
  echo "Optional:"
  echo "  --model        Model (default: claude-sonnet-4-6)"
  echo "  --cron         Daily memory cron time (default: 23:00)"
  echo "  --no-cron      Skip daily memory cron setup"
  echo "  --tz           Timezone (default: America/New_York)"
  echo "  --own-category Claim a category (auto-bind all channels in it)"
  echo "  --guild-id     Discord server ID (or set DISCORD_GUILD_ID env var)"
  echo ""
  echo "Environment:"
  echo "  DISCORD_GUILD_ID      Discord server ID (required for --create)"
  echo "  AGENT_WORKSPACE_ROOT  Agent workspace root (default: ~/clawd/agents)"
  echo ""
  echo "Examples:"
  echo "  $0 --id watson --name Watson --emoji 🔬 --specialty 'Deep research' --create research"
  echo "  $0 --id sage --name Sage --emoji 💰 --specialty 'Finance' --channel 1234567890"
  exit 1
fi

WORKSPACE="$WORKSPACE_ROOT/$ID"

echo "═══════════════════════════════════════════════════════════"
echo "  Agent Council - Creating $NAME $EMOJI"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Create workspace
# ─────────────────────────────────────────────────────────────
echo "📁 Creating workspace..."
mkdir -p "$WORKSPACE/memory"

cat > "$WORKSPACE/SOUL.md" << EOF
# SOUL.md - $NAME $EMOJI

## Identity
- **Name:** $NAME
- **Emoji:** $EMOJI
- **Role:** $SPECIALTY

## Personality
Be helpful, concise, and proactive. You're a specialist — own your domain.

## Guidelines
- Read your memory at session start (\`memory/YYYY-MM-DD.md\` — today + yesterday)
- Write to memory as you work (see below)
- Stay in your lane unless asked to cross domains
- When nothing needs attention, reply \`HEARTBEAT_OK\`

## Memory - Write As You Go!

**Don't wait for end-of-day.** Write to \`memory/YYYY-MM-DD.md\` DURING the session when:
- A significant decision is made
- You learn something new or important
- A task is completed (especially complex ones)
- Context that future-you would need
- You receive information worth remembering

**Pattern:**
\`\`\`markdown
## [HH:MM] Topic
Brief note about what happened, what was decided, or what was learned.
\`\`\`

**Examples:**
- \`## [10:30] Task Completed\` — Finished the research on X, found Y
- \`## [14:00] Decision Made\` — Chose approach A over B because...
- \`## [16:15] Learned\` — Discovered that Z works better when...

The nightly memory cron is for **consolidation**, not primary writing. Capture important moments as they happen.

---
*Customize this as your role evolves.*
EOF

cat > "$WORKSPACE/HEARTBEAT.md" << EOF
# HEARTBEAT.md - $NAME $EMOJI

Handle scheduled cron jobs and system events only.

If there are system events (cron jobs), handle them.
Otherwise, reply \`HEARTBEAT_OK\`.
EOF

cat > "$WORKSPACE/AGENTS.md" << 'AGENTSEOF'
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

Don't ask permission. Just do it.

## Use qmd for Recall

**Before answering from memory, SEARCH FIRST:**
```bash
qmd query "what did we decide about X?" --limit 3  # LLM-reranked (best)
qmd search "topic" -c memory                        # Fast keyword search
qmd vsearch "concept"                                # Semantic vector search
```

qmd indexes your memory files, brain docs, and shared workspace. Use it instead of guessing.

**After significant work:** Run `qmd update` to re-index.

## Memory

Write to `memory/YYYY-MM-DD.md` AS YOU WORK — don't wait for end of day.
- One file per date, always. No suffixes.
- `MEMORY.md` = long-term curated memory (main session only)
- **Text > Brain** — if you want to remember it, write it down.

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking. `trash` > `rm`.

## External vs Internal

**Safe to do freely:** Read files, explore, search web, work within workspace.
**Ask first:** Emails, tweets, public posts, anything that leaves the machine.

## Make It Yours

This is a starting point. Add your own conventions, style, and rules as you figure out what works.
AGENTSEOF

echo "   ✓ Created SOUL.md, HEARTBEAT.md, AGENTS.md, memory/"

# ─────────────────────────────────────────────────────────────
# 2. Discord channel (create or use existing)
# ─────────────────────────────────────────────────────────────
if [[ -n "$CREATE_CHANNEL" ]]; then
  if [[ -z "$GUILD_ID" ]]; then
    echo "   ✗ DISCORD_GUILD_ID not set. Use --guild-id or set the environment variable."
    exit 1
  fi
  echo ""
  echo "📺 Creating Discord channel #$CREATE_CHANNEL..."
  
  TOPIC="${TOPIC:-$NAME $EMOJI — $SPECIALTY}"
  
  # Get Discord bot token from config
  DISCORD_TOKEN=$(cat ~/.openclaw/openclaw.json | jq -r '.channels.discord.token // empty')
  if [[ -z "$DISCORD_TOKEN" ]]; then
    echo "   ✗ Discord bot token not found in config"
    exit 1
  fi
  
  # Build request body
  BODY=$(jq -n \
    --arg name "$CREATE_CHANNEL" \
    --arg topic "$TOPIC" \
    --arg parentId "${CATEGORY_ID:-}" \
    '{name: $name, topic: $topic, type: 0} |
     if $parentId != "" then . + {parent_id: $parentId} else . end')
  
  # Create channel via Discord REST API
  RESULT=$(curl -s -X POST \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels" \
    -H "Authorization: Bot $DISCORD_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$BODY")
  
  CHANNEL_ID=$(echo "$RESULT" | jq -r '.id // empty')
  
  if [[ -z "$CHANNEL_ID" ]]; then
    echo "   ✗ Failed to create channel"
    echo "$RESULT" | jq . 2>/dev/null || echo "$RESULT"
    exit 1
  fi
  
  echo "   ✓ Created channel: $CHANNEL_ID"
fi

# ─────────────────────────────────────────────────────────────
# 2b. Copy auth profiles from default agent
# ─────────────────────────────────────────────────────────────
OPENCLAW_DIR="$HOME/.openclaw"
AGENT_AUTH_DIR="$OPENCLAW_DIR/agents/$ID/agent"
mkdir -p "$AGENT_AUTH_DIR"

# Find default agent's auth-profiles.json to copy
DEFAULT_AGENT_ID=$(cat "$OPENCLAW_DIR/openclaw.json" 2>/dev/null | jq -r '.agents.list[] | select(.default == true) | .id' | head -1)
DEFAULT_AUTH="$OPENCLAW_DIR/agents/${DEFAULT_AGENT_ID:-claire}/agent/auth-profiles.json"

if [[ -f "$DEFAULT_AUTH" ]]; then
  cp "$DEFAULT_AUTH" "$AGENT_AUTH_DIR/auth-profiles.json"
  echo "   ✓ Auth profiles copied from $DEFAULT_AGENT_ID"
elif [[ -f "$OPENCLAW_DIR/agents/main/agent/auth-profiles.json" ]]; then
  cp "$OPENCLAW_DIR/agents/main/agent/auth-profiles.json" "$AGENT_AUTH_DIR/auth-profiles.json"
  echo "   ✓ Auth profiles copied from main"
else
  echo "   ⚠ No auth-profiles.json found to copy — agent may fail to authenticate"
fi

# ─────────────────────────────────────────────────────────────
# 3. Gateway config (agent + binding + allowlist)
# ─────────────────────────────────────────────────────────────
echo ""
echo "⚙️  Updating gateway config..."

# Get current config
CONFIG=$(openclaw gateway call config.get --json)

# SAFETY: Validate we got real config (prevent accidental wipes)
if ! echo "$CONFIG" | jq -e '.parsed' >/dev/null 2>&1; then
  echo "   ✗ Failed to get current config. Aborting to prevent data loss."
  exit 1
fi

CURRENT_AGENTS=$(echo "$CONFIG" | jq -c '.parsed.agents.list // []')
CURRENT_BINDINGS=$(echo "$CONFIG" | jq -c '.parsed.bindings // []')
CURRENT_CHANNELS=$(echo "$CONFIG" | jq -c --arg gid "$GUILD_ID" '.parsed.channels.discord.guilds[$gid].channels // {}')

# SAFETY: If we have agents but got empty array, something's wrong
AGENT_COUNT=$(echo "$CURRENT_AGENTS" | jq 'length')
if [[ "$AGENT_COUNT" -eq 0 ]]; then
  echo "   ⚠ Warning: No existing agents found. If this is unexpected, Ctrl+C now."
  sleep 2
fi

# Build new agent
NEW_AGENT=$(jq -n \
  --arg id "$ID" \
  --arg name "$NAME" \
  --arg workspace "$WORKSPACE" \
  --arg model "$MODEL" \
  --arg emoji "$EMOJI" \
  '{
    id: $id,
    name: $name,
    workspace: $workspace,
    model: { primary: $model },
    identity: { name: $name, emoji: $emoji }
  }')

# Merge agents (replace if exists, add if new)
AGENTS=$(echo "$CURRENT_AGENTS" | jq --argjson new "$NEW_AGENT" '
  if any(.[]; .id == $new.id) then
    map(if .id == $new.id then $new else . end)
  else
    . + [$new]
  end
')

# Build config patch
PATCH=$(jq -n --argjson agents "$AGENTS" '{ agents: { list: $agents } }')

# Add binding if we have a channel
if [[ -n "$CHANNEL_ID" ]]; then
  NEW_BINDING=$(jq -n \
    --arg agentId "$ID" \
    --arg channelId "$CHANNEL_ID" \
    '{
      agentId: $agentId,
      match: {
        channel: "discord",
        peer: { kind: "channel", id: $channelId }
      }
    }')
  
  # Prepend binding (first match wins)
  BINDINGS=$(echo "$CURRENT_BINDINGS" | jq --argjson new "$NEW_BINDING" '
    [($new)] + [.[] | select(.match.peer.id != $new.match.peer.id)]
  ')
  
  PATCH=$(echo "$PATCH" | jq --argjson bindings "$BINDINGS" '. + { bindings: $bindings }')
  
  # Add to allowlist
  CHANNELS=$(echo "$CURRENT_CHANNELS" | jq --arg id "$CHANNEL_ID" '. + { ($id): { allow: true } }')
  PATCH=$(echo "$PATCH" | jq --argjson channels "$CHANNELS" --arg gid "$GUILD_ID" '. + { channels: { discord: { guilds: { ($gid): { channels: $channels } } } } }')
  
  echo "   ✓ Added binding: $ID → #$CHANNEL_ID"
  echo "   ✓ Added to allowlist"
fi

# Apply config
# Get base hash for config patch (required for optimistic locking)
BASE_HASH=$(openclaw gateway call config.get --json 2>/dev/null | jq -r '.hash // empty')
if [[ -z "$BASE_HASH" ]]; then
  echo "   ✗ Failed to get config hash"
  exit 1
fi

PATCH_PARAMS=$(jq -n --arg raw "$(echo "$PATCH" | jq -c .)" --arg hash "$BASE_HASH" '{raw: $raw, baseHash: $hash}')
openclaw gateway call config.patch --params "$PATCH_PARAMS" --json --timeout 30000 >/dev/null 2>&1
echo "   ✓ Config applied"

# ─────────────────────────────────────────────────────────────
# 4. Daily memory cron (default: enabled)
# ─────────────────────────────────────────────────────────────
if [[ "$SKIP_CRON" != "true" ]]; then
  echo ""
  echo "⏰ Setting up daily memory cron at $CRON_TIME $TZ..."
  
  # Parse time
  HOUR=$(echo "$CRON_TIME" | cut -d: -f1)
  MINUTE=$(echo "$CRON_TIME" | cut -d: -f2)
  
  # Remove existing memory cron for this agent
  EXISTING=$(openclaw cron list --json 2>/dev/null | jq -r --arg agent "$ID" \
    '.jobs[] | select(.agentId == $agent and (.name | test("memory|Memory"))) | .id' | head -1)
  [[ -n "$EXISTING" ]] && openclaw cron remove --id "$EXISTING" >/dev/null 2>&1
  
  # Determine delivery channel
  DELIVER_CHANNEL_ID="${CHANNEL_ID:-}"
  
  # Create new cron
  CRON_CMD=(openclaw cron add \
    --name "$NAME Daily Memory Update" \
    --cron "$MINUTE $HOUR * * *" \
    --tz "$TZ" \
    --agent "$ID" \
    --model sonnet \
    --session isolated \
    --message "End of day memory update: Review today's conversations and activity. Create/update memory/\$(date +%Y-%m-%d).md with a summary of: what was worked on, decisions made, progress, and context for tomorrow. If nothing new, reply HEARTBEAT_OK.")
  
  # Add delivery target if we have a channel
  if [[ -n "$DELIVER_CHANNEL_ID" ]]; then
    CRON_CMD+=(--announce --channel discord --to "channel:$DELIVER_CHANNEL_ID")
  fi
  
  "${CRON_CMD[@]}" >/dev/null 2>&1
  
  if [[ $? -eq 0 ]]; then
    echo "   ✓ Cron job created"
  else
    echo "   ✗ Cron job creation failed (create manually with: openclaw cron add --name \"$NAME Daily Memory Update\" --agent $ID --cron \"$MINUTE $HOUR * * *\")"
  fi
fi

# ─────────────────────────────────────────────────────────────
# 5. Category ownership (optional)
# ─────────────────────────────────────────────────────────────
if [[ -n "$OWN_CATEGORY" ]]; then
  echo ""
  echo "📂 Claiming category ownership..."
  "$SKILL_DIR/scripts/claim-category.sh" --agent "$ID" --category "$OWN_CATEGORY" --sync
fi

# ─────────────────────────────────────────────────────────────
# 6. Update qmd index (agent memory becomes searchable)
# ─────────────────────────────────────────────────────────────
if command -v qmd &> /dev/null; then
  echo ""
  echo "🔍 Updating qmd index..."
  qmd update >/dev/null 2>&1 && echo "   ✓ Agent memory now searchable via qmd"
fi

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✓ Agent $NAME $EMOJI created successfully!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Workspace:  $WORKSPACE"
echo "  Model:      $MODEL"
[[ -n "$CHANNEL_ID" ]] && echo "  Discord:    #$CHANNEL_ID"
[[ -n "$CRON_TIME" ]] && echo "  Cron:       Daily at $CRON_TIME $TZ"
echo ""
echo "  Next steps:"
echo "    1. Customize $WORKSPACE/SOUL.md"
echo "    2. Test: send a message in the bound channel"
echo ""
