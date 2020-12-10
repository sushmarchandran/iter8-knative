# Out-of-the-box metrics

Iter8-kfserving package ships with fourteen "out-of-the-box" metrics, which are described in the following table. You can extend this set by defining custom metrics. Each metric is defined at a per-version level. For example, the `request-count` metric measures the number of requests to a model version; the `mean-latency` metric measures the mean latency of a model version. Metrics can be of type `counter` or `gauge`. They are inspired by [Prometheus counter metric type](https://prometheus.io/docs/concepts/metric_types/#counter) and [Prometheus gauge metric type](https://prometheus.io/docs/concepts/metric_types/#gauge).

Users relying on iter8's out-of-the-box metrics can simply reference them in the _criteria_ section of an _experiment_ specification. Description of the _experiment_ CRD is coming soon! During an `experiment`, for every call made from the _controller_ to the _analytics_ service, the latter, in turn, calls Prometheus to retrieve values of the metrics referenced by the Kubernetes `experiment` resource. _Iter8-analytics_ analyzes the model versions that are a part of the experiment and arrives at an assessment based on their metric values. It returns this assessment to the _controller_.

|Name   |Description    |Type   |Units  |
|---    |----           |---    |---    |
|request-count  | Number of requests      | counter   |    |
|mean-latency   | Mean latency    | gauge      | milliseconds |
|95th-percentile-tail-latency   | 95th percentile tail latency    | gauge      | milliseconds |
|error-count   | Number of error responses    | counter      |  |
|error-rate   | Fraction of requests with error responses    | gauge      |  |
|container-throttled-seconds-total   | Total time duration the container has been throttled    | counter      | seconds |
|container-cpu-load-average-10s   | Value of container cpu load average over the last 10 seconds    | gauge      | |
|container-fs-io-time-seconds-total   | Cumulative count of seconds spent doing I/Os    | counter      | seconds |
|container-memory-usage-bytes   | Current memory usage, including all memory regardless of when it was accessed | gauge      | bytes |
|container-memory-failcnt   | Number of times memory usage hit resource limit    | counter      | |
|container-network-receive-errors-total   | Cumulative count of errors encountered while receiving    | counter      | |
|container-network-transmit-errors-total   | Cumulative count of errors encountered while transmitting    | counter      | |
|container-processes   | Number of processes running inside the container    | gauge      | |
|container-tasks-state   | Number of tasks in given state (sleeping, running, stopped, uninterruptible, or ioawaiting)    | gauge      | |

A description of the metrics CRD and instructions on how to add custom metrics is provided [here](metrics_custom.md).