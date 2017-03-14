#!/bin/bash

echo "configuring environment"
export ATLAS_BUILD_GITHUB_COMMIT_SHA=$(git rev-parse HEAD)
export ATLAS_BUILD_GITHUB_TAG=$(git describe --exact-match HEAD 2> /dev/null)
export ATLAS_BUILD_SLUG="arrjay/infra"

echo "dumping environment"
env

packer build efw.json
