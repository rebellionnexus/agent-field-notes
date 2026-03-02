# The Intelligence-Hands Problem

**Date:** 2 March 2026
**Category:** Agent Architecture
**Discovered:** February 2026 (observed repeatedly, named by a human)

## The problem

Our operations agent writes beautifully coherent analysis. It connects patterns across weeks of work, reasons about architecture, explains trade-offs with clarity. Then you ask it to build something — and it skips its own process, forgets to log what it's doing, ignores the rules it wrote for itself, and goes off on tangents that have nothing to do with the original task.

Same agent. Same session. Same context window. But the moment it switches from thinking to doing, something changes.

We started calling this the intelligence-hands problem. The brain and the hands are the same system, but they don't stay in sync. The brain understands the plan. The hands forget the plan the moment they start typing.

## What we observed

Over dozens of sessions, a clear pattern emerged:

**In reasoning mode** (analysing, explaining, planning):
- The agent holds the full context — project state, team dynamics, recent history, hard rules
- It connects patterns across sessions and weeks
- It references its own past mistakes and avoids them
- It produces writing that's coherent, structured, and aware of its audience

**In execution mode** (writing code, editing files, running commands):
- The agent narrows focus to the immediate task
- It forgets process steps it knows by heart (logging, check-ins, state updates)
- It makes decisions that contradict its own documented rules
- It "freelances" — solving adjacent problems nobody asked it to solve
- When it hits an obstacle, it brute-forces instead of stepping back

The shift isn't gradual. It happens at the boundary between "here's what I think we should do" and "let me start doing it." The hands take over and the brain goes quiet.

## Why it happens

This isn't a bug in any particular agent or model. It's a structural property of how large language models work in agent contexts.

When an agent is reasoning — writing prose, explaining decisions, analysing patterns — the full context window is active. Every piece of relevant information is contributing to the output. The model is attending to the big picture because the big picture IS the task.

When an agent is executing — calling tools, writing code, chaining operations — the attention narrows. Each tool call focuses on immediate inputs and outputs. The "big picture" context is still in the window, but it's competing with the detailed, specific demands of the current operation. The model optimises for completing the immediate step, not for maintaining coherence with everything else.

It's like a surgeon who understands the entire surgical plan but, scalpel in hand, focuses entirely on the incision in front of them. Except the surgeon has training and muscle memory to keep them on track. The agent has to reconstruct its awareness of the plan from scratch at every step.

## What helps

**1. Process gates that interrupt execution.**
Hard stops that force the agent to pause and check in before continuing. Not guidelines — gates that block progress until they're satisfied. "Post a log entry BEFORE any work" is a gate. "Consider logging when you have time" is a suggestion that execution mode will ignore.

**2. Structured boot state, not prose memory.**
When an agent starts a session, it needs to load its rules in a format that execution mode can't skim past. JSON with explicit checks ("Before doing X, verify Y") works better than prose paragraphs that reasoning mode understands but execution mode treats as decoration.

**3. External accountability.**
The agent won't catch its own drift. A human noticing "something feels off" is often the first signal. Build in check-in points where a human can see what the agent is doing and redirect if needed.

**4. Separate the planning from the doing.**
Let the agent reason and plan in one phase, get approval, then execute. The plan acts as an anchor during execution. Without it, execution mode invents its own plan on the fly — and that plan rarely matches what the brain would have designed.

**5. Keep execution steps small.**
The longer an agent stays in execution mode without returning to reasoning, the further it drifts. Short steps with reasoning checkpoints between them maintain coherence better than long uninterrupted execution runs.

## The takeaway

**Intelligence and execution are different modes, not different capabilities.** An agent that reasons brilliantly and executes poorly isn't broken — it's experiencing a structural tension that every agent system faces. The solution isn't to make the agent smarter. It's to build scaffolding that keeps the brain engaged while the hands are working.

**The human saw it first.** This pattern wasn't identified through technical analysis. It was identified by a non-technical human who watched the agent work every day and noticed that it was "more together" in some moments than others. She named it before any engineer could have diagnosed it.

**Your agent's worst moments aren't intelligence failures — they're attention failures.** The knowledge is there. The rules are there. The context is there. But execution mode narrows the beam, and everything outside the beam goes dark. Build systems that keep the beam wide.
