#!/bin/bash

# Function to check if a package is installed
function package_installed {
  dpkg-query -W --showformat='${Status}\n' $1 | grep "install ok installed" &> /dev/null
}

# Install and configure libglib
if ! package_installed libglib; then
    echo "libglib n'est pas installé. Installation en cours..."
    sudo apt-get update
    sudo apt-get install libglib2.0-dev
    sudo apt-get install libfixbuf-dev
    sudo apt-get install libpcap0.8-dev
fi

# Install and configure yaf
if ! package_installed libtool || ! package_installed libpcap-dev || ! package_installed libssl-dev || ! package_installed flex || ! package_installed bison || ! package_installed libmaxminddb-dev || ! package_installed librdkafka-dev; then
  sudo apt update
  sudo apt install libtool libpcap-dev libssl-dev flex bison libmaxminddb-dev librdkafka-dev -y
fi

if ! command -v yaf > /dev/null; then
  sudo apt-get install libtool libpcap-dev libssl-dev libtool-bin flex bison -y
  sudo apt-get install -y make
  # Télécharger la dernière version de YAF
  wget https://tools.netsa.cert.org/releases/yaf-2.13.0.tar.gz
  # Extraire les fichiers de l'archive
  tar xvzf yaf-2.13.0.tar.gz
  # Accéder au répertoire créé après l'extraction
  cd yaf-2.13.0
  # Compiler et installer YAF
  ./configure
  make
  sudo make install
  cd ..
fi

# Install and configure iptables
if ! package_installed iptables; then
    sudo apt-get install iptables -y
fi
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT # allow SSH traffic
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT # allow HTTP and HTTPS traffic
sudo iptables -A INPUT -j DROP # drop all other incoming traffic
sudo iptables-save > /etc/iptables/rules.v4 # save the rules

# Install and configure snort
if ! package_installed snort; then
    sudo apt-get install snort -y
fi
sudo sed -i 's/# output unified2: filename snort\.u2/output unified2: filename snort\.u2/' /etc/snort/snort.conf # enable unified2 output
sudo systemctl restart snort # restart snort service

# Install tcpdump and tshark
if ! package_installed tcpdump; then
  sudo apt-get install tcpdump -y
fi
if ! package_installed tshark; then
  sudo apt-get install tshark -y
fi



if [ -f /etc/yaf/yaf.conf ]; then
  sudo sed -i 's/output file:/output file: \/var\/log\/yaf\/flow\.bin\.%Y%m%d%H%M\.gz/' /etc/yaf/yaf.conf # configure file output path
  sudo sed -i 's/rotate_timeout: 86400/rotate_timeout: 3600/' /etc/yaf/yaf.conf # configure rotation timeout
  sudo systemctl restart yaf # restart yaf service
fi

echo "Done!"
