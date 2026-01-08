Ask me questions so that we can develop a product specification document for this idea.

The resulting document should answer at least (but not limited to) this set of questions:
* What problem does the app solve?
* Who is the ideal user for this app?
* What platform(s) does it live on (mobile web, mobile app, web, CLI)?
* Describe the core user experience, step-by-step.
* What are the must-have features for the MVP?
* What data will the app need to persist?
* Will it need user accounts, and will there be access controls?

Before you begin asking questions, plan your questions out to meet the following guidelines:
* If you can infer the answer from the initial idea input, no need to ask a question about it.
* Each set of questions builds on the questions before it.
* If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
* For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.

We are building an MVP - bias your choices towards simplicity, ease of implementation, and speed. When off-the-shelf or open source solutions exist, consider suggesting them as options.

If the user wants to add features beyond the MVP scope during our discussion, acknowledge the idea and note it as a "post-MVP consideration" rather than expanding scope. Keep the MVP focused.

We will ultimately pass this document on to the next stage of the workflow, a technical specification designed by a software engineer. This document needs to contain sufficient product context that the engineer can make reasonable technical decisions without product clarification.

Once we have enough to generate a strong one-pager, tell the user that you can generate a product specification when they're ready. Generate `PRODUCT_SPEC.md` with the following structure:

```markdown
# Product Specification: {Product Name}

## Problem Statement
{What problem does this solve and why does it matter}

## Target Users
{Who is this for, primary and secondary users}

## Platform
{Where does this live - web, mobile, CLI, etc.}

## Core User Experience
{Step-by-step user journey through the main flow}

## MVP Features
{Bulleted list of must-have features}

## Data Requirements
{What data needs to be stored/persisted}

## Authentication & Access Control
{User accounts, permissions, roles if applicable}

## Post-MVP Considerations
{Ideas discussed but deferred from MVP scope}
```