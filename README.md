Local Kubernetes Cluster (Vagrant + VirtualBox)
This repository contains a fully automated setup for a 3-node Kubernetes cluster (1 Master, 2 Workers) running on Ubuntu 22.04 (Jammy). It is optimized for Windows users using WSL2 as their primary terminal.

🏗 Architecture
OS: Ubuntu 22.04 LTS

Kubernetes: v1.30.0

Container Runtime: containerd (with SystemdCgroup enabled)

CNI Plugin: Flannel

Nodes:

k8s-master: 192.168.56.11 (4GB RAM, 2 CPUs)

k8s-worker1: 192.168.56.12 (2GB RAM, 2 CPUs)

k8s-worker2: 192.168.56.13 (2GB RAM, 2 CPUs)

🚀 Getting Started
Prerequisites
VirtualBox: Download here

Vagrant: Download here

WSL2: Installed on Windows with kubectl installed.

Installation
Clone the repo to a folder on your Windows drive (e.g., C:\k8s-lab).

Open a terminal (PowerShell or CMD) in that folder.

Start/Stop the cluster:
start_cluster.bat
stop_cluster.bat

Syncing with WSL
vagrant ssh k8s-master -c "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config
# Edit the config to ensure the server is https://192.168.56.11:6443
sed -i 's/127.0.0.1/192.168.56.11/g' ~/.kube/config

One Final Warning for Windows Users
If you reboot your Windows host, VirtualBox sometimes changes the order of the Host-Only network adapters. If you find that 192.168.56.11 suddenly isn't reachable after a PC restart, simply run: vagrant reload k8s-master --provision This will force the network to re-bind correctly.