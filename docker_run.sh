#!/usr/bin/env bash

export var_tag="$1"

function image_build() {
  #docker build - < Dockerfile_komodo
  docker build -f Dockerfile_komodo -t "meshbits_komodo1604:${var_tag}" .
}

function image_push() {
  docker tag "meshbits_komodo1604:${var_tag}" "nsrea408/meshbits_komodo1604:${var_tag}"
  docker push "nsrea408/meshbits_komodo1604:${var_tag}"
}
