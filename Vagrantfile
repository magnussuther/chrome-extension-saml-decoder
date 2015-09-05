# -*- mode: ruby -*-
# vi: set ft=ruby :


def install_puppet(conf)
	conf.vm.provision "shell", inline: "cd /tmp && sudo wget --progress=bar:force https://apt.puppetlabs.com/puppetlabs-release-trusty.deb"
	conf.vm.provision "shell", inline: "cd /tmp && sudo dpkg -i puppetlabs-release-trusty.deb"
	conf.vm.provision "shell", inline: "sudo apt-get update"
	conf.vm.provision "shell", inline: "sudo apt-get install puppet-common=3.8.1-1puppetlabs1 puppet=3.8.1-1puppetlabs1 -y --force-yes"
	conf.vm.provision "shell", inline: "sudo puppet agent --enable"
end

Vagrant.configure(2) do |config|
	config.vm.box = "ubuntu/trusty64"

	config.vm.provider "virtualbox" do |vb|
		vb.gui = true
		vb.memory = 3048
	end

	config.vm.hostname = "saml-decoder.vagrantbox.local"

	config.vm.provision "shell", privileged: false, inline: 'echo "I will now setup and configure this machine for you. This will take some time, be patient... (don\'t bother logging in to that tty1 prompt, you\'ll have a proper GUI soon.)"'
	
	install_puppet config

	config.vm.provision "shell", inline: "apt-get install ruby1.9.1-dev -y"
	config.vm.provision "shell", inline: "gem install librarian-puppet"
	config.vm.provision "shell", inline: "cd /vagrant/puppet && librarian-puppet install --verbose"
	
	config.vm.provision "puppet" do |puppet|
		puppet.manifests_path = "puppet/manifests"
		puppet.module_path = "puppet/modules"
		puppet.options = "--verbose --debug"
	end
	
	config.vm.provision "shell", privileged: false, inline: 'echo "... Done configuring. You can now login and use the machine"'
end
