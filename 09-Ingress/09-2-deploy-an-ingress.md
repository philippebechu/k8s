# Deploy Ingress an ingress

## container-demo

Pré-requis TP 07 sur le Deployment et TP 08 sur le service avec ClustIP

```sh

# check
kubectl get all

# check the current config
kubectl config get-contexts

# adapter le hostname container-demo-ingress.XX.XX.XX.XX.xip.io
# mettre l'IP PUBLIC du worker 1 ou du worker 2
vim container-demo-ingress.yaml


# deployer l'ingress pour le service container-demo-svc
kubectl apply -f container-demo-ingress.yaml

 

```