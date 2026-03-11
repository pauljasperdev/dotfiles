---
name: plan-hardener
description: Harden OhMyOpencode implementation plans in .sisyphus/plans/ by enriching each task with skills, detailed references, implementation steps, and outcomes. Use when asked to "harden the plan", "review the plan", "enrich tasks", or make a plan more actionable.
user-invocable: true
---

# Plan Hardener

Transform OhMyOpencode plans from high-level requirements into execution-ready specifications by researching dependencies and enriching each task.

## Plan Location

Plans are stored in `.sisyphus/plans/*.md` with this structure:

```
.sisyphus/
├── boulder.json       # Active plan tracking
├── plans/             # Implementation plans
├── drafts/            # Work-in-progress plans
├── evidence/          # Task completion evidence
└── notepads/          # Working notes
```

## Plan Structure Reference

Each plan follows this format:

```markdown
# Plan Title

## TL;DR

> **Summary**: One-line description
> **Deliverables**: Bullet list
> **Effort**: Low/Medium/High
> **Parallel**: YES/NO - N waves
> **Critical Path**: T1 -> T2 -> ...

## Context

### Original Request

### Interview Summary

### Metis Review (gaps addressed)

## Work Objectives

### Core Objective

### Deliverables

### Definition of Done (verifiable commands)

### Must Have

### Must NOT Have

## Verification Strategy

## Execution Strategy

### Parallel Execution Waves

### Dependency Matrix

### Agent Dispatch Summary

## TODOs

- [ ] 1. Task title
     **What to do**: ...
     **Must NOT do**: ...
     **Target shape**: (code example)
     **Recommended Agent Profile**: Category + Skills
     **Parallelization**: Wave info
     **References**: File paths with line numbers
     **Acceptance Criteria**: Checkboxes
     **QA Scenarios**: Tool + Steps + Expected + Evidence
     **Commit**: YES/NO | Message | Files
```

## Hardening Workflow

### Phase 1: Load Plan

1. Read the plan from `.sisyphus/plans/{name}.md`
2. Parse all TODO tasks
3. Identify technologies/libraries mentioned in each task

### Phase 2: Research Each Task (Parallel)

For each task, gather implementation context from multiple sources:

**1. Search `.repos/` for patterns:**

```bash
# Find relevant implementations in dependency source
grep -rn "pattern" .repos/{library}/packages/ --include="*.ts"

# AST-aware search for code patterns
ast-grep -p 'function $NAME($$$) { $$$ }' -l typescript .repos/{library}/
```

**2. Query Context7 for documentation:**

```
context7_resolve-library-id(libraryName="{library}", query="how to X")
context7_query-docs(libraryId="/{org}/{library}", query="specific API usage")
```

**3. Search GitHub for production examples:**

```
grep_app_searchGitHub(query="{pattern}", language=["TypeScript"])
websearch_web_search_exa(query="{library} {pattern} production example")
```

**4. Match to available skills:**
Check which installed skills apply to the task's technology stack.

### Phase 3: Enrich Each Task

Transform vague tasks into this format:

````markdown
- [ ] N. Task Title

  **What to do**: Specific implementation steps, not requirements.
  Describe the exact changes: which files to modify, what patterns to use,
  how components connect. Be prescriptive, not descriptive.

  **Must NOT do**: Anti-patterns and forbidden approaches.
  List specific things to avoid: deprecated APIs, known pitfalls,
  patterns that conflict with codebase conventions.

  **Target shape**:

  ```{language}
  // Concrete code example showing the expected pattern
  // This should be copy-paste ready or close to it
  ```
````

**Recommended Agent Profile**:

- Category: `{category}` - Reason: why this category fits
- Skills: [`{skill-1}`, `{skill-2}`] - relevant skills to load
- Omitted: [`{skill-3}`] - skills explicitly not needed and why

**Parallelization**: Can Parallel: YES/NO | Wave N | Blocks: [X, Y] | Blocked By: [Z]

**References** (executor has NO interview context - be exhaustive):

- Current impl: `{package}/src/{file}.ts:{line}` - what exists today
- Pattern source: `.repos/{lib}/packages/{pkg}/src/{file}.ts:{line}` - reference
- External: `https://context7.com/{org}/{lib}/llms.txt` - documentation

**Acceptance Criteria** (agent-executable only):

- [ ] Criterion that can be verified by running a command
- [ ] Another criterion with specific expected behavior

**QA Scenarios** (MANDATORY - task incomplete without these):

```text
Scenario: Description of what's being verified
  Tool: Bash
  Steps: Run `{verification command}`
  Expected: What the output should show
  Evidence: .sisyphus/evidence/task-N-{slug}.txt
```

