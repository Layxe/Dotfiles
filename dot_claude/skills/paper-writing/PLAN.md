# Token-Efficiency Refactor Plan

## Goal

Reduce the prompt tokens consumed by routine paper-writing tasks without weakening the writing workflow, editorial rules, or final pre-submission audit.

The main change is to make `SKILL.md` a small task router. Detailed guidance should load only when a task needs it.

## Current Baseline

Approximate token counts use two heuristics: 1.35 tokens per word and one token per four characters. Actual counts vary by model and tokenizer.

| Content | Words | Characters | Estimated tokens |
|---|---:|---:|---:|
| `SKILL.md` | 4,784 | 33,558 | 6.5k to 8.4k |
| All files in `author_profile/` | 9,508 | 64,542 | 12.8k to 16.1k |
| Mandatory baseline after activation | 14,292 | 98,100 | **19.3k to 24.5k** |
| Introduction moves and checklist | 1,428 | 9,194 | 1.9k to 2.3k |
| Brainstorming guide and examples | 6,323 | 43,580 | 8.5k to 10.9k |
| Figure guide and templates | 5,787 | 42,318 | 7.8k to 10.6k |
| All runtime documentation | 31,827 | 219,820 | 43k to 55k |

These totals exclude the manuscript, `project_context.md`, conversation history, tool output, and audit findings.

## Diagnosis

### 1. `SKILL.md` is both a router and a reference manual

Pi loads the full `SKILL.md` whenever the skill activates. The file currently repeats material from the detailed references, including:

- editorial and voice rules
- mechanical audit rules
- section move sequences
- compression operations
- the five-stage workflow
- common-request procedures
- pre-submission commands

This makes every invocation expensive, including meta-questions and small edits.

### 2. The skill defeats progressive disclosure

The activation procedure requires reading every file in `author_profile/`. A brainstorming request therefore loads compression, review, drafting, mechanical, and semantic guidance before the task begins. Figure work and small prose edits incur the same baseline cost.

### 3. Several rules have multiple sources of truth

Repeated topics include:

- introduction-twice
- claim-first writing
- named-over-vague terminology
- paragraph length
- compression operations
- rhetorical move sequences
- mechanical bans

The repetition consumes tokens and has introduced inconsistencies:

- `editorial_principles.md` says it contains 13 principles but defines 14.
- `SKILL.md` requires 4 to 6 sentences per paragraph, while `craft_reference.md` allows 3 to 6 and up to 8 for design paragraphs.
- `SKILL.md` says zero hedging, while `craft_reference.md` and S18 require calibrated hedging when evidence is limited.
- Passive voice is described as allowing no exceptions, but audit hits may be explicitly justified.
- The em-dash rule says no exceptions and then permits external quotations.

### 4. Audit scope does not reflect edit scope

A small `.tex` edit can trigger the full mechanical gate, craft review, all semantic checks, an independent red-team, and closure passes. This is appropriate for a full section or submission audit but excessive for a local sentence change.

### 5. Mechanical checks consume prompt space

`gate_mechanical.md` contains both explanations and a long shell script. The model must load the rules, execute the commands, and often include raw output twice. The commands are also hard-coded to `sections/*.tex`, which limits reuse.

## Target Token Budgets

| Task | Current estimate | Target estimate |
|---|---:|---:|
| Skill activation before task files | 19k to 24.5k | 1k to 2k |
| Small paragraph or sentence edit | 20k+ | 2k to 4k plus manuscript text |
| Section draft | 21k to 27k+ | 5k to 8k plus project context |
| Brainstorming phase | 28k to 35k if all examples load | 3k to 6k per phase |
| Full pre-submission audit | Potentially 40k+ | No strict reduction target; preserve rigor |

The refactor should reduce routine-task instruction tokens by 65 to 90 percent. Full audits may remain expensive because they intentionally exercise the complete rule set.

## Proposed Architecture

```text
paper-writing/
├── SKILL.md                         # Small router and core invariants
├── workflows/
│   ├── brainstorming.md
│   ├── architecture.md
│   ├── drafting.md
│   ├── review.md
│   ├── integration.md
│   ├── compression.md
│   └── pre_submission.md
├── author_profile/
│   ├── core_rules.md                # Canonical universal rules
│   ├── editorial_principles.md      # Detailed rationale, loaded for review
│   ├── craft/
│   │   ├── empirical.md
│   │   ├── conceptual.md
│   │   └── narrative.md
│   ├── semantic/
│   │   ├── accessibility.md
│   │   ├── consistency.md
│   │   ├── rigor.md
│   │   ├── structure.md
│   │   ├── figures.md
│   │   └── closure.md
│   ├── compression_patterns.md
│   └── intervention_types.md
├── section_rhetorical_moves/
├── writing_checklists/
├── figure_templates/
└── scripts/
    └── style_audit.py
```

