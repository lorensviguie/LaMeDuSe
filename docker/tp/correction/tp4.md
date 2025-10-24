# TP4 : Docker Compose — Automatiser et sécuriser ses déploiements multi-conteneurs

## 🎯 Objectifs du TP

Dans ce TP, vous apprendrez à orchestrer plusieurs containers avec **Docker Compose**. Vous verrez comment définir des services, réseaux et volumes, gérer les dépendances entre containers, et appliquer des **bonnes pratiques de sécurité**.

Durée estimée : **4 heures**

---

## 1. Prérequis

* Docker et Docker Compose installés (version ≥ 2.0)
* Connaissance de base des containers et images (TP2 et TP3)
* Savoir naviguer dans un terminal Linux

---

## 2. Introduction à Docker Compose

### 📖 Définition

Docker Compose permet de **définir, configurer et exécuter des applications multi-conteneurs** à l’aide d’un seul fichier YAML.

Ce fichier décrit :

* Les **services** (containers)
* Les **volumes** (stockage persistant)
* Les **réseaux** (communication entre services)

### 🚀 Avantages

* Un seul fichier pour tout le déploiement
* Gestion simplifiée des dépendances entre services
* Reproductibilité et portabilité

---

## 3. Premier projet Compose : Web + Base de données

### 🧱 Structure du projet

```bash
mkdir ~/tp4_docker_compose
cd ~/tp4_docker_compose
mkdir web db
```

### 🧾 Fichier `docker-compose.yaml`

```yaml
version: '3.9'
services:
  web:
    image: nginx:latest
    container_name: webserver
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: database
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: site_db
      MYSQL_USER: user1
      MYSQL_PASSWORD: userpass
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

### 🌐 Créez un fichier `web/index.html`

```html
<h1>Docker Compose — Nginx & MySQL</h1>
<p>Base de données connectée via Docker Compose</p>
```

### ▶️ Démarrage du stack

```bash
docker compose up -d
```

### 🧭 Vérifications

```bash
docker ps
```

> Accédez à `http://localhost:8080`

### ⏹️ Arrêt

```bash
docker compose down
```

---

## 4. Ajouter un service PHP (LAMP stack simplifiée)

Ajoutons un conteneur PHP pour dynamiser la page web.

### ⚙️ Nouveau `docker-compose.yaml`

```yaml
version: '3.9'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./web:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php

  php:
    image: php:8.2-fpm
    volumes:
      - ./web:/var/www/html

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: compose_db
      MYSQL_USER: user1
      MYSQL_PASSWORD: userpass
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

### 🔧 Créez un fichier `nginx.conf`

```nginx
server {
  listen 80;
  root /var/www/html;
  index index.php index.html;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ \.php$ {
    fastcgi_pass php:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }
}
```

### 🧪 Testez avec un fichier PHP

Créez `web/index.php` :

```php
<?php
$pdo = new PDO('mysql:host=db;dbname=compose_db', 'user1', 'userpass');
echo '<h1>Connexion MySQL réussie via Docker Compose !</h1>';
?>
```

### ▶️ Lancez l’environnement

```bash
docker compose up -d
```

> Vérifiez `http://localhost:8080` → la page doit s’afficher sans erreur.

---

## 5. Bonnes pratiques de sécurité Docker Compose 🔐

### 1️⃣ Ne jamais stocker de mots de passe en clair

Utilisez un fichier `.env` :

```bash
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_USER=user1
MYSQL_PASSWORD=userpass
```

Puis dans `docker-compose.yaml` :

```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```

### 2️⃣ Utiliser des réseaux internes isolés

```yaml
networks:
  backend:
    driver: bridge

services:
  web:
    networks:
      - backend
  php:
    networks:
      - backend
  db:
    networks:
      - backend
```

> Ainsi, les containers ne sont accessibles que via le réseau interne, pas depuis l’hôte.

### 3️⃣ Utiliser des images officielles et vérifier leur intégrité

```bash
docker pull --quiet --disable-content-trust=false mysql:8.0
```

### 4️⃣ Éviter le mode root dans les containers

Ajoutez dans vos Dockerfiles :

```Dockerfile
USER appuser
```

### 5️⃣ Mettre à jour régulièrement vos images et dépendances

```bash
docker compose pull
```

### 6️⃣ Restreindre les permissions des volumes montés

```yaml
volumes:
  - type: bind
    source: ./web
    target: /var/www/html
    read_only: true
```

---

## 6. Utilisation avancée : monitoring et logs

### 📊 Ajout d’un service `adminer` pour gérer MySQL

```yaml
adminer:
  image: adminer:latest
  ports:
    - "8081:8080"
  depends_on:
    - db
```

> Accès via `http://localhost:8081`

### 🧾 Centralisation des logs

```bash
docker compose logs -f web
```

---

## 7. Déploiement d’un stack complet (exercice final)

Créez un environnement complet avec :

* 1 service `backend` en Node.js
* 1 service `frontend` en Nginx
* 1 base de données PostgreSQL
* 1 service `pgadmin`

Chaque service doit :

* Être sur un réseau sécurisé
* Utiliser des variables dans un `.env`
* Avoir des volumes persistants

> 💡 Bonus : ajoutez un `reverse proxy` Traefik pour gérer le HTTPS.

---

## 8. Nettoyage final

```bash
docker compose down -v --remove-orphans
docker system prune -a
```

---

## ✅ Bilan du TP

À la fin de ce TP, vous savez :

* Créer et gérer un environnement multi-conteneurs complet
* Utiliser `depends_on`, `volumes`, `networks` et `.env`
* Sécuriser vos stacks Docker Compose
* Déployer et superviser des applications composées de plusieurs services

> 💡 Prochain TP : *Sécurisation et orchestration avancée avec Docker Swarm et secrets distribués.*
