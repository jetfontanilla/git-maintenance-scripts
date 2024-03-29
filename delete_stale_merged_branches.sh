#!/bin/bash

function init() {
    git fetch --prune "origin"
    # modify this to whitelist particular branch name patterns
    ALL_BRANCH_LIST="$(git branch -r | grep -v "origin/master" | grep -v "origin/hotfix" | grep -v "origin/release")"
    ALL_BRANCH_ARRAY=($ALL_BRANCH_LIST)
    declare -a DELETE_BRANCH_LIST=()
}

error_exit()
{
    echo $1
    exit 1
}

function delete_branch() {
    echo "Deleting branch $1..."
    git push origin --delete $1 || error_exit "Failed to delete branch $1"
}

function delete_stale_branches() {
    create_delete_list

    for BRANCH_NAME in ${DELETE_BRANCH_LIST[@]}
    do
        delete_branch $BRANCH_NAME
    done
}

function create_delete_list() {
    for branch in ${ALL_BRANCH_ARRAY[@]}
    do
        # Ahead list includes the behind and ahead commit counts
        # Change branch name to compare here. in case you're using something else instead of master
        AHEAD_LIST=$(git rev-list --left-right --count origin/master...$branch)
        AHEAD_ARRAY=($AHEAD_LIST)
        if [[ ${AHEAD_ARRAY[1]} -eq 0 && ${AHEAD_ARRAY[0]} -gt 0 ]]
        then
            DELETE_BRANCH_LIST+=(${branch//origin\/})
        fi
    done
}

init
delete_stale_branches
