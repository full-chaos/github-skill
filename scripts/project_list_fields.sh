#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
need gh; need jq

ORG=""; PROJECT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2;;
    --project) PROJECT="$2"; shift 2;;
    *) die "Unknown arg: $1";;
  esac
done
[[ -n "$ORG" ]] || die "--org is required"
[[ -n "$PROJECT" ]] || die "--project is required"

q='
query($org:String!, $number:Int!){
  organization(login:$org){
    projectV2(number:$number){
      id title
      fields(first:100){
        nodes{
          __typename
          ... on ProjectV2FieldCommon { id name }
          ... on ProjectV2SingleSelectField { id name options { id name } }
          ... on ProjectV2IterationField { id name configuration { iterations { id title } } }
        }
      }
    }
  }
}'
ghgql "$q" -F "org=$ORG" -F "number=$PROJECT" --jq '.data.organization.projectV2.fields.nodes'
