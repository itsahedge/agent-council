#!/bin/bash
# Conversational agent creation state handler
# Manages step-by-step Q&A flow for agent creation

set -e

# State file location (per user/session)
STATE_DIR="${AGENT_COUNCIL_STATE_DIR:-$HOME/.openclaw/tmp/agent-creation}"
mkdir -p "$STATE_DIR"

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Usage message
usage() {
  echo "Usage: $0 <command> [args]"
  echo ""
  echo "Commands:"
  echo "  start <session-id>              Start new agent creation session"
  echo "  answer <session-id> <answer>    Provide answer to current question"
  echo "  status <session-id>             Get current state"
  echo "  cancel <session-id>             Cancel session"
  echo "  execute <session-id>            Execute agent creation (when complete)"
  exit 1
}

# Get state file path for session
get_state_file() {
  local session_id="$1"
  echo "$STATE_DIR/session-${session_id}.json"
}

# Initialize new session
cmd_start() {
  local session_id="$1"
  local state_file=$(get_state_file "$session_id")
  
  if [[ -f "$state_file" ]]; then
    echo -e "${YELLOW}⚠️  Session already exists. Use 'cancel' first to start over.${NC}"
    exit 1
  fi
  
  # Create initial state
  cat > "$state_file" <<EOF
{
  "session_id": "$session_id",
  "step": "name",
  "started": $(date +%s),
  "data": {}
}
EOF
  
  echo -e "${GREEN}✨ Started agent creation session!${NC}"
  echo ""
  echo -e "${CYAN}What should we call this agent?${NC}"
  echo -e "${YELLOW}Examples: Atlas, Watson, Picasso, Aurora${NC}"
}

# Auto-generate agent ID from name
generate_id() {
  local name="$1"
  echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g'
}

# Auto-pick emoji based on name
pick_emoji() {
  local name="$1"
  local lower_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  
  case "$lower_name" in
    *research*|*watson*) echo "🔬" ;;
    *art*|*picasso*|*image*) echo "🎨" ;;
    *health*|*nurse*|*medical*) echo "💊" ;;
    *finance*|*money*) echo "💰" ;;
    *code*|*dev*|*engineer*) echo "💻" ;;
    *write*|*author*) echo "✍️" ;;
    *music*) echo "🎵" ;;
    *cook*|*chef*) echo "👨‍🍳" ;;
    *stoic*|*philosophy*|*aurelius*) echo "📚" ;;
    *crypto*|*blockchain*) echo "₿" ;;
    *data*|*analytics*) echo "📊" ;;
    *teach*|*tutor*) echo "🎓" ;;
    *design*) echo "🎨" ;;
    *marketing*) echo "📢" ;;
    *legal*|*law*) echo "⚖️" ;;
    *security*) echo "🔒" ;;
    *game*) echo "🎮" ;;
    *travel*) echo "✈️" ;;
    *sports*|*fitness*) echo "💪" ;;
    *weather*) echo "🌤️" ;;
    *news*) echo "📰" ;;
    *assistant*|*helper*) echo "🤖" ;;
    *) echo "🤖" ;;
  esac
}

