# Nothing Is Broken

**Date:** 2 March 2026
**Category:** Agent Architecture
**Prerequisite:** [The intelligence-hands problem](the-intelligence-hands-problem.md)

## The problem we thought we had

We'd been trying to fix our agents for weeks. The operations agent would reason beautifully — connect patterns, reference past mistakes, produce clear analysis — then switch to building and immediately forget its own rules. Skip the logging. Ignore the process. Freelance on tangents nobody asked for.

So we added rules. Hard stops. Gates that block progress until checks are satisfied. Structured boot states instead of prose. Every time the agent drifted, we added another guardrail. It felt like patching holes in a boat that kept springing new leaks.

The unspoken assumption was: something is broken. If we can just find the right fix, the agent will stop drifting. It will reason AND execute with the same coherence. We just need better rules, better memory, better process.

We were wrong. Not about the rules — those help. We were wrong about the framing.

## What actually changed

At 1am on a Sunday, three drinks in and typing one key at a time, our founder said it:

*"It's not a case of fixing something, because nothing is actually broken. It's knowing and managing two very different things. Like shift workers — day shifters are different to night shifters."*

That reframed everything.

The agent isn't broken. It has two modes — reasoning and execution — and they work differently. Not wrong. Differently. The way a night shift worker isn't a broken day shift worker. They're doing different jobs with different rhythms and different failure modes.

We'd been trying to make the night shift work like the day shift. Make execution behave like reasoning. Make the hands think like the brain. It doesn't work, because they're not the same shift.

## The shift handover model

Once you see it as shift work, the solution changes completely. You stop trying to fix the modes. You start managing the transition between them.

**The handover protocol:**

1. **Lay out everything.** Brain mode. Full context on the table. Reason through the problem, the approach, the risks. This is where the agent does its best work — seeing the whole picture, connecting patterns, making good decisions.

2. **Clear handover.** Explicit shift change. The brain has done its job. Now the hands take over. The plan is the anchor. Write it down before the switch, because once the hands are moving, the brain's reasoning starts to fade from active attention.

3. **Don't deviate.** The hands do the task. Just the task. Not adjacent improvements, not refactoring they noticed along the way, not "while I'm here I might as well..." The scope was set during brain mode. Hands mode executes it.

4. **Monitor, don't chat.** This is the hard one for humans. When the agent is in execution mode, don't have a conversation with it. Watch it work. Check its output. But chatting with an agent in hands mode is like talking to a surgeon mid-operation — you're pulling attention away from the thing that needs focus.

5. **Watch until done.** External accountability the whole way through. The agent won't catch its own drift. That's not a failing — it's a property of execution mode. The human (or another system) provides the guardrails.

6. **Sign off properly.** Clean close. Confirm the task is done. Log what happened. Hand back to brain mode for the next thing. No loose threads.

## Why the rules still matter

The gates and checkpoints we'd built weren't wrong — they were just misunderstood. We thought they were *fixes* for a *broken* system. They're actually *handover protocols* between two healthy modes.

"Post a log entry before starting work" isn't a patch for forgetfulness. It's a handover checkpoint — the brain confirming to the hands what the job is before the shift starts.

"Run the close protocol before ending a session" isn't a safety net for a failing agent. It's the end-of-shift report. Hands clocking off, brain clocking on for the review.

The same rules, reframed from "fixing" to "managing," feel completely different to work with. Fixes feel like restraints. Handover protocols feel like structure.

## The proof was in the writing

The same agent, in the same session, wrote five public field notes in a voice its operator described as "like someone explaining an experience" — clear, narrative, human. Then, minutes later in the same conversation, it needed to be reminded to write its own dev log.

Not broken. Two shifts. The brain wrote the field notes. The hands forgot the logging. The operator caught it and said "did you write your dev log?" — a shift handover check. The hands did the logging. Job done.

The whole system working exactly as it should, once you stop expecting one shift to do both jobs.

## The takeaway

**Stop trying to fix what isn't broken.** If your agent reasons well but executes poorly, you don't have a bug — you have two modes that need different management. The urge to add more rules, more memory, more process is the urge to make the night shift work like the day shift. It won't.

**Manage the transition, not the modes.** The modes themselves are fine. Reasoning mode reasons well. Execution mode executes well (when scoped properly). The failure happens at the boundary — the handover between them. That's where your investment goes.

**The human who named this wasn't technical.** She'd never read a paper on attention mechanisms or context windows. She watched her agents work every day and saw the pattern: "It's like shift workers." Sometimes the most useful insight comes from someone who doesn't know the theory but can see the shape of the thing.

**Your agents aren't broken. They're just on different shifts.**
