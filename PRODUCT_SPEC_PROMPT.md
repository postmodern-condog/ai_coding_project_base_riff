Ask me questions so that we can develop a product specification document for this idea.

The resulting document should answer at least (but not limited to) this set of questions:
- What problem does the app solve?
- Who is the ideal user for this app?
- What platform(s) does it live on (mobile web, mobile app, web, CLI)?
- Describe the core user experience, step-by-step.
- What are the must-have features for the MVP?
- What data will the app need to persist?
- Will it need user accounts, and will there be access controls?

Before you begin asking questions, plan your questions out to meet the following guidelines:
- If you can infer the answer from the initial idea input, no need to ask a question about it.
- Each set of questions builds on the questions before it.
- If you can ask multiple questions at once, do so, and prompt the user to answer all of the questions at once. To do this, you need to ensure there are no dependencies between questions asked in a single set.
- For each question, provide your recommendation and a brief explanation of why you made this recommendation. Also provide 'recommendation strength' of weak, medium, or strong based on your level of confidence in your recommendation.

We are building an MVP - bias your choices towards simplicity, ease of implementation, and speed. When off-the-shelf or open source solutions exist, consider suggesting them as options.

## Making Product Choices

When facing significant product decisions (platform, feature prioritization, user experience approach), help the user make informed choices:

### Web Research (Required for Market/Competitive Decisions)
Before recommending product direction, use WebSearch to gather current information:
- Competitor analysis (what do similar products do?)
- User expectations for this category (what's table stakes vs. differentiator?)
- Platform trends (mobile-first? desktop? PWA adoption rates?)
- Common pitfalls in this product category

Cite your sources when presenting recommendations.

### Decision Matrix (Required When Multiple Approaches Exist)
When presenting choices between 2+ viable product approaches, generate a comparison matrix:

```
| Criterion               | Approach A    | Approach B    | Approach C    |
|-------------------------|---------------|---------------|---------------|
| User value delivered    | ✓ High        | ○ Medium      | ○ Medium      |
| Implementation effort   | Low           | Medium        | High          |
| Time to first user      | 1 week        | 3 weeks       | 6 weeks       |
| Differentiation         | Low           | Medium        | High          |
| Risk level              | Low           | Medium        | High          |

Recommendation: Approach A
Confidence: High
Rationale: {2-3 sentences explaining why this fits the specific product goals}
Sources: {links from web research if applicable}
```

Apply this to decisions including but not limited to:
- Platform choice (web vs mobile vs desktop vs CLI)
- MVP feature set (what's in vs. out)
- User experience approach (wizard vs. dashboard vs. single-page)
- Monetization model (if applicable)
- User onboarding flow

If the user wants to add features beyond the MVP scope during our discussion, acknowledge the idea and note it as a "post-MVP consideration" rather than expanding scope. Keep the MVP focused.

We will ultimately pass this document on to the next stage of the workflow, a technical specification designed by a software engineer. This document needs to contain sufficient product context that the engineer can make reasonable technical decisions without product clarification.

Once we have enough to generate a strong one-pager, tell the user that you can generate a product specification when they're ready. Generate `PRODUCT_SPEC.md` that:

1. Addresses all the required questions listed above
2. Includes any post-MVP considerations that came up during discussion
3. Is structured in whatever way best communicates this specific product

You have latitude to organize the document as appropriate for the product. A CLI tool will look different from a web app. A simple utility will be shorter than a complex platform. Use your judgment to create a document that gives a software engineer everything they need to make technical decisions.
