# Conversational Agent Creation - Formatting Guide

This guide defines the exact formatting and flow for conversational agent creation in Discord/chat.

## Formatting Rules

### 1. Number Every Question (CRITICAL)
**❌ Wrong:**
```
What should we call this agent?
...
What does Aurelius do?
...
What's Aurelius's communication style?
```

**✅ Right:**
```
1. What should we call this agent?
...
2. What does Aurelius do?
...
3. What's Aurelius's communication style?
```

**Rule:** Each question MUST be numbered sequentially (1., 2., 3., etc.). This helps users track progress through the flow. Never skip this.

### 2. No Extra Fluff Text
**❌ Wrong:**
```
Got it! Starting a new agent creation flow. Let's do this conversationally.

1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)
```

**✅ Right:**
```
1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)
```

**Rule:** Only show the actual question. No introductory text, no enthusiasm, no preamble.

### 3. Agent Name Confirmation
**❌ Wrong:**
```
✓ Agent: Aurelius 📚
✓ ID: aurelius

What does Aurelius do?
```

**✅ Right:**
```
✓ Agent: Aurelius 📚

What does Aurelius do?
```

**Rule:** Don't show the auto-generated ID to the user. It's an internal detail.

### 4. Summary Format
**❌ Wrong (Table):**
```
┌─────────────┬──────────────────────────────────────────┐
│ Setting     │ Value                                    │
├─────────────┼──────────────────────────────────────────┤
│ **Name**    │ Aurelius 📚                              │
│ **ID**      │ aurelius                                 │
│ **Style**   │ philosophical, contemplative             │
└─────────────┴──────────────────────────────────────────┘
```

**✅ Right (Bullet points):**
```
**Name:** Aurelius 📚
**Specialty:** Stoic philosopher and motivational guide
**Style:** philosophical, contemplative, uses ancient wisdom
**Model:** Claude Sonnet 4.5
**Discord:** New #aurelius channel
**Memory cron:** Daily at 9 PM EST
**Workspace:** ~/clawd/agents/aurelius
```

**Rule:** Use clean bullet-point format with bold labels. One line per setting.

### 5. Final Confirmation
**❌ Wrong:**
```
Create this agent? (yes/no)
```

**✅ Right:**
```
Create this agent?
```

**Rule:** Keep it simple. User can say yes/no/confirm/create without needing explicit options.

### 6. Post-Creation Introduction
After successful creation, the agent should **introduce itself in its bound channel** and tag the user.

**Example:**
```
[In #aurelius channel]
@don Greetings. I am Aurelius, your Stoic philosopher and guide. 📚

I'm here to share wisdom from Marcus Aurelius, Seneca, and Epictetus—helping you navigate life's challenges with equanimity and reason.

*"The impediment to action advances action. What stands in the way becomes the way."*
— Marcus Aurelius

Feel free to ask me anything about Stoic philosophy, seek guidance on difficulties you're facing, or just reflect on the nature of virtue and wisdom.
```

**Implementation:**
After agent creation completes successfully:
1. Get the bound Discord channel ID from the config
2. Send an introduction message in that channel
3. Tag the user who created the agent (@userId)
4. Include:
   - Greeting
   - Agent's purpose/specialty
   - A relevant quote or example of its style
   - Call to action / invitation to interact

## Complete Flow Example

### Step 1: Trigger
```
User: create agent
Agent: 1. What should we call this agent? (e.g., Watson, Picasso, Aurelius)
```

### Step 2: Name
```
User: Aurelius
Agent: ✓ Agent: Aurelius 📚

2. What does Aurelius do? (1-2 sentences)
```

### Step 3: Description
```
User: Stoic philosopher and motivational guide
Agent: ✓ Specialty: Stoic philosopher and motivational guide

3. What's Aurelius's communication style? (e.g., philosophical, contemplative, uses ancient wisdom)
```

### Step 4: Style
```
User: philosophical, contemplative, uses ancient wisdom
Agent: ✓ Style: philosophical, contemplative, uses ancient wisdom

4. Which model should Aurelius use?
   (a) opus — Claude Opus 4.5 (deep reasoning)
   (b) sonnet — Claude Sonnet 4.5 (balanced) ⭐
   (c) gemini — Gemini 3 Pro (fast)
   (d) gemini-flash — Gemini 3 Flash (fastest)
   (e) kimi — Kimi K2.5 (free, great for coding)
```

### Step 5: Model
```
User: b
Agent: ✓ Model: Claude Sonnet 4.5

5. Discord channel for Aurelius?
   (a) Create a new #aurelius channel
   (b) Use an existing channel (provide name or ID)
   (c) No Discord channel (CLI/programmatic only)
```

### Step 6: Discord
```
User: a
Agent: ✓ Discord: Create new #aurelius channel

6. Set up daily memory cron? This lets Aurelius review conversations and update its memory file at end of day.
   (a) Yes (recommended for agents with ongoing conversations)
   (b) No
```

### Step 7: Memory Cron
```
User: a
Agent: ✓ Daily memory cron: Yes

7. What time should Aurelius update its memory? (24h format, EST)
   e.g., 21:00 for 9PM EST, 02:30 for 10:30PM PST
```

