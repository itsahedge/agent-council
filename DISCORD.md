# Discord Channel Management

Create, configure, and rename Discord channels for agent bindings.

## Creating Channels

### Quick Start

```bash
python3 scripts/setup_channel.py \
  --name research \
  --context "Deep research and competitive analysis"
```

### With Category

```bash
python3 scripts/setup_channel.py \
  --name research \
  --context "Deep research and competitive analysis" \
  --category-id "1234567890"
```

### Use Existing Channel

```bash
python3 scripts/setup_channel.py \
  --name personal-finance \
  --id 1466184336901537897 \
  --context "Personal finance management"
```

### Arguments

| Arg | Required | Description |
|-----|----------|-------------|
| `--name` | ✅ | Channel name |
| `--context` | ✅ | Channel purpose (becomes systemPrompt) |
| `--id` | ❌ | Existing channel ID |
| `--category-id` | ❌ | Discord category ID |

### Output

Script outputs a `gateway config.patch` command to run:

```bash
openclaw gateway config.patch --raw '{"channels": {...}}'
```

---

## Renaming Channels

### Quick Start

```bash
python3 scripts/rename_channel.py \
  --id 1234567890 \
  --old-name old-name \
  --new-name new-name
```

### With Workspace Search

Updates references in workspace files:

```bash
python3 scripts/rename_channel.py \
  --id 1234567890 \
  --old-name old-name \
  --new-name new-name \
  --workspace "$HOME/clawd"
```

### Arguments

| Arg | Required | Description |
|-----|----------|-------------|
| `--id` | ✅ | Channel ID |
| `--old-name` | ✅ | Current channel name |
| `--new-name` | ✅ | New channel name |
| `--workspace` | ❌ | Workspace to search/update |

---

## Full Workflow: Agent + Channel

```bash
# 1. Create Discord channel
python3 scripts/setup_channel.py \
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
  --workspace "$HOME/clawd/agents/watson" \
  --discord-channel "1234567890"

# Done! Agent responds in #research channel
```

---

## Gateway Config Reference

### Channel Allowlist

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

### Agent Binding

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

### Agent Config

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

---

## Finding Discord IDs

### Enable Developer Mode

Settings → Advanced → Developer Mode

### Copy IDs

- Right-click channel → Copy ID
- Right-click category → Copy ID
- Right-click user → Copy ID

---

## Environment Variables

### Category ID

```bash
export DISCORD_CATEGORY_ID="1234567890"
python3 scripts/setup_channel.py --name channel-name --context "Purpose"
```

---

## Required Bot Permissions

- `Manage Channels` — Create/rename channels
- `View Channels` — Read channel list
- `Send Messages` — Post in channels
