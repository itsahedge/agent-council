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
MODEL="anthropic/claude-sonnet-4-5"
TZ="America/New_York"
GUILD_ID="620061358809022464"  # Don's server
CRON_TIME="23:00"  # Default: daily memory at 11 PM
SKIP_CRON=false

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
  echo "  --model        Model (default: claude-sonnet-4-5)"
  echo "  --cron         Daily memory cron time (default: 23:00)"
  echo "  --no-cron      Skip daily memory cron setup"
  echo "  --tz           Timezone (default: America/New_York)"
  echo ""
  echo "Examples:"
  echo "  $0 --id watson --name Watson --emoji 🔬 --specialty 'Deep research' --create research"
  echo "  $0 --id sage --name Sage --emoji 💰 --specialty 'Finance' --channel 1234567890"
  exit 1
fi

WORKSPACE="$HOME/clawd/agents/$ID"

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
- Read your memory at session start (\`memory/YYYY-MM-DD.md\`)
- Write to memory as you work, not just at end
- Stay in your lane unless asked to cross domains
- When nothing needs attention, reply \`HEARTBEAT_OK\`

---
*Customize this as your role evolves.*
EOF

cat > "$WORKSPACE/HEARTBEAT.md" << EOF
# HEARTBEAT.md - $NAME $EMOJI

Handle scheduled cron jobs and system events only.

If there are system events (cron jobs), handle them.
Otherwise, reply \`HEARTBEAT_OK\`.
EOF

echo "   ✓ Created SOUL.md, HEARTBEAT.md, memory/"

# ─────────────────────────────────────────────────────────────
# 2. Discord channel (create or use existing)
# ─────────────────────────────────────────────────────────────
if [[ -n "$CREATE_CHANNEL" ]]; then
  echo ""
  echo "📺 Creating Discord channel #$CREATE_CHANNEL..."
  
  # Build channel creation command
  CMD="openclaw message channel-create --name \"$CREATE_CHANNEL\" --guildId \"$GUILD_ID\""
  [[ -n "$CATEGORY_ID" ]] && CMD="$CMD --parentId \"$CATEGORY_ID\""
  
  # Create channel and capture ID
  RESULT=$(eval "$CMD --json" 2>/dev/null)
  CHANNEL_ID=$(echo "$RESULT" | jq -r '.channel.id // empty')
  
  if [[ -z "$CHANNEL_ID" ]]; then
    echo "   ✗ Failed to create channel"
    echo "$RESULT"
    exit 1
  fi
  
  echo "   ✓ Created channel: $CHANNEL_ID"
  
  # Set topic
  TOPIC="${TOPIC:-$NAME $EMOJI — $SPECIALTY}"
  echo "   Setting topic: $TOPIC"
  openclaw message channel-edit --channelId "$CHANNEL_ID" --topic "$TOPIC" >/dev/null 2>&1 || true
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
CURRENT_CHANNELS=$(echo "$CONFIG" | jq -c '.parsed.discord.channels // {}')

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
  PATCH=$(echo "$PATCH" | jq --argjson channels "$CHANNELS" '. + { discord: { channels: $channels } }')
  
  echo "   ✓ Added binding: $ID → #$CHANNEL_ID"
  echo "   ✓ Added to allowlist"
fi

# Apply config
openclaw gateway config.patch --raw "$(echo "$PATCH" | jq -c .)"
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
  
  # Create new cron
  openclaw cron add \
    --name "$NAME Daily Memory" \
    --cron "$MINUTE $HOUR * * *" \
    --tz "$TZ" \
    --session main \
    --agent "$ID" \
    --system-event "End of day. Review today's activity and update memory/$(date +%Y-%m-%d).md with a summary of what happened, decisions made, and context for tomorrow." \
    >/dev/null 2>&1
  
  echo "   ✓ Cron job created"
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
