# SERVICES

## container-demo

### deployment

Vérifier si le Deployment container-demo réalisé en fin de TP sur précédant est OK (3 pods)

```sh

# check
kubectl get all

# check the current config
kubectl config get-contexts

# create a namespace
kubectl create ns container-demo-deploy-ns

# change the current namespace
kubectl config set-context --current --namespace=container-demo-deploy-ns

# re-check the current config
kubectl config get-contexts

# apply the file 07-Controller\22-container-demo-deployment-3-replicas.yaml
kubectl apply -f 22-container-demo-deployment-3-replicas.yaml --record

# check
kubectl get all

```

### ClusterIP

01-container-demo-service-ClusterIP.yaml :
```yaml
apiVersion: v1
kind: Service
metadata: 
  labels: 
    app: container-demo
  name: container-demo-svc # correspond a l'alias DNS du service
spec: 
  type: ClusterIP
  ports: 
    - port: 80
      targetPort: 8080
  selector: 
    app: container-demo
```

```sh

# create ClusterIP service
kubectl apply -f 01-container-demo-service-ClusterIP.yaml

# get IP
kubectl get svc -o wide
# output
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
container-demo-svc   ClusterIP   10.101.67.149   <none>        80/TCP    10m   app=container-demo

# Access au service via IP (depuis une VM du cluster)=> Loadbalancing entre les pods
curl <SERVICE_IP>/ping
{"instance":"container-demo-77cf445b64-j5s7c","version":"2.0"}
curl <SERVICE_IP>/ping
{"instance":"container-demo-77cf445b64-jxdhh","version":"2.0"}
curl <SERVICE_IP>/ping
{"instance":"container-demo-77cf445b64-t9tdw","version":"2.0"}

# Accès au service via DNS Service Name (depuis un POD container-demo du namespace)
kubectl exec -it <POD_NAME> sh
wget -qO- container-demo-svc/ping
# visualisation de la config de résolution DNS pour retrouver le nom qualifier
more /etc/resolv.conf
nameserver 10.96.0.10
search container-demo-deploy-ns.svc.cluster.local svc.cluster.local cluster.local


# Test de l'acces depuis un pod dans le meme namespace realisant des wget
kubectl apply -f 10-wget-pod-call-svc.yaml
kubectl logs -f  wget-pod
```

Accès au service via DNS Service Name depuis un POD d'un autre namespace il faut utiliser le nom qualifié :
<SVC-NAME><NAMESPACE>.svc.cluster.local
container-demo-svc.container-demo-deploy-ns.svc.cluster.local

```sh

# create namespace other
kubectl create ns other-namespace

# apply du yaml dans le namespace other-namespace
kubectl apply -f 11-wget-pod-call-svc-qualified-name.yaml --namespace other-namespace

# check resources
kubectl get all --namespace other-namespace
kubectl get pod --all-namespaces
kubectl get svc --all-namespaces

# consultation des logs
kubectl logs -f  wget-pod --namespace other-namespace

```



### NodePort

```sh

# update ClusterIP service to NodePort
kubectl apply -f 02-container-demo-service-NodePort.yaml

# get IP
kubectl get svc -o wide
# output (dans l'exemple le nodeport alloue est le 30797)
NAME                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
container-demo-svc   NodePort   10.101.67.149   <none>        80:30797/TCP   31m   app=container-demo

# récupérer via une commande jsonpath le NodePort alloué dynamiquement par K8s
kubectl get svc container-demo-svc -o jsonpath='{.spec.ports[*].nodePort}'


# Access au service depuis un navigateur
http://<MASTER_PUBLIC_IP>:<NODE_PORT>
http://<WORKER1_PUBLIC_IP>:<NODE_PORT>
http://<WORKER2_PUBLIC_IP>:<NODE_PORT>

# Canary deployment
# en complément des 3 pods V1 on déploit un pods en V2
kubectl apply -f ../07-Controller/22.1-container-demo-deployment-V2-canary.yaml

# vérifier les resources crééer et leurs selector
kubectl get all -o wide

# supprimer le deploiment canary
kubectl delete -f ../07-Controller/22.1-container-demo-deployment-V2-canary.yaml


# scale 1
kubectl scale deployment --replicas=1 container-demo

# TOUTES les machines du cluster server le hostport même si le pod ne tourne par en local sur la machine

# scale 4 et regarder votre navigateur
kubectl scale deployment --replicas=4 container-demo

# faire F5 dans le navigateur pour purger les anciens container

# rolling update 07-Controller\23-container-demo-deployment-v2-4-replicas.yaml
# se placer dans le répertoire 07
# regarder votre navigateur
kubectl apply -f 23-container-demo-deployment-v2-4-replicas.yaml

```

