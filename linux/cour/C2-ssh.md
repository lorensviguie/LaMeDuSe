# SSH — Guide pratique pour débutants → intermédiaires

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

Vous trouverez ici un guide clair et corrigé sur **SSH (Secure Shell)** : usage de base, transfert de fichiers, sécurisation et configuration client. Le document contient des exemples concrets prêts à être copiés/collés.

> **Important :** SSH est l’outil principal d’administration à distance sous Linux. Il doit être utilisé correctement et sécurisé (notamment en production).

---

## 📚 Sommaire

1. [I. SSH : c'est quoi ?](#i-ssh-cest-quoi)  
2. [II. Utiliser SSH (connexion)](#ii-utiliser-ssh-connexion)  
   - [Prérequis](#prérequis)  
   - [Connexion simple](#connexion-simple)  
   - [Known_hosts et empreinte](#known_hosts-et-empreinte)  
3. [III. Envoyer / récupérer des fichiers via SSH](#iii-envoyer--récupérer-des-fichiers-via-ssh)  
   - [scp](#scp)  
   - [rsync sur SSH](#rsync-sur-ssh)  
4. [IV. Sécuriser SSH (recommandations)](#iv-sécuriser-ssh-recommandations)  
   - [Modifier `sshd_config`](#modifier-sshd_config)  
   - [Générer une paire de clés SSH](#générer-une-paire-de-clés-ssh)  
   - [Ajouter la clé publique sur le serveur](#ajouter-la-clé-publique-sur-le-serveur)  
   - [Autres recommandations](#autres-recommandations)  
5. [V. Fichier de configuration client (`~/.ssh/config`)](#v-fichier-de-configuration-client-ssshconfig)  
6. [VI. Commandes et exemples utiles](#vi-commandes-et-exemples-utiles)  
7. [VII. Ressources & bonnes pratiques](#vii-ressources--bonnes-pratiques)

---

## I. SSH : c'est quoi ?

**SSH (Secure Shell)** est un protocole chiffré qui permet d'obtenir un terminal distant sécurisé sur un autre ordinateur (ex. : administrer un serveur depuis votre poste).  
Le serveur SSH (daemon `sshd`) écoute par défaut sur le port **22** — cela peut être changé.

> ⚠️ SSH n'est **pas** un outil de hacking. C’est un outil d’administration. Utilisez-le avec responsabilité et sécurisez l’accès.

---

## II. Utiliser SSH (connexion)

### Prérequis
- L'IP ou le nom d'hôte du serveur cible.  
- Un compte utilisateur valide sur le serveur (et idéalement une paire de clés SSH).  
- Le port SSH ouvert dans le firewall du serveur (par défaut 22).

### Connexion simple

```bash
# Forme simple (port 22 implicite)
ssh utilisateur@192.168.1.152

# Connexion en spécifiant un port différent
ssh -p 2222 utilisateur@exemple.com
```

### Known_hosts et empreinte

À la **première** connexion vers un hôte, le client SSH va vérifier l'empreinte (fingerprint) de la clé publique du serveur. Exemple :

```
The authenticity of host '192.168.1.1 (192.168.1.1)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

- Tapez `yes` si vous reconnaissez la machine (ou après vérification de l’empreinte).  
- La clé publique du serveur est alors ajoutée dans `~/.ssh/known_hosts`.  
- Si ce message réapparaît plus tard pour le même hôte, **c'est une alerte de sécurité** (possible attaque de type *man-in-the-middle* ou changement légitime de la clé serveur).

---

## III. Envoyer / récupérer des fichiers via SSH

### `scp` (simple, sécurisé)

```bash
# Copier un fichier local -> distant
scp /chemin/local/fichier.pdf utilisateur@192.168.1.152:/home/utilisateur/

# Copier un dossier (option -r)
scp -r /chemin/local/dossier utilisateur@192.168.1.152:/home/utilisateur/

# Copier depuis Windows (PowerShell)
scp C:\Users\toto\Documents\test.pdf utilisateur@192.168.1.152:/home/toto/Documents/
```

### `rsync` (plus performant, reflète/sync)

```bash
# Synchroniser un dossier local vers distant (via SSH)
rsync -avz --progress /chemin/local/ utilisateur@192.168.1.152:/chemin/distant/

# Exemple avec port non standard
rsync -avz -e "ssh -p 2222" /chemin/local/ utilisateur@host:/chemin/distant/
```

`rsync` est préférable pour les transferts répétés : il ne transfère que les différences.

---

## IV. Sécuriser SSH (recommandations)

### Modifier `sshd_config` (serveur)

Fichier : `/etc/ssh/sshd_config` (sur la machine **serveur**). Sauvegardez le fichier avant modification.

Exemples de paramètres recommandés :

```conf
# /etc/ssh/sshd_config (extraits recommandés)
Port 22                      # changer si vous voulez un port non-standard
PermitRootLogin no           # interdit la connexion directe en root
PasswordAuthentication no    # désactive la connexion par mot de passe (si clés configurées)
ChallengeResponseAuthentication no
UsePAM yes                   # selon distribution (garde l'authentification PAM)
PermitEmptyPasswords no
AllowUsers toto admin      # (optionnel) n'autorise que les utilisateurs listés
```

Après modification :

```bash
# Vérifier la configuration (très important)
sudo sshd -t

# Recharger le service
sudo systemctl reload sshd
# ou (si reload échoue)
sudo systemctl restart sshd
```

> ⚠️ Avant de désactiver `PasswordAuthentication`, **ajoutez votre clé publique** (voir ci-dessous) pour ne pas vous verrouiller hors du serveur.

### Générer une paire de clés SSH (client)

Sur votre poste (client) :

```bash
# Recommandation actuelle : ed25519 (plus sécurisé et plus petit)
ssh-keygen -t ed25519 -C "votre_email@example.com"

# Exemple interactif (choisissez un bon passphrase)
# Génère : ~/.ssh/id_ed25519 (privée) et ~/.ssh/id_ed25519.pub (publique)
```

- **Protégez** votre clé privée (`~/.ssh/id_ed25519`) ; ne la partagez jamais.  
- Utilisez un **passphrase** pour sécuriser la clé privée ; vous pouvez utiliser `ssh-agent` pour éviter de retaper le passphrase à chaque fois.

### Ajouter votre clé publique sur le serveur (authentification sans mot de passe)

Méthode simple avec `ssh-copy-id` :

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub utilisateur@192.168.1.152
```

Ou manuellement (si `ssh-copy-id` absent) :

```bash
# Sur le client :
cat ~/.ssh/id_ed25519.pub

# Sur le serveur (en tant qu'utilisateur) :
mkdir -p ~/.ssh
echo "clé_publique_ICI" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Autres recommandations de sécurité

- **Désactiver l’authentification par mot de passe** (`PasswordAuthentication no`) une fois les clés en place.  
- **Désactiver PermitRootLogin** et utiliser `sudo` pour les actions root.  
- **Limiter les utilisateurs autorisés** avec `AllowUsers` ou `AllowGroups`.  
- **Changer le port SSH** (obscurcir, pas une protection forte mais réduit le bruit des scans).  
- **Installer fail2ban** pour bloquer les tentatives répétées d'authentification.  
- **Utiliser des clés ED25519 ou RSA 4096 bits** (éviter RSA 1024).  
- **Activer l'enregistrement des connexions** et surveiller `/var/log/auth.log` ou `journalctl -u sshd`.

---

## V. Fichier de configuration client (`~/.ssh/config`)

Créez `~/.ssh/config` pour simplifier vos connexions :

```text
# ~/.ssh/config
Host monserveur
    HostName 192.168.1.152
    User lorens
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ForwardAgent no
```

Puis connectez simplement :

```bash
ssh monserveur
```

Exemples supplémentaires :

```text
Host company-*
    User deploy
    IdentityFile ~/.ssh/id_rsa_company
    Port 2222

Host github.com
    HostName ssh.github.com
    Port 443
    User git
```

- `IdentitiesOnly yes` évite d'envoyer toutes vos clés au serveur (utile si vous avez beaucoup de clés).  
- `ForwardAgent yes` permet d'utiliser l'agent SSH du client depuis le serveur — **attention** aux risques de sécurité.

---

## VI. Commandes et exemples utiles

```bash
# Vérifier l'empreinte d'un serveur (algorithme rsa/ed25519/sha256 selon config)
ssh-keyscan -t ed25519 192.168.1.152

# Tester la connexion verbosément
ssh -vvv utilisateur@host

# Copier via scp
scp /local/fichier utilisateur@host:/remote/chemin

# Synchroniser via rsync (recommandé pour gros transferts)
rsync -avz -e "ssh -p 22" /local/ dossier@host:/remote/

# Surveiller les connexions sur le serveur (exemple systemd)
sudo journalctl -u sshd --since "1 hour ago"

# Autoriser un port SSH dans ufw (ex. port 2222)
sudo ufw allow 2222/tcp
```

---

## VII. Ressources & bonnes pratiques

- Toujours **tester** les modifications SSH sur une session parallèle avant de fermer la session active (garder une connexion ouverte pendant les tests).  
- Sauvegarder `/etc/ssh/sshd_config` avant modification.  
- `fail2ban` est votre ami contre les attaques brute-force.  on en parle plus tard
- Utiliser une **passphrase** pour les clés privées et `ssh-agent` pour la commodité.  
- Lire la documentation : `man ssh`, `man sshd_config`, `man ssh-keygen`.

---

© 2025 — Guide SSH — Niveau Débutant → Intermédiaire
