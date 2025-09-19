Vagrant.configure("2") do |config|
  # Common VM box
  config.vm.box = "ubuntu/jammy64"

  # Disable GUI globally unless really needed
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  # Master node
  config.vm.define "k8s-master" do |node|
    node.vm.hostname = "k8s-master"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4072  # More RAM for control-plane stability
      vb.cpus = 4
    end
    node.vm.provision "shell", path: "bootstrap.sh"
  end

  # Worker 1
  config.vm.define "k8s-worker1" do |node|
    node.vm.hostname = "k8s-worker1"
    node.vm.network "private_network", ip: "192.168.56.12"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 3
    end
    node.vm.provision "shell", path: "bootstrap.sh"
  end

  # Worker 2
  config.vm.define "k8s-worker2" do |node|
    node.vm.hostname = "k8s-worker2"
    node.vm.network "private_network", ip: "192.168.56.13"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 3
    end
    node.vm.provision "shell", path: "scripts/bootstrap.sh", run: "once"
  end
end
