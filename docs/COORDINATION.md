# Multi-Agent Coordination

How to coordinate multiple agents using OpenClaw's session management.

## Core Tools

### List Active Agents

```typescript
sessions_list({
  kinds: ["agent"],
  limit: 10,
  messageLimit: 3  // Last 3 messages per agent
})
```

### Send Messages to Agents

```typescript
// Fire and forget
sessions_send({
  label: "watson",
  message: "Research the competitive landscape for X"
})

// Wait for response
sessions_send({
  label: "watson",
  message: "What did you find?",
  timeoutSeconds: 300
})
```

### Spawn Sub-Agent Tasks

```typescript
sessions_spawn({
  agentId: "watson",
  task: "Research X and write a report",
  model: "anthropic/claude-opus-4-5",
  runTimeoutSeconds: 3600,
  cleanup: "delete"  // or "keep"
})
```

### Check Agent History

```typescript
sessions_history({
  sessionKey: "watson-session-key",
  limit: 50
})
```

---

## Coordination Patterns

### Pattern 1: Discord-Bound Agents

Each agent owns a Discord channel. Users interact directly.

```
User posts in #research
    ↓
Watson Agent (bound to #research)
    ↓
Responds directly in channel
```

**Use when:**
- ✅ Domain-specific agents (research, health, images)
- ✅ User wants direct access
- ✅ Agent should respond to channel activity

### Pattern 2: Programmatic Delegation

Main agent delegates tasks via `sessions_send`.

```typescript
// Main agent receives: "Research competitor X"

// Delegate to Watson
sessions_send({
  label: "watson",
  message: "Research competitor X: products, pricing, market position"
})

// Watson works independently, updates files
// Main agent checks results later
const results = Read("agents/watson/memory/research-X.md")

// Synthesize and reply
"Research complete! Watson found: [summary]"
```

**Use when:**
- ✅ Main agent coordinates specialists
- ✅ Need response in same session
- ✅ Combining results from multiple agents

### Pattern 3: Background Spawn

For long-running, isolated work:

```typescript
sessions_spawn({
  agentId: "watson",
  task: "Deep dive: analyze competitors A, B, C. Write report.",
  runTimeoutSeconds: 7200,
  cleanup: "keep"  // Keep for review
})
```

Sub-agent:
1. Executes task in isolation
2. Announces completion back
3. Self-deletes (if `cleanup: "delete"`)

**Use when:**
- ✅ Long tasks (>5 minutes)
- ✅ Complex multi-step work
- ✅ Want isolation from main session
- ✅ Background processing

### Pattern 4: Agent-to-Agent

Agents can message each other:

```typescript
// In Watson's context
sessions_send({
  label: "picasso",
  message: "Create an infographic from data in reports/research.md"
})
```

---

## Example: Research Workflow

```typescript
// 1. User asks: "Research competitor X"

// 2. Check if Watson is available
const agents = sessions_list({ kinds: ["agent"] })

// 3. Delegate
sessions_send({
  label: "watson",
  message: "Research competitor X: products, pricing, market position. Write to memory/research-X.md"
})

// 4. Watson works independently:
//    - Uses web_search
//    - Uses web_fetch
//    - Analyzes data
//    - Updates memory file
//    - Reports back

// 5. Main agent retrieves results
const results = Read("agents/watson/memory/research-X.md")

// 6. Synthesize and reply to user
```

---

## Communication Flows

### Main Agent ↔ Specialists

```
User Request
    ↓
Main Agent (Claire)
    ↓
sessions_send("watson", "Research X")
    ↓
Watson Agent
    ↓
- web_search, web_fetch
- Updates memory files
    ↓
Responds to main session
    ↓
Main Agent synthesizes and replies
```

### Hybrid Approach

```
User: "Research X" (in main channel)
    ↓
Main Agent delegates to Watson
    ↓
Watson researches, reports back
    ↓
Main Agent: "Done! Watson found..."
    ↓
User: "Show me more details"
    ↓
Main Agent: "@watson post full findings in #research"
    ↓
Watson posts in #research channel
```

---

## Best Practices

### When to use Discord bindings
- Domain-specific agents (research, health, images)
- User wants direct access
- Agent responds to channel activity

### When to use sessions_send
- Programmatic coordination
- Main agent delegates to specialists
- Need response in same session

### When to use sessions_spawn
- Long-running tasks (>5 minutes)
- Complex multi-step work
- Want isolation from main session
- Background processing

---

## Advanced: Large Multi-Agent Systems

### Coordination Patterns
- Main agent delegates based on specialty
- Agents report progress and request help
- Shared knowledge base for common info
- Cross-agent communication via `sessions_send`

### Task Management
- Integrate with task tracking (Mission Control, Linear)
- Route work based on agent specialty
- Track assignments and completions

### Documentation
- Maintain agent roster in main workspace
- Document delegation patterns
- Keep runbooks for common workflows
