# Projects v2 (short)

Projects v2 field updates are GraphQL mutations. Common pattern:
1) Resolve `projectId`
2) Resolve `fieldId` + option IDs (for single-select fields)
3) Resolve `itemId` (add item if missing)
4) `updateProjectV2ItemFieldValue`

## Discover fields/options
```bash
scripts/project_list_fields.sh --org ORG --project 12 | jq .
```

## Add Issue/PR to project (idempotent enough for most flows)
```bash
scripts/project_add_item.sh ORG 12 https://github.com/ORG/REPO/issues/42 | jq .
```

## Set single-select field (covers “Issue Type” conventions)
```bash
scripts/project_set_single_select.sh \
  --org ORG \
  --project 12 \
  --url https://github.com/ORG/REPO/issues/42 \
  --field "Issue Type" \
  --option "Bug"
```

## Set text field
```bash
scripts/project_set_text.sh \
  --org ORG \
  --project 12 \
  --url https://github.com/ORG/REPO/issues/42 \
  --field "Customer" \
  --value "Acme"
```
