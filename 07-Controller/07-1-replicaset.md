# ReplicaSet container-demo

1. init d'un nouveau namespaces

```sh

# check the current config
kubectl config get-contexts

# create a namespace
kubectl create ns container-demo-rs-ns

# change the current namespace
kubectl config set-context --current --namespace=container-demo-rs-ns

# re-check the current config
kubectl config get-contexts

```


2. Création du ReplicaSet

```sh

# création d'un ReplicaSet
kubectl apply -f 11-container-demo-ReplicaSet.yaml


```

3. Affichage des détails

```sh

# lister toutes resources du namespace courant
# le nom des pods est prefixé par le nom du ReplicaSet
kubectl get all --show-labels -o wide

kubectl describe rs container-demo

kubectl get all --selector=app=container-demo --all-namespaces -o wide
```

4. Accès au pod

```sh

# replacer XXXXX
kubectl exec container-demo-XXXXX -- wget -qO- http://localhost:8080/ping
```

5. scaling

```sh
# scaling via la commande scale
kubectl scale rs --replicas=2 container-demo

# scaling via la mise à jour du yaml
kubectl apply -f 12-container-demo-ReplicaSet-3-replicas.yaml

# lister les pods
kubectl get pod

# tester CHAQUE pods
kubectl exec container-demo-XXXXX -- wget -qO- http://localhost:8080/ping

```

6. Mise à jour


```sh
kubectl apply -f 13-container-demo-ReplicaSet-v2-4-replicas.yaml

# lister les pods
kubectl get pod

# tester CHAQUE pods
kubectl exec container-demo-XXXXX -- wget -qO- http://localhost:8080/ping

# C'est quoi le problème !!!!!!!!!!!!

```
