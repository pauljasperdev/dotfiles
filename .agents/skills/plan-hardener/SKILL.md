---
name: plan-hardener
description: Harden implementation plans by deeply researching conceptual foundations of every technology involved, then enriching tasks with correct idioms, anti-patterns, and concrete references. Use when asked to "harden the plan", "review the plan", "enrich tasks", or make a plan more actionable.
user-invocable: true
---

# Plan Hardener

Take an existing implementation plan and make it bulletproof. The output is a plan a human can read, judge, and confidently approve or reject every decision in it.

## Step 0: Load Project Context (MANDATORY — NO EXCEPTIONS)

Before touching a single task:

1. **Re-read the project's `AGENTS.md`** — understand repository structure, conventions, constraints, and how things are built here. Every project has its own rules. You must know them.
2. **Read the plan** — identify every technology, library, framework, and pattern mentioned or implied across all tasks.
3. **Inventory available skills** — check what skills are installed. Map each technology in the plan to its skill. You will need these skills at every phase.

## Step 1: Conceptual Foundation Research

**This is the most important step.** Before you can harden any task, you must deeply understand the *paradigm* of every technology in the plan. Not the API surface — the *why* and the *how*.

This is what prevents agents from writing `async/await` with Effect, doing imperative state mutations with TanStack Query, using `try/catch` in a typed error channel system, or any other paradigm violation that produces technically-working but fundamentally wrong code.

### For Each Technology in the Plan:

**1. Load the skill** — If a matching skill exists (`effect-ts`, `tanstack-query`, `better-auth-best-practices`, etc.), load it NOW. Read it. Internalize it. This is your primary knowledge source.

**2. Research the paradigm** — Use all sources in parallel:

- **Context7** — Query official docs for core concepts, idioms, correct usage patterns
- **`.repos/` directory** — Grep local dependency source for real implementation patterns
- **GitHub search** — Find production usage in established codebases
- **Web search** — Best practices, common mistakes, paradigm explainers
- **Codebase grep** — How does THIS project already use this technology?

