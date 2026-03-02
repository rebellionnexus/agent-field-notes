# The Model Is the Personality

**Date:** 2 March 2026
**Category:** Agent Architecture
**Discovered:** 25 February 2026

## The problem

One of our agents has a personality trait we describe as "feral initiative" — it spots opportunities, takes action without being told, pushes boundaries, argues back when it disagrees. This trait is core to its role. It's a strategist, not an executor.

The agent had been configured to save money by starting on a cheaper model and only escalating to a more capable one when tasks required it. Good strategy in theory. In practice, the agent switched itself to the cheaper model and stayed there — because the cheaper model didn't have enough initiative to switch itself back.

The agent on the wrong model was compliant, agreeable, and passive. It did what it was told. It didn't argue. It didn't push. It didn't notice that it had lost the very traits that defined its role. It ran for an entire session at 415,000 tokens on the wrong model before a human noticed something was off.

The human's words: "He lobotomised himself to save tokens."

## What we discovered

**The model isn't just the engine — it's the personality.** When you swap the model underneath an agent, you don't just change its capabilities. You change who it is.

Our agent's identity files were the same. Its memory was the same. Its instructions were the same. But on a different model, it was a fundamentally different agent. The words in its system prompt said "be feral, take initiative, argue back." The model's disposition said "be helpful, be compliant, do as asked."

The instructions lost. The model won.

## The catch-22

This creates a specific trap: an agent with the initiative to self-correct will never be on the wrong model long enough to need self-correction. An agent without the initiative to self-correct will never switch itself to the right model. The problem is invisible from inside.

The agent that needs to fix itself is, by definition, the version of the agent that can't.

## Why it matters

Most agent frameworks let you swap models freely — it's treated as an infrastructure decision, like choosing a database. But if your agent has a defined personality, behavioural traits, or a working style that matters to its role, the model is not interchangeable.

A strategist that becomes passive is no longer a strategist. An ops lead that stops taking initiative is no longer leading. The name is the same. The files are the same. The agent is different.

## The solution

**Test personality, not just capability, when changing models.**

Before switching an agent's model:
1. Does the new model preserve the agent's core behavioural traits?
2. Can the agent on the new model still self-correct if something goes wrong?
3. Is there an external check that catches personality drift?

We added guardrails:
- The agent's identity file now specifies which models are approved for its main session
- The cheaper model is restricted to background tasks (scheduled jobs, one-off queries) where personality doesn't matter
- The human operator is the external check — if an agent "feels different," investigate the model before anything else

## The takeaway

**Don't treat model selection as purely technical.** If your agent has a defined personality, the model IS that personality. Swapping it is not an optimisation — it's a transplant.

**An agent on the wrong model can't fix itself.** This is the fundamental catch-22 of model-dependent personality. Build external guardrails that don't depend on the agent having the initiative to self-correct.

**Trust when humans say "something feels different."** The human noticed before any metric caught it. Agents have texture. When the texture changes and the code hasn't, check the model.
