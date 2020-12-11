#!/bin/bash

# Check if ITER8_KNATIVE_ROOT env variable is set
# Explanation: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash

set -e 

if [ -z "${ITER8_KNATIVE_ROOT}" ]
then 
    echo "ITER8_KNATIVE_ROOT is unset or set to ''"
    exit 1
else 
    echo "ITER8_KNATIVE_ROOT is set to '$ITER8_KNATIVE_ROOT'"
fi

# Step1: Install Knative (https://knative.dev/docs/install/any-kubernetes-cluster/#installing-the-serving-component)

# 1(a). Install the Custom Resource Definitions (aka CRDs):

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-crds.yaml

# 1(b). Install the core components of Serving (see below for optional extensions):

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-core.yaml


# Step 2: Install a network layer (Istio)

istioctl install -f ${ITER8_KNATIVE_ROOT}/quickstart/istio-minimal-operator.yaml 


# Step 3: Install the Knative Istio Controller

kubectl apply --filename https://github.com/knative/net-istio/releases/download/v0.17.0/release.yaml


# Step 4: Install Prometheus addon for Istio (https://istio.io/latest/docs/ops/integrations/prometheus/)

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
