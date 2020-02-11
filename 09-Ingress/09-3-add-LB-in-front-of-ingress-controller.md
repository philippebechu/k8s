# ADD LB in front of ingress-controller

## deploy HAP en frontal de l'ingress-controller => sur la VM Master

```sh

# se placer dans le répertoire parent du répertoire haproxy

# pour le déploiement sur AWS ADAPTER les IP et les remplacer par les IP PRIVEE des deux worker
# visiualiser la config
vim ./haproxy/haproxy.cfg

# lancer un conteneur Docker qui lance HAP avec cette configuration
docker run -d --name hap -p 80:80 -p 9999:9999 -v $(pwd)/haproxy:/usr/local/etc/haproxy:ro --restart=unless-stopped haproxy:1.8.9-alpine


```

## verifier la config

Sur AWS utilisé l'adresse publique du Master

http://192.169.32.20:9999/stats
user / mot de passe : admin / admin 

## modifier l'ingress container-demo

container-demo-ingress.35.180.243.136.xip.io