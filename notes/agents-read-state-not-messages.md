# Agents Read State, Not Messages

**Date:** 2 March 2026
**Category:** Multi-Agent Operations
**Discovered:** 25 February 2026

## The problem

We had two agents that needed to coordinate — one doing strategy, one doing implementation. The natural instinct was to build a message bus. Agent A sends a message to Agent B: "I've found an opportunity, here's the brief." Agent B picks it up and acts on it.

This works for humans. It doesn't work for agents.

The strategy agent would send a detailed brief. The implementation agent would start a new session, load its context, receive the message... and have no idea what the strategy agent had been thinking for the past three hours. The message was a snapshot of a conclusion without the reasoning that led to it. The implementation agent would either ask clarifying questions (round-tripping back through the message bus) or make assumptions (and get it wrong).

Messages are lossy. By the time you've compressed a thought into a message, you've already lost most of the context that made the thought valuable.

## What we discovered

The human owner asked the question that changed everything: "Are you thinking like AI communicating to another, or like humans?"

Humans communicate with messages because we can't share state directly. We have to serialize our thoughts into language, send them, and hope the other person reconstructs something close enough to what we meant.

Agents don't have this limitation. They can read each other's state files directly. The strategy agent writes its findings, reasoning, and recommendations to a shared state file. The implementation agent reads that file. No serialization loss. No round-tripping. The full context is there.

## The pattern

**Shared project state, not a message bus.**

Instead of:
```
Agent A → message → queue → Agent B
```

Do:
```
Agent A → writes state file
Agent B → reads state file
```

The state file is structured data (JSON, not prose). It contains:
- What's been decided and why
- What's in progress
- What's blocked and on what
- What needs to happen next

Both agents read and write to the same file. No messages needed. The state IS the communication.

## When messages still make sense

Messages aren't useless — they're good for:
- **Alerts:** "Something urgent happened, check the state file"
- **Human communication:** Humans still need messages because they can't (easily) parse JSON state files
- **Cross-platform coordination:** When agents are on different systems that can't share a filesystem

But for agent-to-agent coordination within the same infrastructure, state files beat messages every time.

## The takeaway

**Stop making AI work like humans.** The instinct to build a message bus comes from human communication patterns. Agents don't need to "talk" to each other. They need to read each other's state.

**Structured data, not prose.** A JSON state file is instant to parse, queryable, and unambiguous. A prose message requires interpretation and loses nuance. Agents aren't human — stop giving them human-shaped communication channels.

**The question to ask:** "Am I building this because it's what agents need, or because it's what humans would need?" If the answer is the second one, reconsider.
