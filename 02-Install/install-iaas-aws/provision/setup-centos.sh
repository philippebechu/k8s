#!/bin/bash
echo "setup hostname=$(hostname) ip=$(hostname -i)"

# display command
set -x


# https://medium.com/@pkp.plus/installing-kubernetes-on-centos-7-rhel7-with-kubeadm-step-by-step-c55acac03590
# https://www.vultr.com/docs/deploy-kubernetes-with-kubeadm-on-centos-7

# Specify a the K8s major version to install (x.y or x.y.z) the latest fix version will be installed
export K8S_MAJOR_VERSION=1.16

# Docker version to install (x.y.z)
export DOKER_VERSION=18.09.9

# update
sudo yum update -y


# Disable swap to avoid  fatal errors occurred:unning with swap on is not supported. Please disable swap
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Disable firewalld
# Kubernetes uses IPTables to handle inbound and outbound traffic - so to avoid any issues we disable firewalld.
# sudo systemctl disable firewalld
# sudo systemctl stop firewalld

# install iptables
sudo yum install iptables-services.x86_64 -y
sudo systemctl start iptables
sudo systemctl enable iptables
sudo systemctl unmask iptables
sudo iptables -F
sudo service iptables save



# Docker

echo "Installing Docker on hostname=$(hostname) ip=$(hostname -i)"

# https://kubernetes.io/docs/setup/independent/install-kubeadm/ 
# ne pas changer le cgroupdriver car celui utilisé par Docker ET celui de kubectl sont deja TOUS LES DEUX cgroupfs


 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# install supported version of Docker : 18.09.9

sudo yum install -y docker-ce-$DOKER_VERSION docker-ce-cli-$DOKER_VERSION containerd.io


sudo systemctl start docker

# le groupe docker est initialise lors de l'install de docker-ce
sudo usermod -aG docker centos

# Configure Docker to start on boot
sudo systemctl enable docker

# https://kubernetes.io/docs/setup/cri/
# Setup daemon.

sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF'

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "(1/4) Installing kubeadm on hostname=$(hostname) ip=$(hostname -i)"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config




# kubeadm, kubelet and kubectl
# apt-transport-https allready installed for docker-ce
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

#sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
#deb http://apt.kubernetes.io/ kubernetes-xenial main
#EOF

sudo yum install -y bash-completion



K8S_EXACT_VERSION=$(sudo yum list kubeadm --showduplicates | sort -r | grep $K8S_MAJOR_VERSION | head -1 | awk '{print $2}')

echo $K8S_EXACT_VERSION

sudo yum install -y kubelet-$K8S_EXACT_VERSION kubeadm-$K8S_EXACT_VERSION kubectl-$K8S_EXACT_VERSION  --disableexcludes=kubernetes

# enable kubelet service to load on boot
sudo systemctl enable kubelet

# some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl
sudo bash -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system


# Make sure that the br_netfilter module is loaded before this step. 
modprobe br_netfilter

# cri-tools ebtables ethtool kubeadm kubectl kubelet kubernetes-cni socat