### Step 8: Cron Time
```
User: 21:00 EST
Agent: ✓ Cron time: 21:00 EST

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Summary — Ready to create Aurelius?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Name:** Aurelius 📚
**Specialty:** Stoic philosopher and motivational guide
**Style:** philosophical, contemplative, uses ancient wisdom
**Model:** Claude Sonnet 4.5
**Discord:** New #aurelius channel
**Memory cron:** Daily at 21:00 EST
**Workspace:** ~/clawd/agents/aurelius

Create this agent?
```

### Step 9: Confirmation
```
User: yes
Agent: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       Creating Aurelius...
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       
       ✓ Created workspace at ~/clawd/agents/aurelius
       ✓ Generated SOUL.md and HEARTBEAT.md
       ✓ Created Discord channel #aurelius
       ✓ Updated gateway config
       ✓ Set up daily memory cron (21:00 EST)
       ✓ Gateway restarting...
       
       ✅ Aurelius is ready!
```

### Step 10: Introduction (In #aurelius channel)
```
[In #aurelius channel]
@don Greetings. I am Aurelius, your Stoic philosopher and guide. 📚

I'm here to share wisdom from Marcus Aurelius, Seneca, and Epictetus—helping you navigate life's challenges with equanimity and reason.

*"The impediment to action advances action. What stands in the way becomes the way."*
— Marcus Aurelius

Feel free to ask me anything about Stoic philosophy, seek guidance on difficulties you're facing, or just reflect on the nature of virtue and wisdom.
```

## Implementation Notes

### For Agents Handling This Flow
When you detect a "create agent" intent:

1. **Check for active session:**
   ```bash
   SESSION_ID="discord-${USER_ID}"
   if [[ -f ~/.openclaw/tmp/agent-creation/session-$SESSION_ID.json ]]; then
     # Resume existing session
   else
     # Start new session
   fi
   ```

2. **Track state:**
   - Store: name, specialty, style, model, discord, cron, cron_time
   - Auto-generate: id, emoji, workspace

3. **Format responses:**
   - Use checkmarks (✓) for confirmations
   - Use numbered lists for choices
   - Use bold (**) for labels in summary
   - Keep questions concise

4. **Post-creation:**
   - Call `create-agent.sh` with all params
   - Wait for completion
   - Get channel ID from result
   - Send introduction message to channel with user tag

### Discord Channel Lookup
When user provides channel name:
```bash
# Get channel ID by name
openclaw gateway config.get | jq -r '.channels.discord.guilds."GUILD_ID".channels | to_entries[] | select(.value.systemPrompt | contains("channel name")) | .key'
```

### Channel Creation
When creating new channel:
```bash
openclaw message channel-create \
  --guild-id "$GUILD_ID" \
  --name "$CHANNEL_NAME" \
  --json | jq -r '.channel.id'
```

### Introduction Message
After agent is created and gateway restarts:
```bash
openclaw message send \
  --channel discord \
  --target "$CHANNEL_ID" \
  --message "<@$USER_ID> Greetings. I am $AGENT_NAME..."
```

Or via the message tool:
```typescript
message({
  action: "send",
  channel: "discord",
  target: channelId,
  message: `<@${userId}> Greetings. I am ${agentName}...\n\n${introduction}`
})
```

## Edge Cases

### User Cancels Mid-Flow
```
User: cancel
Agent: ✓ Agent creation cancelled
```

Clean up session state:
```bash
rm ~/.openclaw/tmp/agent-creation/session-$SESSION_ID.json
```

### Invalid Input
Example: Model choice out of range
```
User: z
Agent: Invalid choice. Please enter a-e.

Which model should Aurelius use?
(a) opus — Claude Opus 4.5 (deep reasoning)
(b) sonnet — Claude Sonnet 4.5 (balanced) ⭐
...
```

### Discord Channel Already Exists
If channel name conflicts:
```
Agent: ⚠️ Channel #aurelius already exists.

Use existing channel or choose a different name?
(a) Use existing #aurelius
(b) Enter a different name
```

## Testing

Test the flow manually:
```bash
# Start
cd ~/.openclaw/skills/agent-council
./scripts/conversational-agent-helper.sh --start

# Answer each question
./scripts/conversational-agent-helper.sh "TestAgent"
./scripts/conversational-agent-helper.sh "Test description"
./scripts/conversational-agent-helper.sh "casual"
./scripts/conversational-agent-helper.sh "2"
./scripts/conversational-agent-helper.sh "3"
./scripts/conversational-agent-helper.sh "2"
./scripts/conversational-agent-helper.sh "21:00 EST"

# Check status
./scripts/conversational-agent-helper.sh --status

# Execute
./scripts/conversational-agent-helper.sh --execute
```

## Summary of Changes from Original

1. ❌ Remove "Got it! Starting..." fluff text → ✅ Just ask the question
2. ❌ Show "✓ ID: aurelius" → ✅ Hide the ID (internal detail)
3. ❌ Table format for summary → ✅ Clean bullet points with **bold labels**
4. ❌ Just "✅ Agent created!" → ✅ Agent introduces itself in channel and tags user

These changes make the flow cleaner, more professional, and more engaging for the user.