The exact directories can change during implementation. The important property is that files align with task-loading boundaries.

## Task Loading Matrix

`SKILL.md` should classify the request and load only the files listed below.

| Task | Required references |
|---|---|
| Meta-question about the skill | `SKILL.md` only |
| New-paper brainstorming | Current brainstorming phase and `examples/project_context.md` |
| Architecture planning | Architecture workflow, core rules, and available survey or visualization artifacts |
| Introduction draft | Core rules, selected craft register, introduction moves, and introduction checklist |
| Evaluation draft | Core rules, selected craft register, evaluation moves, and evaluation checklist |
| Design draft | Core rules, selected craft register, design moves, and design checklist |
| Related Work draft | Core rules, selected craft register, related-work moves, and related-work checklist |
| Small `.tex` edit | Core rules and mechanical audit script |
| Draft review | Editorial-principle summary and intervention types |
| Compression | Compression patterns and mechanical audit script |
| Integration | Semantic consistency, structure, and claim-evidence checks |
| Figure synthesis | Figure guide and only the selected archetype template |
| Pre-submission | Full mechanical gate, full semantic gate, closure protocol, and submission checks |
| Loop mode | Ledger protocol and only the references needed by the current iteration |

## Implementation Phases

### Phase 1: Establish measurements and behavior fixtures

1. Add a script that reports words, characters, and estimated tokens for each runtime file.
2. Define representative scenarios:
   - meta-question about the skill
   - one-sentence `.tex` edit
   - introduction draft
   - draft review
   - one brainstorming phase
   - figure synthesis
   - full pre-submission audit
3. Record which files each scenario currently loads.
4. Preserve sample expected behaviors for each scenario so token reduction does not silently remove important checks.

**Exit criterion:** The repository can compare pre-refactor and post-refactor loading costs for the same scenarios.

### Phase 2: Convert `SKILL.md` into a router

Reduce `SKILL.md` to approximately 600 to 1,000 words. Retain only:

- skill purpose and scope
- core pipeline order
- non-negotiable invariants
- task classification and loading matrix
- project-context discovery rule
- audit-tier selection
- links to detailed references

Remove duplicated explanations, examples, shell commands, and common-request walkthroughs. Move any unique content into a workflow or reference file before deleting it.

Change the activation procedure from:

> Read ALL files in `author_profile/`.

to:

> Classify the task, then load only the references listed for that task.

Also change paper discovery behavior:

- infer the paper from the user's request or working directory
- ask only when multiple papers are plausible
- skip paper discovery for generic or meta-level questions
- inspect sibling-skill artifacts only when the current stage uses them

**Exit criterion:** `SKILL.md` stays below the agreed token budget and routes every supported request to a complete workflow.

### Phase 3: Create one canonical core policy

Create `author_profile/core_rules.md` with concise universal rules. It should cover only requirements that apply to nearly every paper-writing task, such as:

- claim-first structure
- active voice
- named and concrete terminology
- evidence-scoped claims
- citation grounding
- consistent terminology
- the em-dash policy
- the introduction-twice ordering where relevant

Detailed rationale and examples should remain in task-specific references.

Resolve the current inconsistencies while creating the file. Other documents should link to the core rule instead of restating it.

**Exit criterion:** Every universal rule has one canonical definition.

### Phase 4: Deduplicate workflow documentation

1. Keep detailed section moves in `section_rhetorical_moves/`.
2. Remove or reduce the duplicate cross-section move summary in `author_profile/rhetorical_moves.md`.
3. Keep compression operations in `compression_patterns.md`; replace copies elsewhere with links.
4. Keep editorial rationale in `editorial_principles.md`; use short rule references in workflow files.
5. Keep section checklists focused on verification rather than reteaching each move.
6. Avoid loading `examples/netburst_project_context.md` unless the user requests an example or struggles with the blank template.

**Exit criterion:** Each concept has one detailed source and, at most, a short routing reference elsewhere.

### Phase 5: Replace grep instructions with an audit tool

Implement `scripts/style_audit.py` with these properties:

- accepts one or more paths instead of assuming `sections/*.tex`
- implements mechanical checks by rule ID
- distinguishes definite violations from findings that need judgment
- outputs compact text or JSON
- reports only nonzero findings by default
- supports a summary mode for user-facing reports
- optionally writes a detailed audit artifact to disk

Example output:

```text
M1   2   sections/intro.tex:18,31
M11  1   sections/intro.tex:44
M12  3   sections/intro.tex:52,60,71
```

Keep explanations for M1 through M18 in a reference file. Load an explanation only when the corresponding rule fires or the agent needs help fixing it.

Replace the requirement to paste all raw grep output with:

- show compact counts and affected lines to the user
- save verbose evidence in an audit artifact when needed
- let the independent reviewer consume the compact structured output

