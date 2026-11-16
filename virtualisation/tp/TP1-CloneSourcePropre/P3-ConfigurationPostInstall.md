# Partie 3 – Configuration post-installation

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Transformer une installation fraîche en un serveur **propre, sécurisé et à jour**, administrable à distance en SSH.

> ⚠️ **Règle d'or** : avant de modifier la configuration SSH ou le pare-feu, **gardez toujours une session ouverte** (console de la VM ou deuxième session SSH). Si vous vous enfermez dehors, c'est elle qui vous sauvera.

---

## 🧩 1. Premiers pas et réseau

Depuis la console de la VM :

* Vérifiez l'adresse IP de chaque interface, la passerelle par défaut et les serveurs DNS utilisés.
* Vérifiez que la VM accède à Internet (résolution DNS **et** accès HTTP/HTTPS).

💡 **Indices** : outils `ip`, `nmcli`, `ping`, `curl`. Sur Rocky 10, qui gère le réseau ? Où sont stockées les connexions ?

❓ **Question :** pourquoi un `ping` qui fonctionne vers une IP mais pas vers un nom de domaine indique-t-il un problème de DNS ?

---

## 🧩 2. Accès SSH depuis votre PC

* Connectez-vous en SSH à la VM **depuis votre PC**, avec **votre utilisateur**.
* Mettez en place une **authentification par clé** : générez une paire de clés sur votre PC et déposez la clé publique sur la VM.
* Vérifiez que la connexion par clé fonctionne **avant** d'aller plus loin.

💡 **Indices** :
* Quel type de clé est recommandé aujourd'hui ?
* Une commande permet de copier automatiquement la clé publique sur le serveur. Si elle n'existe pas sur votre OS, dans quel fichier et avec quelles permissions faut-il déposer la clé ?
* Si la connexion par clé échoue, consultez les **logs de sshd** côté serveur. Pensez aussi aux **permissions** du dossier `.ssh`.

❓ **Question :** expliquez la différence entre la clé publique et la clé privée. Laquelle ne doit **jamais** quitter votre PC ?

---

## 🧩 3. Durcissement du service SSH

Objectifs :

* Le compte **root ne peut pas** se connecter en SSH (ni par mot de passe, ni par clé).
* *(Bonus)* Seule l'authentification **par clé** est acceptée.

💡 **Indices** :
* Le fichier principal de configuration n'est **pas le seul** fichier lu par `sshd`. Regardez la directive `Include` et le contenu du dossier associé. L'installeur y a peut-être déposé quelque chose.
* Pour sshd, quand une même directive apparaît plusieurs fois, **quelle valeur l'emporte** ?
* Il existe une option de `sshd` pour **tester la syntaxe** de la configuration, et une autre pour afficher la **configuration effective**. Utilisez-les avant chaque redémarrage du service.
* Quelle est la différence entre les valeurs `no` et `prohibit-password` ?

✅ **Test** : depuis votre PC, une tentative de connexion SSH en `root` doit être **refusée**, et votre utilisateur doit toujours pouvoir se connecter.

---

## 🧩 4. Politique de sécurité et messages de connexion

En entreprise, chaque connexion à un serveur affiche un **message légal** rappelant que l'accès est réservé aux personnes autorisées et que les actions sont journalisées.

