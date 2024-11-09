#!/bin/bash

# Устанавливаем dante-server, если он не установлен
if ! command -v danted &> /dev/null; then
    echo "Устанавливаем dante-server..."
    sudo apt update && sudo apt install -y dante-server
fi

# Проверяем, существует ли интерфейс
INTERFACE="eth0"  # Замените на нужный интерфейс, если имя другое
if ! ip a | grep -q "$INTERFACE"; then
    echo "Интерфейс $INTERFACE не найден. Пожалуйста, проверьте его название."
    exit 1
fi

# Настраиваем конфигурацию danted
echo "Настройка конфигурации dante-server..."
cat <<EOF | sudo tee /etc/danted.conf > /dev/null
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: $INTERFACE
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

# Запуск danted с помощью команды service
echo "Запуск dante-server..."
sudo service danted restart

# Проверка статуса службы
if sudo service danted status | grep -q "running"; then
    # Получаем IP-адрес
    IP=$(hostname -I | awk '{print $1}')
    EXTERNAL_IP=$(curl -s ifconfig.me)
    PORT=1080
    
    echo "Прокси запущен на ${EXTERNAL_IP}:${PORT}"
else
    echo "Ошибка запуска dante-server. Проверка лога..."
    sudo tail -n 20 /var/log/danted.log
fi
