#!/bin/bash

set -e 

## Ensure experiment is supported
EXPERIMENT_TYPE="conformance progressive fixed-split"
if [[ ! " ${EXPERIMENT_TYPE[@]} " =~ " ${1} " ]]; then
    echo "Experiment Type ${1} unsupported"
    echo "Use one of progreesive, conformance, fixed-split"
    exit 1
fi

# Step 1: Create the namespace where the service will be deployed
kubectl create ns knative-test

# Step 2: Deploy the knative-service
if [[ "progressive" == ${1} ]]; then
    echo "Installing Ksvc for progressive experiment"
    kubectl apply -f samples/common/service.yaml -n knative-test

elif [[ "conformance" == ${1} ]]; then
    echo "Installing Ksvc for conformance experiment"
    kubectl apply -f samples/common/service2.yaml -n knative-test

elif [[ "fixed-split" == ${1} ]]; then
    echo "Installing Ksvc for fixed-split experiment"
    kubectl apply -f samples/common/service3.yaml -n knative-test
fi


# Step 3: Wait for the service to be ready
kubectl wait --for condition=ready --timeout=180s ksvc/sample-application -n knative-test

