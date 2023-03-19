#!/bin/bash

# Configuration des règles de pare-feu
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Autoriser les connexions établies
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Autoriser le trafic ICMP (ping)
sudo iptables -A INPUT -p icmp -j ACCEPT

# Autoriser le trafic SSH sur le port 22
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Autoriser le trafic Telnet sur le port 23
sudo iptables -A INPUT -p tcp --dport 23 -j ACCEPT

# Autoriser le trafic DNS sur le port 53
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT

# Autoriser le trafic Web sur le port 80
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Protection contre les attaques SYN
sudo iptables -N syn-flood
sudo iptables -A syn-flood -m limit --limit 1/s --limit-burst 3 -j RETURN
sudo iptables -A syn-flood -j DROP
sudo iptables -A INPUT -p tcp --syn -j syn-flood

# Protection contre les attaques RST
sudo iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP

# Protection contre les attaques ICMP
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 3 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Protection contre les attaques de services web
sudo iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set --name http
sudo iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 50 --rttl --name http -j DROP

# Protection contre les attaques par dictionnaire
sudo iptables -N dictionary-attack
sudo iptables -A dictionary-attack -m recent --set --name dict
sudo iptables -A dictionary-attack -m recent --update --seconds 60 --hitcount 5 --name dict -j DROP
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j dictionary-attack

# Protection contre les attaques de reconnaissance
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST
# Protection contre les attaques de déni de service (DoS)
sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
# Protection contre les attaques de fragmentation IP
sudo iptables -A INPUT -f -j DROP

# Protection contre les attaques de paquets invalides
sudo iptables -A INPUT -m state --state INVALID -j DROP

# Protection contre les attaques de ping de la mort
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 10 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Protection contre les attaques de SYN/ACK
sudo iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
