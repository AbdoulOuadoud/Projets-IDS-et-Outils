#!/bin/bash

# Function to check if a package is installed
function package_installed {
  dpkg-query -W --showformat='${Status}\n' $1 | grep "install ok installed" &> /dev/null
}

# Install and configure libglib
if ! package_installed libglib; then
    echo "libglib n'est pas installé. Installation en cours..."
    sudo apt-get update
    sudo apt-get install libglib2.0-dev -y
    sudo apt-get install libpcap0.8-dev -y
fi
  sudo apt-get install -y make
  sudo apt-get install systemd libsystemd-journal0 --allow-unauthenticated

# Vérifier si le paquet est déjà installé
if [[ $(dpkg-query -W -f='${Status}' libfixbuf3 2>/dev/null | grep -c "ok installed") -eq 1 ]]; then
    echo "libfixbuf3 est déjà installé"
else

# Télécharger les sources de libfixbuf
sudo apt-get update
sudo apt-get -y install build-essential libtool
wget https://tools.netsa.cert.org/releases/libfixbuf-2.4.0.tar.gz

# Extraire l'archive et installer le paquet
tar -xvf libfixbuf-2.4.0.tar.gz
cd libfixbuf-2.4.0/
./configure
make
sudo make install

# Vérifier si l'installation a réussi
if dpkg -s libfixbuf3 | grep 'Status: install' >/dev/null; then
    echo "libfixbuf3 a été installé avec succès"
else
    echo "L'installation de libfixbuf3 a échoué"
fi
fi

# Vérifier si le paquet est déjà installé
if dpkg -s libmaxminddb-dev >/dev/null 2>&1; then
    echo "Le paquet libmaxminddb-dev est déjà installé."
else
    # Télécharger le fichier d'installation depuis le site Web de MaxMind
    wget https://github.com/maxmind/libmaxminddb/releases/download/1.5.2/libmaxminddb-1.5.2.tar.gz

    # Extraire le fichier d'installation
    tar -xzf libmaxminddb-1.5.2.tar.gz

    # Se déplacer dans le répertoire d'installation
    cd libmaxminddb-1.5.2

    # Configurer l'installation
    ./configure

    # Compiler et installer le paquet
    make && sudo make install

    # Vérifier si l'installation a réussi
    if [[ $? -eq 0 ]]; then
        echo "Le paquet libmaxminddb-dev a été installé avec succès."
    else
        echo "Une erreur s'est produite lors de l'installation du paquet libmaxminddb-dev."
    fi
fi


# Install and configure yaf
if ! package_installed libtool || ! package_installed libpcap-dev || ! package_installed libssl-dev || ! package_installed flex || ! package_installed bison || ! package_installed librdkafka-dev; then
  sudo apt update
  sudo apt install libtool libpcap-dev libssl-dev flex bison librdkafka-dev -y
fi

if ! command -v yaf > /dev/null; then
  sudo apt-get install libtool libpcap-dev libssl-dev libtool-bin flex bison -y
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
sudo mkdir /etc/iptables
sudo touch /etc/iptables/rules.v4
sudo iptables-save > /etc/iptables/rules.v4 # save the rules

# Vérifier si le paquet snort est installé
if ! dpkg -s snort >/dev/null 2>&1; then
  # Installer le paquet snort
  sudo apt-get update
  sudo apt-get install snort -y
fi

# Vérifier si le fichier de configuration de snort existe
if [ ! -f "/etc/snort/snort.conf" ]; then

  # Installer les packages manquants
apt-get install -y libhttp-daemon-perl liblwp-protocol-https-perl libnl-3-200 libnl-genl-3-200 libc-ares2 liblz4-1 libwsutil9 libwiretap8 libwireshark-data libwscodecs2 libwireshark11 wireshark-common tshark

# Télécharger les règles de la communauté Snort
wget https://www.snort.org/downloads/community/community-rules.tar.gz -O /tmp/community-rules.tar.gz

# Extraire les règles de la communauté Snort
tar -xvf /tmp/community-rules.tar.gz -C /etc/snort/


  # Modifier le fichier de configuration pour inclure les règles de la communauté
  sudo sed -i 's|# include \$RULE\_PATH/community.rules|include \$RULE\_PATH/community.rules|g' /etc/snort/snort.conf

# Redémarrer le service Snort
systemctl restart snort

# Vérifier si Tshark est installé
if ! command -v tshark &> /dev/null
then
    # Si Tshark n'est pas installé, l'installer
    apt-get install -y tshark
fi

  # # Télécharger le fichier de configuration par défaut
  # sudo wget https://www.snort.org/downloads/community/community-rules.tar.gz -O /tmp/community-rules.tar.gz
  # sudo tar -xvf /tmp/community-rules.tar.gz -C /etc/snort/ --strip-components=1

  # Modifier le fichier de configuration pour inclure les règles de la communauté
  sudo sed -i 's|# include \$RULE\_PATH/community.rules|include \$RULE\_PATH/community.rules|g' /etc/snort/snort.conf
fi

# Vérifie si le fichier de service snort existe
if [ ! -f /etc/systemd/system/snort.service ]; then
    echo "Le fichier de service snort n'existe pas."
    echo "Création du fichier de service snort..."

    # Crée le fichier de service snort avec les informations de configuration
    cat <<EOT > /etc/systemd/system/snort.service
[Unit]
Description=Snort NIDS Daemon
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/usr/sbin/snort -i eth0 -c /etc/snort/snort.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOT

    # Recharge les fichiers de configuration du système
    systemctl daemon-reload

    # Démarre le service snort
    systemctl start snort.service

    echo "Le service snort a été créé et démarré avec succès."
else
    # Vérifie si le service snort est en cours d'exécution
    if systemctl is-active --quiet snort.service; then
        echo "Le service snort est déjà en cours d'exécution."
    else
        # Démarre le service snort
        systemctl start snort.service

        echo "Le service snort a été redémarré avec succès."
    fi
fi

# Vérifier l'état du service snort
sudo systemctl status snort

# Install tcpdump and tshark
if ! package_installed tcpdump; then
  sudo apt-get install tcpdump -y
fi
if ! package_installed tshark; then
  sudo apt-get install tshark -y
fi

if [ -f /etc/yaf/yaf.conf ]; then
  sudo sed -i 's/output file:/output file: \/var\/log\/yaf\/flow\.bin\.%Y%m%d%H%M\.gz/' /etc/yaf/yaf.conf # configure file output path
  sudo sed -i 's/rotate_timeout: 86400/rotate_timeout: 3600/' /etc/yaf/yaf.conf #
  sudo systemctl restart yaf # restart yaf service
fi

echo "Done!"