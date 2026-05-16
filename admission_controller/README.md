# Admission controller

This is a mutating admission webhook. It modifies a deployment to have 3 replicas

## Install cert manager in the cert-manager namespace
helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.18.2 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

## Build the image
docker build . -t mutating-replicant

## Import the image
k3d image import mutating-replicant –c monitoring

## Create the self-signed CA and certificate
kubectl apply –f certificates.yaml
kubectl get certificates
kubectl get clusterissuer
kubectl get issuer

## Create the webhook controller
kubectl apply –f controller.yaml
kubectl get deployment/mutating-replicant

## Create the mutating webhook
kubectl apply –f mutating-webhook.yaml
kubectl get mutatingwebhookconfigurations.admissionregistration.k8s.io

## Create the sample deployment
kubectl apply –f sample.yaml
kubectl get deployments
