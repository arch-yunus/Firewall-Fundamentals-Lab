FROM alpine:latest

RUN apk add --no-cache iptables iproute2 tcpdump

# Başlangıçta tüm trafiği kabul et (Lab ortamı olduğu için)
CMD ["/bin/sh", "-c", "sysctl -w net.ipv4.ip_forward=1 && tail -f /dev/null"]