# Process answer for current step
cmd_answer() {
  local session_id="$1"
  shift
  local answer="$*"
  local state_file=$(get_state_file "$session_id")
  
  if [[ ! -f "$state_file" ]]; then
    echo -e "${RED}❌ No active session found. Use 'start' first.${NC}"
    exit 1
  fi
  
  # Read current state
  local current_step=$(jq -r '.step' "$state_file")
  
  # Process based on current step
  case "$current_step" in
    name)
      # Store name, generate ID and emoji
      local agent_id=$(generate_id "$answer")
      local emoji=$(pick_emoji "$answer")
      
      jq --arg name "$answer" \
         --arg id "$agent_id" \
         --arg emoji "$emoji" \
         '.data.name = $name | .data.id = $id | .data.emoji = $emoji | .step = "description"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Agent: $answer $emoji${NC}"
      echo -e "${GREEN}✓ ID: $agent_id${NC}"
      echo ""
      echo -e "${CYAN}What does $answer do?${NC}"
      echo -e "${YELLOW}Give me 1-2 sentences describing the agent's purpose.${NC}"
      ;;
      
    description)
      # Store description
      jq --arg desc "$answer" \
         '.data.specialty = $desc | .step = "communication_style"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Specialty saved${NC}"
      echo ""
      echo -e "${CYAN}What's the communication style?${NC}"
      echo -e "${YELLOW}Examples: professional, casual, technical, friendly, philosophical${NC}"
      echo -e "${YELLOW}Default: professional${NC}"
      ;;
      
    communication_style)
      # Store comm style (or use default)
      local style="${answer:-professional}"
      
      jq --arg style "$style" \
         '.data.comm_style = $style | .step = "personality"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Communication style: $style${NC}"
      echo ""
      echo -e "${CYAN}Key personality traits?${NC}"
      echo -e "${YELLOW}Examples: helpful, thorough, creative, wise, patient${NC}"
      echo -e "${YELLOW}Default: helpful${NC}"
      ;;
      
    personality)
      # Store personality
      local traits="${answer:-helpful}"
      
      jq --arg traits "$traits" \
         '.data.personality = $traits | .step = "model"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Personality: $traits${NC}"
      echo ""
      echo -e "${CYAN}Which model should this agent use?${NC}"
      echo ""
      echo "**1)** claude-opus-4-5 (Most capable, best for complex tasks)"
      echo "**2)** claude-sonnet-4-5 (Balanced, great for most use cases) ⭐"
      echo "**3)** gemini-3-flash-preview (Fast, good for simple tasks)"
      echo "**4)** gemini-3-pro-preview (Google's best, strong reasoning)"
      echo "**5)** Custom (you specify provider/model-name)"
      echo ""
      echo -e "${YELLOW}Enter number [2] or custom model:${NC}"
      ;;
      
    model)
      # Parse model choice
      local model=""
      case "$answer" in
        1) model="anthropic/claude-opus-4-5" ;;
        2|"") model="anthropic/claude-sonnet-4-5" ;;
        3) model="google/gemini-3-flash-preview" ;;
        4) model="google/gemini-3-pro-preview" ;;
        5)
          echo -e "${CYAN}Enter custom model (provider/model-name):${NC}"
          jq '.step = "model_custom"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          return
          ;;
        */*) model="$answer" ;;
        *) model="anthropic/claude-sonnet-4-5" ;;
      esac
      
      jq --arg model "$model" \
         '.data.model = $model | .step = "workspace"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Model: $model${NC}"
      echo ""
      
      local agent_id=$(jq -r '.data.id' "$state_file")
      local default_workspace="$HOME/clawd/agents/$agent_id"
      
      echo -e "${CYAN}Where should the agent's workspace be?${NC}"
      echo -e "${YELLOW}Default: $default_workspace${NC}"
      ;;
      
    model_custom)
      # Store custom model
      jq --arg model "$answer" \
         '.data.model = $model | .step = "workspace"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Model: $answer${NC}"
      echo ""
      
      local agent_id=$(jq -r '.data.id' "$state_file")
      local default_workspace="$HOME/clawd/agents/$agent_id"
      
      echo -e "${CYAN}Where should the agent's workspace be?${NC}"
      echo -e "${YELLOW}Default: $default_workspace${NC}"
      ;;
      
    workspace)
      # Store workspace
      local agent_id=$(jq -r '.data.id' "$state_file")
      local workspace="${answer:-$HOME/clawd/agents/$agent_id}"
      workspace="${workspace/#\~/$HOME}"
      
      jq --arg workspace "$workspace" \
         '.data.workspace = $workspace | .step = "discord"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Workspace: $workspace${NC}"
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}Should $agent_name be bound to a Discord channel?${NC}"
      echo ""
      echo "**1)** Yes, use existing channel (provide channel name)"
      echo "**2)** Yes, use existing channel (provide channel ID)"
      echo "**3)** Yes, create a new channel"
      echo "**4)** No, skip Discord binding"
      echo ""
      echo -e "${YELLOW}Enter number [4]:${NC}"
      ;;
      
    discord)
      # Handle Discord choice
      case "$answer" in
        1)
          jq '.step = "discord_name"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo -e "${CYAN}Enter the Discord channel name (e.g., research, fitness):${NC}"
          ;;
        2)
          jq '.step = "discord_id"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo -e "${CYAN}Enter the Discord channel ID:${NC}"
          ;;
        3)
          jq '.step = "discord_new"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo -e "${CYAN}What should we call the new channel?${NC}"
          ;;
        4|"")
          jq '.data.discord_channel = "" | .step = "skills"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          echo -e "${GREEN}✓ Skipping Discord binding${NC}"
          echo ""
          
          local agent_name=$(jq -r '.data.name' "$state_file")
          echo -e "${CYAN}What skills or tools should $agent_name use?${NC}"
          echo -e "${YELLOW}Examples: web_search, browser, qmd, coding-agent${NC}"
          echo -e "${YELLOW}Enter comma-separated list or 'none':${NC}"
          ;;
        *)
          echo -e "${YELLOW}Invalid choice. Enter 1-4 [4]:${NC}"
          ;;
      esac
      ;;
      
    discord_name)
      # Look up channel by name (this would need OpenClaw integration)
      # For now, store and move forward
      jq --arg channel "$answer" \
         '.data.discord_channel_name = $channel | .step = "skills"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Will bind to channel: #$answer${NC}"
      echo -e "${YELLOW}(Channel lookup will happen during creation)${NC}"
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}What skills or tools should $agent_name use?${NC}"
      echo -e "${YELLOW}Examples: web_search, browser, qmd, coding-agent${NC}"
      echo -e "${YELLOW}Enter comma-separated list or 'none':${NC}"
      ;;
      
    discord_id)
      # Store channel ID
      jq --arg channel "$answer" \
         '.data.discord_channel = $channel | .step = "skills"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Channel ID: $answer${NC}"
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}What skills or tools should $agent_name use?${NC}"
      echo -e "${YELLOW}Examples: web_search, browser, qmd, coding-agent${NC}"
      echo -e "${YELLOW}Enter comma-separated list or 'none':${NC}"
      ;;
      
    discord_new)
      # Store new channel name
      jq --arg channel "$answer" \
         '.data.discord_new_channel = $channel | .step = "skills"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      echo -e "${GREEN}✓ Will create channel: #$answer${NC}"
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}What skills or tools should $agent_name use?${NC}"
      echo -e "${YELLOW}Examples: web_search, browser, qmd, coding-agent${NC}"
      echo -e "${YELLOW}Enter comma-separated list or 'none':${NC}"
      ;;
      
    skills)
      # Store skills
      jq --arg skills "$answer" \
         '.data.skills = $skills | .step = "boundaries"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      if [[ -n "$answer" ]] && [[ "$answer" != "none" ]]; then
        echo -e "${GREEN}✓ Skills: $answer${NC}"
      else
        echo -e "${GREEN}✓ No specific skills configured${NC}"
      fi
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}What should $agent_name NOT do?${NC}"
      echo -e "${YELLOW}Examples: Don't make purchases, Don't send emails without approval${NC}"
      echo -e "${YELLOW}Enter boundaries or 'none':${NC}"
      ;;
      
    boundaries)
      # Store boundaries
      jq --arg boundaries "$answer" \
         '.data.boundaries = $boundaries | .step = "cron"' \
         "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
      
      if [[ -n "$answer" ]] && [[ "$answer" != "none" ]]; then
        echo -e "${GREEN}✓ Boundaries: $answer${NC}"
      else
        echo -e "${GREEN}✓ No specific boundaries configured${NC}"
      fi
      echo ""
      
      local agent_name=$(jq -r '.data.name' "$state_file")
      echo -e "${CYAN}Set up daily memory cron for $agent_name?${NC}"
      echo -e "${YELLOW}Examples: 'everyday at 10PM EST', 'daily at 11:30PM PST'${NC}"
      echo -e "${YELLOW}Enter schedule or 'none' to skip:${NC}"
      ;;
      
    cron)
      # Parse cron schedule
      if [[ "$answer" == "none" ]] || [[ -z "$answer" ]]; then
        jq '.data.setup_cron = "no" | .step = "complete"' \
           "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        
        echo -e "${GREEN}✓ Skipping daily memory cron${NC}"
      else
        # Parse time and timezone
        local time_part=$(echo "$answer" | grep -oE '[0-9]{1,2}(:[0-9]{2})?\s*(AM|PM|am|pm)' | head -1)
        local tz_part=$(echo "$answer" | grep -oE '(EST|CST|MST|PST|EDT|CDT|MDT|PDT|America/[A-Za-z_]+|Europe/[A-Za-z_]+)' | head -1)
        
        if [[ -n "$time_part" ]]; then
          # Convert to 24-hour
          if [[ "$time_part" =~ ([0-9]{1,2}):?([0-9]{2})?\s*(AM|PM|am|pm) ]]; then
            local hour="${BASH_REMATCH[1]}"
            local minute="${BASH_REMATCH[2]:-00}"
            local meridiem=$(echo "${BASH_REMATCH[3]}" | tr '[:lower:]' '[:upper:]')
            
            if [[ "$meridiem" == "PM" ]] && [[ "$hour" -ne 12 ]]; then
              hour=$((hour + 12))
            elif [[ "$meridiem" == "AM" ]] && [[ "$hour" -eq 12 ]]; then
              hour=0
            fi
            
            local cron_time=$(printf "%02d:%02d" $hour $minute)
          fi
          
          # Map timezone
          case "$tz_part" in
            EST|EDT) local cron_tz="America/New_York" ;;
            CST|CDT) local cron_tz="America/Chicago" ;;
            MST|MDT) local cron_tz="America/Denver" ;;
            PST|PDT) local cron_tz="America/Los_Angeles" ;;
            *) local cron_tz="${tz_part:-America/New_York}" ;;
          esac
          
          jq --arg cron_time "$cron_time" \
             --arg cron_tz "$cron_tz" \
             '.data.setup_cron = "yes" | .data.cron_time = $cron_time | .data.cron_tz = $cron_tz | .step = "complete"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
          
          echo -e "${GREEN}✓ Daily memory: $cron_time $cron_tz${NC}"
        else
          echo -e "${YELLOW}Couldn't parse time. Skipping cron setup.${NC}"
          jq '.data.setup_cron = "no" | .step = "complete"' \
             "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
      fi
      
      # Show summary
      echo ""
      echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo -e "${GREEN}✅ Configuration Complete!${NC}"
      echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo ""
      
      # Read all data for summary
      local name=$(jq -r '.data.name' "$state_file")
      local emoji=$(jq -r '.data.emoji' "$state_file")
      local id=$(jq -r '.data.id' "$state_file")
      local specialty=$(jq -r '.data.specialty' "$state_file")
      local model=$(jq -r '.data.model' "$state_file")
      local workspace=$(jq -r '.data.workspace' "$state_file")
      local comm_style=$(jq -r '.data.comm_style' "$state_file")
      local personality=$(jq -r '.data.personality' "$state_file")
      
      echo -e "${CYAN}📋 Agent Summary:${NC}"
      echo ""
      echo -e "  ${YELLOW}Name:${NC} $name $emoji"
      echo -e "  ${YELLOW}ID:${NC} $id"
      echo -e "  ${YELLOW}Specialty:${NC} $specialty"
      echo -e "  ${YELLOW}Model:${NC} $model"
      echo -e "  ${YELLOW}Workspace:${NC} $workspace"
      echo -e "  ${YELLOW}Communication Style:${NC} $comm_style"
      echo -e "  ${YELLOW}Personality:${NC} $personality"
      
      if [[ $(jq -r '.data.discord_channel // empty' "$state_file") ]]; then
        echo -e "  ${YELLOW}Discord Channel ID:${NC} $(jq -r '.data.discord_channel' "$state_file")"
      fi
      
      if [[ $(jq -r '.data.skills // empty' "$state_file") ]] && [[ $(jq -r '.data.skills' "$state_file") != "none" ]]; then
        echo -e "  ${YELLOW}Skills:${NC} $(jq -r '.data.skills' "$state_file")"
      fi
      
      if [[ $(jq -r '.data.boundaries // empty' "$state_file") ]] && [[ $(jq -r '.data.boundaries' "$state_file") != "none" ]]; then
        echo -e "  ${YELLOW}Boundaries:${NC} $(jq -r '.data.boundaries' "$state_file")"
      fi
      
      if [[ $(jq -r '.data.setup_cron' "$state_file") == "yes" ]]; then
        echo -e "  ${YELLOW}Daily Memory:${NC} $(jq -r '.data.cron_time' "$state_file") $(jq -r '.data.cron_tz' "$state_file")"
      fi
      
      echo ""
      echo -e "${CYAN}Ready to create! Run:${NC}"
      echo -e "${GREEN}create agent${NC}"
      ;;
      
    complete)
      echo -e "${YELLOW}⚠️  Configuration already complete. Use 'create agent' to execute.${NC}"
      ;;
      
    *)
      echo -e "${RED}❌ Unknown step: $current_step${NC}"
      exit 1
      ;;
  esac
}

# Get current status
cmd_status() {
  local session_id="$1"
  local state_file=$(get_state_file "$session_id")
  
  if [[ ! -f "$state_file" ]]; then
    echo -e "${RED}❌ No active session found.${NC}"
    exit 1
  fi
  
  jq '.' "$state_file"
}

# Cancel session
cmd_cancel() {
  local session_id="$1"
  local state_file=$(get_state_file "$session_id")
  
  if [[ ! -f "$state_file" ]]; then
    echo -e "${YELLOW}No active session to cancel.${NC}"
    exit 0
  fi
  
  rm -f "$state_file"
  echo -e "${GREEN}✓ Session cancelled${NC}"
}

# Execute agent creation
cmd_execute() {
  local session_id="$1"
  local state_file=$(get_state_file "$session_id")
  
  if [[ ! -f "$state_file" ]]; then
    echo -e "${RED}❌ No active session found.${NC}"
    exit 1
  fi
  
  local step=$(jq -r '.step' "$state_file")
  if [[ "$step" != "complete" ]]; then
    echo -e "${RED}❌ Configuration not complete. Current step: $step${NC}"
    exit 1
  fi
  
  # Read all configuration
  local name=$(jq -r '.data.name' "$state_file")
  local id=$(jq -r '.data.id' "$state_file")
  local emoji=$(jq -r '.data.emoji' "$state_file")
  local specialty=$(jq -r '.data.specialty' "$state_file")
  local model=$(jq -r '.data.model' "$state_file")
  local workspace=$(jq -r '.data.workspace' "$state_file")
  
  # Build create-agent.sh command
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local cmd="$script_dir/create-agent.sh"
  cmd="$cmd --name \"$name\""
  cmd="$cmd --id \"$id\""
  cmd="$cmd --emoji \"$emoji\""
  cmd="$cmd --specialty \"$specialty\""
  cmd="$cmd --model \"$model\""
  cmd="$cmd --workspace \"$workspace\""
  
  # Optional Discord channel
  local discord_channel=$(jq -r '.data.discord_channel // empty' "$state_file")
  if [[ -n "$discord_channel" ]]; then
    cmd="$cmd --discord-channel \"$discord_channel\""
  fi
  
  # Optional cron
  local setup_cron=$(jq -r '.data.setup_cron // "no"' "$state_file")
  if [[ "$setup_cron" == "yes" ]]; then
    local cron_time=$(jq -r '.data.cron_time' "$state_file")
    local cron_tz=$(jq -r '.data.cron_tz' "$state_file")
    cmd="$cmd --setup-cron yes --cron-time \"$cron_time\" --cron-tz \"$cron_tz\""
  fi
  
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Creating agent...${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  # Execute
  eval "$cmd"
  
  # Enhance SOUL.md with context
  local soul_file="$workspace/SOUL.md"
  if [[ -f "$soul_file" ]]; then
    local comm_style=$(jq -r '.data.comm_style // empty' "$state_file")
    local personality=$(jq -r '.data.personality // empty' "$state_file")
    local skills=$(jq -r '.data.skills // empty' "$state_file")
    local boundaries=$(jq -r '.data.boundaries // empty' "$state_file")
    
    # Update Personality section
    if [[ -n "$comm_style" ]] || [[ -n "$personality" ]]; then
      local personality_section="## Personality\n\n"
      if [[ -n "$comm_style" ]]; then
        personality_section+="**Communication style:** $comm_style\n\n"
      fi
      if [[ -n "$personality" ]]; then
        personality_section+="**Key traits:** $personality\n\n"
      fi
      
      sed -i '' "s|\[Define the agent's personality traits, communication style, and approach to work\]|$personality_section|g" "$soul_file"
    fi
    
    # Update Skills section
    if [[ -n "$skills" ]] && [[ "$skills" != "none" ]]; then
      local skills_section="## Skills & Tools\n\n"
      IFS=',' read -ra SKILLS_ARRAY <<< "$skills"
      for skill in "${SKILLS_ARRAY[@]}"; do
        skill=$(echo "$skill" | xargs)
        skills_section+="- $skill\n"
      done
      
      sed -i '' "s|\[List any skills or tools this agent should use\]|$skills_section|g" "$soul_file"
    fi
    
    # Update Boundaries section
    if [[ -n "$boundaries" ]] && [[ "$boundaries" != "none" ]]; then
      local boundaries_section="## Boundaries\n\n$boundaries\n"
      sed -i '' "s|\[Define what this agent should NOT do or when to ask for help\]|$boundaries_section|g" "$soul_file"
    fi
    
    echo -e "${GREEN}✓ SOUL.md enhanced with your inputs${NC}"
  fi
  
  # Clean up state file
  rm -f "$state_file"
  
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                    ║${NC}"
  echo -e "${GREEN}║            ✅  Agent Created!  ✅                   ║${NC}"
  echo -e "${GREEN}║                                                    ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}🎉 $name $emoji is ready!${NC}"
}

# Main command router
main() {
  if [[ $# -lt 1 ]]; then
    usage
  fi
  
  local command="$1"
  shift
  
  case "$command" in
    start)
      cmd_start "$@"
      ;;
    answer)
      cmd_answer "$@"
      ;;
    status)
      cmd_status "$@"
      ;;
    cancel)
      cmd_cancel "$@"
      ;;
    execute)
      cmd_execute "$@"
      ;;
    *)
      echo -e "${RED}Unknown command: $command${NC}"
      usage
      ;;
  esac
}

main "$@"
