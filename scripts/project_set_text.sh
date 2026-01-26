#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
need gh; need jq

ORG=""; PROJECT=""; URL=""; FIELD=""; VALUE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2;;
    --project) PROJECT="$2"; shift 2;;
    --url) URL="$2"; shift 2;;
    --field) FIELD="$2"; shift 2;;
    --value) VALUE="$2"; shift 2;;
    *) die "Unknown arg: $1";;
  esac
done
[[ -n "$ORG" ]] || die "--org is required"
[[ -n "$PROJECT" ]] || die "--project is required"
[[ -n "$URL" ]] || die "--url is required"
[[ -n "$FIELD" ]] || die "--field is required"
[[ -n "$VALUE" ]] || die "--value is required"

CONTENT_ID="$(resolve_node_id_from_url "$URL")"
[[ -n "$CONTENT_ID" && "$CONTENT_ID" != "null" ]] || die "Could not resolve node id from URL: $URL"

q='
query($org:String!, $number:Int!){
  organization(login:$org){
    projectV2(number:$number){
      id
      fields(first:100){
        nodes{ ... on ProjectV2TextField { id name } }
      }
    }
  }
}'
resp="$(ghgql "$q" -F "org=$ORG" -F "number=$PROJECT")"
PROJECT_ID="$(echo "$resp" | jq -r '.data.organization.projectV2.id')"
FIELD_ID="$(echo "$resp" | jq -r --arg FIELD "$FIELD" '.data.organization.projectV2.fields.nodes[] | select(.name==$FIELD) | .id' | head -n1)"

[[ -n "$PROJECT_ID" && "$PROJECT_ID" != "null" ]] || die "Could not resolve project id"
[[ -n "$FIELD_ID" && "$FIELD_ID" != "null" ]] || die "Could not find text field named: $FIELD"

ADD_JSON="$(bash "$(dirname "$0")/project_add_item.sh" "$ORG" "$PROJECT" "$URL")"
ITEM_ID="$(echo "$ADD_JSON" | jq -r '.item_id')"

m='mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $value:String!){
  updateProjectV2ItemFieldValue(input:{
    projectId:$projectId,
    itemId:$itemId,
    fieldId:$fieldId,
    value:{ text:$value }
  }){ projectV2Item { id } }
}'
ghgql "$m" -F "projectId=$PROJECT_ID" -F "itemId=$ITEM_ID" -F "fieldId=$FIELD_ID" -F "value=$VALUE" >/dev/null
echo "{\"project_id\":\"$PROJECT_ID\",\"item_id\":\"$ITEM_ID\",\"field_id\":\"$FIELD_ID\",\"value\":\"$VALUE\"}" | jq .