**Exit criterion:** Routine mechanical audits do not require loading the full grep implementation into the prompt.

### Phase 6: Introduce audit tiers

Define four audit levels.

#### Tier 1: Micro edit

Use for isolated sentence or phrase changes.

- run the mechanical audit on changed text
- apply core style rules locally
- verify citations if the edit changes a technical claim

#### Tier 2: Paragraph or subsection rewrite

- run Tier 1
- load the selected craft register
- check local followability, definitions, and paragraph purpose

#### Tier 3: Section draft or substantial rewrite

- run Tier 2
- load the section's rhetorical moves and checklist
- apply relevant semantic groups
- run an independent red-team when the change is substantive

#### Tier 4: Integration or pre-submission

- run the complete mechanical and semantic gates
- check cross-section terminology and decomposition consistency
- check claim-evidence mapping and provenance
- inspect figures
- iterate through the closure protocol

Clarify which tier applies to each common request. Preserve the user's ability to request a stricter tier explicitly.

**Exit criterion:** A one-line edit no longer triggers a full-paper audit, while section and submission work retains the current rigor.

### Phase 7: Split references by actual use

Split files only where doing so changes loading behavior:

- separate empirical, conceptual, and narrative craft registers
- separate local semantic checks from paper-wide integration checks
- consider one file per brainstorming phase
- keep figure templates separated by archetype or generation backend

Do not split short files merely to create a cleaner directory tree. Excessive fragmentation can increase tool calls and make routing unreliable.

**Exit criterion:** Each routine task loads no large block of irrelevant guidance.

### Phase 8: Shorten skill discovery metadata

Replace the current frontmatter description with a shorter trigger description that still covers the important cases. For example:

> Drafts, revises, audits, and compresses research papers and LaTeX submissions using the SNL writing workflow. Use for paper sections, abstracts, rebuttals, reviewer responses, figures, conference submissions, and `.tex` edits.

The description must remain specific enough for reliable automatic activation.

**Exit criterion:** The always-visible skill metadata is concise and preserves trigger coverage.

### Phase 9: Validate and propagate

For each behavior fixture from Phase 1:

1. verify that the router selects the intended workflow
2. record the files loaded
3. compare estimated instruction tokens against the baseline
4. verify required outputs and audits still occur
5. run repository-wide searches for stale paths and duplicate rules
6. update `README.md`, `DESIGN.md`, and `CLAUDE.md` if the architecture changes
7. update `setup` so it copies every new runtime directory and script
8. run `./setup` to propagate the installed skill

**Exit criterion:** Routine scenarios meet their token budgets, and the installed skill matches the repository.

## Validation Criteria

The refactor is successful when all of the following hold:

- `SKILL.md` is no more than approximately 1,000 words.
- Activation does not require reading all of `author_profile/`.
- Meta-level requests do not require a paper name or `project_context.md`.
- A small `.tex` edit loads no full semantic gate.
- A section draft still receives the proper move sequence, checklist, craft rules, and scoped semantic audit.
- A full pre-submission audit still exercises every mechanical and semantic rule.
- Mechanical findings retain stable M-rule identifiers.
- Semantic findings retain stable S-rule identifiers.
- Audit evidence remains reproducible.
- No rule has conflicting canonical definitions.
- Typical section tasks reduce instruction tokens by at least 65 percent.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| The router omits a required reference | Add scenario fixtures and an explicit loading matrix |
| Reduced repetition weakens rule adherence | Keep a concise core policy and stable rule IDs |
| Too many small files increase tool calls | Split only at real task boundaries |
| The model fails to run the audit script | Keep script execution as an explicit invariant in `SKILL.md` |
| Compact audit output hides context | Include lines and locations; save verbose evidence to disk |
| Tiered audits allow quality regressions | Escalate automatically based on changed scope and allow explicit strict mode |
| Existing links break after moves | Validate links and search for stale paths before installation |
| Setup omits new files | Add an installation manifest or update `setup` alongside each move |

## Recommended Order

The highest-value sequence is:

1. Measure representative scenarios.
2. Shrink `SKILL.md` into a router.
3. Remove the unconditional `author_profile/` load.
4. Add the canonical core policy.
5. Introduce audit tiers.
6. Implement the mechanical audit script.
7. Deduplicate and split references.
8. Validate token budgets and behavior.
9. Update installation and documentation.

The first three changes should produce most of the savings. Later phases improve consistency, audit efficiency, and maintainability.

## Non-Goals

- Weakening the introduction-twice workflow
- Removing section-specific rhetorical guidance
- Relaxing final pre-submission checks
- Replacing reader judgment with regexes
- Optimizing only for fewer files or fewer tool calls
- Hiding audit failures to produce shorter reports

The objective is selective loading, not weaker review.
