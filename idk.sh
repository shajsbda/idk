#!/bin/bash

# Устанавливаем dante-server, если он не установлен
if ! command -v danted &> /dev/null; then
    echo "Устанавливаем dante-server..."
    sudo apt update && sudo apt install -y dante-server
fi

# Определяем интерфейс для конфигурации
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

if [ -z "$INTERFACE" ]; then
    echo "Не удалось определить сетевой интерфейс. Пожалуйста, укажите его вручную в конфигурации."
    exit 1
fi

# Настраиваем конфигурацию danted
echo "Настройка конфигурации dante-server..."
cat <<EOF | sudo tee /etc/danted.conf > /dev/null
logoutput: stderr
internal: 0.0.0.0 port = 1080
external: $INTERFACE
method: username none
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

# Проверяем, успешно ли запущена служба
if systemctl is-active --quiet danted; then
    IP=$(hostname -I | awk '{print $1}')
    PORT=1080
    echo "Прокси запущен на ${IP}:${PORT}"
else
    echo "Не удалось запустить dante-server. Проверьте конфигурацию и логи для диагностики."
    echo "Просмотр журнала ошибок:"
    sudo journalctl -u danted --no-pager | tail -n 20
fi
