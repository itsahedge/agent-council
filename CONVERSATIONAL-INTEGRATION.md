# Conversational Agent Creation - Integration Guide

This guide explains how to integrate the conversational agent creation flow with OpenClaw for natural Discord/chat interactions.

## Overview

The conversational flow uses state management to track progress between messages, allowing users to create agents one question at a time through natural conversation.

## How It Works

**State Management:**
- Each session has a unique ID (default: "default")
- State is stored in JSON files at `~/.openclaw/tmp/agent-creation/session-<id>.json`
- State persists between messages, allowing pause/resume

**Flow:**
1. User triggers "create agent" → Start session
2. Agent asks first question
3. User responds → Answer saved, next question asked
4. Repeat until complete
5. User confirms → Agent is created

## Usage from OpenClaw

### Method 1: Direct Shell Execution

When a user wants to create an agent:

```typescript
// Start session
exec({
  command: `cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh --start`,
  session_id: user_id  // Optional: use user ID for multi-user support
})

// Provide answer (subsequent messages)
exec({
  command: `cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh "${user_answer}"`,
  session_id: user_id
})

// Execute when complete
exec({
  command: `cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh --execute`,
  session_id: user_id
})
```

### Method 2: Skill Pattern Recognition

Add pattern matching in your agent's logic:

```typescript
// Detect "create agent" intent
if (message.toLowerCase().includes("create agent") || 
    message.toLowerCase().includes("new agent") ||
    message.toLowerCase().includes("make an agent")) {
  
  // Check if session exists
  const stateFile = `~/.openclaw/tmp/agent-creation/session-${userId}.json`;
  const hasSession = fs.existsSync(stateFile);
  
  if (hasSession) {
    // Session in progress - treat message as answer
    exec(`cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh --session-id ${userId} "${message}"`);
  } else {
    // Start new session
    exec(`cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh --session-id ${userId} --start`);
  }
}
```

### Method 3: State-Aware Response

For more advanced integration, check the current state to provide context-aware help:

```typescript
// Get current state
const state = JSON.parse(
  exec(`cd ~/.openclaw/skills/agent-council && ./conversational-agent-helper.sh --session-id ${userId} --status`)
);

const currentStep = state.step;

// Provide contextual help based on step
if (currentStep === "model") {
  // Show model options
} else if (currentStep === "complete") {
  // Ready to create - confirm
}
```

## Session Management

### Multi-User Support

Use unique session IDs per user to support multiple concurrent agent creations:

```bash
# Per-user sessions
export AGENT_CREATION_SESSION_ID="${USER_ID}"
./conversational-agent-helper.sh --start

# Or pass explicitly
./conversational-agent-helper.sh --session-id "discord-${USER_ID}" --start
```

### Session Cleanup

Sessions persist until explicitly cancelled or executed. Clean up old sessions:

```bash
# Manual cleanup
rm ~/.openclaw/tmp/agent-creation/session-*.json

# Automatic cleanup (add to cron)
find ~/.openclaw/tmp/agent-creation -name "session-*.json" -mtime +7 -delete
```

## Example Discord Integration

Here's a complete example of how an OpenClaw agent might handle this:

```typescript
async function handleMessage(message, userId) {
  const sessionId = `discord-${userId}`;
  const stateFile = `~/.openclaw/tmp/agent-creation/session-${sessionId}.json`;
  
  // Check for "create agent" intent
  if (message.toLowerCase().match(/^(create|make|new) agent$/i)) {
    // Start new session
    const output = await exec(
      `cd ~/.openclaw/skills/agent-council && ` +
      `./conversational-agent-helper.sh --session-id ${sessionId} --start`
    );
    return output; // Returns first question
  }
  
  // Check if user has active session
  if (fs.existsSync(stateFile)) {
    const state = JSON.parse(fs.readFileSync(stateFile));
    
    // Handle special commands
    if (message.toLowerCase() === "cancel") {
      await exec(
        `cd ~/.openclaw/skills/agent-council && ` +
        `./conversational-agent-helper.sh --session-id ${sessionId} --cancel`
      );
      return "Agent creation cancelled.";
    }
    
    if (message.toLowerCase() === "status") {
      return JSON.stringify(state, null, 2);
    }
    
    if (state.step === "complete" && message.toLowerCase().includes("create")) {
      // Execute creation
      const output = await exec(
        `cd ~/.openclaw/skills/agent-council && ` +
        `./conversational-agent-helper.sh --session-id ${sessionId} --execute`
      );
      return output; // Returns success message
    }
    
    // Otherwise, treat as answer to current question
    const output = await exec(
      `cd ~/.openclaw/skills/agent-council && ` +
      `./conversational-agent-helper.sh --session-id ${sessionId} "${message}"`
    );
    return output; // Returns next question
  }
  
  // Not in agent creation mode
  return null;
}
```

## State Schema

The state file structure:

```json
{
  "session_id": "discord-123456789",
  "step": "name",
  "started": 1770356801,
  "data": {
    "name": "Aurelius",
    "id": "aurelius",
    "emoji": "📚",
    "specialty": "Stoic philosophy",
    "model": "anthropic/claude-sonnet-4-5",
    "workspace": "/Users/claire/clawd/agents/aurelius",
    "comm_style": "philosophical",
    "personality": "wise, patient",
    "discord_channel": "",
    "skills": "none",
    "boundaries": "Focus on Stoic philosophy",
    "setup_cron": "no"
  }
}
```

## Steps Flow

1. **name** → Ask for agent name
2. **description** → Ask what the agent does
3. **communication_style** → Ask for communication style
4. **personality** → Ask for personality traits
5. **model** → Ask for model selection
6. **model_custom** → (conditional) Ask for custom model string
7. **workspace** → Ask for workspace path
8. **discord** → Ask about Discord binding
9. **discord_name** / **discord_id** / **discord_new** → (conditional) Discord channel details
10. **skills** → Ask for skills/tools
11. **boundaries** → Ask for boundaries
12. **cron** → Ask for daily memory schedule
13. **complete** → Show summary, ready to execute

## Best Practices

1. **Always use session IDs** - Prevents conflicts in multi-user environments
2. **Validate answers** - Check for empty/invalid input before accepting
3. **Provide examples** - The script shows examples for each question
4. **Allow cancellation** - Let users cancel at any time with "cancel"
5. **Show progress** - Use the status command to show what's been collected
6. **Timeout sessions** - Clean up sessions older than 24 hours

## Troubleshooting

**Session not found:**
```bash
# Check if state directory exists
ls -la ~/.openclaw/tmp/agent-creation/

# List active sessions
ls ~/.openclaw/tmp/agent-creation/session-*.json
```

**Step not advancing:**
```bash
# Check current state
./conversational-agent-helper.sh --status

# Cancel and restart
./conversational-agent-helper.sh --cancel
./conversational-agent-helper.sh --start
```

**Execution fails:**
```bash
# Verify completion
jq '.step' ~/.openclaw/tmp/agent-creation/session-default.json
# Should return: "complete"

# Check for missing data
jq '.data' ~/.openclaw/tmp/agent-creation/session-default.json
```

## Next Steps

- Add validation for each step (name length, valid model, etc.)
- Implement edit/back functionality
- Add rich formatting for Discord embeds
- Support for templates (pre-fill some answers)
- Integration with agent templates library
