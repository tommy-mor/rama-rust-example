#!/bin/bash

set -e

pushd rama

./rama deploy \
--action launch \
--jar ../../backend/build/libs/*.jar \
--module sorter.social.soterweb.SorterModule \
--tasks 64 \
--threads 16 \
--workers 8 \
--replicationFactor 1
