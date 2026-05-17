---
name: github-gh
description: Use when you need to manage GitHub repos, issues, PRs, releases, workflow runs, and Projects v2 items using the `gh` CLI; covers shortcuts (`--fill`, `--auto`, `--log-failed`, `--paginate`, sticky defaults), Projects v2 via `gh project item-edit`, and falling back to `gh api` (REST/GraphQL) for anything the CLI doesn't expose.
---

# GitHub via `gh` + `gh api`

## Default rule
1) Try `gh <feature>` first. 2) If unsupported, use `gh api` with the smallest, most explicit query/mutation.

## Prefer one-shot commands
Don't chain git + gh when a single `gh` command does the job:
- Open a PR for the current branch → `gh pr create --fill` (autofills title/body from commits; auto-pushes — no separate `git push -u`)
- Queue a merge → `gh pr merge --auto --squash --delete-branch` (waits for required checks, then squash-merges + cleans up)
- Wait on CI → `gh pr checks --watch --fail-fast` (blocks + exits nonzero on first failure)
- Failing logs only → `gh run view <id> --log-failed` (saves enormous context vs `--log`)
- Sticky default repo → `gh repo set-default OWNER/REPO` (eliminates `-R` on every command)
- Get only the data you need → add `--json <fields> --jq '<filter>'` to most `gh` commands instead of piping into `jq`

See `reference/shortcuts.md` for the full curated list of efficiency wins, and `reference/recipes.md` for longer-form copy/paste recipes.

## Guardrails
- Always target explicitly: `-R OWNER/REPO` or an explicit URL.
- Read state first, then mutate.
- Never guess IDs. Resolve node IDs with GraphQL before mutations.
- Be idempotent: no-op if already correct.
- Print the exact commands you ran + key IDs you resolved.

## Jump table (short refs)
- **Shortcuts / efficiency wins (read this first): `reference/shortcuts.md`**
- Basics: `reference/gh-basics.md`
- REST patterns: `reference/rest.md`
- GraphQL patterns + node IDs: `reference/graphql.md`
- Projects v2 (modern `gh project` CLI + GraphQL fallback): `reference/projects-v2.md`
- Copy/paste recipes (auth, issues, **fast PR create**, **CI/check polling with `--watch` + `--json`/`--jq`**): `reference/recipes.md`
- Scripts (programmatic Projects v2 batches — prefer `gh project item-edit` for one-offs):
  - List fields: `scripts/project_list_fields.sh`
  - Add item: `scripts/project_add_item.sh`
  - Set single-select (covers “Issue Type”): `scripts/project_set_single_select.sh`
  - Set text: `scripts/project_set_text.sh`
