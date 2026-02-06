---
name: agent-council
description: Complete toolkit for creating autonomous AI agents and managing Discord channels for OpenClaw. Use when setting up multi-agent systems, creating new agents, or managing Discord channel organization.
---

# Agent Council

Complete toolkit for creating and managing autonomous AI agents with Discord integration for OpenClaw.

## What This Skill Does

**Agent Creation:**
- Creates autonomous AI agents with self-contained workspaces
- Generates SOUL.md (personality & responsibilities)
- Generates HEARTBEAT.md (cron execution logic)
- Sets up memory system (hybrid architecture)
- Configures gateway automatically
- Binds agents to Discord channels (optional)
- Sets up daily memory cron jobs (optional)

**Discord Channel Management:**
- Creates Discord channels via API
- Configures OpenClaw gateway allowlists
- Sets channel-specific system prompts
- Renames channels and updates references
- Optional workspace file search

## Installation

```bash
# Install from ClawHub
clawhub install agent-council

# Or manual install
cp -r . ~/.openclaw/skills/agent-council/
openclaw gateway config.patch --raw '{
  "skills": {
    "entries": {
      "agent-council": {"enabled": true}
    }
  }
}'
```

## Part 1: Agent Creation

### Quick Start (Interactive)

**Recommended for most users:**

```bash
scripts/create-agent-interactive.sh
```

This launches an interactive wizard that guides you through:
1. ✨ Agent name and basic info
2. 🤖 Model selection
3. 📁 Workspace setup
4. 💬 Discord channel (existing, new, or none)
5. 🎭 Personality and communication style
6. 🛠️ Skills and tools
7. 🚫 Boundaries and constraints
8. 📅 Daily memory cron setup

The wizard will:
- Look up Discord channels by name
- Create new channels if needed
- Auto-generate agent ID from name
- Customize SOUL.md with your inputs
- Set up everything in one smooth flow

### Quick Start (Programmatic)

**For automation and scripts:**

```bash
scripts/create-agent.sh \
  --name "Watson" \
  --id "watson" \
  --emoji "🔬" \
  --specialty "Research and analysis specialist" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/agents/watson" \
  --discord-channel "1234567890" \
  --setup-cron yes \
  --cron-time "23:00" \
  --cron-tz "America/New_York"
```

### Workflow Options

#### Option A: Conversational (Discord / Chat) 🆕

**Perfect for Discord, Slack, or any chat interface!**

Create agents through natural conversation - one question at a time.

**📋 Important:** See `CONVERSATIONAL-FORMAT.md` for exact formatting rules and flow guidelines.

**Quick reference:**
- **Number each question** (1., 2., 3., etc.) — helps users track progress
- No fluff text ("Got it! Starting...") — just ask the question
- Don't show the auto-generated ID — it's an internal detail  
- Use bullet points for summary (not tables)
- Agent should introduce itself in its bound channel after creation

```bash
# Start a new agent creation session
scripts/conversational-agent-helper.sh --start

# Or from OpenClaw directly:
cd ~/.openclaw/skills/agent-council && ./scripts/conversational-agent-helper.sh --start
```

**How it works:**

1. **Start:** Triggers the first question ("What should we call this agent?")
2. **Answer:** Provide your answer in the next message
3. **Continue:** The agent asks the next question automatically
4. **Complete:** When done, confirm with "create agent" to execute

**Example conversation:**

```
You: create agent
Agent: 1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)

You: Aurelius
Agent: ✓ Agent: Aurelius 📚
       
       2. What does Aurelius do? (1-2 sentences)

You: Stoic philosopher and motivational guide
Agent: ✓ Specialty: Stoic philosopher and motivational guide
       
       3. What's Aurelius's communication style?

You: philosophical, contemplative, uses ancient wisdom
Agent: ✓ Style: philosophical, contemplative, uses ancient wisdom
       
       4. Which model should Aurelius use?
          (a) opus — Claude Opus 4.5 (deep reasoning)
          (b) sonnet — Claude Sonnet 4.5 (balanced) ⭐
          ...
```

