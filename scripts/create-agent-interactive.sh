#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${MAGENTA}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                    ║${NC}"
echo -e "${MAGENTA}║         🤖  Agent Creation Wizard  🤖              ║${NC}"
echo -e "${MAGENTA}║                                                    ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}This wizard will help you create a new autonomous agent.${NC}"
echo ""

# ========================================
# Step 1: Agent Name & Auto-ID
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Agent Name${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "$(echo -e ${CYAN}What should we call this agent? ${NC})" AGENT_NAME

# Auto-generate ID from name
AGENT_ID=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# Auto-pick emoji based on name (simple mapping, can be expanded)
case "$(echo $AGENT_NAME | tr '[:upper:]' '[:lower:]')" in
  *research*|*watson*) AGENT_EMOJI="🔬" ;;
  *art*|*picasso*|*image*) AGENT_EMOJI="🎨" ;;
  *health*|*nurse*|*medical*) AGENT_EMOJI="💊" ;;
  *finance*|*money*) AGENT_EMOJI="💰" ;;
  *code*|*dev*|*engineer*) AGENT_EMOJI="💻" ;;
  *write*|*author*) AGENT_EMOJI="✍️" ;;
  *music*) AGENT_EMOJI="🎵" ;;
  *cook*|*chef*) AGENT_EMOJI="👨‍🍳" ;;
  *stoic*|*philosophy*|*aurelius*) AGENT_EMOJI="📚" ;;
  *crypto*|*blockchain*) AGENT_EMOJI="₿" ;;
  *data*|*analytics*) AGENT_EMOJI="📊" ;;
  *teach*|*tutor*) AGENT_EMOJI="🎓" ;;
  *design*) AGENT_EMOJI="🎨" ;;
  *marketing*) AGENT_EMOJI="📢" ;;
  *legal*|*law*) AGENT_EMOJI="⚖️" ;;
  *security*) AGENT_EMOJI="🔒" ;;
  *game*) AGENT_EMOJI="🎮" ;;
  *travel*) AGENT_EMOJI="✈️" ;;
  *sports*|*fitness*) AGENT_EMOJI="💪" ;;
  *weather*) AGENT_EMOJI="🌤️" ;;
  *news*) AGENT_EMOJI="📰" ;;
  *assistant*|*helper*) AGENT_EMOJI="🤖" ;;
  *) AGENT_EMOJI="🤖" ;; # Default
esac

echo -e "${GREEN}✓ Agent: $AGENT_NAME $AGENT_EMOJI${NC}"
echo -e "${GREEN}✓ ID: $AGENT_ID${NC}"
echo ""

# ========================================
# Step 2: Agent Description & Context (COMBINED)
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Agent Description & Personality${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "$(echo -e ${CYAN}What does $AGENT_NAME do? \(1-2 sentences\): ${NC})" AGENT_SPECIALTY
echo ""

read -p "$(echo -e ${CYAN}Communication style \(e.g., professional, casual, technical, friendly\) [professional]: ${NC})" COMM_STYLE
COMM_STYLE=${COMM_STYLE:-professional}

read -p "$(echo -e ${CYAN}Key personality traits \(e.g., helpful, thorough, creative\) [helpful]: ${NC})" PERSONALITY_TRAITS
PERSONALITY_TRAITS=${PERSONALITY_TRAITS:-helpful}

echo ""

# ========================================
# Step 3: Model Selection
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: Model Selection${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Available models:${NC}"
echo "  1) anthropic/claude-opus-4-5      (Most capable, best for complex tasks)"
echo "  2) anthropic/claude-sonnet-4-5    (Balanced, great for most use cases) ⭐"
echo "  3) google/gemini-3-flash-preview  (Fast, good for simple/creative tasks)"
echo "  4) google/gemini-3-pro-preview    (Google's best, strong reasoning)"
echo "  5) Custom model (you specify)"
echo ""
read -p "$(echo -e ${CYAN}Select a model [2]: ${NC})" MODEL_CHOICE
MODEL_CHOICE=${MODEL_CHOICE:-2}

case $MODEL_CHOICE in
  1) AGENT_MODEL="anthropic/claude-opus-4-5" ;;
  2) AGENT_MODEL="anthropic/claude-sonnet-4-5" ;;
  3) AGENT_MODEL="google/gemini-3-flash-preview" ;;
  4) AGENT_MODEL="google/gemini-3-pro-preview" ;;
  5) 
    read -p "$(echo -e ${CYAN}Enter model \(provider/model-name\): ${NC})" AGENT_MODEL
    ;;
  *) 
    echo -e "${YELLOW}Invalid choice, using claude-sonnet-4-5${NC}"
    AGENT_MODEL="anthropic/claude-sonnet-4-5"
    ;;
