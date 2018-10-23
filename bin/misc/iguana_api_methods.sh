#!/usr/bin/env bash

curl --url "http://127.0.0.1:7776" \
  --data '{ "agent":"SuperNET","method":"help" }' | jq .
