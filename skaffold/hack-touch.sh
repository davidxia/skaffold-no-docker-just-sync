#!/usr/bin/env bash

# This file is a hacky way of making skaffold do an initial sync of all relevant
# files in the working directory.

# Ignore skaffold files and .dockerignore
find_cmd="find . \( -path ./skaffold.yaml -o -path ./skaffold -o -path ./.dockerignore"

# Ignore all paths in .dockerignore
while read -r line; do
  find_cmd="$find_cmd -o -path './$line'"
done <.dockerignore

eval "$find_cmd \) -prune -o -name '*' -exec touch {} +"