See `CONVERSATIONAL-FORMAT.md` for the complete flow with all steps and formatting rules.

**Features:**
- 🎯 One question at a time (no overwhelming walls of text)
- 🤖 Auto-generates ID and emoji from name
- 💾 Saves progress between messages
- 🔄 Can pause and resume
- ✅ Shows clean bullet-point summary before creating
- 🎨 Fully customizable responses
- 👋 Agent introduces itself in its channel after creation

**Commands:**
```bash
# Provide an answer
./scripts/conversational-agent-helper.sh "your answer here"

# Check current status
./scripts/conversational-agent-helper.sh --status

# Cancel session
./scripts/conversational-agent-helper.sh --cancel

# Execute creation (when complete)
./scripts/conversational-agent-helper.sh --execute
```

**Perfect for:**
- ✅ Discord bot interactions
- ✅ Chat-based interfaces
- ✅ Step-by-step guidance
- ✅ Users new to agent creation

#### Option B: Interactive Wizard (Terminal)

Run the interactive wizard and follow the prompts:

```bash
scripts/create-agent-interactive.sh
```

**Features:**
- 🎯 Step-by-step guidance
- 🔍 Channel lookup by name or ID
- 🆕 Create new channels on the fly
- 🎨 Personality customization
- 📝 Auto-enhanced SOUL.md
- ✅ Confirmation before creating

**Perfect for:**
- First-time agent creation
- When you want to explore options
- Setting up agents with rich context
- Interactive development

#### Option C: Programmatic Creation

Use when you have all the details ready or need automation:

**1. Gather Requirements**

Prepare these values:
- **Agent name** (e.g., "Watson")
- **Agent ID** (lowercase, hyphenated, e.g., "watson")
- **Emoji** (e.g., "🔬")
- **Specialty** (what the agent does)
- **Model** (which LLM to use)
- **Workspace** (where to create agent files)
- **Discord channel ID** (optional)

**2. Run Creation Script**

```bash
scripts/create-agent.sh \
  --name "Agent Name" \
  --id "agent-id" \
  --emoji "🤖" \
  --specialty "What this agent does" \
  --model "provider/model-name" \
  --workspace "/path/to/workspace" \
  --discord-channel "1234567890" \  # Optional
  --setup-cron yes \                # Optional (default: no)
  --cron-time "23:00" \             # Required if setup-cron=yes
  --cron-tz "America/New_York"      # Required if setup-cron=yes
```

The script automatically:
- ✅ Creates workspace with memory subdirectory
- ✅ Generates SOUL.md and HEARTBEAT.md
- ✅ Updates gateway config (preserves existing agents)
- ✅ Adds Discord channel binding (if specified)
- ✅ Restarts gateway to apply changes
- ✅ Sets up daily memory cron (if --setup-cron=yes)

**3. Customize Agent**

After creation:
- **SOUL.md** - Refine personality, responsibilities, boundaries
- **HEARTBEAT.md** - Add periodic checks and cron logic
- **Workspace files** - Add agent-specific configuration

### Which Workflow Should I Use?

| Feature | Conversational | Terminal Wizard | Programmatic |
|---------|----------------|-----------------|--------------|
| **Best for** | Discord/chat interfaces | Terminal exploration | Automation, scripts |
| **Interface** | One question at a time | All-in-one wizard | Single command |
| **Can pause/resume** | ✅ Yes (saves state) | ❌ Must complete | N/A |
| **Channel lookup** | ✅ By name or ID | ✅ By name or ID | ID only |
| **Create new channels** | ✅ Built-in | ✅ Built-in | Manual |
| **Context gathering** | ✅ Step-by-step | ✅ Guided prompts | Manual |
| **SOUL.md enhancement** | ✅ Auto-populated | ✅ Auto-populated | Template only |
| **Speed** | Slow (chat pace) | Moderate (interactive) | Fast (one command) |
| **Flexibility** | High (one at a time) | High (choose as you go) | High (all options as flags) |

