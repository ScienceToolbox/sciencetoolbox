# -*- mode: ruby -*-
# vi: set ft=ruby :
require "dotenv"

ENV["ENV"] = "development"

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false
  config.vm.box = "ubuntu/utopic64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.synced_folder ".", "/var/www/sciencetoolbox/current", type: "nfs"

  config.vm.network "private_network", ip: "10.4.4.4"
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/vagrant.yml"
    ansible.host_key_checking = false
    ansible.extra_vars = {
      ansible_ssh_user: "vagrant",
      vagrant: "true"
    }

    ansible.groups = {
      "databaseservers" => ["default"],
      "webservers" => ["default"]
    }
  end
end
