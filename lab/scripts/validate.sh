#!/bin/bash

# Firewall Lab - Otomatik Doğrulama Betiği
# Amacı: Kuralların doğru çalışıp çalışmadığını test etmek.

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔍 Doğrulama Süreci Başlatılıyor..."

check_connectivity() {
    local target=$1
    local port=$2
    local expected=$3 # "SUCCESS" or "FAILURE"

    if curl -s --connect-timeout 2 "http://$target:$port" > /dev/null; then
        result="SUCCESS"
    else
        result="FAILURE"
    fi

    if [ "$result" == "$expected" ]; then
        echo -e "${GREEN}[PASS]${NC} $target:$port -> $result (Beklenen: $expected)"
    else
        echo -e "${RED}[FAIL]${NC} $target:$port -> $result (Beklenen: $expected)"
    fi
}

# Örnek Test Senaryoları
echo "--- Web Sunucusu Erişimi ---"
check_connectivity "10.0.1.10" "80" "SUCCESS"

echo "--- Yasaklı Port (23 Telnet) ---"
check_connectivity "10.0.1.10" "23" "FAILURE"

echo "✅ Doğrulama Tamamlandı."