**Recommendation:** 
- **Discord/chat users:** Use conversational mode for natural step-by-step creation
- **Terminal users:** Use the terminal wizard for richer exploration
- **Automation/scripts:** Use programmatic mode for bulk operations or CI/CD

### Agent Architecture

**Self-contained structure:**
```
agents/
├── watson/
│   ├── SOUL.md              # Personality and responsibilities
│   ├── HEARTBEAT.md         # Cron execution logic
│   ├── memory/              # Agent-specific memory
│   │   ├── 2026-02-01.md   # Daily memory logs
│   │   └── 2026-02-02.md
│   └── .openclaw/
│       └── skills/          # Agent-specific skills (optional)
```

**Memory system:**
- Agent-specific memory: `<workspace>/memory/YYYY-MM-DD.md`
- Shared memory access: Agents can read shared workspace
- Daily updates: Optional cron job for summaries

**Cron jobs:**
If your agent needs scheduled tasks:
1. Create HEARTBEAT.md with execution logic
2. Add cron jobs with `--agent-id <agent-id>` and appropriate session type
3. Document in SOUL.md

### Cron Session Types (Critical!)

OpenClaw cron jobs have two session types. **Using the wrong type is a common mistake.**

| Session Type | Payload Type | Has Conversation History? | Use Case |
|--------------|--------------|---------------------------|----------|
| `main` | `systemEvent` | ✅ Yes | Tasks needing conversation context |
| `isolated` | `agentTurn` | ❌ No | Standalone tasks, fresh start |

