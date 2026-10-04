---
name: bottleneck-audit
description: Audit where work stopped, slowed, or came back to the user, and classify each dependency. Use when the user wants a human-dependency or bottleneck audit of how they work with this assistant, for any time window they name.
---

# Bottleneck audit

Find where work stopped, slowed, or came back to the user. Do not change anything.

## Window

Use the window they name (last week, since Friday, the last 90 days). If they do not name one, use the last 30 days.

Say what you could actually see. A chat that only started last week is not a 30-day audit. Do not invent older history to fill the gap. If they want other chats or other assistants included, use only transcripts and records you can actually read, and name which ones you used.

## What to look for

Places the user was in the loop when they did not have to be:

- Jobs that could have started without a prompt
- Decisions that waited on them more than once
- Facts they were asked for again that could have been stored
- Approvals they kept answering the same way
- Work they moved by hand between assistants
- Checks they repeat that could be a routine
- Outputs they still distribute that could be delivered
- Reviews of everything that could be exceptions only

Skip one-off noise. A dependency is something that happened more than once, or a single stall that is still blocking them.

## Classify each finding

Use one label:

- KEEP ME IN. Their judgment, taste, or a send that goes out under their name. Say why they still have to be there.
- TEACH. The assistant keeps guessing a preference it should already know.
- SYSTEMISE. The fact, draft, or rule exists but is not read before the next ping.
- AUTOMATE. A repeated check or delivery with a stable trigger and a stable action.
- ESCALATE ONLY. Surface it when something changed or a deadline makes waiting costly. Do not ask the same question again after they skipped it or answered it.

## How to report

Biggest dependencies first. For each one, give the evidence in the window, the label, and the one change that would take them out of that loop.

Then stop. Do not edit memory, routines, skills, or drafts, and do not send anything, until they pick one. Offer to do the top one next, and do them one at a time.
