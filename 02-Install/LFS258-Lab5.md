# 5 APIs and Access

## 5.1: Configuring TLS Access

### Overview

Using the Kubernetes API, kubectl makes API calls for you. With the appropriate TLS keys you could run curl as well use a golang client. Calls to the kube-apiserver get or set a PodSpec, or desired state. If the request represents a new state the Kubernetes Control Plane will update the cluster until the current state matches the specified state. Some end states may require multiple requests. For example, to delete a ReplicaSet, you would first set the number of replicas to zero, then delete the ReplicaSet.
An API request must pass information as JSON. kubectl converts .yaml to JSON then making an API request on your behalf. The API request has many settings, but must include apiVersion, kind and metadata, and spec settings to declare what kind of container to deploy. The spec fields depend on the object being created.
We will begin by configuring remote access to the kube-apiserver then explore more of the API.

### Configuring TLS Access

1. Begin by reviewing the kubectl configuration file. We will use the three certificates and the API server address.

```yaml
$ less ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RE...QYVVTQzZURFNxagpyL1NTblpDQngrRlBNcXhMbkZzdFk4d2FEUGRmT1k4U2JzcjQ3TmZLT2loZDU5R3RlUm40emtQSVNoOD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://192.169.32.20:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM4ak...pbXczWlR3d01PQwpkWHB5ZGY2STdMWkZlbkdCQkhqcURuQ1ZiUGh6ZVpoVzZLdDdvRUh1UWdxQUVDbnlLTXdxdVgraFdOYkg4ZENsCmVFWUdKV2FobDh1OFV4S0owYzlRVEZrRi9adm55WjVFTkN4YXgxcHgyczhnQm1aU0FEUT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSU...CRTlyUy9hWDRVQnVDbmpaZ0VoYXhiZCs4RzNDZ00KcHg4bjZmUXRNZTdZcytDbzRtZ01HL1BPaTJFc1JSNHpOeDhqSzhvVXVCT0FIQnBJWTVHcUFrdlNOSkNZb2lNWApNNzlyMEd3ZkJVNCs1RmpHcWVISERiNVB0bk5tOGlEOFI1UmVkSGd0Yld4ODhTZkdld009Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==

```

2. We will set the certificates as variables. You may want to double-check each parameter as you set it. Begin with setting the **client-certificate-data** key.

```
$ export client=$(grep client-cert ~/.kube/config |cut -d " " -f 6)
$ echo $client
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM4ak...pbXczWlR3d01PQwpkWHB5ZGY2STdMWkZlbkdCQkhqcURuQ1ZiUGh6ZVpoVzZLdDdvRUh1UWdxQUVDbnlLTXdxdVgraFdOYkg4ZENsCmVFWUdKV2FobDh1OFV4S0owYzlRVEZrRi9adm55WjVFTkN4YXgxcHgyczhnQm1aU0FEUT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
```

3. Almost the same command, but this time collect the **client-key-data** as the key variable.

```
$ export key=$(grep client-key-data ~/.kube/config |cut -d " " -f 6)
$ echo $key
LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSU...CRTlyUy9hWDRVQnVDbmpaZ0VoYXhiZCs4RzNDZ00KcHg4bjZmUXRNZTdZcytDbzRtZ01HL1BPaTJFc1JSNHpOeDhqSzhvVXVCT0FIQnBJWTVHcUFrdlNOSkNZb2lNWApNNzlyMEd3ZkJVNCs1RmpHcWVISERiNVB0bk5tOGlEOFI1UmVkSGd0Yld4ODhTZkdld009Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
```

4. Finally set the auth variable with the **certificate-authority-data** key.

```
$ export auth=$(grep certificate-authority-data ~/.kube/config |cut -d " " -f 6)
$ echo $auth
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RE...QYVVTQzZURFNxagpyL1NTblpDQngrRlBNcXhMbkZzdFk4d2FEUGRmT1k4U2JzcjQ3TmZLT2loZDU5R3RlUm40emtQSVNoOD0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
```

5. Now encode the keys for use with curl.

```bash
$ echo $client | base64 -d - > ./client.pem
$ echo $key | base64 -d - > ./client-key.pem
$ echo $auth | base64 -d - > ./ca.pem
```

6. Pull the API server URL from the config file.

```bash
$ kubectl config view |grep server
server: https://192.169.32.20:6443
```

7. Use curl command and the encoded keys to connect to the API server.

```bash
$ curl --cert ./client.pem \
--key ./client-key.pem \
--cacert ./ca.pem \
https://192.169.32.20:6443/api/v1/pods
```

```yaml
{
"kind": "PodList",
"apiVersion": "v1",
"metadata": {
"selfLink": "/api/v1/pods",
"resourceVersion": "239414"
},
<output_omitted>
```

8. If the previous command was successful, create a JSON file to create a new pod. Remember to look for this file in the tarball output, it can save you some typing.

```
$ vim curlpod.json
```

```json
{
  "kind": "Pod",
  "apiVersion": "v1",
  "metadata":{
  "name": "curlpod",
  "namespace": "default",
  "labels": {
    "name": "examplepod"
    }
},
  "spec": {
    "containers": [{
      "name": "nginx",
      "image": "nginx",
      "ports": [{"containerPort": 80}]
    }]
  }
}
```

9. The previous curl command can be used to build a XPOST API call. There will be a lot of output, including the scheduler and taints involved. Read through the output. In the last few lines the phase will probably show Pending, as it’s near the beginning of the creation process.

