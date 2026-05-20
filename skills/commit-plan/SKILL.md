---
name: commit-plan
description: Generate structured commit plans from uncommitted changes. Use when asked to plan commits, organize changes into logical commits, or create commit documentation.
---

# Commit Plan Generator

Creates well-organized commit plans with change inventory, branch context, detailed commit messages, and ready-to-run git commands.

## When to Use

- User asks to "plan commits" or "create a commit plan"
- User wants to organize changes into logical commits
- User needs commit documentation before committing

## Workflow

### Step 1: Inventory Changes

Run these commands to understand the current state:

```bash
# Get branch and last commit
git branch --show-current
git log -1 --format='%H %s'

# Get all changes (staged and unstaged)
git status --short
git diff --stat
git diff --staged --stat
```

### Step 2: Analyze and Group Changes

- Group related changes into logical commits
- Each commit should represent one logical change
- Order commits by dependency (base changes first)

### Step 3: Create Commit Plan File

Create a markdown file at `commits/YYYY-MM-DD-brief-description.md` with this structure:

```markdown
# Commit Plan: [Brief Description]

**Date:** YYYY-MM-DD
**Branch:** `branch-name`
**Prior Commit:** `hash` - commit message

---

## Summary

[1-2 sentence overview of what these changes accomplish]

---

## Commit N: [Commit Title]

### Files to Stage

```
path/to/file1.ts
path/to/file2.tsx
```

### Files Detail

| File | Action | Lines |
|------|--------|-------|
| `path/to/file1.ts` | Create/Modify/Delete | +X/-Y |

### Commit Message

```
type(scope): Short summary (max 50 chars)

Problem:
[What issue or need prompted this change]

Solution:
[What was done to address it]

Key Details:
- [Important implementation detail 1]
- [Important implementation detail 2]

Dependencies:
- [What this relies on]

Testing:
- [How to verify this works]

Gotchas:
- [Anything surprising or non-obvious]
```

---

## Git Commands

```bash
# Commit 1
git add file1 file2
git commit -m "message here"

# Commit 2 (if multiple)
git add file3
git commit -m "message here"
```

---

## Architecture Context

[Optional: ASCII diagram or explanation of how changes fit together]

---

## Gotchas & Insights

1. **[Insight title]**: [Explanation that helps future engineers]
```

## Conventions

- **No Co-Authored-By**: Do not add attribution lines
- **Files list**: Simple, one file per line in code block
- **Commit messages**: Outcome-oriented, explain WHY not just WHAT
- **Multiple commits**: If changes are logically separate, plan multiple commits
- **Directory**: Always save to `commits/` in repo root (create if needed)
- **No markdown/doc in planned commits**: Do not include markdown or documentation files (e.g. `.md`, `.mdc`, `docs/*`) in "Files to Stage" or in the Git commands. Commit plans describe code commits only; documentation changes stay out of the planned commits so the user can commit or skip them separately.

## Example Invocations

- "Create a commit plan for my changes"
- "Plan commits for the auth refactor"
- "What commits should I make from these changes?"
- "Help me organize these changes into commits"

## Installation

```bash
# OpenClaw workspace
cp -r skills/commit-plan ~/clawd/skills/

# Claude Code (personal skills)
cp -r skills/commit-plan ~/.claude/skills/

# Cursor (project or global)
cp -r skills/commit-plan .cursor/skills/
# or: cp -r skills/commit-plan ~/.cursor/skills/
```

Invoke with `/commit-plan` when installed as a Cursor skill, or ask the agent to "create a commit plan for my changes".
