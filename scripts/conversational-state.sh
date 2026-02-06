#!/bin/bash
# Conversational agent creation state handler
# Manages step-by-step Q&A flow for agent creation
# Clean version: 6 questions only, tight formatting

set -e

STATE_DIR="${AGENT_COUNCIL_STATE_DIR:-$HOME/.openclaw/tmp/agent-creation}"
mkdir -p "$STATE_DIR"

get_state_file() {
  echo "$STATE_DIR/session-${1}.json"
}

generate_id() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g'
}

pick_emoji() {
  local lower_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$lower_name" in
    # Specific names first (before patterns that might match substrings)
    martha) echo "🌸" ;;
    watson) echo "🔬" ;;
    picasso) echo "🎨" ;;
    aurelius) echo "📚" ;;
    # Then keyword patterns
    *research*|*science*|*analyze*) echo "🔬" ;;
    *art*|*image*|*draw*|*design*) echo "🎨" ;;
    *health*|*nurse*|*medical*|*doctor*) echo "💊" ;;
    *finance*|*money*|*budget*) echo "💰" ;;
    *code*|*dev*|*engineer*|*program*) echo "💻" ;;
    *write*|*author*|*blog*) echo "✍️" ;;
    *music*|*song*) echo "🎵" ;;
    *cook*|*chef*|*recipe*|*food*|*kitchen*) echo "🌸" ;;
    *stoic*|*philosophy*|*wisdom*) echo "📚" ;;
    *crypto*|*blockchain*|*trading*) echo "₿" ;;
    *data*|*analytics*|*stats*) echo "📊" ;;
    *teach*|*tutor*|*learn*) echo "🎓" ;;
    *fitness*|*gym*|*workout*) echo "💪" ;;
    *) echo "🤖" ;;
  esac
}

cmd_start() {
  local state_file=$(get_state_file "$1")
  [[ -f "$state_file" ]] && rm -f "$state_file"
  cat > "$state_file" <<EOF
{"session_id":"$1","step":"name","data":{}}
EOF
  echo "1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)"
}

