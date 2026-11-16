# Partie 5 – Bonus : migrer Nginx dans un conteneur

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Remplacer le Nginx installé sur la VM par un Nginx **conteneurisé**, en réutilisant votre configuration. À la fin, la VM n'héberge plus que des conteneurs, et le résultat vu depuis le PC est **identique**.

---

## 🧩 1. Préparer la migration

* Listez **tout** ce dont votre Nginx actuel a besoin : fichiers de configuration, fichiers du site, certificats, logs, port d'écoute.
* Choisissez une **image** Nginx adaptée.

❓ **Questions :**
* Quelle différence entre l'image officielle `nginx` et l'image `nginxinc/nginx-unprivileged` ? Laquelle est cohérente avec la partie 2 ?
* Sur quel port écoute l'image *unprivileged* par défaut ? Pourquoi ?

---

## 🧩 2. Faire communiquer les deux conteneurs

Le Nginx conteneurisé doit joindre votre service **sans** que celui-ci soit exposé.

💡 **Indices** :
* Créez un **réseau podman** dédié et placez-y les deux conteneurs : comment un conteneur peut-il alors en joindre un autre **par son nom** ?
* Alternative : un **pod** podman. Que partagent les conteneurs d'un même pod ?
* Seul le conteneur Nginx doit **publier** un port.
* Adaptez votre `proxy_pass` en conséquence.

---

## 🧩 3. Monter la configuration et le site

* Montez votre configuration et votre site dans le conteneur, en **lecture seule**.
* Vérifiez que les **contextes SELinux** permettent au conteneur de lire ces fichiers.

💡 **Indices** : options de montage `ro`, `:Z` / `:z` (quelle différence ?). La commande `nginx -t` peut être exécutée **dans** le conteneur.

---

## 🧩 4. Écouter sur le port 80 en rootless

Un conteneur rootless ne peut pas, par défaut, publier un port inférieur à 1024.

💡 **Pistes à étudier** (choisissez et justifiez) :
* Le paramètre noyau qui définit le **premier port non privilégié** (`sysctl`) ;
* Publier un port élevé et faire une **redirection** de port au niveau du pare-feu ;
* Faire tourner ce conteneur en root (et dans ce cas, qu'avez-vous perdu ?).

---

## 🧩 5. Basculer

* **Arrêtez et désactivez** le service Nginx de la VM (gardez le paquet installé tant que la migration n'est pas validée : c'est votre plan de retour arrière).
* Démarrez le Nginx conteneurisé.
* Rendez l'ensemble **persistant** avec Quadlet (fichiers `.container`, et éventuellement `.network` ou `.pod`).

💡 **Alternative** : décrire l'ensemble dans un fichier **compose** (`podman compose` ou `docker compose`). Comparez les deux approches.

---

## 🧩 6. Bilan

❓ **Questions (à rédiger) :**
* Comparez les deux architectures (Nginx système durci vs Nginx conteneurisé) : isolation, mises à jour, facilité de déploiement, logs, débogage.
* Dans quel cas préféreriez-vous l'une ou l'autre en production ?
* Que faudrait-il pour déployer exactement la même chose sur une deuxième VM (clone du TP1) en quelques minutes ?

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Nginx système | Arrêté et désactivé |
| Nginx conteneurisé | Rootless, configuration montée en lecture seule |
| Depuis le PC | Votre page et votre service s'affichent comme avant ✅ |
| Service applicatif | Toujours injoignable en direct ❌ |
| SELinux | `Enforcing` ✅ |
| Reboot | Tout redémarre automatiquement |

---

## 🚀 Pour aller plus loin

* Automatiser le déploiement de ce TP complet (Ansible, script, cloud-init…)
* Ajouter de la supervision (logs centralisés, métriques)
* Passer à l'orchestration : voir la section [Kubernetes](/kubernetes/cour)
