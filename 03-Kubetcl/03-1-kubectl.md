# Kubectl

## Configurer Kubectl:

Il existe différentes manières de configurer kubectl, parmis lesquelles :

- placer un fichier nommé **config** dans un sous répertoire **.kube** dans votre répertoire home
- définir une variable d'environnement nommé **KUBECONFIG** pointant vers un fichier de configuration Kubectl présent dans n'importe quel répertoire

1/ Vérifier la configuration :
```bash
kubectl config view
kubectl config get-contexts
```


## Vérification l'état du cluster

1/ Affiche les informations du cluster. Vérifier que kubectl est correctement configuré et a accès au cluster.

```bash
 kubectl cluster-info 
 ```
Dans le cas contraire, vérifiez que celui-ci est correctement configuré:
Affiche les informations pertinentes concernant le cluster pour le débogage et le diagnostic.

```bash
 kubectl cluster-info dump
 kubectl cluster-info dump --output-directory=/path/to/cluster-state
```

2/ Vérifiez le status de chaque composant:

```bash
kubectl get componentstatuses
kubectl get cs
kubectl get all --all-namespaces
kubectl get pods --all-namespaces
```

3/ Obtenez des informations sur les nodes du cluster:

```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe nodes
```

## commandes complémentaires

1/ Afficher les versions d'API prises en charge sur le cluster.

```bash
kubectl api-versions
```

2/ Afficher les resources prises en charge

```bash
kubectl api-resources
```