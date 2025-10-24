# 🐳 TP – Mise en place de son premier conteneur Docker

## 🎯 Objectif

Découvrir et manipuler vos premières images Docker, créer et exécuter vos premiers conteneurs, et comprendre le rôle des volumes et des variables d'environnement.
Ce TP est prévu pour un environnement Linux local avec Docker déjà installé.

---

## 🧩 1. Pull et exploration des images

Avant de lancer un conteneur, il faut récupérer une image Docker.

* Choisissez une image simple pour commencer (ex : `nginx`, `alpine`).
* Observez comment les images sont stockées localement.
* Explorez leurs couches et tailles.

💡 **Conseil** : cherchez la commande permettant de lister toutes les images locales et de voir leurs détails. C’est une bonne habitude pour comprendre l’impact de chaque image sur votre disque.

---

## 🧩 2. Créer un conteneur depuis la ligne de commande

* Lancez un conteneur simple avec une image téléchargée.
* Testez l'accès au service à l'intérieur du conteneur (ex : serveur web NGINX).
* Notez comment Docker expose le port et ce que vous devez faire pour y accéder depuis votre machine.

💡 **Astuce** : réfléchissez aux options pour lier un port de votre machine au port interne du conteneur.

---

## 🧩 3. Créer un conteneur via fichier YAML (docker-compose)

* Créez un fichier `docker-compose.yml` minimal pour le service choisi.
* Définissez les ports, volumes et éventuellement quelques variables d’environnement.
* Lancer le conteneur via `docker compose up`.
* Observez la différence avec un conteneur lancé à la main.

💡 **Astuce** : vous pouvez monter un dossier local dans le conteneur pour éditer les fichiers directement et voir le résultat immédiatement.

---

## 🧩 4. Déployer un service avec volumes et variables d’environnement

* Choisissez une image un peu plus complexe (ex : HashiCorp Vault).
* Lancez le conteneur en configurant :

  * Les ports exposés
  * Un volume pour la persistance des données
  * Des variables d’environnement nécessaires à l’application
* Vérifiez que le service fonctionne et que les données persistent après un redémarrage.

💡 **Astuce** : essayez de changer le port exposé et observez comment Docker gère cette modification.

---

## 🧩 5. Recréer un conteneur avec les données existantes

* Supprimez le conteneur et recréez-le à partir de la même image, en utilisant le même volume.
* Vérifiez que toutes vos données et configurations sont toujours disponibles.
* Notez le comportement de Docker par rapport aux volumes persistants.

💡 **Astuce** : comprendre cette logique est crucial pour les mises à jour de conteneurs en production.

---

## 🧰 6. Vérifications finales

| Test                      | Observation attendue                                          |
| ------------------------- | ------------------------------------------------------------- |
| L’image est téléchargée   | Liste des images locales montre l’image pullée                |
| Conteneur fonctionne      | Accès au service exposé (ex: NGINX sur votre port local)      |
| Variables d’environnement | Le conteneur utilise correctement les variables définies      |
| Volume persistant         | Les données restent après suppression/recréation du conteneur |
| docker-compose            | Le conteneur se lance correctement via YAML                   |

---

## 🚀 7. Étape suivante

Vous êtes prêt à :

* Créer vos propres images Docker (TP suivant)
* Explorer Docker Compose plus en profondeur
* Automatiser vos déploiements et préparer votre environnement CI/CD

> 💡 **Conseil :** prenez le temps de noter vos observations et les commandes utiles pour construire vos prochains TP Docker.