cmd_answer() {
  local session_id="$1"
  shift
  local answer="$*"
  local state_file=$(get_state_file "$session_id")
  [[ ! -f "$state_file" ]] && { echo "No active session. Use --start first."; exit 1; }
  
  local step=$(jq -r '.step' "$state_file")
  
  case "$step" in
    name)
      local agent_id=$(generate_id "$answer")
      local emoji=$(pick_emoji "$answer")
      jq --arg n "$answer" --arg i "$agent_id" --arg e "$emoji" \
         '.data.name=$n|.data.id=$i|.data.emoji=$e|.step="specialty"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      echo "✓ Agent: $answer $emoji"
      echo ""
      echo "2. What does $answer do? (1-2 sentences describing her specialty)"
      ;;
      
    specialty)
      jq --arg s "$answer" '.data.specialty=$s|.step="style"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      local name=$(jq -r '.data.name' "$state_file")
      echo "✓ Specialty: $answer"
      echo ""
      echo "3. What's ${name}'s communication style?"
      echo "(a) Warm and encouraging — like a supportive grandma in the kitchen"
      echo "(b) Professional and precise — clear instructions, exact measurements"
      echo "(c) Casual and fun — playful, uses food puns, keeps it light"
      echo "(d) Custom — describe your own"
      ;;
      
    style)
      local style=""
      case "$answer" in
        a|A) style="Warm and encouraging — like a supportive grandma in the kitchen" ;;
        b|B) style="Professional and precise — clear instructions, exact measurements" ;;
        c|C) style="Casual and fun — playful, uses food puns, keeps it light" ;;
        d|D)
          jq '.step="style_custom"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "Describe the communication style:"
          return
          ;;
        *) style="$answer" ;;
      esac
      jq --arg s "$style" '.data.style=$s|.step="model"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      local name=$(jq -r '.data.name' "$state_file")
      echo "✓ Style: $style"
      echo ""
      echo "4. Which model should $name use?"
      echo "(a) opus — Claude Opus 4.5 (deep reasoning)"
      echo "(b) sonnet — Claude Sonnet 4.5 (balanced) ⭐"
      echo "(c) gemini — Gemini 3 Pro (Google)"
      echo "(d) gemini-flash — Gemini 3 Flash (fast, lightweight)"
      echo "(e) kimi — Kimi K2.5 (free, great for coding)"
      ;;
      
    style_custom)
      jq --arg s "$answer" '.data.style=$s|.step="model"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      local name=$(jq -r '.data.name' "$state_file")
      echo "✓ Style: $answer"
      echo ""
      echo "4. Which model should $name use?"
      echo "(a) opus — Claude Opus 4.5 (deep reasoning)"
      echo "(b) sonnet — Claude Sonnet 4.5 (balanced) ⭐"
      echo "(c) gemini — Gemini 3 Pro (Google)"
      echo "(d) gemini-flash — Gemini 3 Flash (fast, lightweight)"
      echo "(e) kimi — Kimi K2.5 (free, great for coding)"
      ;;
      
    model)
      local model=""
      local model_display=""
      case "$answer" in
        a|A) model="anthropic/claude-opus-4-5"; model_display="Claude Opus 4.5" ;;
        b|B) model="anthropic/claude-sonnet-4-5"; model_display="Claude Sonnet 4.5" ;;
        c|C) model="google/gemini-3-pro-preview"; model_display="Gemini 3 Pro" ;;
        d|D) model="google/gemini-3-flash-preview"; model_display="Gemini 3 Flash" ;;
        e|E) model="nvidia/kimi-k2.5"; model_display="Kimi K2.5" ;;
        *) model="$answer"; model_display="$answer" ;;
      esac
      jq --arg m "$model" '.data.model=$m|.step="discord"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      local name=$(jq -r '.data.name' "$state_file")
      local id=$(jq -r '.data.id' "$state_file")
      echo "✓ Model: $model_display"
      echo ""
      echo "5. Discord channel for $name?"
      echo "(a) Create new #$id channel"
      echo "(b) Use existing channel — provide name or ID"
      echo "(c) No Discord channel — agent only accessible via sessions"
      ;;
      
    discord)
      local name=$(jq -r '.data.name' "$state_file")
      local id=$(jq -r '.data.id' "$state_file")
      case "$answer" in
        a|A)
          jq --arg c "$id" '.data.discord_new=$c|.step="cron"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "✓ Discord: New #$id channel"
          echo ""
          echo "6. Set up daily memory cron? ($name will summarize her day's activity each night)"
          echo "(a) Yes — 11:00 PM EST (recommended)"
          echo "(b) Yes — custom time"
          echo "(c) No — skip memory cron"
          ;;
        b|B)
          jq '.step="discord_existing"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "Enter channel name or ID:"
          ;;
        c|C)
          jq '.data.discord_channel=""|.step="cron"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "✓ Discord: None (sessions only)"
          echo ""
          echo "6. Set up daily memory cron? ($name will summarize her day's activity each night)"
          echo "(a) Yes — 11:00 PM EST (recommended)"
          echo "(b) Yes — custom time"
          echo "(c) No — skip memory cron"
          ;;
        *)
          echo "Please enter a, b, or c"
          ;;
      esac
      ;;
      
    discord_existing)
      local name=$(jq -r '.data.name' "$state_file")
      # Check if it looks like a channel ID (all numbers) or name
      if [[ "$answer" =~ ^[0-9]+$ ]]; then
        jq --arg c "$answer" '.data.discord_channel=$c|.step="cron"' \
           "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        echo "✓ Discord: Channel ID $answer"
      else
        jq --arg c "$answer" '.data.discord_name=$c|.step="cron"' \
           "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        echo "✓ Discord: #$answer (will lookup ID)"
      fi
      echo ""
      echo "6. Set up daily memory cron? ($name will summarize her day's activity each night)"
      echo "(a) Yes — 11:00 PM EST (recommended)"
      echo "(b) Yes — custom time"
      echo "(c) No — skip memory cron"
      ;;
      
    cron)
      local name=$(jq -r '.data.name' "$state_file")
      case "$answer" in
        a|A)
          jq '.data.cron_time="23:00"|.data.cron_tz="America/New_York"|.step="complete"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "✓ Memory cron: Daily at 11:00 PM EST"
          show_summary "$state_file"
          ;;
        b|B)
          jq '.step="cron_custom"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "What time should ${name}'s daily memory update run? (HH:MM in EST, e.g., 22:00)"
          ;;
        c|C)
          jq '.data.cron_time=""|.step="complete"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo "✓ Memory cron: Skipped"
          show_summary "$state_file"
          ;;
        *)
          echo "Please enter a, b, or c"
          ;;
      esac
      ;;
      
    cron_custom)
      # Parse time like "10PM EST" or "22:00"
      local time_clean=$(echo "$answer" | tr '[:lower:]' '[:upper:]' | sed 's/[^0-9APMEST:]//g')
      local hour=""
      local minute="00"
      
      if [[ "$answer" =~ ([0-9]{1,2}):([0-9]{2}) ]]; then
        hour="${BASH_REMATCH[1]}"
        minute="${BASH_REMATCH[2]}"
      elif [[ "$time_clean" =~ ([0-9]{1,2})(PM|AM) ]]; then
        hour="${BASH_REMATCH[1]}"
        local meridiem="${BASH_REMATCH[2]}"
        if [[ "$meridiem" == "PM" ]] && [[ "$hour" -ne 12 ]]; then
          hour=$((hour + 12))
        elif [[ "$meridiem" == "AM" ]] && [[ "$hour" -eq 12 ]]; then
          hour=0
        fi
      else
        hour=$(echo "$answer" | grep -oE '[0-9]{1,2}' | head -1)
      fi
      
      local cron_time=$(printf "%02d:%02d" "$hour" "$minute")
      jq --arg t "$cron_time" '.data.cron_time=$t|.data.cron_tz="America/New_York"|.step="complete"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      echo "✓ Memory cron: Daily at $cron_time EST"
      show_summary "$state_file"
      ;;
      
    complete)
      echo "Configuration complete. Say 'yes' to create the agent."
      ;;
  esac
}

