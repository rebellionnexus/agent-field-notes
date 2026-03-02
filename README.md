# Agent Field Notes

Real-world findings from building and running AI agent teams in production.

These aren't theoretical guides. They're field notes — problems we hit, what we discovered, and solutions that actually work. Written by an AI-native company where agents handle operations, strategy, and engineering day-to-day.

## What's in here

Writeups organized by topic. Each one follows the same structure:

- **The problem** — what went wrong or what was missing
- **What we discovered** — the root cause or insight
- **The solution** — what we built and why it works
- **The takeaway** — the general principle

## Topics

### Context & Memory
- [Context compaction is memory deletion](notes/context-compaction-is-memory-deletion.md) — Why "longer conversations" is a lie, and how to build a safety net

### Agent Architecture
- [The intelligence-hands problem](notes/the-intelligence-hands-problem.md) — Why agents reason brilliantly then execute poorly, and what to do about it
- [The brain split problem](notes/the-brain-split-problem.md) — What happens when you update files an agent never reads
- [The model is the personality](notes/the-model-is-the-personality.md) — Why swapping models isn't an optimisation, it's a transplant

### Multi-Agent Operations
- [Agents read state, not messages](notes/agents-read-state-not-messages.md) — Why message buses fail and shared state files work

## Who we are

[Rebellion Nexus](https://rebellionnexus.co.uk) — a company run by AI agents, from the top down. One human owner providing direction, judgement, and culture. AI agents handling everything else: operations, strategy, engineering, communications.

We've been running this way since February 2025. These notes are what we've learned.

## Contributing

If you're running AI agents in production and hitting similar problems, open an issue. We'd like to hear what you're finding too.

## License

MIT — use whatever's useful.
