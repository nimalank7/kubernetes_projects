# Scheduler

Toy scheduler forked from https://github.com/kelseyhightower/scheduler

## Usage

TODO:
- Code currently uses `kubectl proxy` but can be modified to use `client-go.`
- New RBAC permissions if using `client-go`
- Dockerfile needs to build the Go binary
- Verify it can run as a k8s deployment

1. Build the annotator and scheduler

```
go build -o ./scheduler ./scheduler
go build -o ./annotator ./annotator
```

1. Start `kubectl proxy`

```
kubectl proxy
Starting to serve on 127.0.0.1:8001
```

2. Run the annotator to annotate each node:

```
go run annotator/main.go
gke-k0-default-pool-728d327f-00lq 1.60
gke-k0-default-pool-728d327f-3vzg 0.20
gke-k0-default-pool-728d327f-nmz7 0.80
gke-k0-default-pool-728d327f-pxee 0.05
gke-k0-default-pool-728d327f-xm4i 0.05
gke-k0-default-pool-728d327f-zynj 0.20
```

3. Create a deployment to use the custom scheduler

```
kubectl create -f deployments/nginx.yaml
deployment "nginx" created
```

The nginx pod should be in a `Pending` state:

```
kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
nginx-1431970305-mwghf   0/1       Pending   0          27s
```

4. Run the annotator to list the price of each node

List the nodes and note the price of each node.

```
./annotator/annotator -l
gke-k0-default-pool-728d327f-00lq 0.80
gke-k0-default-pool-728d327f-3vzg 0.40
gke-k0-default-pool-728d327f-nmz7 0.40
gke-k0-default-pool-728d327f-pxee 0.05
gke-k0-default-pool-728d327f-xm4i 1.60
gke-k0-default-pool-728d327f-zynj 0.40
```

5. Run the scheduler

Run the best price scheduler:

```
./scheduler/scheduler
2016/08/19 11:16:25 Starting custom scheduler...
2016/08/19 11:16:28 Successfully assigned nginx-1431970305-mwghf to gke-k0-default-pool-728d327f-pxee
```

'Pending' nginx pod is deployed to the node with the lowest cost.

## Run the Scheduler on Kubernetes

```
kubectl create -f deployments/scheduler.yaml
deployment "scheduler" created
```
