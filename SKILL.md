---
name: github-gh
description: Use when you need to manage GitHub repos, issues, PRs, releases, and Projects v2 items using the `gh` CLI; fall back to `gh api` (REST/GraphQL) for missing CLI features like Projects v2 field updates (for example, setting an "Issue Type" single-select field).
---

# GitHub via `gh` + `gh api`

## Default rule
1) Try `gh <feature>` first. 2) If unsupported, use `gh api` with the smallest, most explicit query/mutation.

## Guardrails
- Always target explicitly: `-R OWNER/REPO` or an explicit URL.
- Read state first, then mutate.
- Never guess IDs. Resolve node IDs with GraphQL before mutations.
- Be idempotent: no-op if already correct.
- Print the exact commands you ran + key IDs you resolved.

## Jump table (short refs)
- Basics: `reference/gh-basics.md`
- REST patterns: `reference/rest.md`
- GraphQL patterns + node IDs: `reference/graphql.md`
- Projects v2 (add item + set fields, including “Issue Type”): `reference/projects-v2.md`
- Copy/paste recipes: `reference/recipes.md`
- Scripts:
  - List fields: `scripts/project_list_fields.sh`
  - Add item: `scripts/project_add_item.sh`
  - Set single-select (covers “Issue Type”): `scripts/project_set_single_select.sh`
  - Set text: `scripts/project_set_text.sh`
