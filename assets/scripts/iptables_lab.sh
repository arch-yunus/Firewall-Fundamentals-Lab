#!/bin/bash

# Firewall Fundamentals Lab - Iptables Scenario
# Senaryo: Web Sunucusu Güvenliği

echo "🚀 Güvenlik Duvarı Yapılandırması Başlatılıyor..."

# 1. Mevcut kuralları temizle
sudo iptables -F
sudo iptables -X

# 2. Varsayılan politikaları belirle (Whitelist Yaklaşımı)
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# 3. Loopback (Localhost) trafiğine izin ver
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# 4. Mevcut (Established/Related) bağlantıları koru
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 5. SSH Erişimi (Liman: 22) - Bağlantınızın kesilmemesi için kritik!
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 6. Web Trafiği (Liman: 80 & 443)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 7. ICMP (Ping) - Sadece iç ağdan gelenlere izin ver (Opsiyonel)
# sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

echo "✅ Yapılandırma Tamamlandı!"
echo "Mevcut Kurallar Listeleniyor:"
sudo iptables -L -n -v --line-numbers
