# Iter8-knative
> [Knative](https://knative.dev/) is a [Kubernetes](https://kubernetes.io)-based platform to deploy and manage modern serverless workloads. [Iter8](https://iter8.tools) enables metrics-driven live experiments, release engineering and rollout optimization for Kubernetes and OpenShift applications. The iter8-knative package brings the two projects together.

## Quick start on Minikube
The steps below enable you to perform automated canary rollout of a Knative model using latency and error-rate metrics collected in a Prometheus backend.

**Step 1:** Start Minikube with sufficient resources and appropriate Kubernetes version.
```
minikube start --cpus 5 --memory 11264 --kubernetes-version=v1.17.11 --driver=docker
```

**Step 2:** Clone this repository
```
git clone https://github.com/iter8-tools/iter8-knative.git
```


**Step 3:** Install Knative, Istio and Iter8. This may take a couple of minutes. Set up istioctl before running the following:
```
cd iter8-knative
export ITER8_KNATIVE_ROOT=$PWD
./quickstart/install-everything.sh
```

**Step 4:** Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:
```
kubectl get pods --namespace knative-serving
```

**Step 5:** In a separate terminal,, setup Minikube tunnel.
```
minikube tunnel --cleanup
```

**Step 6:** Create a Knative service in the `knative-test` namespace:
```
kubectl create ns knative-test
kubectl apply -f samples/common/service.yaml -n knative-test
```

**Step 7:** Verify that the service is running. This may take a couple of minutes
```
kubectl wait --for condition=ready --timeout=180s ksvc/sample-application -n knative-test
```
**Step 8:** In a separate terminal, from your iter8-knative folder, export `SERVICE_HOSTNAME`, `INGRESS_HOST` and `INGRESS_PORT` environment variables, and generate to the `ksvc` as follows.
```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SERVICE_HOSTNAME=$(kubectl get ksvc sample-application -n knative-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
watch -n 1.0 'curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}'
```

**Step 8:** Install the domain package and metrics
```
kubectl apply -f install/iter8-knative.yaml
kubectl apply -f install/metrics/metrics.yaml -n iter8-system
```

**Step 9:** Check if the installed objects are ready to be used

**Step 10:** Start your experiment
```
kubectl apply -f samples/experiments/example1.yaml -n knative-test
```

**Step 10:** Observe the experiment object
```
kubectl get experiment -n knative-test -oyaml
```


These instructions successfully run a Progressive test.

To run a Performance tests replace Steps 6 and 10 as follows:
Replace Step 6 with:
```
kubectl create ns knative-test
kubectl apply -f samples/common/service2.yaml -n knative-test

```
Replace step 10 with:
```
kubectl apply -f samples/experiments/example2.yaml -n knative-test
```


To run a Fixed Split tests replace Steps 6 and 10 as follows:
Replace Step 6 with:
```
kubectl create ns knative-test
kubectl apply -f samples/common/service3.yaml -n knative-test

```
Replace step 10 with:
```
kubectl apply -f samples/experiments/example3.yaml -n knative-test
```