# Partie 2 – Installation de Rocky Linux 10.2

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Installer Rocky Linux avec l'installeur **Anaconda** en prenant les bonnes décisions **dès l'installation** : langue, réseau, nom d'hôte, partitionnement LVM et comptes.

> 💡 Tout ce qui est bien fait pendant l'installation n'aura pas à être corrigé plus tard. En particulier le **partitionnement**, très pénible à modifier après coup.

---

## 🧩 1. Localisation

* Langue d'installation, **disposition du clavier** et **fuseau horaire** : configurez-les correctement pour votre contexte.
* Dans l'écran « Date & heure », regardez s'il est possible d'activer la synchronisation réseau de l'heure.

❓ **Question :** pourquoi un serveur doit-il absolument avoir une heure exacte ? Citez au moins deux problèmes concrets causés par une horloge décalée.

---

## 🧩 2. Sélection des logiciels

* Choisissez l'environnement **Minimal Install**, sans aucun module additionnel.

❓ **Question :** pourquoi installer le **minimum** sur un serveur ? Pensez en termes de surface d'attaque, de mises à jour et de ressources.

---

## 🧩 3. Réseau et nom d'hôte

* Activez la ou les interfaces réseau et vérifiez qu'elles obtiennent une adresse.
* Donnez à la machine un **nom d'hôte propre**.

💡 **Indices** :
* Renseignez-vous sur la différence entre un *hostname* court et un **FQDN**.
* Un bon nom d'hôte décrit le rôle de la machine et respecte une convention. Quelles règles (caractères autorisés, longueur) doit-il respecter ?

---

## 🧩 4. Partitionnement (la partie la plus importante)

Choisissez le partitionnement **personnalisé** (*Custom*) et construisez vous-même votre schéma.

### Contraintes imposées

| Élément | Contrainte |
|---------|-----------|
| `/boot` | Partition **standard** (hors LVM) |
| `/boot/efi` | Uniquement si la VM est en **UEFI** – partition standard |
| `/` | Volume logique dédié |
| `/home` | Volume logique dédié |
| `/var` | Volume logique dédié |
| `/var/log` | Volume logique dédié |
| `/tmp` | Volume logique dédié |
| `swap` | Volume logique dédié |

C'est à **vous** de choisir la **taille** de chaque volume, en sachant que le disque ne fait que **10 Go** et que la machine fera ensuite tourner des **conteneurs**.

💡 **Indices** :
* Où **podman** stocke-t-il les images et les conteneurs ? En mode root ? En mode utilisateur (*rootless*) ? Cela doit influencer vos tailles.
* Quel est le système de fichiers proposé par défaut ? Peut-on **réduire** sa taille ? Peut-on l'**agrandir** ?
* Est-il obligatoire d'utiliser tout l'espace du groupe de volumes dès l'installation ?
* Bonus : renseignez-vous sur les **options de montage** `nodev`, `nosuid` et `noexec`. Sur quel(s) point(s) de montage ont-elles du sens ?

❓ **Questions (à justifier dans le carnet de bord) :**
* Pourquoi séparer `/var/log` du reste ? Que se passe-t-il si un service remplit les logs et que `/var/log` **n'est pas** séparé ?
* Pourquoi séparer `/home` et `/tmp` ?
* Pourquoi `/boot` est-il traditionnellement hors LVM ?
* Quel intérêt d'utiliser **LVM** plutôt que des partitions classiques ?
* Quelle taille de swap avez-vous choisie et pourquoi ?
* Donnez votre tableau final : point de montage / taille / système de fichiers / justification.

---

## 🧩 5. Comptes utilisateurs

* Créez **votre compte utilisateur** personnel et donnez-lui les droits d'**administration**.
* Choisissez quoi faire du compte **root** : regardez attentivement les options proposées par l'installeur.

⚠️ Exigence du TP : root ne doit **pas** pouvoir se connecter en SSH. Ne cochez pas d'option qui irait à l'encontre de cela.

❓ **Questions :**
* Quelle case donne les droits d'administration à votre utilisateur ? À quel **groupe** est-il alors ajouté ?
* Quelle est la différence entre **désactiver** le compte root et **interdire** sa connexion SSH ?

---

## 🧩 6. Autres options à étudier

* **KDUMP** : à quoi sert-il ? Combien de mémoire réserve-t-il ? Est-ce pertinent sur une VM de 2 Go ?
* **Profil de sécurité** (*Security Profile*) : qu'est-ce que c'est ? Quels profils sont proposés ? (Découverte uniquement, ne l'appliquez pas obligatoirement.)

Lancez ensuite l'installation, puis redémarrez sur le système installé (pensez à **éjecter l'ISO**).

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Démarrage | La VM démarre sur le disque, sans l'ISO |
| Connexion | Vous pouvez vous connecter en console avec **votre** utilisateur |
| Droits | Votre utilisateur peut exécuter une commande en administrateur |
| Partitions | Tous les points de montage demandés existent sur des volumes logiques |

💡 Quelles commandes permettent d'afficher les disques, les partitions, les volumes physiques, les groupes de volumes, les volumes logiques et l'occupation des systèmes de fichiers ? Trouvez-en au moins quatre.

➡️ [Partie 3 – Configuration post-installation](P3-ConfigurationPostInstall.md)
