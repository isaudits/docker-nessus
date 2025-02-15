#!/bin/bash

docker build --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
             --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
             --pull -t isaudits/nessus:latest .
             
docker image prune -f