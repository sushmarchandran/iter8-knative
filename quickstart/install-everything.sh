#!/bin/bash

# Check if ITER8_KFSERVING_ROOT env variable is set
# Explanation: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash

set -e 

if [ -z "${ITER8_KFSERVING_ROOT}" ]
then 
    echo "ITER8_KFSERVING_ROOT is unset or set to ''"
    exit 1
else 
    echo "ITER8_KFSERVING_ROOT is set to '$ITER8_KFSERVING_ROOT'"
fi

rm -rf ${ITER8_KFSERVING_ROOT}/.tmp

mkdir ${ITER8_KFSERVING_ROOT}/.tmp

cd ${ITER8_KFSERVING_ROOT}/.tmp

git clone https://github.com/kubeflow/kfserving.git

cd kfserving 

./hack/quick_install.sh

kubectl create ns knative-monitoring

kubectl apply -f https://github.com/knative/serving/releases/download/v0.18.0/monitoring-metrics-prometheus.yaml

cd ${ITER8_KFSERVING_ROOT}

# Install iter8-kfserving
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/install/iter8-kfserving.yaml
kubectl wait --for condition=established --timeout=120s crd/metrics.iter8.tools
kubectl apply -f https://raw.githubusercontent.com/iter8-tools/iter8-kfserving/main/install/metrics/iter8-kfserving-metrics.yaml
