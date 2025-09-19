#!/bin/bash
set -e

MASTER_IP="192.168.56.11"
POD_NETWORK_CIDR="10.244.0.0/16"
K8S_VERSION="1.30.0"

# Detect role
if [[ "$(hostname)" == "k8s-master" ]]; then
  ROLE="master"
else
  ROLE="worker"
fi

echo "[TASK 1] Update system and install dependencies"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https curl gpg

echo "[TASK 2] Disable swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[TASK 3] Kernel modules and sysctl"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo "[TASK 4] Install containerd"
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Enable systemd cgroups + fix pause image version
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's,sandbox_image = .*,sandbox_image = "registry.k8s.io/pause:3.9",' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "[TASK 5] Install Kubernetes components"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

if [[ "$ROLE" == "master" ]]; then
  echo "[TASK 6] Initialize Kubernetes master"
  sudo kubeadm init --apiserver-advertise-address=${MASTER_IP} \
    --pod-network-cidr=${POD_NETWORK_CIDR} \
    --kubernetes-version=v${K8S_VERSION} | tee /vagrant/kubeadm-init.out

  echo "[TASK 7] Configure kubeconfig for vagrant user"
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  echo "[TASK 8] Deploy Flannel CNI"
  kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

  echo "[TASK 9] Generate join command for workers"
  kubeadm token create --print-join-command | tee /vagrant/join.sh

else
  echo "[TASK 6] Wait for join command"
  while [ ! -f /vagrant/join.sh ]; do
    echo "Waiting for master to generate join command..."
    sleep 10
  done
  echo "[TASK 7] Join worker to cluster"
  sudo bash /vagrant/join.sh
fi
