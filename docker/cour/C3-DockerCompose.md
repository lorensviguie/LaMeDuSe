# 🧩 Cours Docker Compose — Réseaux, Volumes et Communication entre Conteneurs

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 1. Introduction

**Docker Compose** est un outil qui permet de **décrire, configurer et exécuter plusieurs conteneurs** avec un seul fichier YAML : `docker-compose.yml`.

Il est idéal pour les **applications multi-services**, comme une app web + une base de données + un cache.

---

## 2. Installation de Docker Compose

Sur les versions récentes de Docker (>= 20.x), Compose est **déjà inclus** :
```bash
docker compose version
```

Sinon, installez-le manuellement :
```bash
sudo apt install docker-compose
```

---

## 3. Structure d’un fichier `docker-compose.yml`

Exemple basique :
```yaml
version: "3.8"

services:
  web:
    image: nginx
    ports:
      - "8080:80"

  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
```

Lancer le projet :
```bash
docker compose up -d
```

---

## 4. Communication entre conteneurs 🌐

Dans un même fichier Compose, tous les conteneurs sont **automatiquement connectés au même réseau par défaut**.

- Le nom du **service** sert de **DNS** interne.
- Exemple : le conteneur `web` peut accéder au conteneur `db` via l’adresse `db:3306`.

Exemple :
```yaml
services:
  web:
    build: ./app
    environment:
      - DATABASE_HOST=db
      - DATABASE_USER=root
      - DATABASE_PASS=root
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
```

Ici, dans le code Python ou PHP du service `web`, la connexion à la base se fera via `db` (et non `localhost`).

---

## 5. Gestion des réseaux personnalisés 🕸️

Créer un réseau Docker spécifique :
```yaml
version: "3.8"

services:
  app:
    image: php:apache
    networks:
      - front

  db:
    image: mysql
    networks:
      - back

networks:
  front:
  back:
```

- Les services peuvent être **isolés sur différents réseaux**.  
- On peut aussi les **relier à plusieurs réseaux** pour créer des zones de communication contrôlées.

Exemple :
```yaml
services:
  proxy:
    image: nginx
    networks:
      - front
      - back
```

Le conteneur `proxy` agit ici comme une **passerelle** entre les deux réseaux.

---

## 6. Volumes persistants 📦

Les **volumes** permettent de **conserver les données** même après suppression des conteneurs.

### a) Volumes déclarés
```yaml
services:
  db:
    image: mysql
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

Ici, `db_data` est un volume nommé et persistera dans `/var/lib/docker/volumes/`.

### b) Volumes liés à un dossier local
```yaml
services:
  web:
    image: nginx
    volumes:
      - ./site:/usr/share/nginx/html
```

Cela permet de **lier un répertoire local** au conteneur pour le développement en temps réel.

---

## 7. Exemple complet d’application web avec persistance et réseau

```yaml
version: "3.8"

services:
  web:
    build: ./web
    ports:
      - "8080:80"
    depends_on:
      - db
    networks:
      - app_net
    volumes:
      - ./web/html:/usr/share/nginx/html

  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: appdb
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - app_net

networks:
  app_net:

volumes:
  db_data:
```

📌 **Points clés :**
- `depends_on` garantit que `db` démarre avant `web`
- `networks` crée un réseau commun nommé `app_net`
- `volumes` assure la persistance des données MySQL

---

## 8. Commandes utiles 🧠

| Action | Commande |
|--------|-----------|
| Lancer les conteneurs | `docker compose up -d` |
| Arrêter les conteneurs | `docker compose down` |
| Voir les logs | `docker compose logs -f` |
| Lister les services | `docker compose ps` |
| Reconstruire les images | `docker compose build --no-cache` |
| Supprimer tout (conteneurs + volumes + réseau) | `docker compose down -v` |

---

## 9. Réseaux et isolation : explication rapide

Docker Compose crée automatiquement :
- Un **réseau bridge** spécifique au projet
- Une **résolution DNS interne** entre les services

Chaque service peut **voir** les autres via leur nom logique (`db`, `api`, `web`, etc.), sans exposer de ports externes.

👉 Cela permet une **architecture sécurisée et modulaire**, tout en maintenant la **communication interne fluide**.

---

## 10. Bonnes pratiques ✅

1. **Toujours nommer les volumes et réseaux** pour éviter les collisions.
2. **Limiter les ports exposés** : inutile d’exposer `db` si seul `web` doit y accéder.
3. **Séparer les environnements** : `docker-compose.dev.yml`, `docker-compose.prod.yml`.
4. **Utiliser `.env`** pour les mots de passe et variables sensibles.

---

## 🧠 En résumé

| Élément | Rôle |
|----------|------|
| **Service** | Conteneur défini dans le YAML |
| **Réseau** | Communication entre conteneurs |
| **Volume** | Persistance des données |
| **depends_on** | Ordre de démarrage |
| **Docker Compose** | Orchestration simplifiée |

---

> Docker Compose simplifie la gestion d’applications multi-conteneurs, tout en garantissant une isolation claire, une communication interne fiable, et une persistance des données. 🐳
