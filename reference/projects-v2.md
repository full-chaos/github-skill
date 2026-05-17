# Projects v2 (short)

`gh project` now handles Projects v2 field updates natively. Lead with the CLI; fall back to
the bash scripts only when you need batched/programmatic flows that resolve everything from
issue URLs in one pass.

## Required token scope

```bash
gh auth refresh -s read:project,project
```

## Discover IDs

```bash
gh project list       --owner ORG --format json
gh project view       <num> --owner ORG --format json
gh project field-list <num> --owner ORG --format json   # field IDs + option IDs
gh project item-list  <num> --owner ORG --format json
```

## Add an Issue/PR to a project

```bash
gh project item-add <num> --owner ORG \
  --url https://github.com/ORG/REPO/issues/42 \
  --format json --jq .id    # capture the item ID for later edits
```

## Set a single-select field (e.g. "Issue Type")

```bash
gh project item-edit \
  --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID \
  --single-select-option-id OPT_ID
```

## Other field types

```bash
gh project item-edit --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID --text "Acme"
gh project item-edit --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID --number 5
gh project item-edit --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID --date 2026-06-01
gh project item-edit --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID --iteration-id ITER_ID
gh project item-edit --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID --clear
```

## End-to-end (capture IDs once, reuse)

```bash
PROJ_ID=$(gh project view 12 --owner ORG --format json --jq .id)
FIELD_ID=$(gh project field-list 12 --owner ORG --format json \
  --jq '.fields[] | select(.name=="Issue Type") | .id')
OPT_ID=$(gh project field-list 12 --owner ORG --format json \
  --jq '.fields[] | select(.name=="Issue Type") | .options[] | select(.name=="Bug") | .id')
ITEM_ID=$(gh project item-add 12 --owner ORG \
  --url https://github.com/ORG/REPO/issues/42 --format json --jq .id)

gh project item-edit --id "$ITEM_ID" --project-id "$PROJ_ID" \
  --field-id "$FIELD_ID" --single-select-option-id "$OPT_ID"
```

## Fallback: scripts/ (resolve everything from a URL)

Use these when you want a single command that takes `--org / --project / --url / --field /
--option` and does all the resolution for you (e.g. inside a loop or CI step).

```bash
scripts/project_list_fields.sh --org ORG --project 12 | jq .

scripts/project_add_item.sh ORG 12 https://github.com/ORG/REPO/issues/42 | jq .

scripts/project_set_single_select.sh \
  --org ORG --project 12 \
  --url https://github.com/ORG/REPO/issues/42 \
  --field "Issue Type" --option "Bug"

scripts/project_set_text.sh \
  --org ORG --project 12 \
  --url https://github.com/ORG/REPO/issues/42 \
  --field "Customer" --value "Acme"
```

## Fallback: raw GraphQL

If `gh project` lacks a needed flag (rare), drop to `gh api graphql` with
`updateProjectV2ItemFieldValue`. See `reference/graphql.md` for the node-ID resolution pattern.
