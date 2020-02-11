```
kubectl create configmap container-demo-env-file --from-env-file=container-demo-env-file.properties

# display the yaml
kubectl get configmap container-demo-env-file -o yaml

kubectl apply -f container-demo-config-map.yaml
kubectl exec container-demo-69644cdc8d-2gr7x env
kubectl exec container-demo-69644cdc8d-2gr7x sh
    wget -qO- http://localhost:8080/ping

kubectl get pod -o wide
curl http://<POD_IP>:8080/ping

kubectl apply -f container-demo-service-ClusterIP.yaml
kubectl get svc
curl http://<SVC_IP>:8080/ping

kubectl apply -f container-demo-ingress.yaml 
```