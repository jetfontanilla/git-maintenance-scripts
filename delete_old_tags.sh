#!/bin/bash

git fetch --progress "origin" --tags --prune --force --prune-tags
# change '180 days ago' to any date period for cut-off
TAGS=$(git for-each-ref --sort=creatordate --format '%(refname:short) %(creatordate:raw)' refs/tags | awk '$2 < '$(date -d '180 days ago' +%s)'' | cut -d ' ' -f 1)

for tag in ${TAGS[@]}
do
    echo "deleting tag: $tag"
    git push --delete --force origin $tag
done
