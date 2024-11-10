#!/bin/bash

sudo apt update

echo "Installing Dante SOCKS5 proxy server"
sudo apt install -y dante-server

echo "Configuring Dante"
cat <<EOF | sudo tee /etc/danted.conf > /dev/null
logoutput: stderr
internal: 0.0.0.0 port = 1080
external: eth0  # Используйте eth0 или нужный интерфейс
socksmethod: none    # Отключение аутентификации для упрощения
user.notprivileged: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
EOF

echo "Starting Dante SOCKS5 proxy server"
sudo service danted restart

curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install -y playit
playit