esac

echo -e "${GREEN}✓ Selected: $AGENT_MODEL${NC}"
echo ""

# ========================================
# Step 4: Workspace
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Workspace${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

DEFAULT_WORKSPACE="$HOME/clawd/agents/$AGENT_ID"
read -p "$(echo -e ${CYAN}Workspace directory [${DEFAULT_WORKSPACE}]: ${NC})" AGENT_WORKSPACE
AGENT_WORKSPACE=${AGENT_WORKSPACE:-$DEFAULT_WORKSPACE}

# Expand tilde if present
AGENT_WORKSPACE="${AGENT_WORKSPACE/#\~/$HOME}"

echo -e "${GREEN}✓ Workspace: $AGENT_WORKSPACE${NC}"
echo ""

# ========================================
# Step 5: Discord Channel
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Discord Channel${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Should $AGENT_NAME be bound to a Discord channel?${NC}"
echo "  1) Yes, use an existing channel (provide channel ID)"
echo "  2) Yes, use an existing channel (provide channel name - will look up ID)"
echo "  3) Yes, create a new channel"
echo "  4) No, skip Discord binding"
echo ""
read -p "$(echo -e ${CYAN}Choose [4]: ${NC})" CHANNEL_CHOICE
CHANNEL_CHOICE=${CHANNEL_CHOICE:-4}

DISCORD_CHANNEL=""
CHANNEL_CONTEXT="$AGENT_SPECIALTY"

case $CHANNEL_CHOICE in
  1)
    read -p "$(echo -e ${CYAN}Enter Discord channel ID: ${NC})" DISCORD_CHANNEL
    ;;
  2)
    read -p "$(echo -e ${CYAN}Enter channel name \(e.g., research, fitness\): ${NC})" CHANNEL_NAME
    # Look up channel ID by name
    echo -e "${YELLOW}Looking up channel ID for #${CHANNEL_NAME}...${NC}"
    
    # Load config and find channel ID
    CONFIG_FILE="$HOME/.openclaw/config.json"
    if [[ -f "$CONFIG_FILE" ]]; then
      # Extract bot token and guild ID
      TOKEN=$(jq -r '.channels.discord.token // empty' "$CONFIG_FILE")
      GUILD_ID=$(jq -r '.channels.discord.guilds | keys[0] // empty' "$CONFIG_FILE")
      
      if [[ -n "$TOKEN" ]] && [[ -n "$GUILD_ID" ]]; then
        # Fetch channels from Discord API
        CHANNELS_JSON=$(curl -s -H "Authorization: Bot $TOKEN" \
          "https://discord.com/api/v10/guilds/$GUILD_ID/channels")
        
        # Find channel by name
        DISCORD_CHANNEL=$(echo "$CHANNELS_JSON" | jq -r ".[] | select(.name == \"$CHANNEL_NAME\" and .type == 0) | .id")
        
        if [[ -n "$DISCORD_CHANNEL" ]]; then
          echo -e "${GREEN}✓ Found channel #${CHANNEL_NAME}: ${DISCORD_CHANNEL}${NC}"
        else
          echo -e "${RED}✗ Channel #${CHANNEL_NAME} not found${NC}"
          read -p "$(echo -e ${CYAN}Enter channel ID manually, or press Enter to skip: ${NC})" DISCORD_CHANNEL
        fi
      else
        echo -e "${RED}✗ Discord config not found${NC}"
        read -p "$(echo -e ${CYAN}Enter channel ID manually, or press Enter to skip: ${NC})" DISCORD_CHANNEL
      fi
    else
      echo -e "${RED}✗ Config file not found${NC}"
      read -p "$(echo -e ${CYAN}Enter channel ID manually, or press Enter to skip: ${NC})" DISCORD_CHANNEL
    fi
    ;;
  3)
    read -p "$(echo -e ${CYAN}What should we call the new channel? \(e.g., research, fitness\): ${NC})" NEW_CHANNEL_NAME
    
    # Create channel using message tool
    echo -e "${YELLOW}Creating Discord channel #${NEW_CHANNEL_NAME}...${NC}"
    
    # Get guild ID
    CONFIG_FILE="$HOME/.openclaw/config.json"
    if [[ -f "$CONFIG_FILE" ]]; then
      GUILD_ID=$(jq -r '.channels.discord.guilds | keys[0] // empty' "$CONFIG_FILE")
      
      if [[ -n "$GUILD_ID" ]]; then
        # Use OpenClaw CLI to create channel
        CHANNEL_OUTPUT=$(openclaw message channel-create --guild-id "$GUILD_ID" --name "$NEW_CHANNEL_NAME" --json 2>&1)
        
        DISCORD_CHANNEL=$(echo "$CHANNEL_OUTPUT" | jq -r '.channel.id // empty')
        
        if [[ -n "$DISCORD_CHANNEL" ]]; then
          echo -e "${GREEN}✓ Created channel #${NEW_CHANNEL_NAME}: ${DISCORD_CHANNEL}${NC}"
        else
          echo -e "${RED}✗ Failed to create channel${NC}"
          echo "$CHANNEL_OUTPUT"
          DISCORD_CHANNEL=""
        fi
      else
        echo -e "${RED}✗ Could not find guild ID${NC}"
      fi
    else
      echo -e "${RED}✗ Config file not found${NC}"
    fi
    ;;
  4)
    echo -e "${YELLOW}Skipping Discord channel binding${NC}"
    DISCORD_CHANNEL=""
    ;;
  *)
    echo -e "${YELLOW}Invalid choice, skipping Discord binding${NC}"
    DISCORD_CHANNEL=""
    ;;
