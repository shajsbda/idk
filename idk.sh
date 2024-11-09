#!/bin/bash

# Установка Squid, если он еще не установлен
if ! command -v squid &> /dev/null; then
    echo "Устанавливаем Squid..."
    sudo apt update && sudo apt install -y squid
fi

# Настройка конфигурации Squid
echo "Настройка конфигурации Squid..."
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
http_port 3128
acl all src all
http_access allow all
EOF

# Перезапуск Squid для применения настроек
echo "Перезапуск Squid..."
sudo service squid restart

# Открытие порта 3128 в брандмауэре
echo "Настройка брандмауэра для разрешения доступа к порту 3128..."
sudo ufw allow 3128

# Получение IP-адреса и вывод информации о прокси
IP=$(hostname -I | awk '{print $1}')
PORT=3128
echo "HTTP-прокси успешно запущен на ${IP}:${PORT}"
