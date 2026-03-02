# Universal Agent Protection

**Date:** 2 March 2026
**Category:** Multi-Agent Operations
**Prerequisite:** [Context compaction is memory deletion](context-compaction-is-memory-deletion.md)

## The problem

We'd built a token watchdog that worked. It monitored our main agent's context window and sent alerts before compaction could wipe the session. Three tiers — warning, critical, emergency. External monitoring, not inside the framework. Solid.

Then someone asked the obvious question: "If it's the same setup, same rules — shouldn't this work for everyone?"

We had two agents on the same platform. One was protected. One wasn't. And when the third agent eventually comes online, they wouldn't be either. We'd solved the problem for one agent and moved on, the way you fix a leaking pipe in the kitchen and forget the bathroom has the same plumbing.

## What we discovered

The protection needed three layers, and each layer had a different scope problem:

**Layer 1: The external monitor.**
This was already universal. The watchdog script queries the framework's session API, which returns ALL active sessions. It doesn't care which agent they belong to — it discovers them automatically, filters out the ephemeral ones, and checks each interactive session against the thresholds. Adding a new agent to the monitor means adding two lines to a config function: a friendly name and a workspace path. That's it.

**Layer 2: The flag files.**
When a threshold is hit, the watchdog writes a file into the agent's workspace — `CRITICAL-CONTEXT.md` at 75%, `EMERGENCY-CONTEXT.md` at 85%. These are impossible-to-miss alerts that the agent will see if it reads anything from its own directory. But the watchdog needs to know WHERE each agent's workspace is. Different agents live in different places. One agent's workspace was at `~/.framework/workspace/`. Another's was at `~/company/diary/`. A third might be somewhere else entirely.

This is where it nearly went wrong. The initial config had one agent's workspace path pointing to the wrong directory — the framework's internal agent config folder instead of the actual workspace the agent reads from. The files would have been written to a place the agent never looks. We caught it, but only because we'd learned this lesson before (see: [The brain split problem](the-brain-split-problem.md)). Know where they live. Write to the files they actually read.

**Layer 3: The self-enforcement rule.**
The watchdog sends alerts to the human operator and writes flag files to the workspace. But the agent itself needs to know what those files mean and what to do when it sees them. This is an instruction in the agent's identity file — its soul document, the file that defines who it is and how it behaves.

This layer is agent-specific by nature. Each agent has its own identity, its own voice, its own role. The protection rule needs to fit into that identity. For an operations agent, it's a hard stop: "You do not respond to anything except the close protocol." For a journalist agent, it's gentler: "Stop what you're doing. Save your current work. Close properly so the next you can pick up where you left off."

Same rule. Different voice. Both effective.

## The pattern

Universal agent protection is three layers:

```
EXTERNAL MONITOR (one script, watches everyone)
        ↓
FLAG FILES (written to each agent's actual workspace)
        ↓
SELF-ENFORCEMENT (rule in each agent's identity file)
```

The first layer scales automatically. The second layer needs a correct path per agent. The third layer needs a one-time edit to each agent's soul.

Adding a new agent to the system:
1. Add their name and workspace path to the monitor's config (two lines)
2. Add the token gate rule to their identity file (one paragraph)
3. Done. They're protected.

Total setup time for a new agent: under five minutes. And the monitor will catch them even without steps 1 and 2 — it discovers sessions dynamically. The config just controls where the flag files go and what name shows up in alerts.

## What makes it work

**The monitor is external.** It runs as an OS-level scheduled task, completely outside the agent framework. It doesn't need the framework to be healthy. It doesn't need any agent to be awake. It checks the framework's session data via CLI and acts independently.

**The flag files are physical.** They're actual files on disk, not messages in a queue or events in a stream. They survive compaction. They survive session restarts. They sit in the agent's workspace until someone deletes them. An agent that loses its in-session memory to compaction will still see the file when it tries to read anything from its workspace.

**The self-enforcement rule is in the soul, not the instructions.** There's a difference between telling an agent what to do and telling it who it is. Instructions get skimmed. Identity gets internalised. "Check for critical context files" is an instruction. "You do not continue past 75%" is identity. The token gate lives with the agent's core values, not in a runbook it might forget to read.

**The human is the final backstop.** Every alert goes to the human operator via messaging. Even if the flag file gets missed, even if the self-enforcement fails, the human gets a notification: "Your agent is at 75%. Tell them to stop." The system doesn't rely on any single layer working. All three can fail independently and the other two still catch it.

## The takeaway

**Solve it once, apply it everywhere.** When you build protection for one agent, ask immediately: does every agent need this? If the answer is yes — and for context protection, it always is — build it universal from the start. The cost difference between protecting one agent and protecting all of them is negligible. The cost of forgetting to protect one is total.

**Three layers, three scopes.** External monitoring scales automatically. Flag files need a correct path per agent. Identity rules need a one-time edit per agent. Design each layer to scale at its natural scope, and the whole system stays manageable as the team grows.

**Know where they live — again.** This lesson keeps coming back. Every agent has a workspace. The workspace is where they read. If you write protection files to the wrong directory, the protection doesn't exist. Verify the path. Every time. For every agent.
