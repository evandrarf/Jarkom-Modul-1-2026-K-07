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
