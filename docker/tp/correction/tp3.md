# TP3 : Créer sa propre image Docker

## 🎯 Objectifs du TP

Ce TP a pour but de vous apprendre à **créer vos propres images Docker** à partir de zéro. Vous allez comprendre le rôle du `Dockerfile`, la logique des couches (layers), la gestion des dépendances, et la personnalisation d’images pour vos besoins. À la fin, vous publierez votre image sur Docker Hub.

Durée estimée : **3 à 4 heures**

---

## 1. Prérequis

* Docker installé et fonctionnel (TP1)
* Avoir un compte Docker Hub ([https://hub.docker.com](https://hub.docker.com))
* Notions de base en Linux (édition de fichiers, permissions, etc.)

---

## 2. Introduction au concept d'image Docker

Une **image Docker** est une *recette figée* décrivant un environnement logiciel complet. Elle contient :

* Un système de base (ex : `alpine`, `ubuntu`)
* Des dépendances et librairies
* Des configurations
* Une commande par défaut à exécuter (`CMD`)

Les images sont créées à partir d’un fichier nommé **`Dockerfile`**.

---

## 3. Création de son premier Dockerfile

### 🧱 Étape 1 : Structure du projet

Créez un dossier de travail :

```bash
mkdir ~/tp3_docker_image
cd ~/tp3_docker_image
```

### 🧾 Étape 2 : Créez un fichier `Dockerfile`

```Dockerfile
# Utilisation d'une image de base
FROM ubuntu:22.04

# Informations sur le créateur
LABEL maintainer="etudiant@ynov.local"

# Mise à jour du système et installation de packages
RUN apt update && apt install -y nginx curl vim && apt clean

# Copie d’un fichier HTML dans le répertoire web
COPY index.html /var/www/html/index.html

# Exposition du port
EXPOSE 80

# Commande de démarrage
CMD ["nginx", "-g", "daemon off;"]
```

### 🧾 Étape 3 : Créez le fichier `index.html`

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Mon premier serveur Docker</title>
  </head>
  <body>
    <h1>Bienvenue sur mon NGINX Dockerisé 🚀</h1>
  </body>
</html>
```

---

## 4. Construction et test de l’image

### ⚙️ Construire l’image

```bash
docker build -t monnginx:1.0 .
```

### 🔍 Vérifier qu’elle existe

```bash
docker images
```

### 🚀 Lancer un container depuis cette image

```bash
docker run -d --name web -p 8080:80 monnginx:1.0
```

### 🧭 Vérifier le fonctionnement

Accédez à [http://localhost:8080](http://localhost:8080)

---

## 5. Ajout d’un script personnalisé

### 🧾 Étape 1 : Créez un script de test

Fichier `test_script.sh` :

```bash
#!/bin/bash
echo "Bienvenue dans mon container personnalisé !"
echo "Date actuelle : $(date)"
```

Rendez-le exécutable :

```bash
chmod +x test_script.sh
```

### 🧾 Étape 2 : Modifiez le Dockerfile

```Dockerfile
FROM ubuntu:22.04
LABEL maintainer="etudiant@ynov.local"
RUN apt update && apt install -y nginx curl vim && apt clean
COPY index.html /var/www/html/index.html
COPY test_script.sh /usr/local/bin/test_script.sh
RUN chmod +x /usr/local/bin/test_script.sh
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/test_script.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

### ⚙️ Reconstruction

```bash
docker build -t monnginx:2.0 .
```

### 🧭 Test

```bash
docker run monnginx:2.0
```

Vous devriez voir le message du script s’afficher avant que le serveur NGINX démarre.

---

## 6. Gestion des variables d’environnement

Ajoutons une variable personnalisée :

```Dockerfile
ENV SITE_NAME="Mon Site Dockerisé"
CMD ["/bin/bash", "-c", "echo Bienvenue sur $SITE_NAME && nginx -g 'daemon off;' "]
```

Rebuild et test :

```bash
docker build -t monnginx:3.0 .
docker run -d -p 8081:80 monnginx:3.0
```

> Essayez de changer la variable au lancement :

```bash
docker run -d -p 8082:80 -e SITE_NAME="Super Serveur NGINX" monnginx:3.0
```

---

## 7. Optimisation avec une image plus légère (multi-stage build)

Exemple : construction d’une application Go avant de copier le binaire dans une image `alpine`.

```Dockerfile
# Étape 1 : build
FROM golang:1.22 AS builder
WORKDIR /app
COPY main.go .
RUN go build -o myapp main.go

# Étape 2 : image finale
FROM alpine:latest
COPY --from=builder /app/myapp /usr/local/bin/myapp
CMD ["myapp"]
```

### Exemple de code `main.go`

```go
package main
import "fmt"
func main() {
  fmt.Println("Hello depuis mon image multi-stage!")
}
```

Build et test :

```bash
docker build -t goapp:1.0 .
docker run goapp:1.0
```

---

## 8. Publier son image sur Docker Hub

### 🔐 Connexion

```bash
docker login
```

### 🏷️ Taguer votre image

```bash
docker tag monnginx:3.0 votrelogin/monnginx:3.0
```

### 🚀 Push sur Docker Hub

```bash
docker push votrelogin/monnginx:3.0
```

> Vérifiez sur [hub.docker.com](https://hub.docker.com) que votre image est bien publiée.

---

## 9. Nettoyage

```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -q)
```

---

## ✅ Bilan du TP

À l’issue de ce TP, vous savez désormais :

* Créer un `Dockerfile` à partir d’une image de base
* Ajouter vos fichiers, scripts et configurations
* Utiliser des variables d’environnement et des volumes
* Créer des builds multi-étapes optimisées
* Publier votre image sur Docker Hub

> 💡 Prochain TP : *Création de stacks complètes avec Docker Compose et services interconnectés (Base de données, API, Web).*
