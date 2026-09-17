#!/bin/sh

# 1. Update repository dan install vsftpd
echo "[+] Mengupdate repository dan menginstall vsftpd..."
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apk update
apk add vsftpd

# 2. Daftarkan shell /bin/false agar user tidak ditolak login
grep -qxF "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells

# 3. Buat group ftpaccess jika belum ada
echo "[+] Membuat group ftpaccess..."
getent group ftpaccess >/dev/null || addgroup ftpaccess

# 4. Buat folder chroot base dan shared folder data
echo "[+] Menyiapkan struktur direktori /var/wired/data..."
mkdir -p /var/wired/data

# Atur permission base folder (tidak boleh writable oleh user biasa)
chown root:root /var/wired
chmod 755 /var/wired

# Atur permission folder data sesuai permintaan (775 & owner ftpaccess)
chown root:ftpaccess /var/wired/data
chmod 775 /var/wired/data
chmod g+s /var/wired/data

# 5. Buat user alice, mika, eiri dengan password rahasia123
USERS="alice mika eiri"
PASS="rahasia123"

for u in $USERS; do
    echo "[+] Menyiapkan user: $u..."
    if ! id -u "$u" >/dev/null 2>&1; then
        adduser -h /var/wired -s /bin/false -G ftpaccess -D "$u"
    fi
    echo "$u:$PASS" | chpasswd
done

# 7. Siapkan direktori user_conf
mkdir -p /etc/vsftpd/user_conf

# 8. Restart service vsftpd di background
echo "[+] Menjalankan vsftpd di background..."
killall vsftpd 2>/dev/null
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &

echo "[✓] Setup FTP selesai! Daemon vsftpd sudah berjalan."