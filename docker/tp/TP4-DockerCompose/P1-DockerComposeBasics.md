# 🐳 TP – Docker Compose : Automatiser et sécuriser ses déploiements multi-conteneurs

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Découvrir comment orchestrer plusieurs containers avec Docker Compose dans un environnement Linux local. Vous apprendrez à définir des services, volumes et réseaux, gérer les dépendances entre containers et appliquer les bonnes pratiques de sécurité.
Durée estimée : 4 heures

---

## 🧩 1. Prérequis

* Docker et Docker Compose installés (version ≥ 2.0)
* Connaissances de base sur les containers et images (TP2 et TP3)
* Savoir naviguer dans un terminal Linux

---

## 🧩 2. Introduction à Docker Compose

Docker Compose permet de **définir, configurer et exécuter des applications multi-conteneurs** avec un seul fichier YAML. Ce fichier décrit :

* Les **services** (containers)
* Les **volumes** (stockage persistant)
* Les **réseaux** (communication entre services)

**Avantages :**

* Un seul fichier pour tout le déploiement
* Gestion simplifiée des dépendances entre services
* Reproductibilité et portabilité

---

## 🧩 3. Premier projet Compose : Web + Base de données

### Structure du projet

* Créez votre dossier projet :

```
mkdir ~/tp4_docker_compose
cd ~/tp4_docker_compose
mkdir web db
```

* Créez un fichier `docker-compose.yaml` décrivant vos services Nginx et MySQL.
* Créez un fichier HTML simple dans `web/index.html`.
* Lancez le stack avec `docker compose up -d` et vérifiez que `http://localhost:8080` fonctionne.

> Observez le rôle des volumes et du `depends_on`.

---

## 🧩 4. Ajouter un service PHP (stack simplifiée)

* Ajoutez un service PHP-FPM pour dynamiser votre page.
* Mettez à jour `docker-compose.yaml` et configurez Nginx pour utiliser PHP.
* Testez avec un fichier `index.php` qui se connecte à la base MySQL.
* Vérifiez le fonctionnement dans votre navigateur.

> Comprenez comment les services interagissent sur le même réseau interne.

---

## 🧩 5. Bonnes pratiques de sécurité Docker Compose 🔐

1. Ne jamais stocker de mots de passe en clair, utilisez un fichier `.env`
2. Créez des réseaux internes isolés pour les containers
3. Utilisez des images officielles et vérifiez leur intégrité
4. Évitez le mode root dans vos containers
5. Mettez à jour régulièrement vos images et dépendances
6. Restreignez les permissions des volumes montés

> Chaque bonne pratique protège votre environnement et facilite la maintenance.

---

## 🧩 6. Utilisation avancée : monitoring et logs

* Ajoutez un service `adminer` pour gérer MySQL depuis un navigateur.
* Centralisez et suivez les logs avec `docker compose logs -f <service>`

> Permet de diagnostiquer rapidement les erreurs et de superviser vos containers.

---

## 🧩 7. Déploiement d’un stack complet (exercice final)

* Créez un environnement complet avec :

  * Service backend (Node.js)
  * Service frontend (Nginx)
  * Base de données PostgreSQL
  * Service pgAdmin
* Chaque service doit :

  * Être sur un réseau sécurisé
  * Utiliser des variables depuis un fichier `.env`
  * Avoir des volumes persistants

> Bonus : ajoutez un reverse-proxy Traefik pour gérer le HTTPS et simplifier le routage.

---

## 🧩 8. Nettoyage final

* Supprimez les containers, volumes et ressources orphelines :

```
docker compose down -v --remove-orphans
docker system prune -a
```

> Cela permet de repartir sur un environnement propre.

---

## ✅ Bilan du TP

À la fin de ce TP, vous savez :

* Créer et gérer un environnement multi-conteneurs
* Utiliser `depends_on`, `volumes`, `networks` et `.env`
* Sécuriser vos stacks Docker Compose
* Déployer et superviser des applications avec plusieurs services

> 💡 Prochain TP : *Sécurisation et orchestration avancée avec Docker Swarm et secrets distribués.*
