# Custom Metrics

When you install iter8-kfserving, fourteen [out-of-the-box metrics](metrics_ootb.md) are available to be used in _iter8-experiments_. You can extend this set with custom metrics by creating a Metric object. Some of the details needed to create a custom metric are described in the following examples of sample _gauge_ and _counter_ metric objects.

### Sample gauge metric
```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:

  # Name of the custom metric
  name: mean-latency
spec:
  params:

    # Iter8 uses a query template to query Prometheus and compute the value of the metric for every model version. Currently, iter8 supports Prometheus as a backend database to observe metrics.
    # Please refer to the Prometheus Query Template section below to learn more.
    query: (sum(increase(revision_app_request_latencies_sum{service_name=~'.*$name'}[$interval]))or on() vector(0)) / (sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0))
  
  # A description for the metric; optional
  description: Mean latency

  # a string denoting the unit of the metric defined; optional
  units: milliseconds

  # Iter8 metrics can be of two types: if the metric defined is a counter (i.e., its value never decreases over time) then its type is 'counter', otherwise it is 'gauge' 
  type: gauge

  # measures the number of requests to a model version over which this metric is measured; optional
  sample_size: 
    name: request-count

  # Currently, iter8 supports Prometheus as a backend metrics provider. Other backend support is coming soon!
  provider: prometheus
```

#### Sample counter metric CR
```
apiVersion: iter8.tools/v2alpha1
kind: Metric
metadata:

  # Name of the custom metric
  name: request-count
spec:
  params:

    # Iter8 uses a query template to query Prometheus and compute the value of the metric for every model version. Currently, iter8 supports Prometheus as a backend database to observe metrics.
    # Please refer to the Prometheus Query Template section below to learn more.
    query: sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0)
  
  # A description for the metric; optional
  description: Number of requests

  # Iter8 metrics can be of two types: if the metric defined is a counter (i.e., its value never decreases over time) then its type is 'counter', otherwise it is 'gauge' 
  type: counter

  # Currently, iter8 supports Prometheus as a backend metrics provider. Other backend support is coming soon!
  provider: prometheus
```

### Prometheus query template

Every metric object requires parameters as seen in the above section to enable _iter8_analytics_ to query the backend metrics database. Specifically, the Prometheus query template also has placeholders that are processed by _iter8-analytics_ as described below.

Here is a sample Prometheus query template:
```
sum(increase(revision_app_request_latencies_count{service_name=~'.*$name'}[$interval])) or on() vector(0)
```

The query template has two placeholders (i.e., terms beginning with $). These placeholders are substituted with actual values by _iter8-analytics_ in order to construct a Prometheus query.
1) The `$name` placeholder is replaced by the name of the model version participating in the experiment. _Iter8-analytics_ queries Prometheus with different values (i.e. default or canary) for this placeholder based on the type of the experiment.
2) The `$interval` placeholder captures the time period of aggregation.

Once the custom metric is created, it can be referenced in the `criteria` section of the experiment CRD.