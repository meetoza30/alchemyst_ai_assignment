#!/bin/bash

docker run -d \
--name caller-worker \
-e III_URL=ws://10.0.2.97:49134 \
yourdockerhub/caller-worker:v1

