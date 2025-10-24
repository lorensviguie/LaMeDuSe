# 🐳 TP – Création et gestion de vos propres images Docker

## 🎯 Objectif

Découvrir comment créer vos propres images Docker, comprendre la structure d’un Dockerfile, gérer les couches et optimiser vos images pour un usage local.
Ce TP se déroule sur une machine Linux avec Docker déjà installé.

---

## 🧩 1. Comprendre les images Docker

* Une image Docker est composée de **couches** qui s’empilent.
* Chaque commande dans un Dockerfile crée une nouvelle couche.
* Plus il y a de couches, plus l’image peut devenir volumineuse.

💡 **Conseil** : explorez vos images locales et observez les tailles et couches pour comprendre l’impact de chaque modification.

---

## 🧩 2. Création d’un Dockerfile simple

* Choisissez une image de base (par exemple `alpine` ou `debian`).
* Définissez :

  * Le mainteneur de l’image
  * Les commandes à exécuter (installation de paquets, création de fichiers, scripts)
* Comprenez le rôle de chaque instruction (`FROM`, `RUN`, `COPY`, `CMD`).

💡 **Astuce** : construisez le Dockerfile étape par étape pour observer les changements entre chaque couche.

---

## 🧩 3. Construire et tester l’image

* Construisez l’image depuis votre Dockerfile.
* Lancez un conteneur basé sur cette image.
* Vérifiez que tous les fichiers et installations sont présents à l’intérieur du conteneur.

💡 **Astuce** : testez différentes instructions `CMD` et `ENTRYPOINT` pour comprendre leur effet sur le conteneur.

---

## 🧩 4. Optimiser l’image

* Fusionnez plusieurs commandes `RUN` en une seule pour réduire le nombre de couches.
* Supprimez les fichiers temporaires ou caches inutiles.
* Comparez la taille de l’image avant et après optimisation.

💡 **Astuce** : une image légère est plus rapide à déployer et moins coûteuse en stockage.

---

## 🧩 5. Versionner et taguer l’image

* Donnez un **nom et un tag** à votre image.
* Modifiez le contenu, reconstruisez l’image avec un nouveau tag et observez le comportement du cache Docker.
* Notez comment Docker réutilise les couches inchangées.

💡 **Astuce** : le versionnage facilite le déploiement et le suivi des évolutions.

---

## 🧰 6. Vérifications finales

| Test                 | Observation attendue                               |
| -------------------- | -------------------------------------------------- |
| Dockerfile valide    | Image construite sans erreur                       |
| Conteneur fonctionne | Le service ou script prévu fonctionne correctement |
| Optimisation         | Taille réduite après consolidation des couches     |
| Tag et version       | Plusieurs tags coexistent sans conflit             |
| Exploration          | Tous les fichiers et paquets sont présents         |

---

## 🚀 7. Étape suivante

Vous êtes prêt à :

* Déployer plusieurs conteneurs via Docker Compose
* Tester vos images dans différents environnements
* Automatiser la construction d’images dans une pipeline CI/CD

> 💡 **Conseil :** gardez vos bonnes pratiques à l’esprit et optimisez vos Dockerfiles pour gagner du temps dans les TP suivants.