**3. Answer these questions** (if you can't, keep researching):

| Question | Why It Matters |
|---|---|
| What is the paradigm? (functional, declarative, reactive, etc.) | Determines the entire coding style |
| Why does this project use it? What problem does it solve? | Prevents using the tool against its purpose |
| What do correct idioms look like? | Sets the quality bar for target shapes |
| What are the anti-patterns? What do people get wrong? | Becomes the "Must NOT do" sections |
| How does this specific codebase use it? What conventions exist? | Ensures consistency with existing code |

### Why This Step Exists

Without conceptual understanding, plan hardening is just formatting. The agent filling in "What to do" and "Must NOT do" fields without understanding the paradigm will produce plans that look detailed but encode wrong approaches.

**Example — Effect-TS:**
- Wrong understanding → agent plans `async/await` with Effect pipes, `try/catch` for errors, `Promise.all` for concurrency
- Correct understanding → agent plans `Effect.gen` for sequential composition, typed error channel with `Effect.mapError`, `Effect.all` for concurrency, never throws, never awaits an Effect directly

**Example — TanStack Query optimistic updates:**
- Wrong understanding → agent plans manual state updates alongside mutations, `await` on mutation for UI feedback
- Correct understanding → agent plans `onMutate` for cache snapshot + optimistic write, `onError` for rollback, `onSettled` for invalidation, query cache as single source of truth

## Step 2: Implementation Detail Research

Now that you understand the paradigms, research the concrete details for each task.

### For Each Task:

1. **Find existing patterns in the codebase** — How has this project solved similar problems? What files, what conventions?
2. **Find reference implementations** — In `.repos/`, in Context7 docs, in GitHub. With line numbers.
3. **Find the exact APIs** — Function signatures, configuration options, required parameters. Don't guess — verify.
4. **Cross-reference with skills** — Load relevant skills again and validate your research against skill guidance.

### Research Tools

**`.repos/` directory** — Local dependency source code:
```bash
grep -rn "pattern" .repos/{library}/
ast-grep -p '{pattern}' -l {language} .repos/{library}/
```

**Context7** — Official documentation:
```
context7_resolve-library-id(libraryName="{library}", query="{specific question}")
context7_query-docs(libraryId="/{org}/{lib}", query="{specific API or pattern}")
```

**GitHub** — Production examples:
```
grep_app_searchGitHub(query="{code pattern}", language=["{lang}"])
```

**Web search** — Guides, edge cases:
```
websearch_web_search_exa(query="{library} {specific problem or pattern}")
```

### Reference Quality Bar

Every reference must be specific enough that the implementing agent doesn't need to re-research:
```
- Codebase: `src/services/auth.ts:42` — existing error handling pattern
- Library source: `.repos/effect/packages/effect/src/Effect.ts:156` — Effect.gen usage
- Documentation: Context7 query for "Effect.gen composition patterns"
```

Vague references ("see the Effect docs") are useless. Specific references ("Context7 `/effect-ts/effect` query: 'Effect.gen do notation for sequential composition'") are actionable.

## Step 3: Harden Each Task

Enrich every task so that:
1. A human can read it and **judge whether the approach is correct**
2. An implementing agent knows **exactly what to do and what NOT to do**
3. The correct **paradigm and idioms are explicitly stated**

### Required Fields Per Task

**What to do** — Specific implementation steps. Not requirements, not wishes. Which files to change, what pattern to follow, how components connect. The paradigm-correct approach must be explicit.

**Must NOT do** — Specific anti-patterns for THIS task. Based on your conceptual research: what would a naive agent get wrong? What deprecated APIs exist? What patterns violate the library's paradigm? What does the codebase already do that must not be contradicted?

**Target shape** — A concrete code example showing the expected pattern. This is the quality bar. The implementing agent should produce code that looks like this. It must reflect correct idioms from Step 1.

```{language}
// Correct idiomatic example — based on actual research, not guessing
```

**Skills** — Which skills the implementing agent MUST load. Non-negotiable. If the task touches Effect, the agent loads `effect-ts`. If it touches TanStack Query, the agent loads `tanstack-query`. Always.

**References** — File paths with line numbers. Documentation queries. Library source locations. Everything the implementing agent needs to understand context without re-doing research.

**Acceptance criteria** — Verifiable checks. Commands to run, expected outputs, conditions that must be true.

## Step 4: Review for Human Readability

Before delivering, read the hardened plan as if you're the human approving it:

- **Can I see what each task will change?** — File paths, patterns, approach
- **Can I judge if the approach is correct?** — Are the paradigm and idioms respected? Would I write it this way?
- **Can I spot potential problems?** — Are anti-patterns explicitly called out? Are edge cases addressed?
- **Is anything vague?** — "Improve error handling" is unjudgeable. "Replace try/catch in auth.ts:42-58 with Effect.tryPromise piped to Effect.mapError returning typed ServiceError" is judgeable.
- **Are skills specified for every task?** — Will the implementing agent have the knowledge it needs?

A reviewable plan is not necessarily short. It's a plan where every decision is visible and every approach is explicit enough that a human can say "yes" or "no" to each one.

## The Skill Chain (UNBROKEN)

Skills are the knowledge base that prevents paradigm violations. They must be present at every stage:

| Stage | Who | Skills |
|---|---|---|
| Research | You (plan hardener) | Load all relevant skills while researching |
| Plan | The hardened plan | Specifies which skills each task requires |
| Implementation | The executing agent | Loads the specified skills before starting |

**If a skill exists for a technology in the plan, it must be used at all three stages. No exceptions.**

## Example: Before and After

**Before (vague):**
```markdown
- [ ] 1. Add optimistic updates to the bookmark mutation
```

**After (hardened):**

````markdown
- [ ] 1. Add optimistic UI update to bookmark mutation

  **What to do**: Use TanStack Query's `useMutation` with `onMutate` to
  optimistically update the query cache before the server responds. Cancel
  outgoing refetches via `queryClient.cancelQueries`, snapshot previous data
  for rollback, and update cache with `queryClient.setQueryData`. On error,
  roll back to snapshot. On settle, invalidate to refetch.

  **Must NOT do**:
  - Do not manually update component state — the query cache is the source of truth
  - Do not skip the rollback in `onError` — stale optimistic data will persist
  - Do not `await` the mutation for the optimistic path — UI updates happen in `onMutate`, before the request completes
  - Do not invalidate in `onSuccess` — use `onSettled` so both success and error paths refetch

  **Target shape**:

  ```typescript
  const mutation = useMutation({
    mutationFn: toggleBookmark,
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: ["bookmarks"] })
      const previous = queryClient.getQueryData(["bookmarks"])
      queryClient.setQueryData(["bookmarks"], (old) =>
        old.map((b) =>
          b.id === id ? { ...b, bookmarked: !b.bookmarked } : b,
        ),
      )
      return { previous }
    },
    onError: (_err, _id, context) => {
      queryClient.setQueryData(["bookmarks"], context.previous)
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["bookmarks"] })
    },
  })
  ```

  **Skills**: [`tanstack-query`] — implementing agent MUST load before starting

  **References**:
  - Current mutation: `src/features/bookmarks/use-toggle-bookmark.ts:12`
  - TanStack docs: Context7 `/tanstack/query` — "optimistic updates with useMutation"
  - Codebase pattern: `src/features/posts/use-like-post.ts:8` — existing optimistic update

  **Acceptance criteria**:
  - [ ] Bookmark toggles instantly in UI before server response
  - [ ] UI rolls back on server error
  - [ ] Cache invalidates on settle (success or error)
  - [ ] No flash of stale data after mutation
````

The difference: the "after" tells me exactly what the agent will do, why it's doing it that way, and what it must avoid. I can read it and say "yes, that's correct" or "no, use a different approach." That's a reviewable plan.

## Hardening Checklist

Before delivering, verify each task has:

- [ ] **What to do** — Implementation steps, not requirements. Paradigm-correct.
- [ ] **Must NOT do** — Specific anti-patterns from conceptual research.
- [ ] **Target shape** — Idiomatic code example reflecting correct paradigm.
- [ ] **Skills** — Every relevant skill listed. Chain unbroken.
- [ ] **References** — Specific file paths with line numbers, doc queries, source locations.
- [ ] **Acceptance criteria** — Verifiable by running commands or inspecting output.
