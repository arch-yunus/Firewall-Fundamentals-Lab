#!/bin/bash

# Firewall Fundamentals Lab - Merkezi Kontrol Arayüzü (labctl)
# Amacı: Lab ortamını kolayca yönetmek, test etmek ve senaryo uygulamak.

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="firewall-lab"

show_help() {
    echo "🛡️ Firewall Lab Control Interface (labctl)"
    echo "Kullanım: ./labctl.sh [komut]"
    echo ""
    echo "Komutlar:"
    echo "  up        : Lab ortamını başlatır."
    echo "  down      : Lab ortamını durdurur ve temizler."
    echo "  status    : Konteynerlerin durumunu gösterir."
    echo "  test      : Otomatik doğrulama testlerini çalıştırır."
    echo "  logs      : Güvenlik duvarı (Firewall) loglarını izler."
    echo "  shell [n] : Belirtilen düğüme (client|firewall|server) bağlanır."
    echo "  apply [s] : Belirtilen senaryoyu (nat|dos|basic) uygular."
    echo "  help      : Bu yardım mesajını gösterir."
}

case "$1" in
    up)
        echo "🚀 Lab başlatılıyor..."
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME up -d
        ;;
    down)
        echo "🛑 Lab durduruluyor..."
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME down
        ;;
    status)
        docker-compose -f $COMPOSE_FILE -p $PROJECT_NAME ps
        ;;
    test)
        echo "🔍 Doğrulama testleri çalıştırılıyor..."
        docker exec -it lab-client sh /lab/scripts/validate.sh
        ;;
    logs)
        echo "📝 Firewall logları izleniyor (CTRL+C ile çıkın)..."
        docker exec -it lab-firewall tail -f /var/log/messages 2>/dev/null || docker logs -f lab-firewall
        ;;
    shell)
        node=$2
        [ -z "$node" ] && node="firewall"
        docker exec -it "lab-$node" sh
        ;;
    apply)
        scenario=$2
        case "$scenario" in
            nat)
                echo "🌐 NAT senaryosu uygulanıyor..."
                docker exec -it lab-firewall sh /lab/advanced/nat_setup.sh
                ;;
            dos)
                echo "🛡️ DOS koruma senaryosu uygulanıyor..."
                docker exec -it lab-firewall sh /lab/advanced/dos_protection.sh
                ;;
            basic)
                echo "🔥 Temel kurallar uygulanıyor..."
                docker exec -it lab-firewall sh /assets/scripts/iptables_lab.sh
                ;;
            *)
                echo "❌ Geçersiz senaryo: $scenario (nat|dos|basic)"
                ;;
        esac
        ;;
    *)
        show_help
        ;;
esac
