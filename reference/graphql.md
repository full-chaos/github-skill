# gh api GraphQL (short)

## Resolve a URL to a node ID (Issue/PR)
```bash
gh api graphql -f query='
  query($url:URI!){
    resource(url:$url){
      ... on Issue { id number title }
      ... on PullRequest { id number title }
    }
  }' -F url="https://github.com/ORG/REPO/issues/42"
```

## Rule
Use GraphQL when you need:
- node IDs
- Projects v2 operations (fields, items, updates)
