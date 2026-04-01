#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$HOME/.config/tmux/theme.sh"

cd "$1" || exit 1
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
BRANCH_STATUS="$RESET#[fg=${THEME[base05]},bg=${THEME[base00]}] $BRANCH "
STATUS=$(git status --porcelain 2>/dev/null | grep -cE "^(M| M)")
PROVIDER=$(git config remote.origin.url | sed 's|https://||' | sed 's|git@||' | awk -F'[:/]' '{print $1}')
PROVIDER_ICON=""

if [[ -z $BRANCH ]]; then
  exit 0
fi

if [[ $STATUS -ne 0 ]]; then
  DIFF_COUNTS=($(git diff --numstat 2>/dev/null | awk 'NF==3 {changed+=1; ins+=$1; del+=$2} END {printf("%d %d %d", changed, ins, del)}'))
  CHANGE_COUNT=${DIFF_COUNTS[0]}
  ADD_COUNT=${DIFF_COUNTS[1]}
  DELETE_COUNT=${DIFF_COUNTS[2]}
fi

UNTRACKED_COUNT="$(git ls-files --other --exclude-standard | wc -l | bc)"

if [[ $CHANGE_COUNT -gt 0 ]]; then
  CHANGE_STATUS="${RESET}#[fg=${THEME[base0D]},bg=${THEME[base00]}]~${CHANGE_COUNT} "
fi

if [[ $ADD_COUNT -gt 0 ]]; then
  ADD_STATUS="${RESET}#[fg=${THEME[base0F]},bg=${THEME[base00]}]+${ADD_COUNT} "
fi

if [[ $DELETE_COUNT -gt 0 ]]; then
  DELETE_STATUS="${RESET}#[fg=${THEME[base08]},bg=${THEME[base00]}]-${DELETE_COUNT} "
fi

if [[ $UNTRACKED_COUNT -gt 0 ]]; then
  UNTRACKED_STATUS="${RESET}#[fg=${THEME[base04]},bg=${THEME[base00]}]?${UNTRACKED_COUNT} "
fi

if [[ $PROVIDER == "github.com" ]]; then
  if command -v gh &>/dev/null; then
    REPO=$(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')
    read -r OWNER NAME <<<"$REPO"
    DATA=$(gh api graphql -F owner="$OWNER" -F name="$NAME" -f query='
      query($name: String!, $owner: String!) {
        repository(owner: $owner, name: $name) {
          stargazerCount
          forkCount
          issues(states: OPEN) { totalCount }
          pullRequests(states: OPEN) { totalCount }
          defaultBranchRef {
            target {
              ... on Commit {
                history { totalCount }
              }
            }
          }
        }
        search(query: "is:pr is:open review-requested:@me", type: ISSUE, first: 0) {
          issueCount
        }
      }
    ')
    PROVIDER_ICON="$RESET#[fg=${THEME[base05]},bg=${THEME[base00]}] "
    COMMIT_COUNT=$(echo "$DATA" | jq '.data.repository.defaultBranchRef.target.history.totalCount')
    FORK_COUNT=$(echo "$DATA" | jq '.data.repository.forkCount')
    STAR_COUNT=$(echo "$DATA" | jq '.data.repository.stargazerCount')
    ISSUE_COUNT=$(echo "$DATA" | jq '.data.repository.issues.totalCount')
    PR_COUNT=$(echo "$DATA" | jq '.data.repository.pullRequests.totalCount')
    REVIEW_COUNT=$(echo "$DATA" | jq '.data.search.issueCount')
  else
    exit 1
  fi
elif [[ $PROVIDER == "gitlab.com" ]]; then
  if command -v glab &>/dev/null; then
    # NOTE: test me!
    REPO=$(glab repo view --json fullPath -q .fullPath)
    DATA=$(glab api graphql -f query='
      query($path: ID!) {
        project(fullPath: $path) {
          starCount
          forksCount
          statistics {
            commitCount
          }
          issues(state: opened) {
            count
          }
          mergeRequests(state: opened) {
            count
          }
        }
        currentUser {
          assignedMergeRequests(state: opened, reviewState: REVIEW_REQUESTED) {
            count
          }
        }
      }
    ' -F path="$REPO")
    PROVIDER_ICON="$RESET#[fg=${THEME[base09]},bg=${THEME[base00]}] "
    COMMIT_COUNT=$(echo "$DATA" | jq '.data.project.statistics.commitCount')
    FORK_COUNT=$(echo "$DATA" | jq '.data.project.forksCount')
    STAR_COUNT=$(echo "$DATA" | jq '.data.project.starCount')
    ISSUE_COUNT=$(echo "$DATA" | jq '.data.project.issues.count')
    PR_COUNT=$(echo "$DATA" | jq '.data.project.mergeRequests.count')
    REVIEW_COUNT=$(echo "$DATA" | jq '.data.currentUser.assignedMergeRequests.count')
  else
    exit 1
  fi
else
  exit 0
fi

if [[ $COMMIT_COUNT -gt 0 ]]; then
  COMMIT_STATUS="${RESET}#[fg=${THEME[base0C]},bg=${THEME[base00]}]󰜝 ${COMMIT_COUNT} "
fi

if [[ $FORK_COUNT -gt 0 ]]; then
  FORK_STATUS="${RESET}#[fg=${THEME[base0C]},bg=${THEME[base00]}] ${FORK_COUNT} "
fi

if [[ $STAR_COUNT -gt 0 ]]; then
  STAR_STATUS="${RESET}#[fg=${THEME[base0A]},bg=${THEME[base00]}] ${STAR_COUNT} "
fi

if [[ $ISSUE_COUNT -gt 0 ]]; then
  ISSUE_STATUS="${RESET}#[fg=${THEME[base0B]},bg=${THEME[base00]}] ${ISSUE_COUNT} "
fi

if [[ $PR_COUNT -gt 0 ]]; then
  PR_STATUS="${RESET}#[fg=${THEME[base0E]},bg=${THEME[base00]}] ${PR_COUNT} "
fi

if [[ $REVIEW_COUNT -gt 0 ]]; then
  REVIEW_STATUS="${RESET}#[fg=${THEME[base0E]},bg=${THEME[base00]}] $${REVIEW_COUNT} "
fi

WB_STATUS="#[fg=${THEME[base05]},bg=${THEME[base00]}]░ $PROVIDER_ICON "
WB_STATUS+="$BRANCH_STATUS$ADD_STATUS$CHANGE_STATUS$DELETE_STATUS$UNTRACKED_STATUS"
WB_STATUS+="$COMMIT_STATUS$FORK_STATUS$STAR_STATUS$ISSUE_STATUS$PR_STATUS$REVIEW_STATUS$RESET"

echo "$WB_STATUS"

# Wait extra time if status-interval is less than 30 seconds to
# avoid to overload GitHub API
INTERVAL=$(tmux display -p '#{status-interval}')
if [[ $INTERVAL -lt 20 ]]; then
  sleep 30
fi