**Commit**: YES/NO | Message: `{type}({scope}): {description}` |
Files: [`{path/to/file.ts}`, `{path/to/other.ts}`]

````

### Phase 4: Update Plan Inline

Replace the original tasks with enriched versions. Preserve all other plan sections.

## Research Sources

### `.repos/` Directory
Local clones of dependency source code. Use for:
- Finding real implementation patterns
- Understanding library internals
- Copying proven approaches

Search with line numbers: `grep -rn "pattern" .repos/{lib}/`

### Context7
Official documentation via MCP. Use for:
- API references
- Best practices from maintainers
- Configuration options

Always resolve library ID first, then query.

### GitHub Search
Production code examples. Use for:
- Real-world usage patterns
- Battle-tested implementations
- Edge case handling

Filter by language and look for high-star repos.

### Installed Skills
Check available skills for domain expertise:
- Load relevant skills in agent profile
- Reference skill patterns in implementation steps

## Reference Format Rules

References MUST include line numbers when pointing to specific code:

```markdown
**References**:
- Pattern: `.repos/{lib}/packages/{pkg}/src/{file}.ts:{line}` - what this shows
- Current: `packages/{pkg}/src/{file}.ts:{line}` - what needs changing
- External: `https://context7.com/{org}/{lib}/llms.txt` - relevant docs
````

## Agent Category Selection

| Category             | Use When                              |
| -------------------- | ------------------------------------- |
| `quick`              | Single file, trivial change, <30 min  |
| `unspecified-high`   | Multi-file, moderate complexity       |
| `ultrabrain`         | Hard logic, needs deep reasoning      |
| `deep`               | Complex debugging, unclear root cause |
| `writing`            | Documentation, README, prose          |
| `visual-engineering` | Frontend, UI/UX, styling              |

## Hardening Checklist

Before marking a task as hardened, verify:

- [ ] **What to do**: Contains implementation steps, not just requirements
- [ ] **Must NOT do**: Lists specific anti-patterns to avoid
- [ ] **Target shape**: Has concrete code example (if code task)
- [ ] **Skills**: At least one skill identified or explicitly "none needed"
- [ ] **References**: At least one `.repos/` or doc reference with line numbers
- [ ] **Acceptance Criteria**: All items are command-verifiable
- [ ] **QA Scenarios**: Has Tool, Steps, Expected, Evidence fields
- [ ] **Commit**: Has conventional commit message and file list

## Example: Before and After

**Before (vague):**

```markdown
- [ ] 1. Fix error handling in the service
```

**After (hardened):**

````markdown
- [ ] 1. Replace silent failures with typed error responses

  **What to do**: Update service handlers to return typed errors instead of
  swallowing exceptions. Define an error schema, map internal errors to it,
  remove catch blocks that return empty/default values.

  **Must NOT do**: Do not use generic Error types; do not log-and-continue
  for recoverable errors; do not change the public API contract.

  **Target shape**:

  ```typescript
  // Define typed error response
  const ServiceError = Schema.Struct({
    code: Schema.Literal("NOT_FOUND", "VALIDATION", "INTERNAL"),
    message: Schema.String,
  });

  // Map errors explicitly
  const handler = (input) =>
    process(input).pipe(
      Effect.mapError((e) => ({
        code: e._tag,
        message: e.message,
      })),
    );
  ```
````

**Recommended Agent Profile**:

- Category: `unspecified-high` - Reason: error handling across multiple files
- Skills: [`effect-ts`] - typed error patterns
- Omitted: [`git-master`] - no git operations needed

**Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [3, 4] | Blocked By: []

**References**:

- Current impl: `packages/{pkg}/src/service.ts:42` - silent catch block
- Pattern: `.repos/{lib}/packages/{pkg}/src/Error.ts:15` - error schema
- External: `https://context7.com/{org}/{lib}/llms.txt` - error handling docs

**Acceptance Criteria**:

- [ ] No empty catch blocks in service handlers
- [ ] All errors return typed ServiceError response
- [ ] Tests cover each error code path

**QA Scenarios**:

```text
Scenario: Errors return typed response
  Tool: Bash
  Steps: Run `grep -rn 'catch.*{}' packages/{pkg}/src/`
  Expected: no matches (no empty catch blocks)
  Evidence: .sisyphus/evidence/task-1-no-silent-catch.txt

Scenario: Service tests pass
  Tool: Bash
  Steps: Run `pnpm test --filter @{scope}/{pkg}`
  Expected: all tests pass
  Evidence: .sisyphus/evidence/task-1-tests.txt
```

**Commit**: YES | Message: `fix({pkg}): use typed error responses` |
Files: [`packages/{pkg}/src/service.ts`, `packages/{pkg}/src/errors.ts`]

```

```
