# Kelompok K-07 Laporan Resmi Jarkom Modul 1

## Anggota Kelompok

| Nama                   | NRP        |
| :--------------------- | :--------- |
| Evandra Raditya Fauzan | 5027251001 |
| Keisya Dira Anugerah   | 5027251055 |

## Daftar Isi

1. [Topologi Jaringan](#1-topologi-jaringan)
2. [Network Address Translation](#2-network-address-translation)
3. [Static Routing](#3-static-routing)
4. [Firewall dan iptables](#4-firewall-dan-iptables)

## Laporan Resmi

### 1. Topologi Jaringan

![topologi jaringan](./images/1-topologi.png)

Topologi Jaringan dibuat menjadi seperti gambar di atas. Sebuah router dengan nama `Lain` terhubung ke sebuah adapter NAT untuk terkoneksi dengan internet. Router tersebut menjadi gateway utama dari beberapa jaringan yang ada di bawahnya. Pada layer dibawah router terdapat 3 buah switch yang masing masing terhubung dengan 1 hingga 2 client.

#### Switch 1

- Network: 10.67.1.0/24
- Netmask: 255.255.255.0
- Gateway: 10.67.1.1/24

##### Alice

- IP: 10.67.1.2/24
- Netmask: 255.255.255.0
- Default Gateway: 10.67.1.1/24

##### Mika

- IP: 10.67.1.3/24
- Netmask: 255.255.255.0
- Default Gateway: 10.67.1.1/24

#### Switch 2

- Network: 10.67.2.0/24
- Netmask: 255.255.255.0
- Gateway: 10.67.2.1/24

##### Chisa

- IP: 10.67.2.2/24
- Netmask: 255.255.255.0
- Default Gateway: 10.67.2.1/24

#### Switch 3

- Network: 10.67.3.0/24
- Netmask: 255.255.255.0
- Gateway: 10.67.3.1/24

##### Knights

- IP: 10.67.3.2/24
- Netmask: 255.255.255.0
- Default Gateway: 10.67.3.1/24

##### Eiri

- IP: 10.67.3.3/24
- Netmask: 255.255.255.0
- Default Gateway: 10.67.3.1/24

Semua konfigurasi interface terdapat pada folder [config](./config)

## 2. Network Address Translation

Pada router Lain, interface `eth0` dapat dikoneksikan ke sebuah adapter NAT untuk mendapatkan akses internet.

## 3. Static Routing

Semua device yang terhubung ke router lain berada pada subnet/jaringan yang berbeda. Agar mereka bisa saling berkomunikasi maka router `Lain` harus dikonfigurasi dengan static routing.

Jaringan akan dipetakan ke interface tujuan dari jaringan tersebut. Harapannya client yang ada pada jaringan yang berbeda dapat mengetahui ke mana mereka harus berkomunikasi.

```
# /etc/network/interfaces
10.67.1.0/24 dev eth1 proto kernel scope link src 10.67.1.1
10.67.2.0/24 dev eth2 proto kernel scope link src 10.67.2.1
10.67.3.0/24 dev eth3 proto kernel scope link src 10.67.3.1
```

## 4. Firewall dan iptables

Meskipun router sudah terhubung dengan sebuah adapter NAT. Client yang terhubung tidak bisa langsung terkoneksi ke internet. Router perlu dikonfigurasi dengan sebuah firewall untuk meneruskan akses internet yang dimiliki router ke client yang terhubung.


...


## 11. Analisis Kelemahan Protokol Telnet

Untuk membuktikan kelemahan Telnet, dilakukan koneksi dari node Eiri ke node Chisa menggunakan akun `phantom_user` dengan password `wired_ghost` yang telah dikonfigurasi dulu menggunakan di Node Chisa. Proses ini di-capture menggunakan `tcpdump` untuk dianalisis di Wireshark.

```
tcpdump -i eth0 -w /tmp/telnet_capture.pcap port 23 &
telnet 10.67.2.2
```

![](images/11telnet.png)

Dari hasil [capture](config/11-chisalogin), terlihat bahwa Telnet tidak mengenkripsi data transmisi apapun. Hal ini terbukti dari hasil Follow TCP Stream pada wireshark, username dan password terbaca sebagai plaintext tanpa enkripsi. 

Selain itu, setiap keystroke langsung dikirim ke server tanpa buffering, karena protokol ini dirancang untuk interactive terminal session di mana server perlu merespons setiap karakter secara real-time. Akibatnya,  attacker yang melakukan capture dapat merekonstruksi input pengguna secara utuh hanya dari urutan paket.

## 12. Port Scanning dengan Netcat

Untuk mensimulasikan skenario di mana Alice mendeteksi layanan tersembunyi pada node Knights, terlebih dahulu dikonfigurasi dua layanan pada node Knights

```bash
apk add openssh
ssh-keygen -A
/usr/sbin/sshd
apk add nginx
nginx
```

Kemudian dilakukan port scanning dari node Alice menggunakan Netcat ke 3 port berbeda pada node Knights.

```bash
nc -zv 10.67.3.2 22
nc -zv 10.67.3.2 80
nc -zv 10.67.3.2 7777
```

Hasil scan dianalisis di Wireshark untuk membandingkan respons TCP antara port terbuka dan tertutup.

**Port terbuka (22 & 80) - filter `tcp.flags.syn==1 && tcp.flags.ack==1`:**

![](images/12-SYN-ACK.png)

Dua paket SYN-ACK dikembalikan oleh Knights, masing-masing untuk port 22 dan port 80, menandakan ada proses yang aktif listening pada kedua port tersebut.

**Port tertutup (7777) - filter `tcp.flags.rst==1 && tcp.flags.ack==1`:**

![](images/12-RST-ACK.png)

Satu paket RST-ACK dikembalikan untuk port 7777 karena tidak ada proses yang aktif listening pada port tersebut dan tidak ada firewall yang membatasi. Hal ini menandakan bahwa port tertutup dan tidak ada layanan yang berjalan di port tersebut.

## 13. SSH Tanpa Password (Public Key Authentication)

Dikonfigurasi akun `mika_admin` di node Knights yang hanya menerima koneksi SSH berbasis public key dari node Mika.

```bash
adduser mika_admin
mkdir -p /home/mika_admin/.ssh
chmod 700 /home/mika_admin/.ssh
chown -R mika_admin:mika_admin /home/mika_admin/.ssh
```

Public key di-generate di node Mika dan didaftarkan ke `authorized_keys` milik `mika_admin` di Knights. Autentikasi berbasis password kemudian dinonaktifkan, memaksa Knights hanya menerima koneksi yang dapat membuktikan kepemilikan private key.

![](images/13-setnopass.png)

Mika berhasil login ke Knights tanpa memasukkan password.

![](images/13-nopassword.png)

Dari hasil capture, tidak ada kredensial yang terkirim melalui jaringan. Yang terlihat hanya Protocol Version Exchange dan Key Exchange, sisanya terenkripsi dan tidak dapat dibaca atau decode.

![](images/13-filter_ssh.png)


## 14. Analisis Serangan Brute-Force pada Web Alice

Dari file capture `wired_bruteforce.pcapng`, diidentifikasi serangan brute-force terhadap form login pada web Alice.

Dengan filter `http.response`, ditemukan 52 percobaan POST dari attacker ke target dari 52 percobaan, sebagian besar mengembalikan response 401 (gagal), satu 404 (tidak ditemukan), dan dua percobaan berhasil mengembalikan 200 OK, ditemukan kredensial diantaranya:

![](images/14-userpass.png)

Sehingga hasil temuan dapat disimpulkan melalui tabel berikut:

| Keterangan| Detail |
|-|-|
| IP Penyerang| 172.26.7.50 |
| IP Target| 172.26.7.100 port 8080 |
| Web Server| Apache/2.4.62 |
| user:password | lain_admin:wired_pr0tocol_7 |

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26{W1r3d_Brut3_H0yZsExJta1BCs3ArnWVuPx21}`

## 15. Analisis Serangan USB HID (Keystroke Injection)

Terdapat perangkat keyboard berbahaya pada node Alice yang dapat dianalisis melalui file `wired_usb_hid.pcap` dilakukan filtering umum terlebih dahulu seperti `usb` dan cari detail dari `DEVICE DESCRIPTOR response`

![](images/15-usb-urb.png)

Setelah mendapatkan `Vendor ID`, `Product ID`, dan `Device Adress` dilanjutkan dengan filtering paket-paket keystroke melalui filter `usb.capdata`. Terdapat 26 paket format HID Keyboard yang di-decode melalui referensi git [ini.](https://github.com/tmk/tmk_keyboard/wiki/USB%3A-HID-Usage-Table?utm_source=chatgpt.com)

```
02001a00
Left Shift + w = W
.. dst.
```


Keystroke yang berhasil direkonstruksi dari data HID mengungkap pesan rahasia:
`Wired_Protocol_7_is_alive_2026`

| Keterangan | Detail |
|-|-|
| Vendor ID | 046d |
| Product ID | c31c|
| Device Address | 7 |
| Secret Message | Wired_Protocol_7_is_alive_2026 |


![](images/15-usb.png)

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26{USB_K3ystr0k3_dL44AUoovdlk9KE91tzbyjzO3}`


## 16. Analisis Pencurian File Malware melalui FTP

Diberikan file capture `wired_ftp_theft.pcap` untuk identifikasi aktivitas pengunduhan file mencurigakan menggunakan FTP.

Dengan filter `ftp.request.command == "RETR"`, ditemukan pengunduhan file `knights_payload.exe_ oleh attacker yang memiliki detail kredensial seperti [ini.](config/16-ftp-thief)

| Keterangan| Detail |
|-|-|
| IP Attacker | 198.51.100.7|
| Username| knights_agent        |
| Password | N4v1_s3cure_2026|
| FTP Server | vsftpd 3.0.5|
| File | knights_payload.exe |
| Ukuran  | 524288 bytes  |

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26{FTP_Th3ft_dD5Dtocvo91O5гGC3Gip2kohC}`


## 17. Analisis Pengunduhan Malware melalui HTTP

Terdapat payload berbahaya yang diinstall Eiri pada halaman web Alice di node-nya melalui HTTP dan dapat dianalisis dalam file capture `wired_http_c2.pcap`.

Setelah melakukan filtering `http.request` dan melakukan http stream, ditemukan detail-detail yang bisa ditemukan [disini](config/17-payloadstream) dan alamat IP attacker dari source address 

![](images/17-ip.png)

Sehingga ringkasan temuan dari file capture ini yaitu:

| Keterangan| Detail |
|-|-|
| Domain (Host) | `wired-update.net` |
| File Executable | navi_agent.exe |
| Kode status HTTP| 200 |
| IP Attacker | 203.0.113.42 |


Validasi temuan pada socket server menghasilkan flag: `KOMJAR26{Navi_C2_D0wnl04d_3YIA2bqDaR53O6grIoj3DgFEH}`

 

## 18. Analisis Penyebaran Malware melalui SMB

Terdapat file capture `wired_smb_transfer.pcapng`, untuk menganalisis penyebaran malware menggunakan protokol file sharing SMB.

Karena filtering `smb` kosong, filtering `smb2` khususnya `CREATE request [System32/wired_trojan_payload.exe]` memberikan hasil stream seperti [ini](config/18-smbprotocol) dan detail IP

![](images/18-requestmal.png)

Ringkasan temuan dalam tabel berikut
| Keterangan| Detail |
|-|-|
| IP Attacker |10.7.3.100|
| IP Victim| 10.7.1.50 |
| Jarringan yang dieksploitasi | ADMIN$|
| File Executable |wired_trojan_payload.exe|

![](images/18-smb.png)

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26 {SMB_Tr4nsf3r_zli0KTe8ewjVOf9eM5RnIsD3V)`

---

## 19. Analisis Email Pemerasan melalui SMTP

Terdapat pesan ancaman pemerasan melalui protokol SMTP tanpa enkripsi, file `wired_smtp_threat.pcap` dapat dianalisis untuk menggali informasi dari pesan tersebut.

Setelah menggunakan filter `smtp`, terdapat 16 paket yang diantaranya berisikan threat mail tanpa enkripsi yang dapat dilihat [disini.](config/19-letsAllLoveLain)

Dari pesan itu terdapat temuan yang diringkas menjadi:

| Keterangan       | Detail |
|------------------|--------|
| Email Korban     |`victim@protocol7.co.jp`|
| Password Bocor   |pr0tocol_7_user|
| Jenis Malware    |Ransomware|
| Batas Waktu      |3 hari/72h|
| MailClientID     |7719980706|

![](images/19-smtp.png)

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26 {SMTP_Ext0rt10n_G0xwXQXWvq85OawCDLeku99j7}`

---

## 20. Analisis Komunikasi Malware Terenkripsi TLS

Di soal ini, komunikasi malware disembunyikan di balik traffic HTTPS terenkripsi sehingga sebelum kita analisis file capture `wired_tls_decrypt.pcapng` perlu Session Key dari `keyslogfile.txt` untuk dipasangkan di field Wireshark bagian `(Pre)-Master-Secret log file` 

Setelah file berhasil di-decrypt, menggunakan fitur detail pada kolom di bagian bawah untuk menemukan versi TLS yang dinegoisasikan beserta IP server attacker.


![](images/20-tls-vers.webp)
dan


![](images/20-ip.png)



Lalu dengan filtering `http` ditemukan stream seperti pada [link ini.](config/20-decrypted)


Sehingga tabel temuan dari soal ini adalah seperti berikut:

| Keterangan      | Detail |
|-----------------|--------|
| Versi TLS       | TLSv1.2 |
| Domain (SNI)    | example.com |
| IP Server       |93.184.216.34|
| User-Agent      |curl/7.62.0 |
| HTTP Method     | HEAD |
| Path            | / HTTP/1.1|

![](images/20-tls.png)

Validasi temuan pada socket server menghasilkan flag: `KOMJAR26(TLS_D3crypt_UASAuE8QELYaS5EaiZctN2si1}`