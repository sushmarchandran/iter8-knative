set -e

# Sending prediction requests for model versions in quickstart and e2e tests

## Ensure network layer is supported
NETWORK_LAYERS="istio contour gloo kourier"
if [[ ! " ${NETWORK_LAYERS[@]} " =~ " ${1} " ]]; then
    echo "Network Layer ${1} unsupported"
    echo "Use one of istio, gloo, kourier, contour"
    exit 1
fi

# Step 1: Export INGRESS_HOST and INGRESS_PORT
if [[ "istio" == ${1} ]]; then
    ##########INGRESS_HOST for ISTIO ###########
    export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

elif [[ "contour" == ${1} ]]; then
    ##########INGRESS_HOST for CONTOUR ###########
    export INGRESS_HOST=$(kubectl --namespace contour-external get service envoy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export INGRESS_PORT=$(kubectl --namespace contour-external get service envoy -o jsonpath='{.spec.ports[?(@.name=="http")].port}')
    
elif [[ "gloo" == ${1} ]]; then
    ##########INGRESS_HOST for GLOO ###########
    export INGRESS_HOST=$(kubectl --namespace gloo-system get service knative-external-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export INGRESS_PORT=$(kubectl --namespace gloo-system get service knative-external-proxy -o jsonpath='{.spec.ports[?(@.name=="http")].port}')

elif [[ "kourier" == ${1} ]]; then
    ##########INGRESS_HOST for KOURIER ###########
    export INGRESS_HOST=$(kubectl --namespace kourier-system get service kourier -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export INGRESS_PORT=$(kubectl --namespace kourier-system get service kourier -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
fi


# Step 2: Export SERVICE_HOSTNAME
export SERVICE_HOSTNAME=$(kubectl get ksvc sample-application -n knative-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)

# Step 3: Generate prediction requests (2.5 per sec)
while clear; do
    curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}
    sleep 0.4
done