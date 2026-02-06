# Troubleshooting

Common issues and solutions for agent-council.

## Agent Creation Issues

### "Agent not appearing in Discord"

1. **Verify channel ID is correct**
   ```bash
   openclaw gateway config.get | jq '.bindings'
   ```

2. **Check gateway config has binding**
   ```bash
   openclaw gateway config.get | jq '.agents.list[] | select(.id == "agent-id")'
   ```

3. **Restart gateway**
   ```bash
   openclaw gateway restart
   ```

### "Bindings lost after OpenClaw update/onboard"

The `openclaw onboard` wizard can reset bindings.

**Fix:**
1. Check bindings:
   ```bash
   openclaw gateway config.get | jq '.bindings'
   ```

2. Re-add missing bindings via `config.patch`

3. **Important:** The bindings array is REPLACED, not merged. Always include ALL existing bindings when patching.

### "Model errors"

- Verify model name format: `provider/model-name`
- Check model is available:
  ```bash
  openclaw gateway config.get | jq '.agents.defaults.models | keys[]' | head -20
  ```

---

## Cron Job Issues

### "Memory update shows 'no activity' or empty summary"

**Most common cause:** Using `isolated` session instead of `main`.

Isolated sessions start fresh with no conversation history. Agent can't summarize conversations it never saw!

**Fix:** Change to `--session main` with `--system-event`:

```bash
# ✅ CORRECT
openclaw cron add \
  --session main \
  --system-event "Review today's conversations..."

# ❌ WRONG
openclaw cron add \
  --session isolated \
  --agent-turn "Summarize today's activity..."
```

### "Cron job status: skipped, empty-heartbeat-file"

Agent needs a `HEARTBEAT.md` file in its workspace.

**Fix:** Create minimal HEARTBEAT.md:
```markdown
# HEARTBEAT.md

Handle cron jobs and system events.
If nothing needs attention, reply HEARTBEAT_OK.
```

### "Cron job not running for agent"

1. Verify `--agent-id` is correct:
   ```bash
   openclaw cron list
   ```

2. Check agent exists:
   ```bash
   openclaw gateway config.get | jq '.agents.list[] | .id'
   ```

---

## Channel Management Issues

### "Failed to create channel"

1. Check bot has `Manage Channels` permission
2. Verify bot token in OpenClaw config
3. If using category, verify category ID is correct

### "Category not found"

1. Verify category ID (right-click → Copy ID)
2. Check bot has access to category
3. Try without category (creates uncategorized channel)

### "Channel already exists"

Use `--id` flag to configure existing channel:
```bash
python3 scripts/setup_channel.py \
  --name existing-channel \
  --id 1234567890 \
  --context "Channel purpose"
```

---

## Script Issues

### "conversational-agent-helper.sh: No such file"

Path bug in helper script. Make sure you're running from skill directory:
```bash
cd ~/.openclaw/skills/agent-council
./scripts/conversational-agent-helper.sh --start
```

### "jq: command not found"

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
apt install jq
```

### "python3: command not found"

Scripts require Python 3.6+:
```bash
# macOS
brew install python3

# Ubuntu/Debian
apt install python3
```

---

## Gateway Config Issues

### "Config patch failed"

1. Validate JSON syntax:
   ```bash
   echo '{"your": "config"}' | jq .
   ```

2. Check for merge conflicts with existing config

3. Use `config.get` to see current state:
   ```bash
   openclaw gateway config.get | jq .
   ```

### "Gateway not restarting"

1. Check gateway is running:
   ```bash
   openclaw gateway status
   ```

2. Manual restart:
   ```bash
   openclaw gateway restart
   ```

---

## Debug Tips

### Check agent status
```bash
openclaw gateway config.get | jq '.agents'
```

### Check bindings
```bash
openclaw gateway config.get | jq '.bindings'
```

### Check channel config
```bash
openclaw gateway config.get | jq '.channels.discord.guilds'
```

### Check cron jobs
```bash
openclaw cron list
```

### View cron job details
```bash
openclaw cron list | jq '.[] | select(.name | contains("Memory"))'
```
