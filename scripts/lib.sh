#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 2; }; }
die() { echo "ERROR: $*" >&2; exit 1; }
run() { echo "+ $*" >&2; "$@"; }

ghgql() {
  local query="$1"; shift
  run gh api graphql -f "query=$query" "$@"
}

resolve_node_id_from_url() {
  local url="$1"
  local q='query($url:URI!){resource(url:$url){... on Issue{id} ... on PullRequest{id}}}'
  ghgql "$q" -F "url=$url" --jq '.data.resource.id'
}
