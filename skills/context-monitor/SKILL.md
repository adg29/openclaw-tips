---
name: context-monitor
description: Monitor and visualize workspace context file sizes with ASCII bar charts. Tracks per-file and total usage against configurable caps, with warning thresholds. Use when you want to monitor context window usage, check workspace file sizes, set up context budget alerts, or create a daily context usage report. Triggers on "context usage", "context monitor", "context budget", "workspace size", "file size report".
---

# Context Monitor

Monitor workspace context files to prevent silent truncation from exceeding size caps.

## Quick Check

Run the bundled script for an instant report:

```bash
bash scripts/context-usage-report.sh
```

Output includes ASCII bar charts per file, combined total, and ⚠️/🔴 warnings at 80%/95% thresholds.

## Configuration

Edit the variables at the top of `scripts/context-usage-report.sh`:

| Variable | Default | Description |
|----------|---------|-------------|
| `PER_FILE_CAP` | 20000 | Max chars per workspace file |
| `TOTAL_CAP` | 150000 | Max combined chars |
| `BAR_WIDTH` | 30 | ASCII bar character width |
| `FILES` | Array | Workspace files to monitor |

Adjust `FILES` to match your workspace. Add/remove paths as needed.

## Daily Cron Setup

To post a daily report to a channel:

```bash
openclaw cron create \
  --name "context-usage-report" \
  --cron "0 9 * * *" \
  --channel "slack" \
  --to "YOUR_CHANNEL_ID" \
  --announce \
  --model "openrouter/deepseek/deepseek-v3.2" \
  --message "Run: bash /path/to/scripts/context-usage-report.sh — post the exact output."
```

## When to Act

- **< 70% total**: Healthy — no action needed
- **70–90% total**: Review MEMORY.md for stale content; consider archiving old entries
- **> 90% total**: Urgent — trim files or split into references loaded on-demand
- **Any file > 80%**: Consider splitting that file or moving content to memory search
