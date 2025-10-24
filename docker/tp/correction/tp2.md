# TP2 : Mise en place de son premier container et pull de ses premières images

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## Objectifs du TP
Ce TP a pour but de vous familiariser avec la manipulation des **images Docker**, la **création de containers**, et la **persistance des données**. Vous découvrirez également comment déployer un service plus avancé (HashiCorp Vault) en utilisant des volumes, des variables d'environnement et un port personnalisé.

---

## 1. Prérequis
- Docker doit être installé et fonctionnel (voir TP1 : Setup de son environnement Docker)
- Accès à internet pour le téléchargement des images Docker

---

## 2. Découverte et pull des premières images

### 🔍 Rechercher une image sur Docker Hub
Docker Hub est la plateforme principale pour récupérer des images officielles.
```bash
docker search nginx
docker search vault
```

### 📥 Télécharger une image
```bash
docker pull nginx:latest
docker pull vault:latest
```

### 🔎 Vérifier les images téléchargées
```bash
docker images
```

> Vous devriez voir les images `nginx` et `vault` dans la liste.

---

## 3. Manipulation des images Docker

### 🧱 Supprimer une image
```bash
docker rmi nginx:latest
```

### 🧩 Créer une image depuis un container
```bash
docker commit <container_id> monimage:1.0
```

### 📤 Exporter et importer une image
```bash
docker save -o monimage.tar monimage:1.0
docker load -i monimage.tar
```

---

## 4. Création de son premier container (via commande)

### 🚀 Lancer un container NGINX
```bash
docker run -d --name monnginx -p 8080:80 nginx:latest
```

- `-d` : mode détaché
- `--name` : nom du container
- `-p` : mappe le port 8080 local vers le port 80 du container

### 🧭 Vérifier le fonctionnement
```bash
docker ps
docker exec -it monnginx bash
```

> Ouvrez votre navigateur et accédez à `http://localhost:8080`

### 🛑 Stopper et supprimer le container
```bash
docker stop monnginx
docker rm monnginx
```

---

## 5. Création via un fichier YAML (docker-compose)

Créez un fichier `nginx.yaml` :
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./site:/usr/share/nginx/html
```

### ▶️ Démarrer le service
```bash
docker compose -f nginx.yaml up -d
```

### ⏹️ Stopper et nettoyer
```bash
docker compose -f nginx.yaml down
```

---

## 6. Déploiement de HashiCorp Vault

### 🧱 Lancer Vault avec un port personnalisé et un volume persistant
```bash
docker run -d \
  --name vault \
  -p 8201:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=root' \
  -v vault-data:/vault/data \
  vault:latest
```

- `-p 8201:8200` : changement du port d'exposition (accès via `http://localhost:8201`)
- `-e` : définition d'une variable d'environnement
- `-v` : création d’un volume persistant nommé `vault-data`

### 🔍 Vérifier le container et les volumes
```bash
docker ps
docker volume ls
```

### 🧠 Tester Vault
```bash
curl http://localhost:8201/v1/sys/health
```

---

## 7. Persistance des données Vault

### 🧹 Supprimer le container sans supprimer le volume
```bash
docker rm -f vault
```

### 🔁 Recréer le container en réutilisant le même volume
```bash
docker run -d \
  --name vault \
  -p 8201:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=root' \
  -v vault-data:/vault/data \
  vault:latest
```

> ⚙️ Vous constaterez que les données de Vault sont toujours présentes grâce au volume persistant.

---

## 8. Nettoyage final

Pour libérer l’espace et repartir d’un environnement propre :
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume rm $(docker volume ls -q)
```

---

## ✅ Bilan du TP
À l’issue de ce TP, vous avez appris à :
- Télécharger et manipuler des images Docker
- Créer et supprimer des containers via la CLI et des fichiers YAML
- Gérer les volumes et variables d’environnement
- Déployer un service complexe (Vault) de manière persistante

---

> 💡 Prochain TP : *Introduction à Docker Swarm — Création de cluster et déploiement multi-nœuds*

