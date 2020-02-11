# Namespaces

```sh

# lister les namespaces
kubectl get namespaces
kubectl get ns #shortname

# creer via une commade create
kubectl create ns tmp

# lister les namespaces
kubectl get ns #shortname

# supprimer
kubectl delete ns tmp

```

	
---------------------------------------------------------------------------------------------------------------
## NAMESPACE:
---------------------------------------------------------------------------------------------------------------

1/ Créer un namespace via un fichier yaml :

```yaml  
apiVersion: v1
kind: Namespace
metadata:
  name: my-namespace
  labels: 
    env: formation
```

```bash
kubectl apply -f my-namespace.yaml
```

2/ Obtenir des informations sur un namespace:

```bash
kubectl get namespaces --show-labels
kubectl describe namespaces my-namespace
```

3/ Ajouter un label "owner" valorisé avec votre prenom

- mettre à jour le fichier my-namespace.yaml
- appliquer la mise à jour via une commande kubectl apply
- lister les namespaces en affichant les label

4/ Afficher les namespaces en intégrant des colonnes supplémentaire correspondant aux label env et owner

```bash
kubectl get ns --label-columns=env,owner
```


5/ Définir le namespace par defaut pour toutes les commandes kubectl:
```bash

kubectl get all

kubectl config set-context --current --namespace=my-namespace

kubectl config view

kubectl config get-contexts

kubectl get all

```

6/ Test du lancement d'un pod

```bash

# création d'un pod via une commande run
kubectl run busytemp --image=busybox  --generator=run-pod/v1 sleep 3600

# lister les pod dans le namespace courant
kubectl get pod

# lister les pod dans tous les namespace
kubectl get pod --all-namespaces 
```

7/ Supprimer un namespace :

```bash
# suppression du namespace dans la config du context pour qu'il ne soit plus le namespace par defaut
kubectl config set-context --current --namespace=

# suppression du namespace
kubectl delete namespace my-namespace
```
 
8/ Afficher les types de resources qui sont ou ne sont pas dans un NameSpace

 ```bash
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
```


9/ affecter un label à un namespace existant via la commande label
```bash
kubectl label namespace default formation=true
```

10/ lister les ns qui n'ont pas le label formation
```bash
LINUX/MAC :
kubectl get ns --selector='!formation'

Windows :
kubectl get ns --selector="!formation"

```
