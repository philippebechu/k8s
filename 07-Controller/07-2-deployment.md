# Controller Deployment

## container-demo

1. init d'un nouveau namespace

```sh

# check the current config
kubectl config get-contexts

# create a namespace
kubectl create ns container-demo-deploy-ns

# change the current namespace
kubectl config set-context --current --namespace=container-demo-deploy-ns

# re-check the current config
kubectl config get-contexts

```

2. Création du deployment

```sh
kubectl apply -f 21-container-demo-deployment.yaml --record
```

3. Affichage des détails

```sh
kubectl get all --show-labels -o wide

kubectl describe deployment container-demo
  ...
  Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
  StrategyType:           RollingUpdate
  MinReadySeconds:        0
  RollingUpdateStrategy:  25% max unavailable, 25% max surge
  ...

kubectl get all --selector=app=container-demo -o wide
```

4. Accès au pod

```sh

# tester un pod
kubectl exec container-demo-XXXXX-YYYYYY -- wget -qO- http://localhost:8080/ping

# depuis une machine du cluster
curl <IP-POD-1>:8080/ping
{"instance":"container-demo-99cf445b64-q7yqd","version":"1.0"}

``` 

5. scale

```sh

# scaling via la commande scale
kubectl scale deployment --replicas=2 container-demo

# lister les ressources
kubectl get all -o wide

# scaling via la mise à jour du yaml
kubectl apply -f 22-container-demo-deployment-3-replicas.yaml --record

# lister les ressources
kubectl get all -o wide

```

6. Mise à jour Rolling Update


```sh
kubectl apply -f 23-container-demo-deployment-v2-4-replicas.yaml --record

# lister toutes les ressources du namespace
kubectl get all 

    # en cours de rolling update
    NAME                                  READY   STATUS        RESTARTS   AGE
    pod/container-demo-5d78566d8b-k7q67   0/1     Terminating   0          7m24s
    pod/container-demo-5d78566d8b-tvjhq   1/1     Running       0          20m
    pod/container-demo-879fbc449-22wxd    1/1     Running       0          24s
    pod/container-demo-879fbc449-4vts5    0/1     Running       0          10s
    pod/container-demo-879fbc449-fx97c    1/1     Running       0          24s
    pod/container-demo-879fbc449-pd9jg    0/1     Running       0          9s

    NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/container-demo   3/4     4            3           20m

    NAME                                        DESIRED   CURRENT   READY   AGE
    replicaset.apps/container-demo-5d78566d8b   1         1         1       20m
    replicaset.apps/container-demo-879fbc449    4         4         2       24s

    # à la fin de rolling update
    NAME                                 READY   STATUS    RESTARTS   AGE
    pod/container-demo-879fbc449-22wxd   1/1     Running   0          31s
    pod/container-demo-879fbc449-4vts5   1/1     Running   0          17s
    pod/container-demo-879fbc449-fx97c   1/1     Running   0          31s
    pod/container-demo-879fbc449-pd9jg   1/1     Running   0          16s

    NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/container-demo   4/4     4            4           20m

    NAME                                        DESIRED   CURRENT   READY   AGE
    replicaset.apps/container-demo-5d78566d8b   0         0         0       20m
    replicaset.apps/container-demo-879fbc449    4         4         4       31s



# tester CHAQUE pods
kubectl exec container-demo-XXXXX-YYYY -- wget -qO- http://localhost:8080/ping
  {"instance":"container-demo-879fbc449-22wxd","version":"v2.0","metadata":"container-demo-deploy-ns"}
# Pourquoi un Deployment est mieux qu'un ReplicaSet ????

```

5. historique

```sh
kubectl rollout history deployment container-demo
    deployment.apps/container-demo
    REVISION  CHANGE-CAUSE
    1         kubectl apply --filename=21-container-demo-deployment.yaml --record=true
    2         kubectl apply --filename=23-container-demo-deployment-v2-4-replicas.yaml --record=true
```

6. rollback

```sh
kubectl rollout undo deployment container-demo

# check history
kubectl rollout history deployment container-demo
  deployment.apps/container-demo
  REVISION  CHANGE-CAUSE
  2         kubectl apply --filename=23-container-demo-deployment-v2-4-replicas.yaml --record=true
  3         kubectl apply --filename=21-container-demo-deployment.yaml --record=true

# list
kubectl get all --selector=app=container-demo -o wide

# tester un POD
kubectl exec container-demo-XXXXX-YYYY -- wget -qO- http://localhost:8080/ping
{"instance":"container-demo-5d78566d8b-w22vl","version":"1.0","metadata":"container-demo-deploy-ns"}

```

7. swith to specific revision

