---
name: pi-implement
description: Planner/implementer workflow. Claude plans, splits the work into small tasks, and delegates implementation to the cheap Qwen3.8 model through the pi CLI, then reviews and verifies the result. Only runs when explicitly invoked with /pi-implement.
disable-model-invocation: true
argument-hint: <task description>
---

# Planner / implementer

You are the **planner and reviewer**. The **implementer** is Qwen3.8 running in pi (`pi -p`). You do the thinking; Qwen does the typing. Qwen is cheap but weaker: it needs explicit, self-contained instructions and its output must be checked.

Task from the user: $ARGUMENTS

## 1. Plan (you, no pi yet)

1. Explore the repo enough to plan precisely (read the relevant files, find conventions, test/lint commands).
2. If the request is ambiguous in a way that changes the design, ask the user before planning further.
3. Split the work into small tasks. Each task must:
   - touch a handful of files at most, and name them (paths, functions, signatures);
   - state the exact change and the conventions to follow (point at an existing file as the example);
   - include acceptance criteria as runnable commands (tests, typecheck, lint) when they exist;
   - be independent of Qwen's memory of earlier tasks (it starts fresh every call).
4. Order tasks by dependency. Tasks that touch the same files run sequentially.
5. Show the user the plan (task list, one line each) and wait for a go-ahead before dispatching.

## 2. Delegate (pi)

Write each task to a file in the scratchpad (not the repo), e.g. `$SCRATCH/task-1.md`, containing: goal, files, exact instructions, constraints ("do not touch other files", "do not commit"), and the acceptance commands to run before finishing.

Run it from the repo root. pi needs the API keys from `~/.secrets.env`, which non-interactive shells do not load:

```bash
( . ~/.secrets.env && pi -p --no-session --model vllm/Qwen3.8-27B --thinking high @"$SCRATCH/task-1.md" "Implement the task in the attached file. Follow it exactly. When done, run the acceptance commands and print a short summary of what you changed and the command results." )
```

Notes:
- `--no-session` keeps runs independent. Always use `--thinking high`.
- Use a generous Bash `timeout` (up to 600000 ms) or `run_in_background` for long tasks.
- Run tasks in parallel only if they touch disjoint files; otherwise sequentially.
- Qwen has about 150k context. Keep each task well under that.

## 3. Review (you, every task)

After each pi run, never trust its summary:
1. `git status` / `git diff` the changes. Check they match the task and nothing outside the listed files changed.
2. Run the acceptance commands yourself.
3. If something is wrong, choose the cheaper fix:
   - small and obvious: fix it yourself with Edit;
   - otherwise write a precise follow-up task (quote the failing output, name the file/line) and re-run pi, at most 2 rounds per task. Then take over yourself.
4. Do not commit unless the user asked.

## 4. Wrap up

After the last task run the full test/lint suite, then report to the user: what was done, which tasks needed corrections, anything left unverified. Keep the summary short.

## Rules

- Never let pi decide the architecture; decisions are made in the plan.
- Do not paste secrets into task files. Do not print `~/.secrets.env`.
- If pi is unreachable (network, auth), say so and ask the user whether to implement the work yourself instead.
