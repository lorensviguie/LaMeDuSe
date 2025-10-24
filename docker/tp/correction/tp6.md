# TP5 : Administrer ses conteneurs Docker

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 🎯 Objectifs du TP

Ce TP a pour objectif de vous apprendre à **administrer, superviser et automatiser la gestion de vos conteneurs Docker**. Vous apprendrez à :

* Automatiser le démarrage des containers via Docker Compose
* Gérer les ressources CPU, RAM et volumes
* Gérer et analyser les logs
* Effectuer des sauvegardes (backups) et restaurations

Durée estimée : **4 heures**

---

## 1. Prérequis

* Avoir Docker et Docker Compose installés
* Avoir suivi les TP précédents (TP2 à TP4)
* Avoir des connaissances de base en Linux

---

## 2. Automatiser le démarrage des containers avec Docker Compose

### 🧾 Exemple de fichier `docker-compose.yaml`

```yaml
version: '3.9'
services:
  nginx:
    image: nginx:latest
    container_name: web
    ports:
      - "8080:80"
    restart: always
    volumes:
      - ./site:/usr/share/nginx/html
  
  mysql:
    image: mysql:8.0
    container_name: database
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: webdb
    restart: always
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

### ▶️ Lancer et automatiser le démarrage

```bash
docker compose up -d
```

Les options de **redémarrage automatique** disponibles :

* `no` — ne redémarre jamais (par défaut)
* `always` — redémarre toujours après un crash ou reboot
* `on-failure` — redémarre uniquement si le code de retour ≠ 0
* `unless-stopped` — redémarre sauf si stoppé manuellement

> Vérifiez après un redémarrage de votre machine que les containers se relancent automatiquement.

---

## 3. Gestion des ressources (CPU / RAM / Volume)

### ⚙️ Limiter les ressources d’un service

```yaml
services:
  app:
    image: nginx:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'   # 50% d’un CPU
          memory: 256M  # 256 Mo de RAM
```

> Cela permet d’éviter qu’un container consomme toute la mémoire ou le CPU du système.

### 🔍 Vérifier les limites appliquées

```bash
docker stats
```

> Vous verrez la consommation CPU / RAM en temps réel.

### 📦 Gérer les volumes

Lister :

```bash
docker volume ls
```

Inspecter :

```bash
docker volume inspect mysql_data
```

Supprimer :

```bash
docker volume rm mysql_data
```

---

## 4. Gestion et supervision des logs

### 🧾 Consulter les logs d’un container

```bash
docker logs web
```

### 🔄 Suivre les logs en temps réel

```bash
docker logs -f web
```

### 📂 Rediriger les logs vers un fichier

```bash
docker logs web > web_logs.txt
```

### 🧰 Options avancées : limiter la taille des logs

```yaml
services:
  nginx:
    image: nginx:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

> Cela limite la taille et le nombre de fichiers de logs, évitant une saturation du disque.

---

## 5. Sauvegarde et restauration (BACKUP)

### 💾 Sauvegarde des volumes Docker

Créez un dossier de backup :

```bash
mkdir ~/docker_backups
```

Sauvegarder un volume :

```bash
docker run --rm \
  -v mysql_data:/volume \
  -v ~/docker_backups:/backup \
  alpine tar czf /backup/mysql_backup.tar.gz -C /volume .
```

### 🔁 Restaurer un volume

```bash
docker run --rm \
  -v mysql_data:/volume \
  -v ~/docker_backups:/backup \
  alpine tar xzf /backup/mysql_backup.tar.gz -C /volume
```

### 💡 Automatiser la sauvegarde avec un script Bash

Fichier : `backup.sh`

```bash
#!/bin/bash
DATE=$(date +%F_%H-%M-%S)
BACKUP_DIR=~/docker_backups
mkdir -p $BACKUP_DIR

echo "Sauvegarde en cours..."
docker run --rm \
  -v mysql_data:/volume \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/mysql_backup_$DATE.tar.gz -C /volume .

echo "Sauvegarde terminée : $BACKUP_DIR/mysql_backup_$DATE.tar.gz"
```

> Planifiez-le via `cron` pour une sauvegarde quotidienne.

---

## 6. Monitoring des containers

### 📊 Utilisation de `docker stats`

```bash
docker stats --no-stream
```

### 🧠 Utiliser `cAdvisor` pour un monitoring visuel

Ajoutez à votre `docker-compose.yaml` :

```yaml
cadvisor:
  image: gcr.io/cadvisor/cadvisor:latest
  ports:
    - "8081:8080"
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:ro
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
```

> Accédez ensuite à `http://localhost:8081` pour visualiser les performances en temps réel.

---

## 7. Bonnes pratiques d’administration Docker 🧠

1️⃣ **Toujours nommer vos containers et volumes** : facilite la maintenance

```bash
docker run --name webapp -v webdata:/usr/share/nginx/html nginx
```

2️⃣ **Nettoyer régulièrement** les ressources inutilisées

```bash
docker system prune -af --volumes
```

3️⃣ **Sécuriser les permissions des volumes** (éviter le root total)

```bash
chmod 700 /data/secure_volume
```

4️⃣ **Surveiller les logs d’erreurs** et les redémarrages intempestifs

```bash
docker inspect --format='{{.State.RestartCount}}' web
```

5️⃣ **Limiter la taille des fichiers journaux** (voir section 4)

6️⃣ **Utiliser des outils externes de supervision** : Prometheus, Grafana, ELK, Portainer…

---

## 8. Exercice final 🧩

Créez un environnement complet qui :

* Démarre automatiquement au boot
* Contient un NGINX, une base de données PostgreSQL et un service d’administration (Adminer)
* A des ressources CPU et RAM limitées
* Dispose d’un script automatique de backup
* Gère les logs avec rotation automatique

> Bonus : ajoutez un monitoring visuel (cAdvisor ou Grafana + Prometheus)

---

## ✅ Bilan du TP

À la fin de ce TP, vous savez :

* Automatiser et gérer le démarrage des containers
* Surveiller et limiter les ressources système
* Gérer les logs efficacement
* Sauvegarder et restaurer les volumes
* Appliquer de bonnes pratiques d’administration Docker

> 💡 Prochain TP : *Monitoring et observabilité avancée avec Prometheus, Grafana et Alertmanager dans un environnement Docker Compose.*
