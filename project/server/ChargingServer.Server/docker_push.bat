docker build -t charging-admin -f Dockerfile ..
docker login -u admin -p 1q2w3e4r5 registry.servertut.ru
docker tag charging-admin:latest registry.servertut.ru/charging-admin
docker push registry.servertut.ru/charging-admin

ssh root@176.108.253.192 -o "IdentitiesOnly=yes" -i %1 "docker pull registry.servertut.ru/charging-admin && cd /var/docker/charging && docker compose up -d && exit"