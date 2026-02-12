#!/bin/bash
set -e

# Remove an agent (config only, keeps workspace)
# Usage: ./remove-agent.sh --id <agent-id> [--delete-workspace] [--delete-channel]

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) ID="$2"; shift 2 ;;
    --delete-workspace) DELETE_WORKSPACE=true; shift ;;
    --delete-channel) DELETE_CHANNEL=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$ID" ]]; then
  echo "Usage: $0 --id <agent-id> [--delete-workspace] [--delete-channel]"
  exit 1
fi

echo "Removing agent: $ID"

# Get current config
CONFIG=$(openclaw gateway call config.get --json)

# SAFETY: Validate config
if ! echo "$CONFIG" | jq -e '.parsed' >/dev/null 2>&1; then
  echo "✗ Failed to get config. Aborting."
  exit 1
fi

# Get channel ID before removing binding
CHANNEL_ID=$(echo "$CONFIG" | jq -r --arg id "$ID" \
  '.parsed.bindings[] | select(.agentId == $id and .match.channel == "discord") | .match.peer.id' | head -1)

# Remove from agents list
AGENTS=$(echo "$CONFIG" | jq -c --arg id "$ID" '.parsed.agents.list | map(select(.id != $id))')

# Remove bindings for this agent
BINDINGS=$(echo "$CONFIG" | jq -c --arg id "$ID" '.parsed.bindings | map(select(.agentId != $id))')

# Build patch
PATCH=$(jq -n --argjson a "$AGENTS" --argjson b "$BINDINGS" \
  '{ agents: { list: $a }, bindings: $b }')

# Remove from allowlist if we have a channel
if [[ -n "$CHANNEL_ID" ]]; then
  CHANNELS=$(echo "$CONFIG" | jq -c --arg id "$CHANNEL_ID" 'del(.parsed.discord.channels[$id])')
  PATCH=$(echo "$PATCH" | jq --argjson c "$CHANNELS" '. + { discord: { channels: $c } }')
fi

openclaw gateway config.patch --raw "$(echo "$PATCH" | jq -c .)"
echo "✓ Removed from config"

# Remove cron jobs
CRON_IDS=$(openclaw cron list --json 2>/dev/null | jq -r --arg id "$ID" '.jobs[] | select(.agentId == $id) | .id')
for cron_id in $CRON_IDS; do
  openclaw cron remove --id "$cron_id" >/dev/null 2>&1
  echo "✓ Removed cron job: $cron_id"
done

# Delete Discord channel
if [[ "$DELETE_CHANNEL" == "true" ]] && [[ -n "$CHANNEL_ID" ]]; then
  openclaw message channel-delete --channelId "$CHANNEL_ID" >/dev/null 2>&1 && \
    echo "✓ Deleted Discord channel: $CHANNEL_ID" || \
    echo "✗ Failed to delete channel (may need manual deletion)"
fi

# Delete workspace
WORKSPACE="$HOME/workspace/agents/$ID"
if [[ "$DELETE_WORKSPACE" == "true" ]] && [[ -d "$WORKSPACE" ]]; then
  rm -rf "$WORKSPACE"
  echo "✓ Deleted workspace: $WORKSPACE"
else
  echo "  Workspace preserved: $WORKSPACE"
fi

# Update qmd index
if command -v qmd &> /dev/null; then
  qmd update >/dev/null 2>&1 && echo "✓ Updated qmd index"
fi

echo ""
echo "Done. Agent $ID removed."
