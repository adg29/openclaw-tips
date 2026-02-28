---
name: show-your-work
description: Enforce a "Resources changed" summary at the end of every action that modifies files, config, cron jobs, or external resources. Use when you want the agent to always report what changed after completing tasks. Triggers on "show your work", "track changes", "resources changed", or any request to make the agent more transparent about modifications.
---

# Show Your Work

After completing any action that creates, modifies, or deletes resources, end the message with a **Resources changed** summary.

## Format

```
Resources changed:
• path/or/resource (new|edit|delete) — brief description
```

## Rules

1. Include **all** resources touched — internal (files, config, cron jobs, skills) and external (third-party pages, databases, integrations)
2. Use `new` for created, `edit` for modified, `delete` for removed
3. Keep descriptions brief — one line per resource
4. Place the summary as the **last thing** in the message
5. Skip the summary only when no resources were changed (e.g., read-only queries)

## Examples

```
Resources changed:
• scripts/deploy.sh (new) — deployment script for staging
• .env.local (edit) — added BROWSERBASE_API_KEY
• cron: daily-backup (new) — runs at 02:00 UTC
```

```
Resources changed:
• MEMORY.md (edit) — added team member notes from today's call
• memory/2026-02-28.md (new) — daily log entry
```

## Installation

Add this to your `AGENTS.md` under a "Show Your Work" section, or install as a skill. The behavior will apply across all sessions and channels.
