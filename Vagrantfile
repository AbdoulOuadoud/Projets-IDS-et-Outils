# Defensive VM
Vagrant.configure("2") do |config|
  config.vm.define "defensive" do |defensive|
    defensive.vm.box = "ubuntu/trusty64"
    defensive.vm.hostname = "defensive"
    defensive.vm.network "private_network", ip: "192.168.33.10"
    defensive.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    defensive.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get -y install build-essential
      apt-get -y install bash zsh
      apt-get -y install dnsutils telnet apache2
    SHELL
  end 

  # Offensive VM
  config.vm.define "offensive" do |offensive|
    offensive.vm.box = "ubuntu/trusty64"
    offensive.vm.hostname = "offensive"
    offensive.vm.network "private_network", ip: "192.168.33.20"
    offensive.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    offensive.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get -y install build-essential
      apt-get -y install bash zsh
      apt-get -y install metasploit hping3 nmap hydra
    SHELL
  end
end