**Use `main` + `systemEvent` when:**
- Memory updates (summarizing the day's conversations)
- Daily reports/standups ("what did we work on?")
- Anything referencing "today's activity" or "yesterday's conversations"
- Tasks that need to know what the agent discussed with users

**Use `isolated` + `agentTurn` when:**
- Running scripts and posting output (digests, fetches)
- Fetching external data (weather, prices, API calls)
- Generating content from scratch (not based on conversations)
- Self-contained tasks where fresh context is preferred

**Examples:**
```bash
# ✅ CORRECT: Memory update (needs conversation history)
openclaw cron add \
  --name "Watson Daily Memory Update" \
  --agent-id "watson" \
  --cron "0 23 * * *" \
  --tz "America/New_York" \
  --session main \
  --system-event "Review today's conversations and update memory file..."

# ✅ CORRECT: Script execution (no history needed)
openclaw cron add \
  --name "Daily Digest" \
  --agent-id "claire" \
  --cron "0 9 * * *" \
  --tz "America/New_York" \
  --session isolated \
  --agent-turn "Run the digest script and post results..."

# ❌ WRONG: Memory update with isolated session
# This will fail - isolated sessions can't see conversation history!
--session isolated \
--agent-turn "Review today's activity..."  # Can't review what it never saw
```

⚠️ **Common mistake:** Using `isolated` for memory updates. The agent wakes up with no context and can't summarize conversations it never saw!

### Examples

**Research agent:**
```bash
scripts/create-agent.sh \
  --name "Watson" \
  --id "watson" \
  --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/agents/watson" \
  --discord-channel "1234567890" \
  --setup-cron yes \
  --cron-time "23:00" \
  --cron-tz "America/New_York"
```

**Image generation agent:**
```bash
scripts/create-agent.sh \
  --name "Picasso" \
  --id "picasso" \
  --emoji "🎨" \
  --specialty "Image generation and editing specialist" \
  --model "google/gemini-3-flash-preview" \
  --workspace "$HOME/agents/picasso" \
  --discord-channel "9876543210"
```

**Health tracking agent:**
```bash
scripts/create-agent.sh \
  --name "Nurse Joy" \
  --id "nurse-joy" \
  --emoji "💊" \
  --specialty "Health tracking and wellness monitoring" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/agents/nurse-joy" \
  --discord-channel "5555555555" \
  --setup-cron yes \
  --cron-time "22:30" \
  --cron-tz "America/New_York"
```

## Part 2: Discord Channel Management

### Channel Creation

#### Quick Start

```bash
python3 scripts/setup-channel.py \
  --name research \
  --context "Deep research and competitive analysis"
```

#### Workflow

1. Run setup script:
```bash
python3 scripts/setup-channel.py \
  --name <channel-name> \
  --context "<channel-purpose>" \
  [--category-id <discord-category-id>]
```

2. Apply gateway config (command shown by script):
```bash
openclaw gateway config.patch --raw '{"channels": {...}}'
```

#### Options

**With category:**
```bash
python3 scripts/setup-channel.py \
  --name research \
  --context "Deep research and competitive analysis" \
  --category-id "1234567890"
```

**Use existing channel:**
```bash
python3 scripts/setup-channel.py \
  --name personal-finance \
  --id 1466184336901537897 \
  --context "Personal finance management"
```

### Channel Renaming

#### Quick Start

```bash
python3 scripts/rename-channel.py \
  --id 1234567890 \
  --old-name old-name \
  --new-name new-name
```

#### Workflow

1. Run rename script:
```bash
python3 scripts/rename-channel.py \
  --id <channel-id> \
  --old-name <old-name> \
  --new-name <new-name> \
  [--workspace <workspace-dir>]
```

2. Apply gateway config if systemPrompt needs updating (shown by script)

3. Commit workspace file changes (if `--workspace` used)

#### With Workspace Search

```bash
python3 scripts/rename-channel.py \
  --id 1234567890 \
  --old-name old-name \
  --new-name new-name \
  --workspace "$HOME/my-workspace"
```

This will:
- Rename Discord channel via API
- Update gateway config systemPrompt
- Search and update workspace files
- Report files changed for git commit

## Complete Multi-Agent Setup

**Full workflow from scratch:**

```bash
# 1. Create Discord channel
python3 scripts/setup-channel.py \
  --name research \
  --context "Deep research and competitive analysis" \
  --category-id "1234567890"

# (Note the channel ID from output)

# 2. Apply gateway config for channel
openclaw gateway config.patch --raw '{"channels": {...}}'

# 3. Create agent bound to that channel
scripts/create-agent.sh \
  --name "Watson" \
  --id "watson" \
  --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/agents/watson" \
  --discord-channel "1234567890"

# Done! Agent is created and bound to the channel
```

## Configuration

### Discord Category ID

**Option 1: Command line**
```bash
python3 scripts/setup-channel.py \
  --name channel-name \
  --context "Purpose" \
  --category-id "1234567890"
```

**Option 2: Environment variable**
```bash
export DISCORD_CATEGORY_ID="1234567890"
python3 scripts/setup-channel.py --name channel-name --context "Purpose"
```

### Finding Discord IDs

**Enable Developer Mode:**
- Settings → Advanced → Developer Mode

**Copy IDs:**
- Right-click channel → Copy ID
- Right-click category → Copy ID

## Scripts Reference

### create-agent-interactive.sh

**Interactive wizard for agent creation.**

**Usage:**
```bash
scripts/create-agent-interactive.sh
```

**Features:**
- 🎯 Step-by-step guided setup
- 📋 Model selection menu
- 🔍 Channel lookup by name or ID
- 🆕 Create new Discord channels
- 🎨 Personality customization prompts
- 🛠️ Skills and tools configuration
- 📝 Auto-enhanced SOUL.md
- ✅ Confirmation summary

**Workflow:**
1. Basic info (name, ID, emoji, specialty)
2. Model selection (menu with 5 options)
3. Workspace path
4. Discord channel (existing by name/ID, new, or none)
5. Agent context (communication style, personality, skills, boundaries)
6. Daily memory cron setup
7. Review and confirm

**Output:**
- Calls `create-agent.sh` with all flags
- Customizes SOUL.md with user inputs
- Creates agent ready to use

### create-agent.sh

**Non-interactive, programmatic agent creation.**

**Arguments:**
- `--name` (required) - Agent name
- `--id` (required) - Agent ID (lowercase, hyphenated)
- `--emoji` (required) - Agent emoji
- `--specialty` (required) - What the agent does
- `--model` (required) - LLM to use (provider/model-name)
- `--workspace` (required) - Where to create agent files
- `--discord-channel` (optional) - Discord channel ID to bind
- `--setup-cron` (optional) - yes|no (default: no)
- `--cron-time` (optional) - HH:MM format (required if setup-cron=yes)
- `--cron-tz` (optional) - Timezone (required if setup-cron=yes)

**Output:**
- Creates agent workspace
- Generates SOUL.md and HEARTBEAT.md
- Updates gateway config
- Optionally creates daily memory cron

### setup-channel.py

**Arguments:**
- `--name` (required) - Channel name
- `--context` (required) - Channel purpose/context
- `--id` (optional) - Existing channel ID
- `--category-id` (optional) - Discord category ID

**Output:**
- Creates Discord channel (if doesn't exist)
- Generates gateway config.patch command

### rename-channel.py

**Arguments:**
- `--id` (required) - Channel ID
- `--old-name` (required) - Current channel name
- `--new-name` (required) - New channel name
- `--workspace` (optional) - Workspace directory to search

**Output:**
- Renames Discord channel
- Updates gateway systemPrompt (if needed)
- Lists updated files (if workspace search enabled)

## Gateway Integration

This skill integrates with OpenClaw's gateway configuration:

**Agents:**
```json
{
  "agents": {
    "list": [
      {
        "id": "watson",
        "name": "Watson",
        "workspace": "/path/to/agents/watson",
        "model": {
          "primary": "anthropic/claude-opus-4-5"
        },
        "identity": {
          "name": "Watson",
          "emoji": "🔬"
        }
      }
    ]
  }
}
```

**Bindings:**
```json
{
  "bindings": [
    {
      "agentId": "watson",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "1234567890"
        }
      }
    }
  ]
}
```

**Channels:**
```json
{
  "channels": {
    "discord": {
      "guilds": {
        "YOUR_GUILD_ID": {
          "channels": {
            "1234567890": {
              "allow": true,
              "requireMention": false,
              "systemPrompt": "Deep research and competitive analysis"
            }
          }
        }
      }
    }
  }
}
```

## Agent Coordination

Your main agent coordinates with specialized agents using OpenClaw's built-in session management tools.

### List Active Agents

See all active agents and their recent activity:

```typescript
sessions_list({
  kinds: ["agent"],
  limit: 10,
  messageLimit: 3  // Show last 3 messages per agent
})
```

### Send Messages to Agents

**Direct communication:**
```typescript
sessions_send({
  label: "watson",  // Agent ID
  message: "Research the competitive landscape for X"
})
```

**Wait for response:**
```typescript
sessions_send({
  label: "watson",
  message: "What did you find about X?",
  timeoutSeconds: 300  // Wait up to 5 minutes
})
```

### Spawn Sub-Agent Tasks

For complex work, spawn a sub-agent in an isolated session:

```typescript
sessions_spawn({
  agentId: "watson",  // Optional: use specific agent
  task: "Research competitive landscape for X and write a report",
  model: "anthropic/claude-opus-4-5",  // Optional: override model
  runTimeoutSeconds: 3600,  // 1 hour max
  cleanup: "delete"  // Delete session after completion
})
```

The sub-agent will:
1. Execute the task in isolation
2. Announce completion back to your session
3. Self-delete (if `cleanup: "delete"`)

### Check Agent History

Review what an agent has been working on:

```typescript
sessions_history({
  sessionKey: "watson-session-key",
  limit: 50
})
```

### Coordination Patterns

**1. Direct delegation (Discord-bound agents):**
- User messages agent's Discord channel
- Agent responds directly in that channel
- Main agent doesn't need to coordinate

**2. Programmatic delegation (main agent → sub-agent):**
```typescript
// Main agent delegates task
sessions_send({
  label: "watson",
  message: "Research X and update memory/research-X.md"
})

// Watson works independently, updates files
// Main agent checks later or Watson reports back
```

**3. Spawn for complex tasks:**
```typescript
// For longer-running, isolated work
sessions_spawn({
  agentId: "watson",
  task: "Deep dive: analyze competitors A, B, C. Write report to reports/competitors.md",
  runTimeoutSeconds: 7200,
  cleanup: "keep"  // Keep session for review
})
```

**4. Agent-to-agent communication:**
Agents can send messages to each other:
```typescript
// In Watson's context
sessions_send({
  label: "picasso",
  message: "Create an infographic from data in reports/research.md"
})
```

### Best Practices

**When to use Discord bindings:**
- ✅ Domain-specific agents (research, health, images)
- ✅ User wants direct access to agent
- ✅ Agent should respond to channel activity

**When to use sessions_send:**
- ✅ Programmatic coordination
- ✅ Main agent delegates to specialists
- ✅ Need response in same session

**When to use sessions_spawn:**
- ✅ Long-running tasks (>5 minutes)
- ✅ Complex multi-step work
- ✅ Want isolation from main session
- ✅ Background processing

### Example: Research Workflow

```typescript
// Main agent receives request: "Research competitor X"

// 1. Check if Watson is active
const agents = sessions_list({ kinds: ["agent"] })

// 2. Delegate to Watson
sessions_send({
  label: "watson",
  message: "Research competitor X: products, pricing, market position. Write findings to memory/research-X.md"
})

// 3. Watson works independently:
//    - Searches web
//    - Analyzes data
//    - Updates memory file
//    - Reports back when done

// 4. Main agent retrieves results
const results = Read("agents/watson/memory/research-X.md")

// 5. Share with user
"Research complete! Watson found: [summary]"
```

### Communication Flow

**Main Agent (You) ↔ Specialized Agents:**

```
User Request
    ↓
Main Agent (Claire)
    ↓
sessions_send("watson", "Research X")
    ↓
Watson Agent
    ↓
- Uses web_search
- Uses web_fetch
- Updates memory files
    ↓
Responds to main session
    ↓
Main Agent synthesizes and replies
```

**Discord-Bound Agents:**

```
User posts in #research channel
    ↓
Watson Agent (bound to channel)
    ↓
- Sees message directly
- Responds in channel
- No main agent involvement
```

**Hybrid Approach:**

```
User: "Research X" (main channel)
    ↓
Main Agent delegates to Watson
    ↓
Watson researches and reports back
    ↓
Main Agent: "Done! Watson found..."
    ↓
User: "Show me more details"
    ↓
Main Agent: "@watson post your full findings in #research"
    ↓
Watson posts detailed report in #research channel
```

## Troubleshooting

**Agent Creation Issues:**

**"Agent not appearing in Discord"**
- Verify channel ID is correct
- Check gateway config bindings section
- Restart gateway: `openclaw gateway restart`

**⚠️ "Bindings lost after OpenClaw update/onboard"**
The `openclaw onboard` wizard can reset or overwrite bindings. If agents stop responding after an update:
1. Check bindings: `openclaw gateway config.get | jq '.bindings'`
2. Re-add missing bindings via `config.patch`
3. **Important:** The bindings array is REPLACED, not merged. Always include ALL existing bindings when patching.

**"Model errors"**
- Verify model name format: `provider/model-name`
- Check model is available in gateway config

**Cron Job Issues:**

**"Memory update shows 'no activity' or empty summary"**
- **Most common cause:** Using `isolated` session instead of `main`
- Isolated sessions start fresh with no conversation history
- **Fix:** Change to `--session main` with `--system-event "..."`
- See "Cron Session Types" section above

**"Cron job status: skipped, empty-heartbeat-file"**
- Agent needs a HEARTBEAT.md file in its workspace
- Create a minimal HEARTBEAT.md (see template in workspace)

**"Cron job not running for agent"**
- Verify `--agent-id <agent-id>` is set correctly
- Check agent exists in gateway config: `openclaw gateway config.get | jq '.agents.list'`

**Channel Management Issues:**

**"Failed to create channel"**
- Check bot has "Manage Channels" permission
- Verify bot token in OpenClaw config
- Ensure category ID is correct (if specified)

**"Category not found"**
- Verify category ID is correct
- Check bot has access to category
- Try without category ID (creates uncategorized)

**"Channel already exists"**
- Use `--id <channel-id>` to configure existing channel
- Or script will auto-detect and configure it

## Use Cases

- **Domain specialists** - Research, health, finance, coding agents
- **Creative agents** - Image generation, writing, design
- **Task automation** - Scheduled monitoring, reports, alerts
- **Multi-agent systems** - Coordinated team of specialized agents
- **Discord organization** - Structured channels for different agent domains

## Advanced: Multi-Agent Coordination

For larger multi-agent systems:

**Coordination Patterns:**
- Main agent delegates tasks to specialists
- Agents report progress and request help
- Shared knowledge base for common information
- Cross-agent communication via `sessions_send`

**Task Management:**
- Integrate with task tracking systems
- Route work based on agent specialty
- Track assignments and completions

**Documentation:**
- Maintain agent roster in main workspace
- Document delegation patterns
- Keep runbooks for common workflows

## Best Practices

1. **Organize channels in categories** - Group related agent channels
2. **Use descriptive channel names** - Clear purpose from the name
3. **Set specific system prompts** - Give each channel clear context
4. **Document agent responsibilities** - Keep SOUL.md updated
5. **Set up memory cron jobs** - For agents with ongoing work
6. **Test agents individually** - Before integrating into team
7. **Update gateway config safely** - Always use config.patch, never manual edits

## Conversational Flow Formatting (OpenClaw Agents)

When handling agent creation conversationally in Discord/chat, follow these formatting rules:

### Golden Rules

1. **No fluff text** — Don't say "Got it! Let's do this!" Just ask the question.
2. **Hide internal details** — Don't show the auto-generated ID. Users don't need it.
3. **Bullet points for summary** — Use `**Label:** value` format, not tables.
4. **Agent introduces itself** — After creation, agent tags user in its channel with greeting.

### Example Summary Format

**✅ Correct:**
```
**Name:** Aurelius 📚
**Specialty:** Stoic philosopher and motivational guide
**Style:** philosophical, contemplative
**Model:** Claude Sonnet 4.5
**Discord:** New #aurelius channel
**Memory cron:** Daily at 9 PM EST
```

**❌ Wrong:**
```
┌──────────┬────────────────────┐
│ Name     │ Aurelius 📚        │
│ ID       │ aurelius           │  ← Don't show ID
└──────────┴────────────────────┘
```

### Post-Creation Introduction

After agent is created, it should introduce itself in its bound channel:

```
[In #aurelius channel]
@don Greetings. I am Aurelius, your Stoic philosopher and guide. 📚

I'm here to share wisdom from Marcus Aurelius, Seneca, and Epictetus.

*"The impediment to action advances action. What stands in the way becomes the way."*

Feel free to ask me anything about Stoic philosophy.
```

**See `CONVERSATIONAL-FORMAT.md` for complete formatting guide and implementation details.**

## Requirements

**Bot Permissions:**
- `Manage Channels` - To create/rename channels
- `View Channels` - To read channel list
- `Send Messages` - To post in channels

**System:**
- OpenClaw installed and configured
- Node.js/npm via nvm
- Python 3.6+ (standard library only)
- Discord bot token (for channel management)

## See Also

- OpenClaw documentation: https://docs.openclaw.ai
- Multi-agent patterns: https://docs.openclaw.ai/agents
- Discord bot setup: https://docs.openclaw.ai/channels/discord
