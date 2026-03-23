#!/bin/bash

# DOS / DDOS Koruması ve Hız Sınırlama (Rate Limiting)
# Amacı: Belirli bir IP'den gelen ICMP (Ping) veya TCP bağlantı isteklerini sınırlamak.

echo "🛡️ DOS Koruması Yapılandırması Başlatılıyor..."

# 1. ICMP (Ping) Sınırlama: Saniyede en fazla 1 ping, 5 burst.
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# 2. SYN Flood Koruması: Yeni TCP bağlantılarını sınırla
iptables -N SYN_FLOOD
iptables -A INPUT -p tcp --syn -j SYN_FLOOD
iptables -A SYN_FLOOD -m limit --limit 1/s --limit-burst 3 -j RETURN
iptables -A SYN_FLOOD -j DROP

# 3. Port Tarama Koruması (Opsiyonel)
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

echo "✅ DOS Koruma Kuralları Uygulandı!"
iptables -L -n -v
