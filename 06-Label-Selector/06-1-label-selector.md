# Labels & selector

1/ Afficher les labels générées pour chaque objets (pod, namespace, limitrange, resourcequota...) :
```bash
kubectl get all --show-labels --all-namespaces
kubectl get namespaces --show-labels

```


2/ Attribuer des labels aux objets:
```bash
kubectl label pod simplepod1 tier=frontend type=pod
kubectl get pod --show-labels

kubectl label namespace my-namespace type=namespace
kubectl get namespaces --show-labels

```


3/ Vérifier la présence des labels sur les objets (pod, namespace, limitrange, resourcequota...):
```bash
kubectl get pod --show-labels
```

3/ Effectuer une recherche avec le selector equality-base:
```bash
kubectl get pods --show-labels
kubectl get pods -l tier=frontend --show-labels
```

*equality-base permet de filtrer par clé et par valeur. Les objets correspondants doivent satisfaire à tous les labels spécifiées.

4/ Supprimer un objet par une recherche avec le selector equality-base:
```bash
kubectl describe pod simplepod1
kubectl delete pods -l tier=frontend
```

5/ Attacher une anotation à un Pod:
```bash
kubectl annotate pods simplepod3 description='my frontend'
```

6/ Recréer plusieurs Pods avec des nom, labels et anotations différentes 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simplepod1
  namespace: tst
  annotations:
    description: my frontend
  labels:
    environment: "tst"
    tier: "frontend"
```

