# gh api REST (short)

## Read
```bash
gh api -X GET repos/ORG/REPO/issues/42 | jq .
```

## Update issue title/body (example)
```bash
gh api -X PATCH repos/ORG/REPO/issues/42 -f title="New title" -f body="New body"
```

## Pagination pattern
```bash
gh api -X GET "repos/ORG/REPO/issues?per_page=100&page=1"
```