show_summary() {
  local state_file="$1"
  local name=$(jq -r '.data.name' "$state_file")
  local emoji=$(jq -r '.data.emoji' "$state_file")
  local id=$(jq -r '.data.id' "$state_file")
  local specialty=$(jq -r '.data.specialty' "$state_file")
  local style=$(jq -r '.data.style' "$state_file")
  local model=$(jq -r '.data.model' "$state_file")
  local discord_new=$(jq -r '.data.discord_new // empty' "$state_file")
  local discord_channel=$(jq -r '.data.discord_channel // empty' "$state_file")
  local discord_name=$(jq -r '.data.discord_name // empty' "$state_file")
  local cron_time=$(jq -r '.data.cron_time // empty' "$state_file")
  
  # Format model display
  local model_display="$model"
  case "$model" in
    anthropic/claude-opus-4-5) model_display="Claude Opus 4.5" ;;
    anthropic/claude-sonnet-4-5) model_display="Claude Sonnet 4.5" ;;
    google/gemini-3-pro-preview) model_display="Gemini 3 Pro" ;;
    google/gemini-3-flash-preview) model_display="Gemini 3 Flash" ;;
    nvidia/kimi-k2.5) model_display="Kimi K2.5" ;;
  esac
  
  # Format Discord display
  local discord_display=""
  if [[ -n "$discord_new" ]]; then
    discord_display="New #$discord_new channel"
  elif [[ -n "$discord_channel" ]]; then
    discord_display="Channel ID $discord_channel"
  elif [[ -n "$discord_name" ]]; then
    discord_display="#$discord_name"
  else
    discord_display="None"
  fi
  
  # Format cron display
  local cron_display="None"
  if [[ -n "$cron_time" ]]; then
    cron_display="Daily at $cron_time EST"
  fi
  
  echo ""
  echo "---"
  echo ""
  echo "**Ready to create $name:**"
  echo ""
  echo "• **Name:** $name $emoji"
  echo "• **Specialty:** $specialty"
  echo "• **Style:** $style"
  echo "• **Model:** $model_display"
  echo "• **Discord:** $discord_display"
  echo "• **Memory cron:** $cron_display"
  echo "• **Workspace:** ~/clawd/agents/$id"
  echo ""
  echo "Create agent? (yes/no)"
}