esac

echo ""

# ========================================
# Step 6: Skills & Tools
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 6: Skills & Boundaries${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}What skills or tools should ${AGENT_NAME} use?${NC}"
echo -e "${YELLOW}Examples: web_search, browser, qmd, coding-agent${NC}"
read -p "$(echo -e ${CYAN}Skills/tools \(comma-separated\) [none]: ${NC})" AGENT_SKILLS

echo ""
echo -e "${CYAN}What should ${AGENT_NAME} NOT do?${NC}"
echo -e "${YELLOW}Examples: Don't make purchases, Don't send emails without approval${NC}"
read -p "$(echo -e ${CYAN}Boundaries/constraints [none]: ${NC})" AGENT_BOUNDARIES

echo ""

# ========================================
# Step 7: Daily Memory System
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 7: Daily Memory System${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Set up a daily memory cron job for ${AGENT_NAME}?${NC}"
echo -e "${YELLOW}This creates a job that reviews and updates the agent's daily memory file.${NC}"
echo ""
read -p "$(echo -e ${CYAN}Daily memory schedule \(e.g., \"everyday at 10PM EST\", \"none\" to skip\) [none]: ${NC})" MEMORY_SCHEDULE
MEMORY_SCHEDULE=${MEMORY_SCHEDULE:-none}

SETUP_CRON="no"
CRON_TIME=""
CRON_TZ=""

if [[ "$MEMORY_SCHEDULE" != "none" ]] && [[ -n "$MEMORY_SCHEDULE" ]]; then
  # Parse human-readable time like "everyday at 10PM EST"
  # Extract time (10PM, 9:30PM, etc.)
  TIME_PART=$(echo "$MEMORY_SCHEDULE" | grep -oE '[0-9]{1,2}(:[0-9]{2})?\s*(AM|PM|am|pm)' | head -1)
  
  # Extract timezone (EST, PST, America/New_York, etc.)
  TZ_PART=$(echo "$MEMORY_SCHEDULE" | grep -oE '(EST|CST|MST|PST|EDT|CDT|MDT|PDT|America/[A-Za-z_]+|Europe/[A-Za-z_]+)' | head -1)
  
  if [[ -n "$TIME_PART" ]]; then
    # Convert to 24-hour format HH:MM
    if [[ "$TIME_PART" =~ ([0-9]{1,2}):?([0-9]{2})?\s*(AM|PM|am|pm) ]]; then
      HOUR="${BASH_REMATCH[1]}"
      MINUTE="${BASH_REMATCH[2]:-00}"
      MERIDIEM=$(echo "${BASH_REMATCH[3]}" | tr '[:lower:]' '[:upper:]')
      
      # Convert to 24-hour
      if [[ "$MERIDIEM" == "PM" ]] && [[ "$HOUR" -ne 12 ]]; then
        HOUR=$((HOUR + 12))
      elif [[ "$MERIDIEM" == "AM" ]] && [[ "$HOUR" -eq 12 ]]; then
        HOUR=0
      fi
      
      CRON_TIME=$(printf "%02d:%02d" $HOUR $MINUTE)
    fi
    
    # Map common timezone abbreviations
    case "$TZ_PART" in
      EST|EDT) CRON_TZ="America/New_York" ;;
      CST|CDT) CRON_TZ="America/Chicago" ;;
      MST|MDT) CRON_TZ="America/Denver" ;;
      PST|PDT) CRON_TZ="America/Los_Angeles" ;;
      *) CRON_TZ="${TZ_PART:-America/New_York}" ;;
    esac
    
    if [[ -n "$CRON_TIME" ]]; then
      SETUP_CRON="yes"
      echo -e "${GREEN}✓ Daily memory: $CRON_TIME $CRON_TZ${NC}"
    else
      echo -e "${YELLOW}Could not parse time from \"$MEMORY_SCHEDULE\". Skipping cron setup.${NC}"
    fi
  else
    echo -e "${YELLOW}Could not parse time from \"$MEMORY_SCHEDULE\". Skipping cron setup.${NC}"
  fi
