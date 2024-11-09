#!/bin/bash

# Устанавливаем dante-server, если он не установлен
if ! command -v danted &> /dev/null; then
    echo "Устанавливаем dante-server..."
    sudo apt update && sudo apt install -y dante-server
fi

# Настраиваем конфигурацию danted
echo "Настройка конфигурации dante-server..."
cat <<EOF | sudo tee /etc/danted.conf > /dev/null
logoutput: stderr
internal: 0.0.0.0 port = 1080
external: eth0
method: username
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

# Перезапускаем службу danted
echo "Запуск dante-server..."
sudo systemctl restart danted

# Получаем IP-адрес
IP=$(hostname -I | awk '{print $1}')
PORT=1080

# Выводим прокси в формате IP:PORT
echo "Прокси запущен на ${IP}:${PORT}"
