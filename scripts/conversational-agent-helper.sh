#!/bin/bash
# Helper script for conversational agent creation from OpenClaw
# Makes it easy to call from Discord naturally

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_HANDLER="$SCRIPT_DIR/conversational-state.sh"

# Default session ID (can be overridden with --session-id)
SESSION_ID="${AGENT_CREATION_SESSION_ID:-default}"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id)
      SESSION_ID="$2"
      shift 2
      ;;
    --start)
      "$STATE_HANDLER" start "$SESSION_ID"
      exit 0
      ;;
    --answer)
      shift
      "$STATE_HANDLER" answer "$SESSION_ID" "$@"
      exit 0
      ;;
    --status)
      "$STATE_HANDLER" status "$SESSION_ID"
      exit 0
      ;;
    --cancel)
      "$STATE_HANDLER" cancel "$SESSION_ID"
      exit 0
      ;;
    --execute|--create)
      "$STATE_HANDLER" execute "$SESSION_ID"
      exit 0
      ;;
    yes|Yes|YES|"create agent"|"Create agent")
      "$STATE_HANDLER" execute "$SESSION_ID"
      exit 0
      ;;
    no|No|NO|cancel|Cancel)
      "$STATE_HANDLER" cancel "$SESSION_ID"
      exit 0
      ;;
    *)
      # If first arg is not a flag, treat it as an answer
      "$STATE_HANDLER" answer "$SESSION_ID" "$@"
      exit 0
      ;;
  esac
done

# No args - show status
"$STATE_HANDLER" status "$SESSION_ID"
