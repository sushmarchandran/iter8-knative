#!/bin/bash

set -e 

## Ensure experiment is supported
EXPERIMENT_TYPE="conformance progressive fixed-split"
if [[ ! " ${EXPERIMENT_TYPE[@]} " =~ " ${1} " ]]; then
    echo "Experiment Type ${1} unsupported"
    echo "Use one of progressive, conformance, fixed-split"
    exit 1
fi


# Step 1: Start the experiment
if [[ "progressive" == ${1} ]]; then
    echo "Starting progressive experiment"
    kubectl apply -f samples/experiments/experiment1.yaml -n knative-test

elif [[ "conformance" == ${1} ]]; then
    echo "Starting conformance experiment"
    kubectl apply -f samples/experiments/experiment2.yaml -n knative-test

elif [[ "fixed-split" == ${1} ]]; then
    echo "Starting fixed-split experiment"
    kubectl apply -f samples/experiments/experiment3.yaml -n knative-test
fi