# 🚀 Cours Docker — Introduction Synthétique

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 1. Installation de Docker

### 1.1 Sur Windows (pour les débutants)
1. Télécharger **Docker Desktop** : [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Lancer l’installeur et suivre les étapes.
3. Activer **WSL2** (Windows Subsystem for Linux) si demandé.
4. Vérifier l’installation :  
   ```bash
   docker --version
   ```

### 1.2 Sur Linux (pour les experts 🐐)
```bash
sudo apt update && sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
docker --version
```

---

## 2. Docker, c’est quoi ?
Docker est une **plateforme de virtualisation légère** qui permet d’exécuter des applications dans des **conteneurs isolés** partageant le même noyau Linux.

Un conteneur = une mini machine **autonome**, rapide à lancer, basée sur une **image**.

---

## 3. À quoi sert Docker ?
- Déployer des applications **rapidement et partout**
- Garantir un **environnement identique** entre développement et production
- Simplifier la **gestion des dépendances**
- Automatiser les **tests, CI/CD et microservices**

---

## 4. Notion d’Image Docker 🧱
Une **image** est un modèle figé contenant tout ce qu’il faut pour exécuter un conteneur :
- Système de base (ex: Alpine, Debian…)
- Dépendances, librairies, configuration
- Application à lancer

Commandes clés :
```bash
docker pull nginx        # Télécharge une image
docker images            # Liste les images
docker rmi <image>       # Supprime une image
```

---

## 5. Notion de Volume 📦
Les **volumes** permettent de **stocker les données de manière persistante**, même si le conteneur est supprimé.

```bash
docker volume create data
docker run -v data:/app/data nginx
docker volume ls
```

---

## 6. Créer son premier conteneur 🐳
```bash
docker run -d -p 8080:80 nginx
docker ps
docker exec -it <id> bash
docker stop <id>
docker rm <id>
```

---

## 7. Créer sa propre image ⚙️

Fichier `Dockerfile` :
```Dockerfile
FROM ubuntu:22.04
RUN apt update && apt install -y nginx
CMD ["nginx", "-g", "daemon off;"]
```

Construire et exécuter :
```bash
docker build -t monserveur .
docker run -d -p 8080:80 monserveur
```

---

## 8. Docker Compose 🧩
Permet de **décrire et lancer plusieurs conteneurs** avec un seul fichier YAML.

Exemple `docker-compose.yml` :
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

Lancer :
```bash
docker compose up -d
```

---

## 9. Comment fonctionne Docker ? ⚙️

Docker repose sur :
- Le **même noyau Linux** que l’hôte
- Des **espaces de noms (namespaces)** pour isoler les processus
- Des **cgroups** pour limiter les ressources
- Un **démon Docker** (`dockerd`) qui gère les conteneurs

Ainsi, plusieurs conteneurs tournent **en parallèle** sur le même serveur, sans virtualisation complète.

---

### 🧠 En résumé :
| Concept | Description rapide |
|----------|--------------------|
| **Image** | Modèle d’application |
| **Conteneur** | Instance d’une image |
| **Volume** | Stockage persistant |
| **Compose** | Orchestre plusieurs conteneurs |
| **Avantage clé** | Isolation + Portabilité + Rapidité |

---

> Docker simplifie la vie des développeurs, des DevOps, et des administrateurs système.  
> Une fois maîtrisé, il devient un **outil incontournable** du monde moderne.
