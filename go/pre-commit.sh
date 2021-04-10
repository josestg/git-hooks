#!/usr/bin/env bash

# Actions
FORMATS='[GO FORMATS]'
IMPORTS='[GO IMPORTS]'

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'


## this will retrieve all of the .go files that have been
## changed since the last commit
STAGED_GO_FILES=$(git diff --cached --name-only -- '*.go')

if [[ $STAGED_GO_FILES == "" ]]; then
    # shellcheck disable=SC2059
    printf "${PURPLE} No go files changed ${NC}\n"
else
  for file in $STAGED_GO_FILES; do
    ## Runs go fmt
    formatted=$(gofmt -l -w "$file")
    if [[ $formatted != "" ]]; then
      printf "${GREEN}${FORMATS} %-5s ${file} ${NC}\n"
    fi

    ## Runs go imports
    fixed_imports=$(goimports -l -w "$file")
    if [[ $fixed_imports != "" ]]; then
      printf "${YELLOW}${IMPORTS} %-5s ${file} ${NC}\n"
    fi

    git add "$file"
  done
fi

# Runs go mod tidy.
if go mod tidy -v 2>&1 | grep -q 'updates to go.mod needed'; then
    exit 1
fi

git diff --exit-code go.* &> /dev/null

if [ $? -eq 1 ]; then
    printf "go.mod or go.sum differs, please re-add it to your commit\n"
    exit 1
fi
