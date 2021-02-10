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


**Step 3:** Install Knative, a networking layer of your choice and iter8. This may take a couple of minutes. Replace <NETWORK-LAYER> in the following command with one of the following network layers that iter8 has been tested with: `contour`, `gloo`, `istio` and `kourier`.
```
cd iter8-knative
./quickstart/platformsetup.sh <NETWORK-LAYER>
```


**Step 4:** Set up the knative service for the type of experiment you wish to run. Replace <EXPERIMENT-TYPE> in the following command with one of the following experiment types that iter8 supports: `progressive`, `conformance` or `fixed-split`. This may take a couple of minutes.

```
./quickstart/ksvcsetup.sh <EXPERIMENT-TYPE>
```

**Step 5:** In a separate terminal generate load for the knative service.
```
export URL_VALUE=$(kubectl get ksvc sample-application -n knative-test -o json | jq .status.address.url)
sed "s+URL_VALUE+${URL_VALUE}+g" quickstart/fortio.yaml | kubectl apply -f -
```


**Step 6:** Start your experiment. Replace <EXPERIMENT-TYPE> in the following command with one of the following experiment types that iter8 supports: `progressive`, `conformance` or `fixed-split`. 

```
./quickstart/startexperiment.sh <EXPERIMENT-TYPE>
```

**Step 7:** Observe the experiment object
```
kubectl get experiment -n knative-test -oyaml
```


**Step 8:** *In a separate terminal,* periodically describe the experiment.

**Install** [iter8ctl](https://github.com/iter8-tools/iter8ctl). You can change the directory where `iter8ctl` binary is installed by changing GOBIN below.
```shell
GO111MODULE=on GOBIN=/usr/local/bin go get github.com/iter8-tools/iter8ctl@v0.1.0-alpha
```

Periodically describe the experiment.
```
while clear; do
  kubectl get experiment <EXPERIMENT-NAME> -n knative-test -o yaml | iter8ctl describe -f -
  sleep 15
done
```

You should see output similar to the following.
```shell
******
Experiment name: experiment-1
Experiment namespace: knative-test
Experiment target: knative-test/sample-application

******
Number of completed iterations: 6

******
Winning version: sample-application-v2

******
Objectives
+--------------------------+-----------------------+-----------------------+
|        OBJECTIVE         | SAMPLE-APPLICATION-V1 | SAMPLE-APPLICATION-V2 |
+--------------------------+-----------------------+-----------------------+
| mean-latency <= 2000.000 | true                  | true                  |
+--------------------------+-----------------------+-----------------------+
| error-rate <= 0.010      | true                  | true                  |
+--------------------------+-----------------------+-----------------------+

******
Metrics
+-----------------------------+-----------------------+-----------------------+
|           METRIC            | SAMPLE-APPLICATION-V1 | SAMPLE-APPLICATION-V2 |
+-----------------------------+-----------------------+-----------------------+
| request-count               |               133.138 |                 9.943 |
+-----------------------------+-----------------------+-----------------------+
| mean-latency (milliseconds) |                 5.473 |                 4.251 |
+-----------------------------+-----------------------+-----------------------+
| error-rate                  |                 0.000 |                 0.000 |
+-----------------------------+-----------------------+-----------------------+
```

The experiment should complete after 8 iterations (~3 mins). Once the experiment completes, inspect the KnativeService object. 
```shell
kubectl get ksvc -n knative-test
```

You should see 100% of the traffic shifted to the canary model in the case of a progressive experiment. The traffic split should have remained unchanged during the course of the experiment.