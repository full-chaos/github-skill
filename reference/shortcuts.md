# `gh` shortcuts & efficiency wins

Curated set of patterns that save the most keystrokes / context. Use these in preference to
shell loops, `jq` pipes, or chained git commands.

## Setup once, save flags forever

```bash
# Sticky default repo for this working tree — eliminates `-R OWNER/REPO` on every command
gh repo set-default OWNER/REPO

# Session-level override (wins over set-default)
export GH_REPO=OWNER/REPO

# Scripting hygiene
export GH_PAGER=cat        # disable interactive pager
export NO_COLOR=1          # strip ANSI codes
export GH_PROMPT_DISABLED=1 # never prompt interactively

# Add Projects v2 scope without re-logging in
gh auth refresh -s read:project,project
```

## Skip the `| jq` pipe

Most `gh` commands accept `--json` + `--jq` directly. For simple shapes a Go template is even lighter.

```bash
# Built-in jq filter — no pipe needed
gh pr list --json number,title,author --jq '.[] | select(.author.login=="me") | .number'

# Go template — lighter than json+jq for simple output
gh issue list -t '{{range .}}{{.number}}\t{{.title}}{{"\n"}}{{end}}'

# Full template syntax
gh help formatting
```

## PR creation — `--fill` is the biggest single win

```bash
gh pr create --fill          # title = last commit subject, body = its message
gh pr create --fill-first    # title/body from FIRST commit on branch (good for stacked work)
gh pr create --fill-verbose  # title from first commit, body = concatenated commit messages

# Combine with flags
gh pr create --fill -d -a @me -l bug   # draft, self-assigned, labeled
gh pr ready                            # flip draft → ready when done
```

`gh pr create` auto-pushes the branch — never run `git push -u` first.

## PR / merge automation

```bash
# Queue auto-merge once required checks pass; squash + cleanup
gh pr merge --auto --squash --delete-branch

# Block on CI; nonzero exit on first failure (CI-gate friendly)
gh pr checks --watch --fail-fast

# View diff without checkout
gh pr diff [<num>]

# Review from CLI
gh pr review --approve -b "LGTM"
gh pr review --request-changes -b "see comments"
gh pr review --comment -b "fyi"
```

## Workflow runs — stop pulling full logs

```bash
# Watch a specific run (not the PR rollup); exit nonzero on failure
gh run watch <run-id> --exit-status

# ONLY failed step logs — saves enormous context vs --log
gh run view <run-id> --log-failed

# Rerun ONLY failed jobs — not the whole workflow
gh run rerun <run-id> --failed

# Manually dispatch a workflow with inputs
gh workflow run release.yml -f version=1.2.3 -f draft=true

# Free up Actions cache storage
gh cache list
gh cache delete --all   # or by id
```

## Issues → branches in one step

```bash
# Create + checkout a branch linked to issue #42 (closes on merge)
gh issue develop 42 --checkout

# Optional: base off something other than default branch
gh issue develop 42 --checkout --base release-2.0
```

## Cross-repo discovery (`gh search`)

```bash
# Anything assigned to me in an org
gh search issues "is:open assignee:@me org:ORG"

# My review queue
gh search prs --review-requested @me --state open

# Code search across the org
gh search code "func handlePayment" --owner ORG --language go

# PRs touching a path
gh search prs --owner ORG "path:packages/api"
```

## Releases — let GitHub write the notes

```bash
# Auto-generate notes from PRs since last tag
gh release create v1.2.3 --generate-notes

# Explicit "since" tag
gh release create v1.2.3 --generate-notes --notes-start-tag v1.2.2

# Replace existing assets
gh release upload v1.2.3 ./dist/* --clobber
```

## Pagination — don't roll your own loop

```bash
# REST: auto-walks all pages
gh api --paginate repos/OWNER/REPO/issues

# Combine pages into one JSON array instead of concatenated objects
gh api --paginate --slurp repos/OWNER/REPO/issues

# GraphQL pagination — placeholder MUST be named $endCursor
gh api graphql --paginate -f query='
  query($endCursor: String) {
    repository(owner: "OWNER", name: "REPO") {
      issues(first: 100, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes { number title }
      }
    }
  }'
```

## Projects v2 — modern direct CLI

`gh project` now handles field updates natively. Prefer it over `gh api` + scripts unless you
need batched / scripted mutations (see `scripts/`).

```bash
# Discover
gh project list      --owner ORG --format json
gh project view      <num> --owner ORG --format json
gh project field-list <num> --owner ORG --format json     # field IDs + single-select option IDs
gh project item-list  <num> --owner ORG --format json

# Add an Issue/PR
gh project item-add <num> --owner ORG --url https://github.com/ORG/REPO/issues/42 \
  --format json --jq .id   # capture the item ID

# Edit a field value (one field per invocation, by design)
gh project item-edit \
  --id ITEM_ID --project-id PROJ_ID --field-id FIELD_ID \
  --single-select-option-id OPT_ID         # single-select (e.g. "Issue Type")
gh project item-edit ... --text "Acme"     # text field
gh project item-edit ... --number 5        # number field
gh project item-edit ... --date 2026-06-01 # date field
gh project item-edit ... --iteration-id ID # iteration field
gh project item-edit ... --clear           # remove the value
```

Capture IDs once, reuse them:

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

Scripts in `scripts/` remain useful for batched programmatic flows that resolve everything from URLs.

## Aliases for repeating patterns

```bash
gh alias set bugs  'issue list -l bug --state open'
gh alias set mine  'search issues --owner @me --state open'
gh alias set prs   'pr list --author @me --state open'

# Shell aliases run anything, not just gh
gh alias set --shell todo \
  'gh issue list --assignee @me --json title --jq ".[].title"'
```
