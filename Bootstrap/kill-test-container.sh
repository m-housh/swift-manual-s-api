#!/bin/sh

docker container kill \
  $(docker container ls --all --quiet --filter name=^/api-client-test$) \
  || true
docker container rm \
  $(docker container ls --all --quiet --filter name=^/api-client-test$) \
  || true
