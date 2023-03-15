#!/bin/bash

# Install and configure iptables
sudo apt-get install iptables -y
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT # allow SSH traffic
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT # allow HTTP and HTTPS traffic
sudo iptables -A INPUT -j DROP # drop all other incoming traffic
sudo iptables-save > /etc/iptables/rules.v4 # save the rules

# Install and configure snort
sudo apt-get install snort -y
sudo sed -i 's/# output unified2: filename snort\.u2/output unified2: filename snort\.u2/' /etc/snort/snort.conf # enable unified2 output
sudo systemctl restart snort # restart snort service

# Install tcpdump and tshark
sudo apt-get install tcpdump tshark -y

# Définir la version de YAF à télécharger
YAF_VERSION="2.11.0"

# Installer les dépendances nécessaires
sudo apt-get update
sudo apt-get install -y libpcap-dev libtool autoconf automake libyaml-dev libpcre3-dev libglib2.0-dev libssl-dev

# Télécharger YAF
wget "https://tools.netsa.cert.org/releases/yaf/yaf-${YAF_VERSION}.tar.gz"

# Extraire les fichiers de l'archive
tar xvzf "yaf-${YAF_VERSION}.tar.gz"

# Accéder au répertoire créé après l'extraction
cd "yaf-${YAF_VERSION}"

# Compiler et installer YAF
./configure
make
sudo make install


# Compress measurement files
sudo sed -i 's/output file:/output file: \/var\/log\/yaf\/flow\.bin\.%Y%m%d%H%M\.gz/' /etc/yaf/yaf.conf # configure file output path
sudo sed -i 's/rotate_timeout: 86400/rotate_timeout: 3600/' /etc/yaf/yaf.conf # configure rotation timeout
sudo systemctl restart yaf # restart yaf service

echo "Done!"