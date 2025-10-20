# 🧱 Créer sa propre image Docker

## 1. Introduction

Une **image Docker** est un modèle immuable qui contient tout le nécessaire pour exécuter une application :  
➡️ Système de base (ex : Debian, Alpine, Ubuntu)  
➡️ Fichiers de l’application  
➡️ Dépendances et configurations  
➡️ Commande de lancement

Les images servent à créer des **conteneurs**, qui sont des instances exécutables de ces images.

---

## 2. Structure d’une image

Chaque image est composée de **couches (layers)**.  
Chaque instruction dans le fichier `Dockerfile` crée une nouvelle couche.

Exemple :  
```Dockerfile
FROM ubuntu:22.04
RUN apt update && apt install -y nginx
COPY index.html /var/www/html/
CMD ["nginx", "-g", "daemon off;"]
```

Cette image aura :
- Une couche Ubuntu
- Une couche avec Nginx installé
- Une couche avec `index.html` copié
- Une commande de démarrage

---

## 3. Créer un `Dockerfile`

Le fichier `Dockerfile` décrit **comment construire** une image.

Exemple simple :
```Dockerfile
# Étape 1 : Image de base
FROM python:3.11-slim

# Étape 2 : Définir le dossier de travail
WORKDIR /app

# Étape 3 : Copier les fichiers de l'application
COPY . .

# Étape 4 : Installer les dépendances
RUN pip install -r requirements.txt

# Étape 5 : Commande de démarrage
CMD ["python", "app.py"]
```

---

## 4. Construire l’image

Pour construire l’image à partir du Dockerfile :
```bash
docker build -t monapp:1.0 .
```

- `-t monapp:1.0` : nom et version de l’image
- `.` : chemin vers le dossier contenant le `Dockerfile`

Vérifier la création :
```bash
docker images
```

---

## 5. Lancer un conteneur depuis l’image

```bash
docker run -d -p 5000:5000 monapp:1.0
```

- `-d` : détaché (en arrière-plan)
- `-p` : redirige le port 5000 du conteneur vers le port 5000 de l’hôte

Tester dans un navigateur : [http://localhost:5000](http://localhost:5000)

---

## 6. Optimiser son image

### a) Utiliser une image de base légère
Ex : `python:3.11-alpine` au lieu de `python:3.11`

### b) Nettoyer les caches après installation
```Dockerfile
RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*
```

### c) Multistage build (pour réduire la taille finale)
```Dockerfile
FROM golang:1.22 AS builder
WORKDIR /src
COPY . .
RUN go build -o app

FROM alpine:latest
COPY --from=builder /src/app /app
CMD ["/app"]
```

---

## 7. Ajouter des métadonnées

Bonnes pratiques : documenter l’image avec des **labels**.

```Dockerfile
LABEL maintainer="admin@example.com"
LABEL version="1.0"
LABEL description="Application web Python Flask"
```

---

## 8. Publier son image sur Docker Hub

1. Créer un compte sur [https://hub.docker.com](https://hub.docker.com)
2. Se connecter :
   ```bash
   docker login
   ```
3. Renommer l’image :
   ```bash
   docker tag monapp:1.0 monutilisateur/monapp:1.0
   ```
4. Pousser sur Docker Hub :
   ```bash
   docker push monutilisateur/monapp:1.0
   ```

---

## 9. Résumé des commandes clés

| Action | Commande |
|--------|-----------|
| Créer l’image | `docker build -t monapp .` |
| Lister les images | `docker images` |
| Lancer le conteneur | `docker run -d -p 8080:80 monapp` |
| Supprimer une image | `docker rmi monapp` |
| Pousser sur Docker Hub | `docker push user/monapp` |

---

## 🧠 En résumé
Créer sa propre image Docker, c’est :
1. Définir un `Dockerfile`
2. Construire l’image (`docker build`)
3. Lancer et tester le conteneur
4. Optimiser et publier si besoin

Une fois maîtrisée, cette compétence te permet de **packager n’importe quelle application** dans un environnement contrôlé et portable. 🐳
