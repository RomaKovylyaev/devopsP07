#!/bin/bash
set -e

mkdir -p ./ssl
if [ ! -f ./ssl/selfsigned.crt ] || [ ! -f ./ssl/selfsigned.key ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./ssl/selfsigned.key \
    -out ./ssl/selfsigned.crt \
    -subj "/C=RU/ST=Perm/L=Perm/O=DevOpsCourse/CN=localhost"
fi

# Удаляем старый контейнер, если есть
docker stop nginx-cont 2>/dev/null || true
docker rm nginx-cont 2>/dev/null || true

# Собираем образ
docker build -t devops/nginx-server ./nginx

# Создаём и запускаем контейнер (HTTP -> 54321, HTTPS -> 5443, SSL через volume)
docker run -d --name nginx-cont \
  -p 54321:80 \
  -p 5443:443 \
  -v "$(pwd)/ssl:/etc/nginx/ssl:ro" \
  --restart unless-stopped \
  devops/nginx-server

sleep 2
docker exec nginx-cont nginx -t
docker ps -a
curl -s http://127.0.0.1:54321
curl -sk https://127.0.0.1:5443
docker logs -n 10 nginx-cont
