# TP8 : Développer proprement dans un environnement Docker

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## Objectifs pédagogiques

À la fin de ce TP, vous serez capable de :

* Développer une application dans un environnement Docker isolé.
* Comprendre le montage des volumes pour le développement en direct.
* Nettoyer efficacement votre environnement.
* Gérer les performances et les gros volumes de données.

---

## 1. Pré-requis

* Docker et Docker Compose installés.
* Un IDE (VSCode, JetBrains, etc.) configuré pour éditer les fichiers locaux.
* Git installé sur votre machine.

---

## 2. Cloner un projet prêt à l’emploi

Choisissez un projet exemple (ex: Flask, Node.js) ou votre propre dépôt.

> 💡 Objectif : identifier comment le projet est structuré et comment Docker y est intégré.

---

## 3. Analyse du `docker-compose.yml`

* Quels services sont définis ?
* Quels ports sont exposés ?
* Quels volumes sont montés pour le développement ?
* Quelles variables d’environnement sont utilisées ?
* Quelle commande est exécutée au démarrage ?

> Recherchez comment ces instructions impactent votre environnement de développement.

---

## 4. Dockerfile de développement

* Comprendre l’importance du `WORKDIR`, du `COPY` et de l’installation des dépendances.
* Tester comment les modifications dans le code sont visibles dans le conteneur.
* Étudier l’impact des `CMD` et `ENTRYPOINT` sur le démarrage du conteneur.

---

## 5. Lancer l’environnement de développement

* Cherchez la commande pour construire l’image et démarrer les services.
* Vérifiez que les changements de code sont reflétés immédiatement grâce aux volumes montés.
* Accédez à votre application dans un navigateur pour tester son fonctionnement.

---

## 6. Travailler avec son IDE

* Explorez comment lier votre projet local à un conteneur Docker pour éditer le code en direct.
* Testez les modifications et observez leur effet sans reconstruire l’image à chaque fois.

---

## 7. Redéploiement après modification majeure

* Étudiez quand il est nécessaire de reconstruire l’image (ex: ajout de nouvelles dépendances).
* Recherchez les commandes pour arrêter et relancer un service avec reconstruction.

---

## 8. Gestion des volumes et nettoyage

* Identifier les volumes utilisés par vos services.
* Trouvez comment nettoyer les conteneurs, images et volumes inutilisés.
* Recherchez comment supprimer uniquement les volumes spécifiques ou massifs.

---

## 9. Automatisation du redéploiement

* Étudiez comment détecter les changements de fichiers pour redémarrer automatiquement un conteneur.
* Explorez les scripts ou outils qui permettent le live reload dans Docker.

---

## 10. Bonnes pratiques pour un dev propre

1. Utiliser des fichiers `.dockerignore` pour éviter de copier les fichiers inutiles.
2. Toujours nommer vos volumes pour faciliter le nettoyage.
3. Ne pas coder directement dans le conteneur.
4. Automatiser les rebuilds avec un script ou un outil dédié.
5. Nettoyer régulièrement votre environnement pour éviter l’accumulation de conteneurs et volumes orphelins.

---

## 11. Exercice pratique

1. Créez un petit projet local (Flask, Node.js…).
2. Écrivez votre `Dockerfile` et `docker-compose.yml`.
3. Montez le code source avec un volume local.
4. Modifiez le code depuis votre IDE et observez le comportement.
5. Testez le nettoyage de votre environnement et notez ce qui est supprimé.

---

## 🧩 Pour aller plus loin

* Intégrer un outil de **live reload** pour accélérer le développement.
* Utiliser **Docker Compose profiles** pour différencier dev/staging/prod.
* Gérer les logs et les erreurs via **volumes montés**.
* Créer un script de **backup automatique** avant un nettoyage massif.

---

### 🕓 Durée estimée : 3 à 4 heures
