#!/bin/bash

echo "################"
echo "*** Testing  ***"
echo "################"

docker run --rm -v /root/.m2:/root/.m2 -v $PWD/Back:/app -w /app maven:3-alpine "$@"