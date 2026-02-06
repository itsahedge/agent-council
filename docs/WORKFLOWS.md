# Agent Creation Workflows

Three ways to create agents: conversational (chat), interactive wizard (terminal), or programmatic (scripts).

## Option A: Conversational (Discord/Chat)

**Perfect for Discord, Slack, or any chat interface.**

### How It Works

6 questions, one at a time:

1. **Name** → "What should we call this agent?"
2. **Specialty** → "What does [name] do?"
3. **Style** → Communication style (a-d options)
4. **Model** → Which LLM (a-e options)
5. **Discord** → Channel binding (a-c options)
6. **Cron** → Daily memory update (a-c options)

### Commands

```bash
# Start session
./scripts/conversational-agent-helper.sh --start

# Answer questions
./scripts/conversational-agent-helper.sh "your answer"

# Check status
./scripts/conversational-agent-helper.sh --status

# Cancel
./scripts/conversational-agent-helper.sh --cancel

# Create (after summary)
./scripts/conversational-agent-helper.sh yes
```

### Example Flow

```
You: create agent
Bot: 1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)

You: Martha
Bot: ✓ Agent: Martha 🌸
     2. What does Martha do? (1-2 sentences)

You: Provides awesome cooking recipes
Bot: ✓ Specialty: Provides awesome cooking recipes
     3. What's Martha's communication style?
     (a) Warm and encouraging — like a supportive grandma
     (b) Professional and precise — clear instructions
     (c) Casual and fun — playful, keeps it light
     (d) Custom — describe your own

You: a
Bot: ✓ Style: Warm and encouraging
     4. Which model should Martha use?
     (a) opus — Claude Opus 4.5 (deep reasoning)
     (b) sonnet — Claude Sonnet 4.5 (balanced) ⭐
     ...

[continues through Discord and cron questions]

Bot: **Ready to create Martha:**
     • **Name:** Martha 🌸
     • **Specialty:** Provides awesome cooking recipes
     • **Style:** Warm and encouraging
     • **Model:** Claude Sonnet 4.5
     • **Discord:** New #martha channel
     • **Memory cron:** Daily at 11:00 PM EST
     
     Create agent? (yes/no)

You: yes
Bot: ✅ Martha 🌸 created! She'll introduce herself in #martha.
```

### Formatting Rules

- Number each question (1., 2., 3.)
- No fluff ("Got it! Starting...") — just ask
- Use (a), (b), (c) for options
- Don't show auto-generated ID
- Bullet points for summary (not tables)
- Agent introduces itself in channel after creation

---

## Option B: Interactive Wizard (Terminal)

**Step-by-step terminal prompts with richer exploration.**

```bash
scripts/create-agent-interactive.sh
```

### Features

- 🎯 Guided prompts for each field
- 🔍 Channel lookup by name or ID
- 🆕 Create new channels on the fly
- 🎨 Personality customization
- 📝 Auto-enhanced SOUL.md
- ✅ Confirmation before creating

### Workflow

1. Basic info (name, ID, emoji, specialty)
2. Model selection (menu)
3. Workspace path
4. Discord channel (existing, new, or none)
5. Communication style, personality, skills, boundaries
6. Daily memory cron setup
7. Review and confirm

---

## Option C: Programmatic (Scripts/Automation)

**Single command with all options as flags.**

```bash
scripts/create-agent.sh \
  --name "Watson" \
  --id "watson" \
  --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/clawd/agents/watson" \
  --discord-channel "1234567890" \
  --setup-cron yes \
  --cron-time "23:00" \
  --cron-tz "America/New_York"
```

### Arguments

| Arg | Required | Description |
|-----|----------|-------------|
| `--name` | ✅ | Agent name |
| `--id` | ✅ | Agent ID (lowercase, hyphenated) |
| `--emoji` | ✅ | Agent emoji |
| `--specialty` | ✅ | What the agent does |
| `--model` | ✅ | LLM (provider/model-name) |
| `--workspace` | ✅ | Where to create agent files |
| `--discord-channel` | ❌ | Discord channel ID to bind |
| `--setup-cron` | ❌ | yes/no (default: no) |
| `--cron-time` | ❌ | HH:MM (required if setup-cron=yes) |
| `--cron-tz` | ❌ | Timezone (required if setup-cron=yes) |

### What It Does

1. Creates workspace with memory subdirectory
2. Generates SOUL.md and HEARTBEAT.md
3. Updates gateway config (preserves existing agents)
4. Adds Discord channel binding (if specified)
5. Restarts gateway to apply changes
6. Sets up daily memory cron (if requested)

---

## Which Should I Use?

| Feature | Conversational | Wizard | Programmatic |
|---------|----------------|--------|--------------|
| **Best for** | Chat interfaces | Terminal exploration | Automation |
| **Interface** | One Q at a time | All-in-one | Single command |
| **Can pause** | ✅ Yes | ❌ No | N/A |
| **Channel lookup** | ✅ Name/ID | ✅ Name/ID | ID only |
| **Create channels** | ✅ Built-in | ✅ Built-in | Manual |
| **Speed** | Slow (chat) | Moderate | Fast |

**Recommendations:**
- **Discord/chat users:** Conversational
- **Terminal users:** Wizard
- **Scripts/CI:** Programmatic

---

## Cron Session Types (Critical!)

When setting up memory cron jobs, use the right session type:

| Type | Payload | Has History? | Use For |
|------|---------|--------------|---------|
| `main` | `systemEvent` | ✅ Yes | Memory updates, daily reports |
| `isolated` | `agentTurn` | ❌ No | Script execution, API calls |

**⚠️ Common mistake:** Using `isolated` for memory updates. Agent can't summarize conversations it never saw!

```bash
# ✅ CORRECT: Memory update (needs history)
openclaw cron add --session main --system-event "Review today..."

# ✅ CORRECT: Script execution (no history needed)
openclaw cron add --session isolated --agent-turn "Run script..."

# ❌ WRONG: Memory update without history
openclaw cron add --session isolated --agent-turn "Summarize today..."
```

---

## Examples

### Research Agent

```bash
scripts/create-agent.sh \
  --name "Watson" --id "watson" --emoji "🔬" \
  --specialty "Deep research and competitive analysis" \
  --model "anthropic/claude-opus-4-5" \
  --workspace "$HOME/clawd/agents/watson" \
  --discord-channel "1234567890" \
  --setup-cron yes --cron-time "23:00" --cron-tz "America/New_York"
```

### Image Agent

```bash
scripts/create-agent.sh \
  --name "Picasso" --id "picasso" --emoji "🎨" \
  --specialty "Image generation and editing" \
  --model "google/gemini-3-flash-preview" \
  --workspace "$HOME/clawd/agents/picasso" \
  --discord-channel "9876543210"
```

### Health Agent

```bash
scripts/create-agent.sh \
  --name "Nurse Joy" --id "nurse-joy" --emoji "💊" \
  --specialty "Health tracking and wellness" \
  --model "anthropic/claude-sonnet-4-5" \
  --workspace "$HOME/clawd/agents/nurse-joy" \
  --discord-channel "5555555555" \
  --setup-cron yes --cron-time "22:30" --cron-tz "America/New_York"
```
