#!/bin/bash

docker buildx build --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
             --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
             --platform linux/amd64,linux/arm64 \
             --pull -t isaudits/nessus:latest .
             
docker image prune -f