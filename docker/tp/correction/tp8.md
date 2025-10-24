# TP7 : Développer proprement dans un environnement Docker

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## Objectifs pédagogiques

À la fin de ce TP, vous serez capable de :

* Développer une application dans un environnement Docker isolé.
* Comprendre le montage des volumes pour le développement en direct.
* Nettoyer efficacement votre environnement avec `docker system prune`.
* Gérer les performances et les gros volumes de données.

---

## 1. Pré-requis

* Docker et Docker Compose installés.
* Un IDE (VSCode, JetBrains, etc.) configuré pour éditer les fichiers locaux.
* Git installé sur votre machine.

---

## 2. Cloner un projet prêt à l’emploi

Nous allons utiliser un projet d’exemple basé sur **Flask (Python)**.

```bash
git clone https://github.com/docker/example-voting-app.git
cd example-voting-app
```

> 💡 Vous pouvez aussi utiliser votre propre dépôt personnel contenant un `docker-compose.yml`.

---

## 3. Analyse du `docker-compose.yml`

Un fichier `docker-compose.yml` typique pour le développement ressemble à ceci :

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./app:/usr/src/app
    environment:
      - FLASK_ENV=development
    command: flask run --host=0.0.0.0
```

### Explications

* **build:** crée une image à partir du `Dockerfile` local.
* **ports:** expose le port 5000 du conteneur.
* **volumes:** monte le dossier local `./app` dans le conteneur.
* **environment:** configure l’environnement de développement.
* **command:** lance Flask en mode dev.

---

## 4. Création du Dockerfile de développement

Exemple de `Dockerfile` :

```Dockerfile
FROM python:3.11-slim
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["flask", "run", "--host=0.0.0.0"]
```

---

## 5. Lancer l’environnement de développement

```bash
docker compose up --build
```

> Après chaque modification de code dans le dossier `./app`, le changement est immédiatement visible dans le conteneur.

Accédez à votre application :

```
http://localhost:5000
```

---

## 6. Travailler avec son IDE

### Exemple avec VSCode

* Ouvrez le dossier du projet (`File > Open Folder`).
* Modifiez les fichiers dans `./app`.
* Enregistrez et observez les changements sans redéployer.

### Exemple avec JetBrains (PyCharm / IntelliJ)

* Configurez un interpréteur Docker dans les paramètres du projet.
* Liez le dossier `app` pour l’édition directe.

---

## 7. Redéploiement après modification majeure

Si vous modifiez les dépendances (ex: `requirements.txt`), reconstruisez l’image :

```bash
docker compose down
docker compose up --build -d
```

---

## 8. Gestion des volumes et nettoyage

### 8.1 Supprimer les conteneurs, images et volumes inutilisés

```bash
docker system prune -a --volumes
```

> ⚠️ Attention : cette commande supprime **tous les conteneurs arrêtés**, **images non utilisées** et **volumes orphelins**.

### 8.2 Supprimer uniquement les volumes massifs

```bash
docker volume prune
```

### 8.3 Supprimer un volume spécifique

```bash
docker volume rm <nom_du_volume>
```

---

## 9. Astuce : automatiser le redéploiement en développement

Ajoutez un script `watch.sh` :

```bash
#!/bin/bash
while inotifywait -r -e modify,create,delete ./app; do
  docker compose restart web
done
```

Rendez-le exécutable :

```bash
chmod +x watch.sh
```

Puis lancez-le :

```bash
./watch.sh
```

---

## 10. Bonnes pratiques pour un dev propre

1. **Utiliser des fichiers `.dockerignore`** pour éviter de copier les fichiers inutiles (logs, venv, etc.).
2. **Toujours nommer vos volumes** pour faciliter le nettoyage.
3. **Ne pas coder directement dans le conteneur.**
4. **Automatiser les rebuilds** avec un script ou un outil comme `docker-compose watch`.
5. **Nettoyer régulièrement votre environnement** avec `docker system prune`.

---

## 11. Exercice pratique

1. Créez un petit projet Flask (ou Node.js) local.
2. Écrivez votre `Dockerfile` et `docker-compose.yml`.
3. Montez le code source avec un volume local.
4. Modifiez le code depuis votre IDE et observez le comportement.
5. Faites un `docker system prune` et vérifiez ce qui est supprimé.

---

## 🧩 Pour aller plus loin

* Intégrer un outil de **live reload** (comme `Flask --reload` ou `nodemon`).
* Utiliser **Docker Compose profiles** pour différencier dev/staging/prod.
* Gérer les logs et les erreurs via **volumes montés**.
* Créer un script de **backup automatique** avant un `prune` massif.

---

### 🕓 Durée estimée : 3 à 4 heures
