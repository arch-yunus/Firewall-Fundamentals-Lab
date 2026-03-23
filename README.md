# 🛡️ Firewall Fundamentals Lab

[![Security](https://img.shields.io/badge/Security-Firewall-red.svg)](https://github.com/arch-yunus/Firewall-Fundamentals-Lab)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

Bu depo, ağ güvenliğinin temel taşı olan **Güvenlik Duvarı (Firewall)** teknolojilerini, çalışma prensiplerini ve yapılandırma türlerini öğrenmek/öğretmek amacıyla oluşturulmuş kapsamlı bir eğitim rehberidir.

---

## 📑 İçindekiler
* [Güvenlik Duvarı Nedir?](#güvenlik-duvarı-nedir)
* [Çalışma Prensipleri](#çalışma-prensipleri)
* [Güvenlik Duvarı Türleri](#güvenlik-duvarı-türleri)
* [Modern Teknolojiler (NGFW & WAF)](#modern-teknolojiler)
* [Pratik Senaryolar & Iptables](#pratik-senaryolar)
* [Lab: Uygulamalı Senaryo (Host-Based)](#lab-uygulamalı-senaryo)
* [Lab: Docker Ortamı (Network-Based)](#lab-docker-ortamı)
* [İleri Seviye Konseptler (NAT & DOS)](#i̇leri-seviye-konseptler)
* [Modern Alternatif: NFTables](#modern-alternatif-nftables)

---

## 🔍 Güvenlik Duvarı Nedir?

Güvenlik duvarı, önceden belirlenmiş güvenlik kurallarına dayanarak gelen ve giden ağ trafiğini izleyen ve kontrol eden bir ağ güvenlik sistemidir. Temel amacı, güvenilir bir iç ağ ile güvenilmeyen bir dış ağ (İnternet gibi) arasında bir engel oluşturmaktır.

### Trafik Akış Diyagramı
```mermaid
graph TD
    A[İnternet] -->|Gelen Trafik| B{Güvenlik Duvarı}
    B -->|Kurala Uygun| C[İç Ağ / Sunucu]
    B -->|Kural Dışı| D[LOG & DROP]
```

---

## 🛠️ Güvenlik Duvarı Türleri

| Tür | Açıklama | Odak Noktası |
| :--- | :--- | :--- |
| **Host-Based** | Sadece yüklü olduğu cihazın trafiğinden sorumludur. | Uç Nokta Güvenliği |
| **Network-Based** | Tüm ağ trafiğini süzmek için ağın girişine konumlandırılır. | Ağ Geneli Güvenlik |
| **WAF (Web Application Firewall)** | L7 (Uygulama) katmanında SQLi, XSS gibi saldırıları engeller. | Web Uygulamaları |
| **NGFW (Next-Gen Firewall)** | DPI, IPS ve Uygulama Farkındalığı içeren modern çözümlerdir. | Gelişmiş Tehdit Kontrolü |

---

## 🚀 Temel Komutlar ve Konfigürasyonlar

### Linux Iptables (Temel Yapı)
`iptables`, Linux çekirdeği tarafından sağlanan bir güvenlik duvarı tablosu yönetim aracıdır.

- **Tüm kuralları temizle:**
  ```bash
  sudo iptables -F
  ```
- **Mevcut kuralları listele:**
  ```bash
  sudo iptables -L -n -v --line-numbers
  ```
- **Poliçeleri belirle (Hepsini reddet):**
  ```bash
  sudo iptables -P INPUT DROP
  sudo iptables -P FORWARD DROP
  sudo iptables -P OUTPUT ACCEPT
  ```

---

## 🔥 Lab: Uygulamalı Senaryo

### Senaryo: Web Sunucusu Güvenliği
Bir web sunucumuz var ve sadece HTTP (80), HTTPS (443) ve SSH (22) bağlantılarına izin vermek istiyoruz. Diğer her şeyi engelleyeceğiz.

#### Adım 1: SSH Erişimi Ver (Bağlantınızın Kesilmemesi İçin!)
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

#### Adım 2: Web Trafiğine İzin Ver (80 & 443)
```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

#### Adım 3: Mevcut Bağlantıları Koru
```bash
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

#### Adım 4: Geri Kalan Her Şeyi Engelle
```bash
sudo iptables -P INPUT DROP
```

> [!IMPORTANT]  
> `iptables` kuralları sistem yeniden başlatıldığında silinir. Kalıcı hale getirmek için `iptables-persistent` kullanmalısınız.

---

## 🐳 Lab: Docker Ortamı (Network-Based)

Daha gelişmiş ve izole bir test ortamı için Docker Compose topolojisini kullanabilirsiniz. Bu ortam; bir istemci, bir güvenlik duvarı ve bir hedef sunucudan oluşur.

### Topoloji
- **Client (10.0.2.10):** Dış ağdaki istemci.
- **Firewall (10.0.2.1 / 10.0.1.1):** Geçit (Gateway).
- **Server (10.0.1.10):** İç ağdaki hedef web sunucusu.

### Başlatma
```bash
cd lab
docker-compose up -d
```

### Test Örneği: Bağlantı Engelleme
1. **İstemciden sunucuya erişimi test edin:**
   ```bash
   docker exec -it lab-client curl 10.0.1.10
   ```
2. **Güvenlik duvarında trafiği engelleyin:**
   ```bash
   docker exec -it lab-firewall iptables -A FORWARD -s 10.0.2.10 -d 10.0.1.10 -j DROP
   ```
3. **Tekrar test edin (Erişim engellenmiş olmalı).**

---

## 🛰️ İleri Seviye Konseptler

Lab ortamındaki `lab/advanced` dizininde bulunan betikler ile daha karmaşık senaryoları test edebilirsiniz.

### NAT (Network Address Translation)
İç ağdaki cihazların dış dünyaya erişimini sağlar. 
- **Setup:** `bash lab/advanced/nat_setup.sh`

### DOS Koruması (Rate Limiting)
Belirli bir IP'den gelen paket sayısını sınırlayarak basit saldırıları engeller.
- **Setup:** `bash lab/advanced/dos_protection.sh`

---

## 🛠️ Modern Alternatif: NFTables

`iptables` yerini alan `nftables`, daha performanslı ve temiz bir sözdizimi sunar. 

### Iptables vs. NFTables Karşılaştırması

| Özellik | Iptables | NFTables |
| :--- | :--- | :--- |
| **Sözdizimi** | Sabit / Karmaşık | Esnek / Hiyerarşik |
| **Performans** | Orta (Zincir tabanlı) | Yüksek (VM tabanlı) |
| **Güncelleme** | Atomik değil | Tam atomik kural güncellemeleri |

**NFTables Örnek Kurallar:** `lab/nftables/rules.nft`

---

## 🧪 Otomatik Doğrulama

Kurallarınızın doğru çalışıp çalışmadığını test etmek için doğrulama betiğini kullanın:
```bash
docker exec -it lab-client sh /lab/scripts/validate.sh
```

---

## 🤝 Katkıda Bulunma
Bu proje eğitim amaçlıdır. Yeni senaryolar veya yapılandırma örnekleri eklemek isterseniz lütfen bir **Pull Request** açın!

1. Depoyu forklayın.
2. Yeni özellik dalı (branch) oluşturun.
3. Değişikliklerinizi commit edin.
4. Pull Request oluşturun.

---

## 📝 Lisans
Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