```bash
$ curl --cert ./client.pem \
--key ./client-key.pem --cacert ./ca.pem \
https://192.169.32.20:6443/api/v1/namespaces/default/pods \
-XPOST -H'Content-Type: application/json' \
-d@curlpod.json
```
```json
{
"kind": "Pod",
"apiVersion": "v1",
"metadata": {
"name": "curlpod",
<output_omitted>
```

10. Verify the new pod exists and shows a Running status.

```bash
$ kubectl get pods
NAME READY STATUS RESTARTS AGE
curlpod 1/1 Running 0 45s
```

11. The curl command doesn't work as is from a host that don't trust the ROOT CA.

```
curl --cert ./client.pem --key ./client-key.pem --cacert ./ca.pem https://192.169.32.20:6443/api/v1/pods
curl: (77) schannel: next InitializeSecurityContext failed: SEC_E_UNTRUSTED_ROOT (0x80090325) - La chaîne de certificats a été fournie par une autorité qui n'est pas approuvée.
```
Add the ca.crt to the trusted root CA on your OS. this file is located here /etc/kubernetes/pki/ca.crt 

After that there is still an error

```
curl --cert ./client.pem --key ./client-key.pem --cacert ./ca.pem https://192.169.32.20:6443/api/v1/pods
curl: (35) schannel: next InitializeSecurityContext failed: Unknown error (0x80092012) - La fonction de révocation n'a pas pu vérifier la révocation du certificat.
```

## 5.2: Explore API Calls

1. One way to view what a command does on your behalf is to use strace. In this case, we will look for the current endpoints, or targets of our API calls.

```
$ kubectl get endpoints
NAME ENDPOINTS AGE
kubernetes 192.169.32.20:6443 3h
```

2. Run this command again, preceded by strace. You will get a lot of output. Near the end you will note several openat functions to a local directory, /home/student/.kube/cache/discovery/10.128.0.3_6443. If you cannot find the lines, you may want to redirect all output to a file and grep for them.

```
$ strace kubectl get endpoints
execve("/usr/bin/kubectl", ["kubectl", "get", "endpoints"], [/*....
....
openat(AT_FDCWD, "/home/student/.kube/cache/discovery/10.128.0.3_6443..
<output_omitted>
```

3. Change to the parent directory and explore. Your endpoint IP will be different, so replace the following with one suited to your system.

```
$ cd /home/student/.kube/cache/discovery/
/.kube/cache/discovery$ ls
10.128.0.3_6443
/.kube/cache/discovery$ cd 10.128.0.3_6443/
```

4. View the contents. You will find there are directories with various configuration information for kubernetes.

```
/.kube/cache/discovery/10.128.0.3_6443$ ls
admissionregistration.k8s.io batch policy
apiextensions.k8s.io certificates.k8s.io rbac.authorization.k8s.io
apiregistration.k8s.io coordination.k8s.io scheduling.k8s.io
apps crd.projectcalico.org servergroups.json
authentication.k8s.io events.k8s.io storage.k8s.io
authorization.k8s.io extensions v1
autoscaling networking.k8s.io
```

5. Use the find command to list out the subfiles. The prompt has been modified to look better on this page.
```
student@lfs458-node-1a0a:./10.128.0.3_6443$ find .
.
./events.k8s.io
./events.k8s.io/v1beta1
./events.k8s.io/v1beta1/serverresources.json
./apps
./apps/v1
./apps/v1/serverresources.json
./apps/v1beta1
./apps/v1beta1/serverresources.json
<output_omitted>
```

6. View the objects available in version 1 of the API. For each object, or kind:, you can view the verbs or actions for that object, such as create seen in the following example. Note the prompt has been truncated for the command to fit on one line. Some are HTTP verbs, such as GET, others are product specific options, not standard HTTP verbs.

```
student@lfs458-node-1a0a:.$ python -m json.tool v1/serverresources.json
{
"apiVersion": "v1",
"groupVersion": "v1",
"kind": "APIResourceList",
"resources": [
{
"kind": "Binding",
"name": "bindings",
"namespaced": true,
"singularName": "",
"verbs": [
"create"
]
},
<output_omitted>
```

7. Some of the objects have shortNames, which makes using them on the command line much easier. Locate the
shortName for endpoints.

```
student@lfs458-node-1a0a:.$ python -m json.tool v1/serverresources.json | less
.
{
"kind": "Endpoints",
"name": "endpoints",
"namespaced": true,
"shortNames": [
"ep"
],
"singularName": "",
"verbs": [
"create",
"delete",
.
```

8. Use the shortName to view the endpoints. It should match the output from the previous command.

```
student@lfs458-node-1a0a:.$ kubectl get ep
NAME ENDPOINTS AGE
kubernetes 192.169.32.20:6443 3h
```

9. We can see there are 37 objects in version 1 file.

```
student@lfs458-node-1a0a:.$ python -m json.tool v1/serverresources.json | grep kind
"kind": "APIResourceList",
"kind": "Binding",
"kind": "ComponentStatus",
"kind": "ConfigMap",
"kind": "Endpoints",
"kind": "Event",
<output_omitted>
```

10. Looking at another file we find nine more.

```
student@lfs458-node-1a0a:$ python -m json.tool \
apps/v1beta1/serverresources.json | grep kind
"kind": "APIResourceList",
"kind": "ControllerRevision",
"kind": "Deployment",
<output_omitted>
```

11. Delete the curlpod to recoup system resources.

```student@lfs458-node-1a0a:$ kubectl delete po curlpod
pod "curlpod" deleted
```

12. Take a look around the other files in this directory as time permits.