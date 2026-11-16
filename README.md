# 🐙 LaMéDuSe – Environnement DevOps & Cloud

Bienvenue dans le dépôt **LaMeDuSe**, un ensemble complet de **cours et TP** pour apprendre et maîtriser les technologies **Docker**, **Kubernetes** et **Linux**, à travers des exercices concrets, progressifs et orientés production.

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)
---

## 🎯 Objectifs pédagogiques

À travers ce dépôt, vous apprendrez à :

- Créer et préparer des **machines virtuelles** propres et réutilisables.  
- Maîtriser les **bases de Linux** et de l’administration système.  
- Comprendre et manipuler **Docker** pour la conteneurisation.  
- Construire et déployer vos propres **images Docker**.  
- Gérer des environnements complexes avec **Docker Compose** et **Swarm**.  
- Mettre en place un **registre privé** et une **chaîne CI/CD locale**.  
- Découvrir les fondements de **Kubernetes** et du déploiement distribué.  
- Adopter une démarche **DevOps** complète, du développement au déploiement.

---

## 🧱 Arborescence du dépôt

```bash
LAMEDUSE/
├── docker/               # Cours et TP autour de Docker et Swarm
│   ├── cour/             # Cours théoriques Docker
│   └── tp/               # Travaux pratiques Docker (TP1 → TP8)
│
├── kubernetes/           # Introduction à Kubernetes
│   └── cour/             # Cours de découverte (C1 - Introduction)
│
├── linux/                # Notions de base Linux pour DevOps
│   ├── cour/             # Cours Linux
│   ├── memos/            # Fiches mémo et raccourcis utiles
│   └── tp/               # Travaux pratiques Linux
│
├── virtualisation/       # Création de VM et clones source
│   └── tp/               # Travaux pratiques Virtualisation
│
└── README.md             # Ce fichier d’accueil
```

---

## 🐋 Section Docker

### Description
Apprenez à **installer, administrer et automatiser** Docker à travers des TPs progressifs.  
Chaque TP introduit une brique clé de la conteneurisation : image, volume, réseau, orchestration, registry, etc.

📘 **Sous-dossiers :**
- [`cour/`](docker/cour) – Cours et notions fondamentales.  
- [`tp/`](docker/tp) – Série de TPs de mise en pratique.

---

## ☸️ Section Kubernetes

### Description
Découvrez les **bases de Kubernetes** et de l’orchestration de conteneurs à grande échelle.  
Les cours présentent la logique de déploiement, les objets clés et la philosophie cloud-native.

📘 **Sous-dossiers :**
- [`cour/`](kubernetes/cour) – Cours d’introduction.

---

## 🖥️ Section Virtualisation

### Description
Avant de travailler sur un serveur, il faut savoir le **construire proprement** : création de la VM, installation from scratch, partitionnement LVM, sécurisation de l’accès et préparation d’un **clone source** réutilisable pour tous les autres TP.

📘 **Sous-dossiers :**
- [`tp/`](virtualisation/tp) – Travaux pratiques ([TP1 – Clone source propre](virtualisation/tp/TP1-CloneSourcePropre/README.md)).

---

## 🐧 Section Linux

### Description
Avant de maîtriser Docker et Kubernetes, il est essentiel de comprendre le **monde Linux** :  
commandes de base, services, permissions, réseau et automatisation.

📘 **Sous-dossiers :**
- [`cour/`](linux/cour) – Cours théoriques.  
- [`memos/`](linux/memos) – Raccourcis, astuces et résumés pratiques.  
- [`tp/`](linux/tp) – Exercices pour renforcer vos compétences (dont le [TP3 – Service web sécurisé & conteneurs](linux/tp/TP3-ServiceWebEtConteneurs/README.md)).

---

## 💡 Méthodologie de travail

1. **Lire le cours** dans chaque dossier pour comprendre la théorie.  
2. **Suivre les TPs** en appliquant les concepts pas à pas.  
3. **Faire vos propres recherches** : peu de commandes sont données volontairement.  
4. **Documenter votre avancement** (via un carnet de bord ou un repo personnel).

---

## 🧠 Ressources utiles

| Domaine | Outils / Docs |
|----------|----------------|
| 🐋 Docker | [docs.docker.com](https://docs.docker.com) |
| ☸️ Kubernetes | [kubernetes.io/docs](https://kubernetes.io/docs/home/) |
| 🐧 Linux | [linuxjourney.com](https://linuxjourney.com) |
| 🖥️ Virtualisation | [docs.rockylinux.org](https://docs.rockylinux.org) · [virtualbox.org/manual](https://www.virtualbox.org/manual/) |
| ⚙️ DevOps | [roadmap.sh/devops](https://roadmap.sh/devops) |

---

## 📦 Auteur & Licence

Projet pédagogique créé pour accompagner les étudiants/proffesionels dans leur **montée en compétence DevOps**.  
Sous Licence MIT.

> © 2025 - LaMeDuSe Project 🧠  
> Développé avec passion et conteneurs 🚀
