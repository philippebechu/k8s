# Volumes and Data

## install NFS Server


### on master

We will first deploy an NFS server. Once tested we will create a persistent NFS volume for containers to claim.

1. Install the software on your master node.

```
sudo apt-get install -y nfs-kernel-server
```

2. Make and populate a directory to be shared. Also give it similar permissions to /tmp/

```sh
sudo mkdir /opt/nfs-k8s-pv
sudo chmod 777 /opt/nfs-k8s-pv/

# create an index.html file
cat << EOF > /opt/nfs-k8s-pv/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx NFS custom page!!</title>
</head>
<body>
<h1>Welcome to nginx NFS custom page!!!!!!!!!!!</h1>
</body>
</html>
EOF
```

3. Edit the NFS server file to share out the newly created directory. In this case we will share the directory with all. You can always snoop to see the inbound request in a later step and update the file to be more narrow.

```
$ sudo vim /etc/exports

# ajouter la ligne suivante à la fin du fichier /etc/exports
/opt/nfs-k8s-pv/ *(rw,sync,no_root_squash,subtree_check)
```

4. Cause /etc/exports to be re-read:

```
$ sudo exportfs -ra
```
### on worker nodes
5. Test by mounting the resource from your second node.

```sh
sudo apt-get -y install nfs-common


# check the NFS share on  NFS_SRV_HOSTNAME
# with vagrant : the hostname of the NFS Server is "master"
vagrant@node1:~$ showmount -e <NFS_SRV_HOSTNAME>
Export list for master:
/opt/nfs-k8s-pv *

```

## Creating a Persistent NFS Volume (PV)

6. Return to the master node and create a YAML file for the object with kind PersistentVolume. Use the hostname of the master server and the directory you created in the previous step. Only syntax is checked, an incorrect name or directory will not generate an error, but a Pod using the resource will not start. Note that the accessModes do not currently affect actual access and are typically used as labels instead.

```yaml
$ vim pv-1.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/nfs-k8s-pv
    server: 192.169.32.20   #<-- Edit to match master node  (private IP for AWS)
    readOnly: false
```

7. Create the persistent volume, then verify its creation.

```
$ kubectl apply -f pv-1.yaml
persistentvolume/pv-1 created
$ kubectl get pv
NAME CAPACITY ACCESSMODES RECLAIMPOLICY STATUS
CLAIM STORAGECLASS REASON AGE
pv-1 1Gi RWX Retain Available 4s
```

## Creating a Persistent Volume Claim (PVC)
Before Pods can take advantage of the new PV we need to create a Persistent Volume Claim (PVC).

1. Begin by determining if any currently exist.

```
$ kubectl get pvc
No resources found.
```

2. Create a YAML file for the new pvc.

```yaml
$ vim pvc-1.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-1
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 200Mi
```

3. Create and verify the new pvc is bound. Note that the size is 1Gi, even though 200Mi was suggested. Only a volume of at least that size could be used.

```
$ kubectl apply -f pvc-1.yaml
persistentvolumeclaim/pvc-1 created
$ kubectl get pvc
NAME STATUS VOLUME CAPACITY ACCESSMODES STORAGECLASS AGE
pvc-1 Bound pv-1 1Gi RWX 4s
```

4. Look at the status of the pv again, to determine if it is in use. It should show a status of Bound.

```
$ kubectl get pv
NAME CAPACITY ACCESSMODES RECLAIMPOLICY STATUS CLAIM STORAGECLASS REASON AGE
pv-1 1Gi RWX Retain Bound default/pvc-1 5m
```

5. Create a new deployment to use the pvc. We will copy and edit an existing deployment yaml file. We will change the deployment name then add a volumeMounts section under containers and volumes section to the general spec. The name used must match in both places, whatever name you use. The claimName must match an existing pvc. As shown in the following example.

```yaml
$ vim nginx-deployment-with-volume.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-nfs
spec:
  replicas: 2
  selector:
    matchLabels:
      run: nginx
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        volumeMounts:
        - name: nfs-vol
          mountPath: /usr/share/nginx/html # HTML NGINX DIR
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      volumes:                           #<<-- These four lines
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: pvc-1
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30

```

6. Create the pod using the newly edited file.

```
$ kubectl create -f nginx-deployment-with-volume.yaml
deployment.apps/nginx-nfs created
```

7. Look at the details of the pod.

```yaml
$ kubectl get pods
NAME READY STATUS RESTARTS AGE
nginx-nfs-1054709768-s8g28 1/1 Running 0 3m
$ kubectl describe pod nginx-nfs-1054709768-s8g28
Name:               nginx-nfs-6b865c5796-46jdb
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               node1/192.169.32.21
<output_omitted>
Mounts:
/usr/share/nginx/html from nfs-vol (rw)
<output_omitted>
Volumes:
  nfs-vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pvc-1
    ReadOnly:   false
<output_omitted>
```

8. View the status of the PVC. It should show as bound.

```
$ kubectl get pvc
NAME      STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-1   Bound    pv-1   1Gi        RWX                           36m
```

9. check the nginx default page (depuis le MASTER car pas de service nodeport ni ingress)

```sh
# check the IP of the pods
kubectl get pod -o wide

# curl
curl <POD_IP>
curl <POD_2_IP>

```

10. update file

Se connecter au master et modifier le contenu du fichier HTML partagé et retester les pages

```sh
vi /opt/nfs-k8s-pv/index.html
```
