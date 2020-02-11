# Deploy Ingress an ingress

## container-demo

```sh
# adapter le hostname container-demo-ingress.XX.XX.XX.XX.xip.io
# mettre l'IP PUBLIC du Load Balancer HAP proxy (master)
vim container-demo-ingress.yaml


# appliquer la mise à jour de l'ingress pour le service container-demo-svc
kubectl apply -f container-demo-ingress.yaml


```