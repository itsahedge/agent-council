# OpenClaw Integration - Quick Reference

**For the main OpenClaw agent:** Use this guide to handle conversational agent creation.

## Trigger Phrases

Detect these user messages to start agent creation:

- "create agent"
- "make agent"
- "new agent"
- "create an agent"
- "let's create an agent"
- "build an agent"
- "set up an agent"

## Simple Integration Pattern

```typescript
// In your message handler
if (userMessage.toLowerCase().match(/\b(create|make|new|build|set up) (an? )?agent\b/i)) {
  
  const sessionId = `${channel}-${userId}`;
  const skillPath = "~/.openclaw/skills/agent-council";
  
  // Check if user has active session
  const stateCheck = exec(`test -f ~/.openclaw/tmp/agent-creation/session-${sessionId}.json && echo "exists"`);
  
  if (stateCheck.includes("exists")) {
    // Session in progress - this is an answer
    return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} "${userMessage}"`);
  } else {
    // Start new session
    return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} --start`);
  }
}

// If user has active session, treat ALL messages as answers
const sessionId = `${channel}-${userId}`;
const hasSession = exec(`test -f ~/.openclaw/tmp/agent-creation/session-${sessionId}.json && echo "exists"`);

if (hasSession.includes("exists")) {
  // Special commands
  if (userMessage.toLowerCase() === "cancel agent") {
    return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} --cancel`);
  }
  
  if (userMessage.toLowerCase() === "status" || userMessage.toLowerCase() === "agent status") {
    return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} --status`);
  }
  
  // Check if ready to execute
  const state = JSON.parse(exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} --status`));
  
  if (state.step === "complete" && userMessage.toLowerCase().match(/\b(yes|create|confirm)\b/i)) {
    return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} --execute`);
  }
  
  // Otherwise, treat as answer
  return exec(`cd ${skillPath} && ./conversational-agent-helper.sh --session-id ${sessionId} "${userMessage}"`);
}
```

## Minimal Pattern (even simpler)

For a minimal implementation that "just works":

```bash
# Detect intent
SKILL_PATH="$HOME/.openclaw/skills/agent-council"
SESSION_ID="${CHANNEL}-${USER_ID}"

# Check for session file
if [[ -f "$HOME/.openclaw/tmp/agent-creation/session-${SESSION_ID}.json" ]]; then
  # Has active session - pass message as answer
  cd "$SKILL_PATH" && ./conversational-agent-helper.sh --session-id "$SESSION_ID" "$USER_MESSAGE"
elif [[ "$USER_MESSAGE" =~ (create|make|new).*agent ]]; then
  # Start new session
  cd "$SKILL_PATH" && ./conversational-agent-helper.sh --session-id "$SESSION_ID" --start
fi
```

## Commands Users Can Use

During agent creation, users can type:

- **cancel** - Cancel the current agent creation
- **status** - See what's been configured so far
- **create agent** - (when complete) Execute the agent creation
- Any other text is treated as an answer to the current question

## Session ID Best Practices

**Format:** `${channel}-${userId}` or `discord-${userId}`

**Why:** Allows multiple users to create agents simultaneously without conflicts.

**Example:**
- User A in Discord: `discord-123456789`
- User B in Slack: `slack-987654321`

## Testing

Test the flow manually:

```bash
# Start
cd ~/.openclaw/skills/agent-council
./conversational-agent-helper.sh --session-id test --start

# Answer questions
./conversational-agent-helper.sh --session-id test "TestBot"
./conversational-agent-helper.sh --session-id test "Test description"
./conversational-agent-helper.sh --session-id test "casual"
./conversational-agent-helper.sh --session-id test "helpful"
./conversational-agent-helper.sh --session-id test "2"
./conversational-agent-helper.sh --session-id test ""
./conversational-agent-helper.sh --session-id test "4"
./conversational-agent-helper.sh --session-id test ""
./conversational-agent-helper.sh --session-id test ""
./conversational-agent-helper.sh --session-id test ""

# Execute
./conversational-agent-helper.sh --session-id test --execute

# Or cancel
./conversational-agent-helper.sh --session-id test --cancel
```

## Error Handling

```typescript
try {
  const output = exec(`cd ${skillPath} && ./conversational-agent-helper.sh ...`);
  return output;
} catch (error) {
  // Session might not exist, or command failed
  if (error.message.includes("No active session")) {
    return "No agent creation in progress. Type 'create agent' to start!";
  }
  throw error;
}
```

## Example Discord Flow

```
User: create agent
Bot: ✨ Started agent creation session!
     
     What should we call this agent?
     Examples: Atlas, Watson, Picasso, Aurora

User: Socrates
Bot: ✓ Agent: Socrates 📚
     ✓ ID: socrates
     
     What does Socrates do?
     Give me 1-2 sentences describing the agent's purpose.

User: Philosophical guide using Socratic method
Bot: ✓ Specialty saved
     
     What's the communication style?
     Examples: professional, casual, technical, friendly, philosophical
     Default: professional

User: philosophical
Bot: ✓ Communication style: philosophical
     
     Key personality traits?
     ...

[continues until complete]

Bot: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     ✅ Configuration Complete!
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     
     📋 Agent Summary:
     
       Name: Socrates 📚
       ID: socrates
       Specialty: Philosophical guide using Socratic method
       ...
     
     Ready to create! Run:
     create agent

User: create agent
Bot: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     Creating agent...
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     
     [creation output]
     
     ╔════════════════════════════════════════════════════╗
     ║                                                    ║
     ║            ✅  Agent Created!  ✅                   ║
     ║                                                    ║
     ╚════════════════════════════════════════════════════╝
     
     🎉 Socrates 📚 is ready!
```

## Quick Commands Reference

```bash
# Start session
./conversational-agent-helper.sh --start [--session-id ID]

# Provide answer
./conversational-agent-helper.sh [--session-id ID] "answer text"

# Check status
./conversational-agent-helper.sh --status [--session-id ID]

# Cancel
./conversational-agent-helper.sh --cancel [--session-id ID]

# Execute (when complete)
./conversational-agent-helper.sh --execute [--session-id ID]
```

## Next Steps

1. Add this pattern to your main agent's message handler
2. Test with `--session-id test` first
3. Deploy to production with user-specific session IDs
4. Monitor `~/.openclaw/tmp/agent-creation/` for active sessions
5. Set up periodic cleanup for old sessions (>24h)
