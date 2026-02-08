#!/bin/bash

# List all agents and their Discord bindings
# Usage: ./list-agents.sh

CONFIG=$(openclaw gateway call config.get --json 2>/dev/null)

echo "═══════════════════════════════════════════════════════════"
echo "  Agent Council - Current Roster"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get agents
AGENTS=$(echo "$CONFIG" | jq -r '.parsed.agents.list[] | "\(.identity.emoji // "🤖") \(.name // .id) (\(.id)) — \(.model.primary // "default")"')

if [[ -z "$AGENTS" ]]; then
  echo "  No agents configured."
  exit 0
fi

echo "$AGENTS" | while read line; do
  echo "  $line"
done

echo ""
echo "───────────────────────────────────────────────────────────"
echo "  Discord Bindings"
echo "───────────────────────────────────────────────────────────"
echo ""

# Get bindings
echo "$CONFIG" | jq -r '
  .parsed.bindings[]
  | select(.match.channel == "discord")
  | "  \(.agentId) → #\(.match.peer.id)"
'

# Show default
DEFAULT=$(echo "$CONFIG" | jq -r '.parsed.agents.list[] | select(.default == true) | .id')
if [[ -n "$DEFAULT" ]]; then
  echo ""
  echo "  Default (fallback): $DEFAULT"
fi

echo ""
