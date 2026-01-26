#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
need gh; need jq

[[ $# -eq 3 ]] || die "Usage: $0 ORG PROJECT_NUMBER ISSUE_OR_PR_URL"
ORG="$1"; PROJECT="$2"; URL="$3"

CONTENT_ID="$(resolve_node_id_from_url "$URL")"
[[ -n "$CONTENT_ID" && "$CONTENT_ID" != "null" ]] || die "Could not resolve node id from URL: $URL"

q_proj='query($org:String!, $number:Int!){organization(login:$org){projectV2(number:$number){id title}}}'
PROJECT_ID="$(ghgql "$q_proj" -F "org=$ORG" -F "number=$PROJECT" --jq '.data.organization.projectV2.id')"
[[ -n "$PROJECT_ID" && "$PROJECT_ID" != "null" ]] || die "Could not resolve project id"

m='mutation($projectId:ID!, $contentId:ID!){addProjectV2ItemById(input:{projectId:$projectId, contentId:$contentId}){item{id}}}'
ITEM_ID="$(ghgql "$m" -F "projectId=$PROJECT_ID" -F "contentId=$CONTENT_ID" --jq '.data.addProjectV2ItemById.item.id')"

echo "{\"project_id\":\"$PROJECT_ID\",\"content_id\":\"$CONTENT_ID\",\"item_id\":\"$ITEM_ID\"}" | jq .
