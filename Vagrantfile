# Defensive VM
Vagrant.configure("2") do |config|
  config.vm.box_download_insecure = true
  config.vm.define "defensive" do |defensive|
    defensive.vm.box = "ubuntu/trusty64"
    defensive.vm.hostname = "defensive"
    defensive.vm.network "private_network", ip: "192.168.33.10"
    defensive.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
   vb.cpus = 2
   #config.ssh.private_key_path = ".vagrant/machines/defensive/virtualbox/private_key"
    end
    defensive.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install dos2unix -y
      sudo apt-get install systemd -y
      sudo apt-get -y install build-essential
      sudo apt-get -y install bash zsh
      sudo apt-get -y install dnsutils telnet apache2
      sudo apt-get install -y telnetd

      # Configure DNS server
      sudo sed -i 's/#DNS=/DNS=192.168.33.10/' /etc/systemd/resolved.conf
      sudo service systemd-resolved restart

      # Configure Telnet server
      sudo sed -i 's/telnet\s*=\s*\/usr\/sbin\/telnetd/telnet stream tcp nowait telnetd \/usr\/sbin\/tcpd \/usr\/sbin\/telnetd -b 0.0.0.0 -i -F/g' /etc/inetd.conf
      sudo service openbsd-inetd restart

      # Configure Apache web server
      sudo mkdir /var/www/html/defensive
      sudo echo "This is the defensive web server" > /var/www/html/defensive/index.html
      sudo service apache2 restart
    SHELL
  end 

  # Offensive VM
  config.vm.box_download_insecure = true
  config.vm.define "offensive" do |offensive|
  offensive.vm.box = "ubuntu/trusty64"
  offensive.vm.hostname = "offensive"
  offensive.vm.network "private_network", ip: "192.168.33.20"
  offensive.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
     vb.cpus = 2
     #config.ssh.private_key_path = ".vagrant/machines/offensive/virtualbox/private_key"
   end
    offensive.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install dos2unix -y
      sudo apt-get install nmap -y
      sudo apt-get install bash -y
      sudo apt-get install zsh -y
      sudo apt-get install hydra -y
      sudo apt-get install hping3 -y
      sudo apt-get install telnet -y
      sudo apt-get install systemd -y
      sudo sh -c 'echo "deb http://apt.metasploit.com/ trusty main" > /etc/apt/sources.list.d/metasploit-framework.list'
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CDFB5FA52007B954
      sudo apt-get update
      sudo apt-get install metasploit-framework -y
    SHELL
  end
end