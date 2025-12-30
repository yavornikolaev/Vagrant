Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Global VirtualBox Settings
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true  # Kept as requested
    vb.linked_clone = true
    # This helps with clock sync issues common on Windows hosts
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]
  end

  # Master node
  config.vm.define "k8s-master" do |node|
    node.vm.hostname = "k8s-master"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 2 # Your CPU has 12 cores, so 2 is very safe
    end
    node.vm.provision "shell", path: "bootstrap.sh"
  end

  # Workers - Loop to keep code clean
  (1..2).each do |i|
    config.vm.define "k8s-worker#{i}" do |node|
      node.vm.hostname = "k8s-worker#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{11 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
      node.vm.provision "shell", path: "bootstrap.sh"
    end
  end
end