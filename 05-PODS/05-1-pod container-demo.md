# Les Pods : container-demo

## create namespace

```sh

# se connecter sur le master

# check the current config
kubectl config get-contexts

# create a namespace
kubectl create ns container-demo-pod-ns

# change the current namespace
kubectl config set-context --current --namespace=container-demo-pod-ns

# re-check the current config
kubectl config get-contexts
```

## create pod from minimal yaml file

- name of the pod : container-demo-pod
- name of the container : container-demo-container
- image & version : dmaumenee/container-demo:1.0

Créer un fichier container-demo-pod.yaml à partir de contenu suivant et replacer les <<<XXX>>> par les bonnes valeurs
**ATTENTION aux espaces !!!!!!**

```yaml
# Minimal pod definition
apiVersion: v1
kind: Pod
metadata:
  name: <<<POD_NAME>>>
spec:
  containers:
  - name: <<<CONTAINER_NAME>>>
    image: <<<IMAGES:VERSION>>>
```

```sh
kubectl apply -f container-demo-pod.yaml
```

## test du pod

```sh
# get pod IP
kubectl get pod -o wide

# détail du pod au format json
kubectl get pod container-demo-pod -o json

# utilisation de jsonpath pour afficher uniquement l'IP du pod
kubectl get pod container-demo-pod -o jsonpath='{.status.podIP}'

# sous linux : initialisation d'une variable d'environnement
POD_IP=`kubectl get pod container-demo-pod -o jsonpath='{.status.podIP}'`

# access the container-demo /ping API from the master or the worker
# sous windows remplacer $POD_IP par l'IP du pod
curl $POD_IP:8080/ping


# exec sh ouvrir un shell dans le container
kubectl exec -it container-demo-pod sh
env
wget -qO- http://localhost:8080/ping
exit

# execution de la commande env dans le container sans rester dans le shell du container
kubectl exec container-demo-pod env

# execution de la commande wget dans le container sans rester dans le shell du container
# -- nécessaire à cause des espaces dans la commande
kubectl exec container-demo-pod -- wget -qO- http://localhost:8080/ping

# accès au logs
kubectl logs container-demo-pod

```

## add env var

https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#define-an-environment-variable-for-a-container

ajouter ce bloc au fichier yaml :

```yaml
    env:
      - name: TITLE
        value: "Formation Kubernetes"
      - name: SHOW_VERSION
        value: "true"
```

```sh
# update => error Forbidden: pod updates may not change fields other than `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds` or `spec.tolerations`
kubectl apply -f container-demo-pod.yaml

# delete
kubectl delete -f container-demo-pod.yaml

# create
kubectl apply -f container-demo-pod.yaml

# check new env var TITLE and SHOW_VERSION
kubectl exec container-demo-pod env

```


## add env var from pod fields

https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/#use-pod-fields-as-values-for-environment-variables

ajouter ce bloc au fichier yaml :

```yaml
    env:
      ...
      - name: METADATA
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace 
```

```sh
# delete
kubectl delete pod container-demo-pod

# create
kubectl apply -f container-demo-pod.yaml

# check new env var METADATA
kubectl exec container-demo-pod env

```

## port

```sh
# check Port
kubectl describe pod container-demo-pod
      Port:           <none>
```

ajouter ce bloc au fichier yaml :

```yaml
    ports:
      - containerPort: 8080
```

```sh
# delete
kubectl delete pod container-demo-pod

# create
kubectl apply -f container-demo-pod.yaml

# re-check Port
kubectl describe pod container-demo-pod
    Port:           8080/TCP

```

## host port

/!\ ATTENTION DANGER /!\

ajouter la ligne hostPort au fichier yaml :
```yaml
    ports:
      - containerPort: 8080
        hostPort: 30080
```

```sh
# delete
kubectl delete pod container-demo-pod

# create
kubectl apply -f container-demo-pod.yaml

# re-check Port
kubectl describe pod container-demo-pod
...
Node:         <NODE-HOST-NAME>/<NODE-IP>
...
    Port:           8080/TCP
    Host Port:      30080/TCP

se connecter au master
curl http://<NODE-IP>:30080/ping
```

retrouver l'IP public correpondant au node sur lequel tourne le pod
dans un navigateur
http://<NODE1-PUBLIC-IP>:30080
http://<NODE2-PUBLIC-IP>:30080