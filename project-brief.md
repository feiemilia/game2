# 小小夢魔：生活理財冒險 — Project Brief

Status: draft (requirements baseline recorded; gameplay and visual approval gates remain open)

## Goal

Create a child-friendly, atmospheric two-level game that teaches practical financial decision-making through play, with learning outcomes prioritized over engagement alone.

## Target users and context

Elementary-school learners (assumed ages 8–12), playing a local browser build. Exact grade and classroom context remain open.

## Evidence and pain points

The project owner specified everyday finance/investing, two levels with one interactive activity per level, a required solved challenge to earn each key, level scores, and a final progress summary. CFPB elementary-school curriculum guidance emphasizes goal-based saving, spending priorities, budgeting, and distinguishing saving from investing. This supports concrete goals and age-appropriate risk concepts rather than abstract market mechanics.

## Problem statement

How might a short adventure help elementary learners make and explain sensible choices about allocating money toward goals, while preventing random guessing and avoiding excessive reading or rule load?

## Inputs, processing, and outputs

- Inputs: movement/interaction, choices in each learning activity, optional retry/help, and brief explanation prompts.
- Processing: deterministic scoring from correct decisions, strategy quality, retries, and hint use; keys unlock only on solved challenges.
- Outputs: immediate explanatory feedback, one score per level, two keys, and a final progress summary showing demonstrated concepts and next practice.

## AI role and authority

AI supports concept generation, rubric-based pre-scoring, implementation, and test planning. It does not determine actual student learning, replace human concept/style selection, or provide investment advice.

## MVP and non-goals

MVP: two levels, one required finance interaction per level, solve-to-key progression, score feedback, final progress result, keyboard/touch-friendly local web build, and reusable Blender asset(s).

Non-goals: real money, real securities, financial recommendations, student analytics/identifiers, public hosting, multiplayer, or claims of validated learning gains.

## Constraints and risks

- Strong priority on learning; guessing/exploitation and overload receive maximum (0.30) diagnostic penalties.
- Young learners need plain language, low reading burden, explainable feedback, recoverable mistakes, and non-punitive retries.
- Current Godot Web templates are missing; export is blocked until the matching official templates are available.
- The user-provided reference is a mood reference only; no copied copyrighted characters, scenes, or assets.

## Delivery context

Local Godot Web export files in this workspace; not publicly hosted.

## Success measures

- Functional: both challenges require a correct solution before their keys appear; each level score and final result are visible.
- Learning hypothesis: post-activity learners can better identify a suitable saving plan and explain a basic investment risk/diversification choice than on a matched pre-activity prompt. This must be tested; it is not yet an observed result.
- Integrity/accessibility: event review and playtest observation show low random answer behavior and manageable confusion; indicators and thresholds are specified before formal testing.
- Delivery: browser opens local export via a local HTTP server and completes both levels.

## Assumptions to test

1. Learners understand the two activities without adult explanation.
2. Explanation prompts and reason-based feedback reduce random guessing.
3. Finance concepts are age-appropriate across the assumed 8–12 band.
4. Local Web build input and text remain usable on classroom-sized displays and touch devices.

## Acceptance examples

- Wrong or incomplete response does not award a key and gives a concise clue.
- Correct reasoned response awards the level key and score feedback.
- Final screen compares demonstrated outcomes across the two concepts, without claiming measured learning gain absent pre/post evidence.
- Web build runs from local HTTP serving with no missing assets.

## Open questions

- Which gameplay concept from the concept tournament should be developed?
- Which visual direction should be applied after gameplay selection?
- What exact grade band, language(s), and curriculum standard should be targeted?

## User approval

Gameplay and visual direction: pending explicit selection. Local Web delivery scope: confirmed.