else
  echo -e "${YELLOW}Skipping daily memory cron${NC}"
fi

echo ""

# ========================================
# Step 8: Confirmation
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 8: Review & Confirm${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Agent Summary:${NC}"
echo ""
echo -e "  ${YELLOW}Name:${NC} $AGENT_NAME $AGENT_EMOJI"
echo -e "  ${YELLOW}ID:${NC} $AGENT_ID"
echo -e "  ${YELLOW}Specialty:${NC} $AGENT_SPECIALTY"
echo -e "  ${YELLOW}Model:${NC} $AGENT_MODEL"
echo -e "  ${YELLOW}Workspace:${NC} $AGENT_WORKSPACE"
if [[ -n "$DISCORD_CHANNEL" ]]; then
  echo -e "  ${YELLOW}Discord Channel:${NC} $DISCORD_CHANNEL"
else
  echo -e "  ${YELLOW}Discord Channel:${NC} None"
fi
echo -e "  ${YELLOW}Communication Style:${NC} $COMM_STYLE"
echo -e "  ${YELLOW}Personality:${NC} $PERSONALITY_TRAITS"
if [[ -n "$AGENT_SKILLS" ]] && [[ "$AGENT_SKILLS" != "none" ]]; then
  echo -e "  ${YELLOW}Skills/Tools:${NC} $AGENT_SKILLS"
fi
if [[ -n "$AGENT_BOUNDARIES" ]] && [[ "$AGENT_BOUNDARIES" != "none" ]]; then
  echo -e "  ${YELLOW}Boundaries:${NC} $AGENT_BOUNDARIES"
fi
if [[ "$SETUP_CRON" == "yes" ]]; then
  echo -e "  ${YELLOW}Daily Memory:${NC} $CRON_TIME $CRON_TZ"
fi
echo ""
read -p "$(echo -e ${CYAN}Create this agent? \(y/n\) [y]: ${NC})" CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "${RED}Cancelled.${NC}"
  exit 0
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Creating agent...${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ========================================
# Execute: Create Agent
# ========================================

# Build create-agent.sh command
CREATE_CMD="$SCRIPT_DIR/create-agent.sh \
  --name \"$AGENT_NAME\" \
  --id \"$AGENT_ID\" \
  --emoji \"$AGENT_EMOJI\" \
  --specialty \"$AGENT_SPECIALTY\" \
  --model \"$AGENT_MODEL\" \
  --workspace \"$AGENT_WORKSPACE\""

if [[ -n "$DISCORD_CHANNEL" ]]; then
  CREATE_CMD="$CREATE_CMD --discord-channel \"$DISCORD_CHANNEL\""
fi

if [[ "$SETUP_CRON" == "yes" ]]; then
  CREATE_CMD="$CREATE_CMD --setup-cron yes --cron-time \"$CRON_TIME\" --cron-tz \"$CRON_TZ\""
fi

# Execute
eval "$CREATE_CMD"

# ========================================
# Apply channel config if created new channel
# ========================================

if [[ -n "$DISCORD_CHANNEL" ]] && [[ "$CHANNEL_CHOICE" == "3" ]]; then
  echo ""
  echo -e "${YELLOW}Applying channel configuration...${NC}"
  
  # Get guild ID
  GUILD_ID=$(jq -r '.channels.discord.guilds | keys[0] // empty' "$CONFIG_FILE")
  
  if [[ -n "$GUILD_ID" ]]; then
    # Build config patch
    CONFIG_PATCH=$(cat <<EOF
{
  "channels": {
    "discord": {
      "guilds": {
        "$GUILD_ID": {
          "channels": {
            "$DISCORD_CHANNEL": {
              "allow": true,
              "requireMention": false,
              "systemPrompt": "$CHANNEL_CONTEXT"
            }
          }
        }
      }
    }
  }
}
EOF
)
    
    # Apply via openclaw CLI
    echo "$CONFIG_PATCH" | openclaw gateway config.patch --raw "$(echo $CONFIG_PATCH | jq -c .)" --note "Configure channel for $AGENT_NAME" 2>/dev/null
    
    echo -e "${GREEN}✓ Channel configuration applied${NC}"
  fi
fi

# ========================================
# Customize SOUL.md
# ========================================

echo ""
echo -e "${YELLOW}Enhancing SOUL.md with your inputs...${NC}"

SOUL_FILE="$AGENT_WORKSPACE/SOUL.md"

# Update Personality section
if [[ -n "$COMM_STYLE" ]] || [[ -n "$PERSONALITY_TRAITS" ]]; then
  PERSONALITY_SECTION="## Personality\n\n"
  if [[ -n "$COMM_STYLE" ]]; then
    PERSONALITY_SECTION+="**Communication style:** $COMM_STYLE\n\n"
  fi
  if [[ -n "$PERSONALITY_TRAITS" ]]; then
    PERSONALITY_SECTION+="**Key traits:** $PERSONALITY_TRAITS\n\n"
  fi
  
  # Replace placeholder
  sed -i '' "s|\[Define the agent's personality traits, communication style, and approach to work\]|$PERSONALITY_SECTION|g" "$SOUL_FILE"
fi

# Update Skills section
if [[ -n "$AGENT_SKILLS" ]] && [[ "$AGENT_SKILLS" != "none" ]]; then
  SKILLS_SECTION="## Skills & Tools\n\n"
  IFS=',' read -ra SKILLS_ARRAY <<< "$AGENT_SKILLS"
  for skill in "${SKILLS_ARRAY[@]}"; do
    skill=$(echo "$skill" | xargs) # trim whitespace
    SKILLS_SECTION+="- $skill\n"
  done
  
  sed -i '' "s|\[List any skills or tools this agent should use\]|$SKILLS_SECTION|g" "$SOUL_FILE"
fi

# Update Boundaries section
if [[ -n "$AGENT_BOUNDARIES" ]] && [[ "$AGENT_BOUNDARIES" != "none" ]]; then
  BOUNDARIES_SECTION="## Boundaries\n\n$AGENT_BOUNDARIES\n"
  sed -i '' "s|\[Define what this agent should NOT do or when to ask for help\]|$BOUNDARIES_SECTION|g" "$SOUL_FILE"
fi

echo -e "${GREEN}✓ SOUL.md customized${NC}"

# ========================================
# Done!
# ========================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                    ║${NC}"
echo -e "${GREEN}║            ✅  Agent Created!  ✅                   ║${NC}"
echo -e "${GREEN}║                                                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}🎉 ${AGENT_NAME} ${AGENT_EMOJI} is ready!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review and refine: $SOUL_FILE"
echo "  2. Review heartbeat logic: $AGENT_WORKSPACE/HEARTBEAT.md"
if [[ -n "$DISCORD_CHANNEL" ]]; then
  echo "  3. Test by messaging in your Discord channel"
else
  echo "  3. Test with: sessions_send --label \"$AGENT_ID\" --message \"Hello!\""
fi
echo ""
echo -e "${CYAN}Gateway is restarting to load the new agent...${NC}"
echo ""
