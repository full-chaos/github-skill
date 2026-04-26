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

## Create PR from current branch (one command)
`gh pr create` pushes the current branch to `origin` if it has no upstream, then opens the PR — no separate `git push -u` needed.
```bash
gh pr create --title "fix: null user in auth middleware" --body "Closes #42"

# Short flags
gh pr create -t "feat: add retry policy" -b "Adds exponential backoff."

# Multi-line body via heredoc
gh pr create -t "feat: X" -b "$(cat <<'EOF'
## Summary
- did X
- did Y

## Test plan
- [ ] manual smoke
EOF
)"
```
Useful flags: `-B main` (base branch), `-d` (draft), `-a @me` (assign), `-l bug` (label), `-w` (open in browser after).

## Check GitHub Actions / CI status (one command)
`gh pr checks` reports the state of every check run on a PR. Combine `--json` + `--jq` to get exactly what you need without piping through `jq` separately.
```bash
# Human-readable status for current branch's PR
gh pr checks

# Block until all checks finish (default poll: 10s)
gh pr checks --watch

# Custom poll interval (seconds) — useful for slow workflows
gh pr checks --watch -i 30

# Only failing checks, as a list of name + link
gh pr checks --json name,state,conclusion,link \
  --jq '.[] | select(.conclusion == "FAILURE") | {name, link}'

# Still-running checks
gh pr checks --json name,state --jq '.[] | select(.state == "IN_PROGRESS")'

# Wait for completion AND fail the shell if any check failed (CI gate)
gh pr checks --watch --fail-fast
```
Available `--json` fields: `bucket`, `completedAt`, `description`, `event`, `link`, `name`, `startedAt`, `state`, `workflow`.
`bucket` collapses `state`+`conclusion` into one of: `pass`, `fail`, `pending`, `skipping`, `cancel`.

## Inspect a workflow run directly
When you need logs or step-level detail (not just the PR rollup):
```bash
gh run list -R ORG/REPO --limit 5 --json databaseId,name,status,conclusion,headBranch
gh run view <run-id> -R ORG/REPO --log-failed
```
