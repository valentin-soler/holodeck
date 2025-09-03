#!/bin/bash

echo "Ce script va installer UFW et les différentes régles dont nous avons besoins dans Holodeck"

echo "Installation d'UFW"
apt update
apt install ufw -y

echo "Nous allons maintenant mettre en place les régles de pare-feu"
#Par défaut, nous allons demandé à UFW de bloqué toutes les connections entrante.
ufw default deny incomming
ufw default allow outgoing

#Nous allons maintenant ouvrir certain port uniquement pour notre LAN.
#Dans mon cas ma plage IP de mon lan est 192.168.22.0/24
#Et je dois ouvrir les ports pour mon DHCP,DNS,FTP et serveur web vers mon LAN
#DHCP
ufw allow from 192.168.22.0/24 to any port 67 proto udp comment 'Allow DHCP Server (bootps)'
ufw allow from 192.168.22.0/24 to any port 68 proto udp comment 'Allow DHCP Client (bootpc)'
#DNS
ufw allow from 192.168.22.0/24 to any port 53 proto udp comment 'DNS over UDP'
ufw allow from 192.168.22.0/24 to any port 53 proto tcp comment 'DNS over TCP'
#FTP
ufw allow from 192.168.22.0/24 to any port 21 proto tcp comment 'FTP Control'
ufw allow from 192.168.22.0/24 to any port 990 proto tcp comment 'FTPS Implicit'
#J'ouvre uniqument 100 port pour le passif, car je ne compte pas avoir beaucoups de connection en simultanée.
#Pour renseignez les port pour proftpd : echo "30000 30100" > /etc/pure-ftpd/conf/PassivePortRange
ufw allow from 192.168.22.0/24 to any port 30000:30100 proto tcp comment 'FTP Data Passive'
#Srv web
ufw allow from 192.168.22.0/24 to any port 80 proto tcp comment 'HTTP'
ufw allow from 192.168.22.0/24 to any port 443 proto tcp comment 'HTTPS'

echo "Nous allons maintenant autorisé le passage du trafic entre du LAN vers internet"
#Activation du forwarding IPv4
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf

#regles Pare-feu
sed -i '/^*nat/,/^COMMIT/d' /etc/ufw/before.rules

bash -c "cat >> /etc/ufw/before.rules" << EOF
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

-A PREROUTING -i ens33 -j DNAT --to-destination 192.168.22.0/24
-A POSTROUTING -s 192.168.22.0/24 -o ens34 -j MASQUERADE

COMMIT
EOF

ufw route allow in on ens34 out on ens33
ufw route allow in on ens33 out on ens34

systemctl restart ufw