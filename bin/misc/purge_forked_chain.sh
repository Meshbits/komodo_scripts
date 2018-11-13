#!/usr/bin/env bash
# Purges the block, chainstate while preserving other shiz

array=(
STUPIDCHAIN
)

for item in ${array[@]}; do
  rm -rf ~/.komodo/$item/{blocks,chainstate}
done
