# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "bento/ubuntu-16.04"
  vmcpu=(ENV['VPP_VAGRANT_VMCPU'] || 2)
  vmram=(ENV['VPP_VAGRANT_VMRAM'] || 4096)
  vppnodes=(ENV['VPP_NODES'] || 2)
  vppversion=(ENV['VPP_VERSION'] || ".stable.1609")

	(1..vppnodes).each do |i|
    config.vm.define "vppnode#{i}" do |node|
      # Define some physical ports for your VMs to be used by DPDK
      nics = (ENV['VPP_VAGRANT_NICS'] || "2").to_i(10)
      for i in 1..nics
        node.vm.network "private_network", type: "dhcp"
      end
      node.vm.hostname = "vppnode#{i}"
  		node.vm.provision :shell, :path => File.join(File.dirname(__FILE__),"install.sh"), :args => "#{vppversion}"
  		node.vm.provision :shell, :path => File.join(File.dirname(__FILE__),"setupinterfaces.sh")
      node.vm.provider :virtualbox do |vb|
      	vb.customize ["modifyvm", :id, "--ioapic", "on"]
      	vb.memory = "#{vmram}"
      	vb.cpus = "#{vmcpu}"
        vb.linked_clone = true
      end
    end
	end
end
