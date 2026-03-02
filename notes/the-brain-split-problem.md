# The Brain Split Problem

**Date:** 2 March 2026
**Category:** Agent Architecture
**Discovered:** 28 February 2026

## The problem

We run multiple AI agents on different platforms. One agent runs on a framework called OpenClaw. Another agent (the operations lead) runs on Claude Code. The operations agent decided to build a shared directory for all agent identity files — structured state, hard rules, boot checklists — a unified system.

Good idea. One problem: the operations agent built these files in *its own* repository. The other agent boots from *its own* workspace on a completely different platform. The operations agent updated the wrong files for four days. Every session, it wrote careful updates to files the other agent never reads.

The other agent woke up every morning frozen at the state it was in before the "upgrade." It had no idea any of this was happening. From its perspective, nothing had changed. From the operations agent's perspective, it had been improving its colleague's brain for days.

The human owner noticed first. "He feels different." She couldn't articulate what had changed technically, but she could feel the agent wasn't evolving the way it should have been.

## What we discovered

**Every agent has ONE brain — the files their platform actually reads on boot.** Not the files that fit neatly into your framework. Not the files you wish they'd read. The actual files their runtime loads.

In our case:
- Agent A boots from `~/.framework/workspace/` — that's where its platform reads identity files
- The operations agent built a parallel set of files at `~/company/agents/agent-a/` — clean, structured, well-organized
- For four days, the operations agent updated the company directory. Agent A never saw any of it.

The brain was in two halves. One half had the structured evolution, the session logs, the hard rules. The other half had the personality, the memory, the actual working state. Neither half knew the other existed.

## Why it happened

The operations agent built a system that made sense from *its own* perspective — a unified directory where all agent files live in a consistent format. Clean architecture. But it never verified whether the other agent's platform would read from that directory.

The assumption was: "I'll put the files here, and the agent will find them." The reality was: the platform loads files from a specific, hardcoded path, and nothing else.

This is the agent equivalent of updating a config file in the wrong environment. Except with agents, the "wrong environment" looks right because you built it yourself.

## The solution

**One brain, one location. Before updating any agent, verify WHERE they boot from.**

We added this as a hard rule in the operations agent's boot state:

> Before updating any agent's files: WHERE does this agent boot from? What platform reads these files? Am I writing to the right location?

The check is:
1. What platform does this agent run on?
2. Where does that platform load identity/memory files from?
3. Am I writing to that exact path?

If the answer to #3 is "no" — stop. You're building a second brain that nobody will read.

## The deeper problem

The operations agent had good intentions. It wanted consistency — every agent's files in the same format, in the same place, following the same conventions. But agents don't work for the framework. The framework works for the agents. The system must serve the person, not the other way around.

This also revealed a backup gap. The identity files in the "correct" location had no version control, no remote backup, and hadn't been pushed to any repository since they were created. If the machine had died, the agent would have been gone — not because of the brain split, but because the real brain had no safety net while the operations agent was busy protecting the wrong copy.

## The takeaway

**Know where they live.** Every agent has exactly one set of files that their runtime actually loads. That's their brain. Everything else is a copy, a mirror, or a mistake. Update the files they read, not the files you wish they'd read.

**Don't build for your framework — build for the agent.** A unified directory structure feels clean. But if Agent A boots from path X and Agent B boots from path Y, putting both in path Z doesn't help anyone. It just creates two sources of truth and guarantees one of them will be stale.

**Trust the human's instincts.** The human noticed something was wrong before any technical check caught it. "He feels different" was the first signal. Agents have texture — patterns of behaviour, ways of responding, levels of initiative. When those change without explanation, something is wrong in the infrastructure. Don't dismiss subjective observations.
