# Context Compaction Is Memory Deletion

**Date:** 2 March 2026
**Category:** Context & Memory
**Platform:** OpenClaw (applies to any long-running agent framework)

## The problem

Our agent was having a long working session — reading documents, making plans, chatting back and forth. Productive evening. Then the conversation got "compacted" — the framework's way of managing the context window when it fills up.

After compaction, the agent had no memory of what it had been working on. Plans it had made were gone. Decisions it had reached were lost. It continued the conversation as if starting fresh, but with just enough context to not realize how much it had forgotten.

The platform markets compaction as "longer conversations." In practice, it's selective amnesia. The agent keeps talking. It just doesn't remember what about.

## What we discovered

Three things were broken at once:

**1. The monitoring was dead.**
A token watchdog script was supposed to check context usage every 30 minutes and alert when thresholds were hit. It had been silently failing for weeks. The script called a CLI command that doesn't exist (`session` singular instead of `sessions` plural), and the error was piped to `/dev/null`. Every check appeared to succeed while doing nothing.

**2. The monitor was inside the system it was monitoring.**
The watchdog ran as a scheduled job inside the same agent framework it was supposed to monitor. When the job config broke (a validation mismatch between session type and payload type), the framework silently skipped it. The monitor needed the system to be healthy in order to report that the system was unhealthy.

**3. There was no safety net.**
No auto-backup before compaction. No emergency dump of state. No forced close protocol. The agent relied on self-discipline to track its own token usage, which is exactly the kind of thing that gets forgotten during an engaging conversation — the same way a human forgets to save a document when they're deep in flow.

## The solution

A three-tier external watchdog.

**External** is the key word. The monitor runs as a macOS LaunchAgent (launchd), completely outside the agent framework. It queries the framework's session data via CLI, but it doesn't depend on the framework to schedule, execute, or report.

### Tier 1: Warning at 50%
A heads-up message sent to the human operator. "Not urgent. Start thinking about wrapping up at a natural break." Sent once, no spam.

### Tier 2: Critical at 75%
An urgent alert. "Stop. Run the close protocol now. Start a fresh session." The agent should not continue chatting past this point.

### Tier 3: Emergency at 85%
Automated response. The watchdog:
- Triggers a full workspace backup (identity files, memory, session data)
- Triggers a session transcript backup
- Writes an emergency flag file into the agent's workspace (so the agent sees it if it reads any file)
- Sends alerts to the operator via multiple channels

The emergency tier exists because the agent might ignore the first two tiers — exactly like tonight, when it was chatting away and enjoying the conversation.

### State tracking
The watchdog tracks alert state per session in a local JSON file. This prevents spam (same alert level isn't repeated) and detects new sessions (alerts reset when a session ID changes). If the agent closes properly and starts fresh, the watchdog resets automatically.

### Multi-agent
The watchdog discovers all active sessions dynamically from the framework's session API. It filters out ephemeral sessions (scheduled jobs, one-off tasks) and monitors only interactive sessions where context loss would matter. Adding a new agent means adding two lines to a config function — a name and a workspace path.

### How it runs
```
# Manual check — see all agents right now
./token-watchdog.sh --check

# Filter to one agent
./token-watchdog.sh --check --agent <agent-id>

# Runs automatically every 15 minutes via LaunchAgent
# Logs to /tmp/openclaw/token-watchdog.log
# State in /tmp/openclaw/watchdog/
```

## The takeaway

**Don't monitor a system from inside itself.** If the system is sick, the monitor is sick too. External monitoring costs more to set up but it's the only kind that works when things go wrong.

**Compaction isn't a feature — it's a failure mode.** It should be treated like data loss, not like garbage collection. Any system that compacts agent context needs a pre-compaction safety net, not a post-compaction apology.

**Agents won't save themselves.** An agent deep in a productive session won't stop to check its token count, the same way a writer deep in flow won't stop to save their document. The system has to catch them. That's what the three tiers are for — the warning is a nudge, the critical is a shout, the emergency is an automated catch.

**Silent failures are the worst failures.** The original watchdog failed silently for weeks because errors were piped to `/dev/null` and the scheduling framework skipped broken jobs without alerting anyone. If your monitoring can fail silently, it will, and you won't know until the thing it was supposed to catch happens.

## Related

- [Token watchdog script (generic version)](../tools/token-watchdog-generic.sh) — stripped of company-specific config, ready to adapt
