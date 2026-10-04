# skill-pack

SKILL.md files that work across agent tools. Each skill in this repo is a plain folder with a
`SKILL.md` at its root, so it can be dropped into Grok Bot, Cursor, Claude Code, or any other agent
that reads that format.

## Skills

| Skill | Description |
|-------|-------------|
| [show-your-work](skills/show-your-work/) | Make your agent report every file/resource it changes |
| [context-monitor](skills/context-monitor/) | ASCII dashboard for workspace context budget tracking |
| [commit-plan](skills/commit-plan/) | Generate structured commit plans with messages and ready-to-run git commands |
| [ssh-harden](skills/ssh-harden/) | Lock down sshd to key-only auth and install fail2ban with safety pre-checks |
| [bottleneck-audit](skills/bottleneck-audit/) | Audit where work stalled or came back to you, and classify each human dependency |

## Installation

Copy the skill folder you want into the skills directory your agent already uses:

```bash
cp -r skills/show-your-work /path/to/your/agent/skills/
```

Check your agent's own documentation for where that directory lives — it differs per tool, and some
tools support both a per-project and a global location. Restart or reload the agent afterwards if it
caches its skill list.

## Contributing

Got a useful agent pattern? Open a PR! Each skill is a single folder laid out like this:

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable helpers
├── references/       # Optional: docs loaded on-demand
└── assets/           # Optional: templates, images, etc.
```

`SKILL.md` starts with YAML frontmatter holding at least a `name` and a `description`. The
description is what an agent matches against when deciding whether to load the skill, so state what
the skill does and the phrases that should trigger it. Everything after the frontmatter is the
instructions the agent follows once loaded.

## License

MIT
