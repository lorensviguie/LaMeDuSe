# 🐳 TP – Mise en place de son premier conteneur Docker et pull des premières images

## 🎯 Objectif

Se familiariser avec les images Docker, créer et gérer des conteneurs, comprendre la persistance des données et explorer le déploiement d’un service plus complexe comme HashiCorp Vault avec Docker.

Ce TP se déroule sur une machine Linux locale avec Docker installé et fonctionnel.

---

## 🧩 1. Préparation

* Vérifiez que Docker fonctionne correctement (voir TP1).
* Assurez-vous d’avoir un accès à Internet pour télécharger des images.

💡 **Conseil** : notez les commandes que vous utilisez et observez les résultats pour bien comprendre le fonctionnement.

---

## 🧩 2. Découverte et téléchargement d’images Docker

* Choisissez une image simple pour commencer (NGINX, Alpine, etc.)
* Explorez Docker Hub pour comprendre les différentes versions disponibles.
* Téléchargez les images sur votre machine.
* Observez les images locales et leurs tailles.

💡 **Astuce** : cherchez comment lister toutes les images locales et voir leurs détails. Cela aide à comprendre l’impact de chaque image.

---

## 🧩 3. Manipulation d’images

* Supprimez une image pour comprendre comment Docker gère le stockage.
* Créez une nouvelle image à partir d’un conteneur existant pour voir la persistance des modifications.
* Exportez et importez une image pour comprendre les mécanismes de sauvegarde et de transfert.

💡 **Astuce** : observer le comportement de Docker lorsque vous créez, supprimez ou importez des images.

---

## 🧩 4. Création d’un conteneur via la CLI

* Lancez un conteneur NGINX et mappez un port local.
* Explorez le conteneur et testez l’accès via un navigateur.
* Stoppez et supprimez le conteneur pour observer la gestion des processus et des ressources.

💡 **Astuce** : réfléchissez aux options pour lier un port local au conteneur et pour accéder aux fichiers du conteneur.

---

## 🧩 5. Création via Docker Compose

* Créez un fichier YAML pour un service simple (NGINX).
* Définissez les ports et un volume pour les fichiers du site.
* Lancez le service avec Docker Compose et observez la différence avec la CLI.
* Stoppez et nettoyez le service.

💡 **Astuce** : monter un dossier local permet de modifier les fichiers et de voir les changements en temps réel.

---

## 🧩 6. Déploiement de HashiCorp Vault

* Lancez Vault avec un port personnalisé, des variables d’environnement et un volume persistant.
* Vérifiez le container et les volumes.
* Testez le service pour vérifier qu’il fonctionne correctement.

💡 **Astuce** : notez comment Docker gère les volumes pour la persistance des données.

---

## 🧩 7. Persistance des données

* Supprimez le conteneur Vault sans supprimer le volume.
* Recréez le conteneur en utilisant le même volume.
* Observez que les données sont toujours disponibles.

💡 **Astuce** : comprendre cette logique est essentiel pour la gestion des services en production.

---

## 🧩 8. Nettoyage final

* Arrêtez tous les conteneurs.
* Supprimez les conteneurs et volumes pour repartir d’un environnement propre.

💡 **Conseil** : c’est une bonne pratique de nettoyer régulièrement votre environnement pour éviter l’accumulation de conteneurs et volumes inutiles.

---

## ✅ Bilan

Vous avez appris à :

* Découvrir et télécharger des images Docker
* Créer, explorer et supprimer des conteneurs via CLI et Docker Compose
* Utiliser des volumes et variables d’environnement pour la persistance des données
* Déployer un service complexe (Vault) de manière persistante

> 💡 **Prochain TP :** *Introduction à Docker Swarm — Création de cluster et déploiement multi-nœuds*
