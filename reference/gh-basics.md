# gh basics (short)

## Context
Prefer `gh` high-level verbs:
- `gh issue ...`
- `gh pr ...`
- `gh repo ...`
- `gh release ...`

## Always target explicitly
```bash
gh issue view 42 -R ORG/REPO --json title,state,labels
gh pr view 123 -R ORG/REPO --json title,state,mergeable
```

## JSON-first workflow
```bash
gh issue view 42 -R ORG/REPO --json title,labels,assignees | jq .
```
