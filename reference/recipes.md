# Recipes (short)

## Auth + identity
```bash
gh auth status
gh api user --jq .login
```

## Create issue
```bash
gh issue create -R ORG/REPO --title "TITLE" --body "BODY" --assignee "@me"
```

## View PR
```bash
gh pr view 123 -R ORG/REPO --json title,state,author,mergeable
```

## Label issue (CLI)
```bash
gh issue edit 42 -R ORG/REPO --add-label "bug"
```

## Label issue (REST fallback)
```bash
gh api -X POST repos/ORG/REPO/issues/42/labels -f labels[]="bug"
```