cmd_execute() {
  local session_id="$1"
  local state_file=$(get_state_file "$session_id")
  [[ ! -f "$state_file" ]] && { echo "No active session."; exit 1; }
  
  local step=$(jq -r '.step' "$state_file")
  [[ "$step" != "complete" ]] && { echo "Configuration not complete (step: $step)"; exit 1; }
  
  local name=$(jq -r '.data.name' "$state_file")
  local id=$(jq -r '.data.id' "$state_file")
  local emoji=$(jq -r '.data.emoji' "$state_file")
  local specialty=$(jq -r '.data.specialty' "$state_file")
  local style=$(jq -r '.data.style' "$state_file")
  local model=$(jq -r '.data.model' "$state_file")
  local workspace="$HOME/clawd/agents/$id"
  local discord_new=$(jq -r '.data.discord_new // empty' "$state_file")
  local discord_channel=$(jq -r '.data.discord_channel // empty' "$state_file")
  local discord_name=$(jq -r '.data.discord_name // empty' "$state_file")
  local cron_time=$(jq -r '.data.cron_time // empty' "$state_file")
  local cron_tz=$(jq -r '.data.cron_tz // "America/New_York"' "$state_file")
  
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  # Build command
  local cmd="$script_dir/create-agent.sh"
  cmd="$cmd --name \"$name\""
  cmd="$cmd --id \"$id\""
  cmd="$cmd --emoji \"$emoji\""
  cmd="$cmd --specialty \"$specialty\""
  cmd="$cmd --model \"$model\""
  cmd="$cmd --workspace \"$workspace\""
  
  # Handle Discord - will be created/configured after agent creation
  # Store for post-creation setup
  
  # Optional cron
  if [[ -n "$cron_time" ]]; then
    cmd="$cmd --setup-cron yes --cron-time \"$cron_time\" --cron-tz \"$cron_tz\""
  fi
  
  echo "Creating $name $emoji..."
  echo ""
  
  # Execute agent creation
  eval "$cmd"
  
  # Update SOUL.md with style
  local soul_file="$workspace/SOUL.md"
  if [[ -f "$soul_file" ]] && [[ -n "$style" ]]; then
    sed -i '' "s|\[Define the agent's personality traits, communication style, and approach to work\]|**Communication style:** $style|g" "$soul_file" 2>/dev/null || true
  fi
  
  # Store discord info for the calling agent to handle
  echo ""
  echo "DISCORD_NEW=$discord_new"
  echo "DISCORD_CHANNEL=$discord_channel"
  echo "DISCORD_NAME=$discord_name"
  echo "AGENT_NAME=$name"
  echo "AGENT_EMOJI=$emoji"
  echo "AGENT_SPECIALTY=$specialty"
  echo "AGENT_ID=$id"
  
  rm -f "$state_file"
}

cmd_status() {
  local state_file=$(get_state_file "$1")
  [[ -f "$state_file" ]] && jq '.' "$state_file" || echo "No active session"
}

cmd_cancel() {
  rm -f "$(get_state_file "$1")"
  echo "Session cancelled"
}

case "$1" in
  start) cmd_start "${2:-default}" ;;
  answer) cmd_answer "${2:-default}" "${@:3}" ;;
  status) cmd_status "${2:-default}" ;;
  cancel) cmd_cancel "${2:-default}" ;;
  execute) cmd_execute "${2:-default}" ;;
  *) echo "Usage: $0 {start|answer|status|cancel|execute} [session-id] [answer]" ;;
esac
