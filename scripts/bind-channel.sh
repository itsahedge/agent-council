#!/bin/bash
set -e

# Bind an agent to a Discord channel
# Usage: ./bind-channel.sh --agent <id> --channel <id> [--topic "..."]

GUILD_ID="620061358809022464"

while [[ $# -gt 0 ]]; do
  case $1 in
    --agent) AGENT_ID="$2"; shift 2 ;;
    --channel) CHANNEL_ID="$2"; shift 2 ;;
    --create) CREATE_CHANNEL="$2"; shift 2 ;;
    --category) CATEGORY_ID="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$AGENT_ID" ]] || [[ -z "$CHANNEL_ID" && -z "$CREATE_CHANNEL" ]]; then
  echo "Usage: $0 --agent <agent-id> --channel <channel-id>"
  echo "   or: $0 --agent <agent-id> --create <channel-name> [--category <id>]"
  exit 1
fi

# Create channel if needed
if [[ -n "$CREATE_CHANNEL" ]]; then
  echo "Creating channel #$CREATE_CHANNEL..."
  CMD="openclaw message channel-create --name \"$CREATE_CHANNEL\" --guildId \"$GUILD_ID\""
  [[ -n "$CATEGORY_ID" ]] && CMD="$CMD --parentId \"$CATEGORY_ID\""
  RESULT=$(eval "$CMD --json")
  CHANNEL_ID=$(echo "$RESULT" | jq -r '.channel.id')
  echo "Created: $CHANNEL_ID"
  
  if [[ -n "$TOPIC" ]]; then
    openclaw message channel-edit --channelId "$CHANNEL_ID" --topic "$TOPIC" >/dev/null 2>&1
  fi
fi

# Get current config
CONFIG=$(openclaw gateway call config.get --json)

# SAFETY: Validate config
if ! echo "$CONFIG" | jq -e '.parsed' >/dev/null 2>&1; then
  echo "✗ Failed to get config. Aborting."
  exit 1
fi

BINDINGS=$(echo "$CONFIG" | jq -c '.parsed.bindings // []')
CHANNELS=$(echo "$CONFIG" | jq -c '.parsed.discord.channels // {}')

# Build binding
NEW_BINDING=$(jq -n \
  --arg agentId "$AGENT_ID" \
  --arg channelId "$CHANNEL_ID" \
  '{
    agentId: $agentId,
    match: { channel: "discord", peer: { kind: "channel", id: $channelId } }
  }')

# Prepend and dedupe
BINDINGS=$(echo "$BINDINGS" | jq --argjson new "$NEW_BINDING" \
  '[($new)] + [.[] | select(.match.peer.id != $new.match.peer.id)]')

# Add to allowlist
CHANNELS=$(echo "$CHANNELS" | jq --arg id "$CHANNEL_ID" '. + { ($id): { allow: true } }')

# Patch
PATCH=$(jq -n --argjson b "$BINDINGS" --argjson c "$CHANNELS" \
  '{ bindings: $b, discord: { channels: $c } }')

openclaw gateway config.patch --raw "$(echo "$PATCH" | jq -c .)"

echo "✓ Bound $AGENT_ID → #$CHANNEL_ID"
