# POD multi containers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-demo-pod
spec:
  containers:
  - name: container-demo-container
    image: dmaumenee/container-demo:1.0
    env:
      - name: TITLE
        value: "Formation Kubernetes"
      - name: SHOW_VERSION
        value: "true"
      - name: METADATA
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace    
    ports:
      - containerPort: 8080
        hostPort: 30080  
  - name: wget-container
    image: alpine
    env:
    - name: URL
      value: "http://localhost:8080/ping"
    command: ["/bin/sh"]
    args: ["-c", "while true; do wget -qO- $(URL) ; sleep 10;done"]
```

```sh

# création du pod à partir du fichier présent 
kubectl apply -f 20-container-demo-pod-multi-container.yaml

# afficher les pods le pod multi container doit afficher 2/2 dans la colonne READY

# affichier les logs du container
kubectl logs container-demo-pod
Error from server (BadRequest): a container name must be specified for pod container-demo-pod, choose one of: [container-demo-container wget-container]


# affichage des logs du container wget-container qui réaliser des wget sur localhost:8080 et affiche le resultat retourné par le container container-demo-container
kubectl logs -c wget-container container-demo-pod

# delete de l'ancien pod
kubectl delete -f 20-container-demo-pod-multi-container.yaml

# création du pod à partir du fichier 05-PODS/container-demo/21-container-demo-pod-multi-container-KO.yaml
kubectl apply -f 21-container-demo-pod-multi-container-KO.yaml

# delete de l'ancien pod
kubectl delete -f 21-container-demo-pod-multi-container-KO.yaml

# création du pod à partir du fichier 05-PODS/container-demo/22-container-demo-pod-multi-container.yaml
kubectl apply -f 22-container-demo-pod-multi-container.yaml

```

