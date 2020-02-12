# Helm

## Working with Helm and Charts

### Overview

helm allows easy deployment of complex configurations. This could be handy for a vendor to deploy a multi-part application in a single step. Through the use of a Chart, or template file, the required components and their relationships are declared.

Local agents like Tiller use the API to create objects on your behalf. Effectively its orchestration for orchestration.

There are a few ways to install Helm. The newest version may require building from source code. We will download a recent, stable version. Once installed we will deploy a Chart, which will configure Hadoop on our cluster.

## Install Helm

1. On the master node use wget to download the compressed tar file.  https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz

```sh
$ wget https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz
<output_omitted>
2019-05-13 08:17:46 (26.0 MB/s) - ‘helm-v3.0.3-linux-amd64.tar.gz’ saved [22949819/22949819]
```

2. Uncompress and expand the file.

```sh
$ tar -xvf helm-v3.0.3-linux-amd64.tar.gz
linux-amd64/
linux-amd64/README.md
linux-amd64/helm
linux-amd64/LICENSE
```

3. Copy the helm binary to the ```/usr/local/bin/``` directory, so it is usable via the shell search path.

```sh
$ sudo cp linux-amd64/helm /usr/local/bin/
sudo mv linux-amd64/helm /usr/local/bin/helm
```

helm repo add stable https://kubernetes-charts.storage.googleapis.com/

helm search repo stable

helm repo update

helm ls



9. View the available sub-commands for helm. As with other Kubernetes tools, expect ongoing change.

```
$ helm help
<output_omitted>
```

10. View the current configuration files, archives and plugins for helm. Return to this directory after you have worked with a Chart later in the lab.

```sh
$ helm home
/home/vagrant/.helm

$ ls -R /home/vagrant/.helm
/home/vagrant/.helm:
cache  plugins  repository  starters

/home/vagrant/.helm/cache:
archive

/home/vagrant/.helm/cache/archive:

/home/vagrant/.helm/plugins:

/home/vagrant/.helm/repository:
cache  local  repositories.yaml

/home/vagrant/.helm/repository/cache:
local-index.yaml  stable-index.yaml

/home/vagrant/.helm/repository/local:
index.yaml

/home/vagrant/.helm/starters:
```

11. Verify helm and tiller are responding, also check the current version installed.

```
helm version
Client: &version.Version{SemVer:"v3.0.3", GitCommit:"618447cbf...", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v3.0.3", GitCommit:"618447cbf...", GitTreeState:"clean"}
```

12. Ensure both are upgraded to the most recent stable version.

```
$ helm init --upgrade
$HELM_HOME has been configured at /home/vagrant/.helm.

Tiller (the Helm server-side component) has been upgraded to the current version.
Happy Helming!
```

13. A Chart is a collection of containers to deploy an application. There is a collection available on https://github.com/kubernetes/charts/tree/master/stable, provided by vendors, or you can make your own. Take a moment and view the current stable Charts. Then search for available stable databases. ``` helm search [keyword] [flags]```

```
$ helm search

```



## install WordPress



1. Dry run debug pour troubleshooting et identification des clés de configuration à adapter

```
helm install --name my-wordpress --set "persistence.enabled=false,mariadb.master.persistence.enabled=false,service.type=NodePort" --dry-run stable/wordpress --debug
```

1. install

```sh
helm install --name my-wordpress --set "persistence.enabled=false,mariadb.master.persistence.enabled=false,service.type=NodePort" stable/wordpress
```

output
```sh
NAME:   my-wordpress
LAST DEPLOYED: Wed Jun  5 13:12:09 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                        DATA  AGE
my-wordpress-mariadb        1     1s
my-wordpress-mariadb-tests  1     1s

==> v1/Deployment
NAME                    READY  UP-TO-DATE  AVAILABLE  AGE
my-wordpress-wordpress  0/1    1           0          0s

==> v1/Pod(related)
NAME                                     READY  STATUS             RESTARTS  AGE
my-wordpress-mariadb-0                   0/1    ContainerCreating  0         0s
my-wordpress-wordpress-5fcc75b6d9-n44gz  0/1    ContainerCreating  0         0s

==> v1/Secret
NAME                    TYPE    DATA  AGE
my-wordpress-mariadb    Opaque  2     1s
my-wordpress-wordpress  Opaque  1     1s

==> v1/Service
NAME                    TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)                     AGE
my-wordpress-mariadb    ClusterIP  10.111.150.92  <none>       3306/TCP                    1s
my-wordpress-wordpress  NodePort   10.111.11.21   <none>       80:30451/TCP,443:32347/TCP  0s

==> v1beta1/StatefulSet
NAME                  READY  AGE
my-wordpress-mariadb  0/1    0s


NOTES:
1. Get the WordPress URL:

  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-wordpress-wordpress)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
  echo "WordPress Admin URL: http://$NODE_IP:$NODE_PORT/admin"

2. Login with the following credentials to see your blog

  echo Username: user
  echo Password: $(kubectl get secret --namespace default my-wordpress-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
 ``` 

3. purge

```
helm del --purge my-wordpress
```