* Mettez en place une **bannière affichée avant l'authentification** SSH (avertissement légal).
* Mettez en place un **message affiché après la connexion** (informations utiles : nom de la machine, rôle, contact de l'administrateur…).

💡 **Indices** : renseignez-vous sur `/etc/issue`, `/etc/issue.net`, `/etc/motd`, le dossier `/etc/motd.d/` et la directive `Banner` de sshd. Lequel est affiché à quel moment ? Lequel concerne la console locale ?

### 🔍 Découverte des politiques de sécurité du système

Rocky Linux embarque plusieurs mécanismes de sécurité actifs par défaut. Pour chacun, trouvez **à quoi il sert**, **comment voir son état** et notez le résultat :

| Mécanisme | À découvrir |
|-----------|-------------|
| **SELinux** | Mode actuel ? Différence entre `Enforcing`, `Permissive` et `Disabled` ? Où voir les refus ? |
| **firewalld** | Zone par défaut ? Services et ports autorisés ? Le SSH est-il autorisé ? |
| **Crypto-policies** | Quelle politique cryptographique système est appliquée ? Quelles autres existent ? |
| **sudo** | Où sont journalisées les commandes exécutées avec sudo ? |

⚠️ Ne désactivez **ni SELinux ni firewalld**. Si quelque chose est bloqué, on corrige la cause, on ne coupe pas la sécurité.

---

## 🧩 5. Nom d'hôte

* Vérifiez que le nom d'hôte choisi pendant l'installation est bien appliqué et **persistant**.
* Vérifiez que la machine sait **résoudre son propre nom**.

💡 **Indices** : `hostnamectl`, `/etc/hostname`, `/etc/hosts`. Quelle différence entre le nom *static*, *transient* et *pretty* ?

---

## 🧩 6. Synchronisation du temps (NTP)

* Identifiez le service qui gère le NTP sur Rocky Linux.
* Vérifiez qu'il est **actif**, **lancé au démarrage**, et que l'horloge est **synchronisée**.
* Identifiez les **serveurs de temps** utilisés et celui qui est actuellement sélectionné.
* Vérifiez le **fuseau horaire**.

💡 **Indices** : `timedatectl`, le service `chronyd`, son fichier de configuration, et son outil client (`chronyc`) avec les sous-commandes `sources` et `tracking`.

❓ **Question :** qu'est-ce qu'un *pool* NTP ? Pourquoi en utiliser un plutôt qu'un serveur unique ?

---

## 🧩 7. Dépôts et mises à jour

* Listez les **dépôts** configurés et ceux qui sont **activés**.
* Vérifiez d'où viennent les paquets : miroirs, **clés GPG** de signature.
* Vérifiez s'il existe des **mises à jour** disponibles, puis appliquez-les.
* Déterminez si un **redémarrage** est nécessaire après la mise à jour, et si oui, redémarrez.

💡 **Indices** : sous-commandes `repolist`, `check-update`, `upgrade` de `dnf`. Où sont stockés les fichiers `.repo` ? Où sont stockées les clés GPG ? Une sous-commande de `dnf` permet de savoir si un redémarrage est nécessaire.

❓ **Questions :**
* À quoi servent les dépôts **BaseOS**, **AppStream** et **extras** ?
* Qu'est-ce que **EPEL** ? Faut-il l'activer sur notre clone source ? Justifiez.
* Pourquoi la signature GPG des paquets est-elle importante ?

---

## 🧩 8. Installation de Podman

* Installez **podman**.
* Vérifiez qu'il fonctionne **en tant que votre utilisateur** (sans sudo) en lançant un conteneur de test.

💡 **Indices** :
* Que signifie *rootless* ? Que contiennent les fichiers `/etc/subuid` et `/etc/subgid` ?
* Où sont stockées les images en mode rootless ? Est-ce cohérent avec votre partitionnement ?

❓ **Question :** quelles différences principales entre **podman** et **docker** (démon, rootless, compatibilité des commandes) ?

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| SSH utilisateur | Connexion par clé depuis votre PC ✅ |
| SSH root | Connexion **refusée** ❌ |
| Bannière | Message légal affiché avant l'authentification |
| Message de connexion | Affiché après l'authentification |
| SELinux / firewalld | Actifs |
| NTP | Horloge synchronisée |
| Mises à jour | Plus aucune mise à jour disponible |
| Podman | Un conteneur de test fonctionne en rootless |

➡️ [Partie 4 – Vérification et finalisation du clone](P4-VerificationEtClone.md)
