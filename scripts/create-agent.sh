#!/bin/bash
set -e

# Minimal agent creation script
# Usage: ./create-agent.sh <id> <name> <emoji> <specialty> [model] [discord-channel-id]

ID="$1"
NAME="$2"
EMOJI="$3"
SPECIALTY="$4"
MODEL="${5:-anthropic/claude-sonnet-4-5}"
DISCORD_CHANNEL="$6"

if [[ -z "$ID" ]] || [[ -z "$NAME" ]] || [[ -z "$EMOJI" ]] || [[ -z "$SPECIALTY" ]]; then
  echo "Usage: $0 <id> <name> <emoji> <specialty> [model] [discord-channel-id]"
  echo "Example: $0 watson Watson 🔬 'Deep research and analysis'"
  exit 1
fi

WORKSPACE="$HOME/clawd/agents/$ID"

# 1. Create workspace
echo "Creating workspace: $WORKSPACE"
mkdir -p "$WORKSPACE/memory"

# 2. Write SOUL.md
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

# 3. Write HEARTBEAT.md
cat > "$WORKSPACE/HEARTBEAT.md" << EOF
# HEARTBEAT.md - $NAME $EMOJI

Handle scheduled cron jobs and system events only.

If there are system events (cron jobs), handle them.
Otherwise, reply \`HEARTBEAT_OK\`.
EOF

echo "✓ Created SOUL.md and HEARTBEAT.md"

# 4. Add to gateway config
echo "Adding agent to gateway config..."

# Get current agents list and add new one
CURRENT=$(openclaw gateway call config.get --json | jq -c '.parsed.agents.list // []')
NEW_AGENT="{\"id\":\"$ID\",\"name\":\"$NAME\",\"workspace\":\"$WORKSPACE\",\"model\":{\"primary\":\"$MODEL\"},\"identity\":{\"name\":\"$NAME\",\"emoji\":\"$EMOJI\"}}"
AGENTS=$(echo "$CURRENT" | jq --argjson new "$NEW_AGENT" '. + [$new]')

PATCH="{\"agents\":{\"list\":$AGENTS}}"

# Add Discord binding if specified
if [[ -n "$DISCORD_CHANNEL" ]]; then
  echo "Adding Discord binding for channel $DISCORD_CHANNEL"
  BINDINGS=$(openclaw gateway call config.get --json | jq -c '.parsed.bindings // []')
  NEW_BINDING="{\"agentId\":\"$ID\",\"match\":{\"channel\":\"discord\",\"peer\":{\"kind\":\"channel\",\"id\":\"$DISCORD_CHANNEL\"}}}"
  ALL_BINDINGS=$(echo "$BINDINGS" | jq --argjson new "$NEW_BINDING" '[$new] + .')
  PATCH=$(echo "$PATCH" | jq --argjson b "$ALL_BINDINGS" '. + {bindings: $b}')
fi

openclaw gateway config.patch --raw "$PATCH"

echo ""
echo "✓ Agent '$NAME' created!"
echo "  Workspace: $WORKSPACE"
echo "  Model: $MODEL"
[[ -n "$DISCORD_CHANNEL" ]] && echo "  Discord: #$DISCORD_CHANNEL"
