# TP6 : Docker Swarm - Gestion de Cluster et Haute Disponibilité

## Objectifs pédagogiques

À la fin de ce TP, vous serez capable de :

* Comprendre le fonctionnement de Docker Swarm et sa différence avec Docker Compose.
* Créer et administrer un cluster Swarm multi-nœuds (manager / worker).
* Déployer des services répliqués et les mettre à jour.
* Gérer les volumes, les réseaux et la haute disponibilité.
* Appliquer les bonnes pratiques de sécurité Swarm.

---

## 1. Pré-requis

* 3 machines Linux ou VM avec Docker installé (`manager01`, `worker01`, `worker02`).
* Réseau fonctionnel entre les trois machines.
* Accès root ou sudo.

---

## 2. Introduction à Docker Swarm

Docker Swarm est l’orchestrateur natif de Docker. Il permet de :

* Gérer un cluster de serveurs Docker.
* Déployer des applications distribuées.
* Assurer la haute disponibilité et la réplication automatique.

### Différence avec Docker Compose

| Fonctionnalité      | Docker Compose   | Docker Swarm        |
| ------------------- | ---------------- | ------------------- |
| Portée              | Machine unique   | Cluster multi-hôtes |
| Commande            | `docker-compose` | `docker stack`      |
| Haute disponibilité | Non              | Oui                 |
| Scalabilité         | Manuelle         | Automatique         |
| Load balancing      | Non              | Oui (intégré)       |

---

## 3. Création du cluster Swarm

### 3.1 Initialisation du manager

Recherchez la commande pour initialiser un manager et comprendre le rôle de `--advertise-addr`.

### 3.2 Ajout des workers

Explorez comment ajouter un worker à un cluster Swarm et récupérer le token d’adhésion.

### 3.3 Vérification du cluster

Cherchez comment lister les nœuds et vérifier leur rôle et statut.

---

## 4. Déploiement d’un service Swarm

### 4.1 Service répliqué

Déterminez comment créer un service avec plusieurs répliques et exposer un port vers l’extérieur.

### 4.2 Vérification

Découvrez comment consulter l’état des services et voir sur quels nœuds les conteneurs tournent.

### 4.3 Load balancing

Testez le load balancing en accédant au service depuis différentes machines ou en utilisant `curl`.

---

## 5. Déploiement via Stack YAML

### 5.1 Rédiger un fichier `stack.yml`

Incluez dans votre YAML :

* Au moins un service répliqué.
* Des volumes pour la persistance des données.
* Des contraintes de placement pour certains nœuds.

### 5.2 Déployer la stack

Cherchez la commande pour déployer une stack Swarm à partir du YAML.

### 5.3 Vérification

Comment vérifier que la stack est déployée correctement ? Quels services sont actifs ?

---

## 6. Mise à jour et rollback d’un service

Explorez comment :

* Mettre à jour l’image d’un service en production.
* Revenir à une version précédente si la mise à jour échoue.

---

## 7. Gestion du stockage et volumes partagés

Recherchez comment créer des volumes partagés pour vos services (ex: NFS ou autre driver) et comment les utiliser dans un service Swarm.

---

## 8. Monitoring du cluster

### 8.1 Surveillance via Docker

Trouvez les commandes permettant de suivre l’état des nœuds, services et logs.

### 8.2 Outils avancés

Cherchez comment déployer un outil comme **Portainer** pour gérer visuellement le cluster.

---

## 9. Sécurité dans Swarm

### Bonnes pratiques à appliquer

1. Chiffrement des communications internes.
2. Limitation des rôles manager/worker.
3. Gestion des secrets avec Docker Swarm.
4. Éviter l’exposition inutile des ports.
5. Mise à jour régulière des nœuds.

---

## 10. Comparaison rapide avec Kubernetes

| Critère                | Docker Swarm | Kubernetes                  |
| ---------------------- | ------------ | --------------------------- |
| Installation           | Très simple  | Complexe                    |
| Courbe d’apprentissage | Faible       | Élevée                      |
| Scalabilité            | Bonne        | Excellente                  |
| Load balancing         | Intégré      | Avancé (Ingress Controller) |
| Écosystème             | Limité       | Très riche                  |

---

## 11. Nettoyage

Cherchez les commandes pour :

* Supprimer une stack.
* Supprimer les services.
* Quitter un Swarm sur chaque nœud.

---

## 🧩 Pour aller plus loin

* Intégrer un registry privé pour le déploiement Swarm.
* Mettre en place un réseau overlay sécurisé entre plusieurs sites.
* Ajouter une stack complète de monitoring (Prometheus + Grafana).

---

### 🕓 Durée estimée : 4 heures