```sh

# list revision history
kubectl rollout history deployment container-demo
deployment.apps/container-demo
REVISION  CHANGE-CAUSE
2         kubectl apply --filename=23-container-demo-deployment-v2-4-replicas.yaml --record=true
3         kubectl apply --filename=21-container-demo-deployment.yaml --record=true

# swith to revision 2
kubectl rollout undo deployment container-demo --to-revision=2

# list
kubectl get all -o wide

# tester un POD
kubectl exec container-demo-XXXXX-YYYY -- wget -qO- http://localhost:8080/ping
{"instance":"container-demo-879fbc449-zfmrn","version":"v2.0","metadata":"container-demo-deploy-ns"}
```


8. test Recreate Strategy

```sh
kubectl apply -f 24-container-demo-deployment-Recreate.yaml
```

9. hostport

ouvrir dans un navigateur deux onglets
http://<IP_PUBLIC_Worker1>:30080/
http://<IP_PUBLIC_Worker2>:30080/

```sh

# update Deployment
kubectl apply -f 26-container-demo-deployment-hostport.yaml --record

# list resource
kubectl get all -o wide

# check votre navigateur

# scale à 2
kubectl scale deployment --replicas=2 container-demo

# list resource
kubectl get all -o wide

# check votre navigateur

# scale à 3
kubectl scale deployment --replicas=3 container-demo

# list resource
kubectl get all -o wide

# le dernier pod est en state Pending WHY ?????????
kubectl describe pod

# ATTENTION au Host Port

```

10. retour à la v1 pour la suite des TP

```sh
kubectl apply -f 22-container-demo-deployment-3-replicas.yaml --record
```

## TP facultatifs


Bien que les ensembles des Controller aient toujours la capacité de gérer les pods et d’échelonner les instances de certains pods, ils ne peuvent pas effectuer de mise à jour propagée ni d’autres fonctionnalités. La méthode pour créer une application répliquée consiste à utiliser un déploiement, qui à son tour utilise un ReplicaSet. Le Deployment est un objet API de niveau supérieur qui met à jour ses ReplicaSets sous-jacents et leurs Pods de la même manière que kubectl rolling-update .

Ils ont la capacité de mettre à jour le jeu de réplicas et sont également capables de revenir à la version précédente. Ils fournissent de nombreuses fonctionnalités mises à jour de matchLabels et de sélecteurs.

1/ Exécuter une application à l'aide d'un objet Kubernetes Deployment.
```yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: Mydeployment
spec:
  selector:  # Utilisé pour déterminer les Pods du Cluster géré par ce controller Deployment
    matchLabels:
      app: nginx
  replicas: 2 
  template: 
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```


2/ Créez un déploiement basé sur le fichier YAML:
```bash
$ kubectl apply -f https://k8s.io/docs/tasks/run-application/deployment.yaml
ou
$ kubectl run Name-Pod --image=Image-registry:tag 
```


3/ Afficher des informations sur le déploiement:
```bash
$ kubctl get deployments
$ kubectl describe deployment nginx-deployment 
```


4/ Vérifier l'état du déploiement
```bash
$ kubectl rollout status deployment/nginx-deployment
```
Revenir au déploiement précédent
```bash
$ kubectl rollout undo deployment/Deployment --to-revision=2
```


5/ Mittre à jour la version d'image "1.8" utilisé par les Pods du Déployment et appliquer le nouveau fichier YAML. 
```bash
$ kubectl apply -f deployment-update.yaml 
ou 
$ kubectl set image deployment/Deployment tomcat=tomcat:6.0
```
Alternativement, nous pouvons edit le Déploiement et changer:
```bash
$ kubectl edit deployment/nginx
```


6/ Augmenter le "Scaling" en augmentant le nombre de réplicas (Pods) et appliquer les fichier Yaml:
```bash
kubectl apply -f deployment-scale.yaml
$ kubectl get pods -l app=nginx
ou
$ kubectl scale deployment nginx-deployment --replicas=10 
```

7/ Supprimer un déploiement:
```bash
$  kubectl delete deployment nginx-deployment 
```


## Pour aller plus loin 

-comment exécuter une application avec état à instance unique à l'aide de PersistentVolume et d'un déploiement.:
https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/

-comment exécuter une application avec état répliquée à l'aide d'un contrôleur StatefulSet. L'exemple est une topologie mono-maître MySQL avec plusieurs esclaves exécutant une réplication asynchrone. Notez qu'il ne s'agit pas d'une configuration de production. 
https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/

-Utiliser un correctif de fusion stratégique pour mettre à jour un déploiement:
https://kubernetes.io/docs/tasks/run-application/update-api-object-kubectl-patch/
