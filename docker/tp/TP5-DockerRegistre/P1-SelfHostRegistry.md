# 🐳 TP – Créer son propre registre Docker privé

## 🎯 Objectif

Mettre en place un **Docker Registry privé** sur votre machine locale, apprendre à y stocker et récupérer vos propres images, sans dépendre de Docker Hub.
Ce TP se fait entièrement sur un environnement Linux local avec Docker déjà installé.

---

## 🧩 1. Pré-requis

Avant de commencer, assurez-vous que :

* Docker est installé et fonctionne
* Vous connaissez les bases : `docker pull`, `docker run`, `docker tag`, `docker push`, `docker pull`
* Vous avez un terminal ouvert sur votre machine locale

---

## 🧱 2. Lancer un registre Docker privé

Docker fournit une image officielle `registry` pour créer facilement un registre local.

🌞 **Objectif** : créer un conteneur Registry sur le port 5000

> Remarque : le port 5000 est standard pour un registre local, mais vous pouvez le changer si nécessaire.

* Observez comment Docker expose les ports et détache le conteneur pour qu’il tourne en arrière-plan
* Vérifiez le fonctionnement après le lancement

💡 **Question à se poser** : pourquoi utiliser un registre privé plutôt que Docker Hub ?

> Réponse : sécurité, contrôle local, tests sans push sur un registre public

---

## 🧩 3. Taguer une image pour le registre local

Prenons l’image `alpine` comme exemple.

* Puller l’image depuis Docker Hub si nécessaire
* Apprendre à **taguer une image** pour qu’elle corresponde à votre registre local

💡 **Astuce** : le tag doit inclure l’adresse et le port du registre (`localhost:5000/alpine`) pour que Docker sache où la pousser.

---

## 🧱 4. Pousser l’image dans le registre

* Le `docker push` enverra l’image vers votre registre privé
* Observez la sortie et notez le temps nécessaire pour transférer l’image
* Vérifiez ensuite la présence de l’image dans le registre

💡 **Question** : que se passe-t-il si vous poussez plusieurs fois la même image ?

> Réponse : Docker ne renvoie que les couches modifiées, donc c’est rapide et efficace

---

## 🔍 5. Récupérer une image depuis le registre local

* Supprimez l’image locale pour tester le pull
* Lancez `docker pull localhost:5000/alpine`
* Vérifiez que le conteneur fonctionne comme prévu

💡 **Astuce** : cette étape montre que votre registre local est pleinement fonctionnel, même si vous n’êtes pas connecté à Internet

---

## 🧾 6. Vérifier le contenu du registre

* Pour un TP simple, utilisez `curl` pour lister les images :

```bash
curl http://localhost:5000/v2/_catalog
```

* Vous devriez voir `alpine` dans la liste

> Optionnel : vous pouvez explorer des interfaces web comme **Portus** ou **Docker Registry UI**, mais ce TP reste centré sur la CLI

---

## 🧹 7. Nettoyer le registre

* Arrêtez et supprimez le conteneur du registre

```bash
docker stop registry
docker rm registry
```

💡 **Conseil** : supprimez aussi les volumes ou images locales si vous voulez repartir d’un environnement propre

---

## ✅ 8. Bilan du TP

À la fin de ce TP, vous savez :

* Lancer un registre Docker privé sur votre machine
* Taguer vos images pour un registre local
* Pousser et récupérer des images depuis votre propre registre
* Vérifier le contenu du registre et nettoyer votre environnement

> 💡 Prochain TP : *Automatisation des déploiements multi-conteneurs avec Docker Compose et bonnes pratiques de sécurité*