### retour au cluster IP

Pour les TPs du chapitre 9 revenir à un ClusterIP

```sh

kubectl delete svc container-demo-svc

kubectl apply -f 01-container-demo-service-ClusterIP.yaml

kubectl get svc

```


## Voting APP

[TP Voting APP](./voting-app/voting-app.md)

## TPs Facultatif
Lorsque k8s démarre un conteneur, il fournit des variables d'environnement pointant vers tous les services en cours d'exécution 
Si un service existe, tous les conteneurs recevront les variables
Ne spécifiez pas de hostPort pour un Pod, sauf si cela est absolument nécessaire. (Limite le nombre d'endroits où le Pod peut être planifié, car chaque hostIP < hostIP , hostPort , protocol > doit être unique)
 Si vous ne spécifiez pas explicitement le hostIP et le protocol , k8s utilise 0.0.0.0 comme hostIP par défaut et TCP comme protocol
Si vous avez seulement besoin d'accéder au port à des fins de débogage, vous pouvez utiliser le proxy kubectl port-forward
Si vous avez explicitement besoin d'exposer le port d'un Pod sur le nœud, envisagez d'utiliser un service NodePort avant de recourir à hostPort .
Évitez d'utiliser hostNetwork , pour les mêmes raisons que hostPort .
Utilisez les services sans ClusterIP  pour faciliter la découverte du service lorsque vous n'avez pas besoin de l'équilibrage.


1/ Service avec ou sans Selector:
```yaml
apiVersion: v1
kind: Service
metadata:
   name: My_Service
spec:
   selector: # falcultatif: Contraint à créer un Endpoint pour transférer le trafic
      application: "My Application"  
   ports:
   - port: 8080
   targetPort: 31999
```
*Dans cet exemple, nous avons un sélecteur; Pour transférer le trafic, nous devons donc créer manuellement un EndPoint
-créer un EndPoint qui acheminera le trafic vers le node final défini comme "192.168.168.40:8080".
```yaml
apiVersion: v1
kind: Endpoints
metadata:
   name: Tutorial_point_service
subnets:
   address:
      "ip": "192.168.168.40" -------------------> (Selector)
   ports:
      - port: 8080
```

2/ Service multi-ports:
```yaml
piVersion: v1
kind: Service
metadata:
   name: Tutorial_point_service
spec:
   selector:
      application: "My Application"
   ClusterIP: 10.3.0.12
   ports:
      -name: http
      protocol: TCP
      port: 80
      targetPort: 31999
   -name:https
      Protocol: TCP
      Port: 443
      targetPort: 31998
```      
*CLUSTERIP: Expose (restreindre) le service a l'interieur du cluster.       
      
      
3/ Créer un service complet "NodePort". 
*Un service ClusterIP, auquel ce service "NodePort" acheminera les flux est automatiquement créé. Le service est accéssible de l'extérieur à l'aide de :  NodeIP:NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
   name: My-service
   labels:
      k8s-app: appname
spec:
   type: NodePort   #Expose le service sur un port statique du node
   ports:
   - port: 8080
      nodePort: 31999
      name: Name-NodePord-Service
      #clusterIP: 10.10.10.10
   selector:
      k8s-app: appname
      component: nginx
      env: env_name
```   

