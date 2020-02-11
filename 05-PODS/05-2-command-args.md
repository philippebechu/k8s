# Commande (Entrypoint) et arguments (Cmd)

1/ Définir une commande (Entrypoint) et des arguments (Cmd) pour un conteneur:
La commande et les arguments définis ne peuvent pas être modifiés après la création du Pod.

10-container-demo-echo-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-demo-echo-pod
spec:
  containers:
  - name: container-demo-container
    image: dmaumenee/container-demo:1.0
    env:
    - name: MESSAGE
      value: "Hello World"
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(MESSAGE) at $(date); sleep 10;done"]
```

11-container-demo-env-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-demo-env-pod
spec:
  containers:
  - name: env-container
    image: dmaumenee/container-demo:1.0
    command: ["printenv"]
  restartPolicy: OnFailure
```

12-container-demo-wget-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: container-demo-wget-pod
spec:
  containers:
  - name: wget-container
    image: dmaumenee/container-demo:1.0
    env:
    - name: URL
      value: "http://localhost:8080/ping"
    command: ["/bin/sh"]
    args: ["-c", "while true; do wget -qO- $(URL) ; sleep 10;done"]
```