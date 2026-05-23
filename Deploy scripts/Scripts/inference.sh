#!/bin/bash

source ~/venvs/inference-env/bin/activate

export III_URL=ws://10.0.2.97:49134

python inference_worker.py
