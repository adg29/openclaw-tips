# 🦞 OpenClaw Tips & Skills

Practical tips for running OpenClaw agents, packaged as installable skills.

## Skills

| Skill | Description |
|-------|-------------|
| [show-your-work](skills/show-your-work/) | Make your agent report every file/resource it changes |
| [context-monitor](skills/context-monitor/) | ASCII dashboard for workspace context budget tracking |

## Installation

Copy a skill folder into your workspace's `skills/` directory, or install the `.skill` package:

```bash
# Copy directly
cp -r skills/show-your-work ~/clawd/skills/

# Or use the packaged .skill file (if available in releases)
openclaw skills install show-your-work.skill
```

## Contributing

Got a useful agent pattern? Open a PR! Each skill should follow the [OpenClaw skill format](https://docs.openclaw.ai):

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable helpers
├── references/       # Optional: docs loaded on-demand
└── assets/           # Optional: templates, images, etc.
```

## License

MIT
