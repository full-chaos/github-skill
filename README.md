# github-gh

A skill that teaches LLM-based agents to manage GitHub repos, issues, PRs, releases,
workflow runs, and Projects v2 items via the `gh` CLI — with `gh api` (REST/GraphQL) as a
fallback for anything the CLI doesn't expose.

Optimized for context efficiency: curated shortcuts (`--fill`, `--auto`, `--log-failed`,
`--paginate`, sticky defaults), modern `gh project item-edit` for Projects v2, and
copy/paste recipes that avoid unnecessary `jq` pipes and polling loops.

## Requirements

- `gh` ≥ 2.20 (Projects v2 CLI support). Tested on 2.92.
- `gh auth login` completed. For Projects v2: `gh auth refresh -s read:project,project`.

## Contents

| Path                              | Purpose                                           |
|-----------------------------------|---------------------------------------------------|
| `SKILL.md`                        | Entry point + jump table                          |
| `reference/shortcuts.md`          | Curated efficiency wins (read first)              |
| `reference/recipes.md`            | Long-form copy/paste recipes                      |
| `reference/gh-basics.md`          | Concise basics                                    |
| `reference/rest.md`               | `gh api` REST patterns                            |
| `reference/graphql.md`            | `gh api graphql` patterns + node-ID resolution    |
| `reference/projects-v2.md`        | Projects v2 via `gh project item-edit`            |
| `scripts/`                        | Projects v2 batch helpers (URL-driven, programmatic) |

## Install

### Claude Code — per user

```bash
git clone https://github.com/full-chaos/github-gh.git ~/.claude/skills/github-gh
```

Or symlink an existing checkout:

```bash
ln -s /path/to/github-gh ~/.claude/skills/github-gh
```

Claude Code auto-discovers skills under `~/.claude/skills/`. The `description` field in
`SKILL.md` is the trigger phrase the model sees.

### Claude Code — per project

```bash
git clone https://github.com/full-chaos/github-gh.git <repo>/.claude/skills/github-gh
```

Commit it for team-wide use or add to `.gitignore` if it stays personal.

### Codex CLI

Same `SKILL.md` spec — drop into Codex's skill path:

```bash
git clone https://github.com/full-chaos/github-gh.git ~/.codex/skills/github-gh
```

Or share one checkout between Codex and Claude Code:

```bash
git clone https://github.com/full-chaos/github-gh.git ~/.claude/skills/github-gh
ln -s ~/.claude/skills/github-gh ~/.codex/skills/github-gh
```

### General agents (Anthropic Agent SDK, OpenAI Agents, LangChain, etc.)

There's no native skill loader, but the same files plug into two common patterns:

**System-prompt injection** — read `SKILL.md` once and include in the agent's system
prompt; give the agent filesystem-read access to the skill directory so it can pull
`reference/*.md` files on demand:

```python
from pathlib import Path
SKILL_ROOT = Path("/path/to/github-gh")
system_prompt += "\n\n" + (SKILL_ROOT / "SKILL.md").read_text()
# Then expose SKILL_ROOT to the agent via a file-read tool.
```

**MCP server / tool wrapper** — wrap reference reads behind a single tool like
`gh_skill(topic)` that returns the contents of `reference/<topic>.md`. The model invokes
it on demand instead of preloading everything.

Either pattern still requires `gh` installed and authenticated in the agent's runtime.

## Future: install via `/plugin install` (Claude Code)

This repo currently ships `SKILL.md` at the root. To make it `/plugin install`-able,
restructure as:

```
repo-root/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── github-gh/
        ├── SKILL.md
        ├── reference/
        └── scripts/
```

Minimal `plugin.json`:

```json
{
  "name": "github-gh",
  "description": "GitHub via gh CLI — shortcuts, recipes, and Projects v2.",
  "version": "0.1.0",
  "author": { "name": "full-chaos" }
}
```

For one-command install, also publish a `marketplace.json` (in this repo or a
registry repo) listing this plugin. Then users run:

```
/plugin marketplace add full-chaos/github-gh
/plugin install github-gh
```

## Updating

```bash
cd ~/.claude/skills/github-gh && git pull
```

(Or, if symlinked, pull from wherever the checkout lives.)

## License

See [`LICENSE`](./LICENSE).
