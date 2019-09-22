#!/usr/bin/env bash

docker build --cpuset-cpus 0-"$(expr $(nproc) - 1)" -t pandalinux/temp-system:latest --compress --no-cache -f Dockerfile.temp . && docker push pandalinux/temp-system:latest