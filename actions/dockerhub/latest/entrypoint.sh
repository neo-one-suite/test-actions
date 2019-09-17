#!/bin/sh

set -u -e -o pipefail

## mapping of var from user input or default value

USERNAME=${GITHUB_REPOSITORY%%/*}
REPOSITORY=${GITHUB_REPOSITORY#*/}

SHA_TAG=${GITHUB_SHA:0:7}
LATEST_TAG=latest
IMAGE_NAME=${DOCKER_IMAGE_NAME:-$REPOSITORY} ## use github repository name as docker image name unless specified
REGISTRY_IMAGE="$DOCKER_NAMESPACE/$IMAGE_NAME"
echo IMAGE_NAME: $IMAGE_NAME
echo REGISTRY_IMAGE: $REGISTRY_IMAGE

## login if needed
if [ -n "${DOCKER_PASSWORD+set}" ]
then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
fi

## build the image locally
docker build -t $IMAGE_NAME ${*:-.} ## pass in the build command from user input, otherwise build in default mode

# push sha tagged image to the repository
docker tag $IMAGE_NAME $REGISTRY_IMAGE:$SHA_TAG
docker push $REGISTRY_IMAGE:$SHA_TAG

# push latest tagged image to the repository
docker tag $IMAGE_NAME $REGISTRY_IMAGE:$LATEST_TAG
docker push $REGISTRY_IMAGE:$LATEST_TAG