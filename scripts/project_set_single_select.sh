#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
need gh; need jq

ORG=""; PROJECT=""; URL=""; FIELD=""; OPTION=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2;;
    --project) PROJECT="$2"; shift 2;;
    --url) URL="$2"; shift 2;;
    --field) FIELD="$2"; shift 2;;
    --option) OPTION="$2"; shift 2;;
    *) die "Unknown arg: $1";;
  esac
done
[[ -n "$ORG" ]] || die "--org is required"
[[ -n "$PROJECT" ]] || die "--project is required"
[[ -n "$URL" ]] || die "--url is required"
[[ -n "$FIELD" ]] || die "--field is required"
[[ -n "$OPTION" ]] || die "--option is required"

CONTENT_ID="$(resolve_node_id_from_url "$URL")"
[[ -n "$CONTENT_ID" && "$CONTENT_ID" != "null" ]] || die "Could not resolve node id from URL: $URL"

q='
query($org:String!, $number:Int!){
  organization(login:$org){
    projectV2(number:$number){
      id
      fields(first:100){
        nodes{
          ... on ProjectV2SingleSelectField{
            id name options { id name }
          }
        }
      }
      items(first:100){
        nodes{
          id
          content { ... on Issue { id } ... on PullRequest { id } }
        }
      }
    }
  }
}'
resp="$(ghgql "$q" -F "org=$ORG" -F "number=$PROJECT")"
PROJECT_ID="$(echo "$resp" | jq -r '.data.organization.projectV2.id')"
FIELD_ID="$(echo "$resp" | jq -r --arg FIELD "$FIELD" '.data.organization.projectV2.fields.nodes[] | select(.name==$FIELD) | .id' | head -n1)"
OPTION_ID="$(echo "$resp" | jq -r --arg FIELD "$FIELD" --arg OPT "$OPTION" '
  .data.organization.projectV2.fields.nodes[]
  | select(.name==$FIELD)
  | .options[]
  | select(.name==$OPT)
  | .id
' | head -n1)"

[[ -n "$PROJECT_ID" && "$PROJECT_ID" != "null" ]] || die "Could not resolve project id"
[[ -n "$FIELD_ID" && "$FIELD_ID" != "null" ]] || die "Could not find single-select field named: $FIELD"
[[ -n "$OPTION_ID" && "$OPTION_ID" != "null" ]] || die "Could not find option \"$OPTION\" for field \"$FIELD\""

ITEM_ID="$(echo "$resp" | jq -r --arg CID "$CONTENT_ID" '
  .data.organization.projectV2.items.nodes[]
  | select(.content.id==$CID)
  | .id
' | head -n1)"

if [[ -z "${ITEM_ID:-}" || "${ITEM_ID:-}" == "null" ]]; then
  m_add='mutation($projectId:ID!, $contentId:ID!){addProjectV2ItemById(input:{projectId:$projectId, contentId:$contentId}){item{id}}}'
  ITEM_ID="$(ghgql "$m_add" -F "projectId=$PROJECT_ID" -F "contentId=$CONTENT_ID" --jq '.data.addProjectV2ItemById.item.id')"
fi

m='mutation($projectId:ID!, $itemId:ID!, $fieldId:ID!, $optionId:String!){
  updateProjectV2ItemFieldValue(input:{
    projectId:$projectId,
    itemId:$itemId,
    fieldId:$fieldId,
    value:{ singleSelectOptionId:$optionId }
  }){ projectV2Item { id } }
}'
ghgql "$m" -F "projectId=$PROJECT_ID" -F "itemId=$ITEM_ID" -F "fieldId=$FIELD_ID" -F "optionId=$OPTION_ID" >/dev/null
echo "{\"project_id\":\"$PROJECT_ID\",\"item_id\":\"$ITEM_ID\",\"field_id\":\"$FIELD_ID\",\"option_id\":\"$OPTION_ID\"}" | jq .
