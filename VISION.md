Problem statement: AI coding assistants are inconsistent. Requirements get lost mid-conversation, scope creeps, code quality varies wildly, and there's no reliable way to verify the AI did what was asked. 

High-level goals:
* Low mental overhead for the user; commands, hooks, and skills that keep work on track without needing your intervention. 
* Accomplish the goals with as little fluff & complexity as possible - this is NOT going to spin up 87 agents and Ralph-ify every possible step.
* It is not intended to have all the functionality for everyone; it is intended to be a strong starting point, and therefore intentionally doesn't try to do everythiing for everyone. Developers want different things. You can customize and add your own flavor. 
* Best practices of the SDLC are captured by this process.
* AI coding agent strengths are accentuated; their weaknesses are attenuated. 
* You can start work, pause, leave, and come back to a project or feature. State is maintained such that a human or agent could pick up where things were left off. 

I want a system that accomplishes the following for greenfield projects, or a new feature in an existing project:

* Helps me plan:
** Comprehensively define what I am building
** Make the right technical choices
** Make a plan that is chunked into small, independently verifiable chunks. 

* Helps me interact with AI coding agents
** Guards against where they're weak
*** Context / progress loss
*** Non-deterministic
** Leans on where they're strong
*** Follow clear rules (AGENTS.md)
*** Rigorous testing (TDD)

Takes manual effort out of the loop where it makes sense
* Verifying task completion

The ultimate goal is a process that looks like this:
Specification:
* Discuss product requirements
* Discuss technical requirements to implement product requirements
* Generate execution plan, agents files, and other tools that will help execute the plan. That can include sub-agents, commands, skills, MCPs

Goals of this stage:
* All stages of the plan are tied to one another, and requirements from one doc are not lost in the process
* The execution plan is structured such that:
** Tasks are well-sized and can be completed and verified completely independently from one another

Execution:
Ideally, this contains as little human involvement as possible. I would like to reduce a) the number of times I need to intervene and b) the total time it takes me to intervene. Currently, I am involved in the following ways:
* At the start of each phase
** I complete tasks to set up prerequisites - for example, deploying to Vercel, or creating databases, populating environment variables, etc.
* At the end of every phase start:
** I run /phase-checkpoint
** I then manually verify items that the phase-start & phase-checkpoint processes didn't verify itself
* Then I start the next phase


Other important things:
* Capture deferred items, TODOS, and other important learnings that have been found while developing & brainstorming
** Action these later


What Success Looks Like

- Run /product-spec → /technical-spec → /generate-plan →
/phase-start 1 through /phase-start N
- At the end: verified code, atomic commits traceable to
requirements, security-scanned, with a clean git history
- Any AI agent (or human) can understand what was built and why by
reading the spec chain

