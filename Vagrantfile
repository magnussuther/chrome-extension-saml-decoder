# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "janihur/ubuntu-1404-desktop"
  #config.vm.box_url = "https://vagrantcloud.com/puppetlabs/boxes/ubuntu-14.04-64-puppet/versions/1.0.1/providers/virtualbox.box"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = 3048
  end

  config.vm.provision "shell", path: "provision/dart.sh"
end
