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

mkdir ${ITER8_KFSERVING_ROOT}/.tmp

cd ${ITER8_KFSERVING_ROOT}/.tmp

git clone https://github.com/kubeflow/kfserving.git

cd kfserving

./hack/quick_install.sh