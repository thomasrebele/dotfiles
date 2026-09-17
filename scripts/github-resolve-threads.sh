#!/bin/bash

# unfortunately this seems to require "Repository Permissions > Contents to Read and Write access"

owner="$1"
repo="$2"
pr="$3"

file="/tmp/gh-unresolved.txt"

fetch_unresolved() {
  gh api graphql -f query='
  query($owner:String!, $repo:String!, $pr:Int!) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$pr) {
        reviewThreads(first: 100) {
          nodes { 
            id
            isResolved 
            comments(first: 100) {
              nodes {
                id
                url
                body
                author {
                  login
                }
              }
            }
          }
        }
      }
    }
  }' -F owner="$owner" -F repo="$repo" -F pr="$pr" | jq -r '
    .data.repository.pullRequest.reviewThreads.nodes |
     map(select(.isResolved==false))  |
     .[] | "\n\n#" + .id, (.comments.nodes[]? | ["# ", .author.login, .body] | @tsv) ' > "$file"

  sed -i '1s/^/# list of unresolved threads; uncomment the thread id (PRT_...) to resolve them/' "$file"
}

user_choice() {
  vi "$file"
}

select_tasks() {
  cat "$file" | grep -v -e '^#' -e '^$'
}

resolve() {
  while read -r id; do
    
    gh api graphql -f query='mutation($id:ID!) {
      resolveReviewThread(input: {threadId: $id}) { thread { id isResolved } }
    }' -f id="$id" && printf 'resolved %s\n' "$id"
  done
}


select_tasks | resolve
