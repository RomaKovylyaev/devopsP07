#!/bin/bash
set -e

mkdir -p ./ssl
echo "=== Генерация нового SSL-сертификата ==="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./ssl/selfsigned.key \
  -out ./ssl/selfsigned.crt \
  -subj "/C=RU/ST=Perm/L=Perm/O=DevOpsCourse/CN=localhost-$(date +%s)"

echo "=== Перечитывание конфигурации и сертификата в nginx ==="
docker exec nginx-cont nginx -t
docker exec nginx-cont nginx -s reload

echo "=== Проверка нового сертификата ==="
echo | openssl s_client -connect 127.0.0.1:5443 -servername localhost 2>/dev/null | openssl x509 -noout -subject -dates
