# Agent Council

Minimal toolkit for creating autonomous AI agents in [OpenClaw](https://openclaw.ai).

## Installation

```bash
# Clone and install
git clone https://github.com/itsahedge/agent-council.git ~/.openclaw/skills/agent-council

# Enable in config
openclaw gateway config.patch --raw '{"skills":{"entries":{"agent-council":{"enabled":true}}}}'
```

## Usage

```bash
~/.openclaw/skills/agent-council/scripts/create-agent.sh <id> <name> <emoji> <specialty> [model] [discord-channel-id]
```

**Example:**
```bash
./create-agent.sh watson Watson 🔬 "Deep research" anthropic/claude-opus-4-5 1468311503156281477
```

This creates:
- `~/clawd/agents/<id>/` with SOUL.md, HEARTBEAT.md, memory/
- Adds agent to gateway config
- Optionally binds to Discord channel

## Manual Setup

See [SKILL.md](./SKILL.md) for templates and manual setup instructions.

## License

MIT
