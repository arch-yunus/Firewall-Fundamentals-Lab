#!/bin/bash

# NAT / Masquerading Senaryosu
# Amacı: İç ağdaki (10.0.1.0/24) cihazların dış dünyaya (Internet) 
# Firewall üzerinden kendi IP'sini kullanarak çıkmasını sağlamak.

echo "🌐 NAT Yapılandırması Başlatılıyor..."

# IPv4 Yönlendirmesini Etkinleştir
sysctl -w net.ipv4.ip_forward=1

# POSTROUTING Zincirinde Masquerade uygula (External interface: eth0 varsayılmaktadır)
# Bu kural iç ağdan gelen paketlerin kaynak IP'sini Firewall'un IP'siyle değiştirir.
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# İlgili trafiğin FORWARD zincirinden geçmesine izin ver
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "✅ NAT/Masquerade Yapılandırması Tamamlandı!"
iptables -t nat -L -n -v
