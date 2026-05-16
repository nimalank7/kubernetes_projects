Build and import the image

```
docker run . -t go-application:latest
k3d image import go-application -c autoscale
```

Create the deployment

```
kubectl apply -f deployment.yaml
```

Install the metrics server

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
```

Apply some load

```
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://go-application; done"
```

Track the replica increase

```
kubectl get hpa go-application-hpa --watch
```



