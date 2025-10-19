# TP1 — Linux Basics (Rocky 9.6 recommandé)

**Objectif :** apprendre et pratiquer les commandes de base sur un système Linux via un terminal Bash. Ce TP est conçu pour des débutants → intermédiaires. Faites-le sur une VM (Rocky Linux 9.6 recommandé) ou sur tout autre Linux disposant d'un shell Bash.

---

## Prérequis
- Une VM ou machine Linux avec accès SSH / console. Rocky 9.6 recommandé mais toute distribution récente conviendra.  
- Accès à un compte non-root (et, si nécessaire, sudo).  
- Accès à Internet pour effectuer des recherches et utiliser `man`/`--help`.

---

## Consignes générales
- Pour chaque question, indiquez les **commandes** utilisées, fournissez la **sortie** (copie ou capture d'écran) et une **brève explication** (1–2 phrases).  
- Si une question risque de vous déconnecter, **gardez une session ouverte** (ou une autre connexion) avant d'exécuter une commande destructive.  
- Travaillez dans un répertoire de travail : `~/TP1_linux`.
```bash
mkdir -p ~/TP1_linux && cd ~/TP1_linux
```

---

## Questions (à rendre)

### Question 1 — Taille du disque système
> Trouvez la taille et l'utilisation du disque sur lequel est installé le système d'exploitation (partition racine `/`).

**Indication :** `df -h`, `lsblk`, `mount`, `lsblk -f`.

**À fournir :** la commande, la sortie, et indiquer la **capacité totale**, l'**utilisé** et le **disponible** pour la partition racine.

---

### Question 2 — Utilisateurs présents
> Listez tous les utilisateurs présents sur le système (comptes locaux).

**Indication :** contenu de `/etc/passwd`, `getent passwd`.

**À fournir :** la commande et la méthode pour repérer les comptes système vs comptes humains (UID ≥ 1000 en général).

---

### Question 3 — PID du processus de votre terminal
> Trouvez le PID (identifiant) du processus associé à votre session de terminal (shell).

**Indication :** `echo $$` (PID du shell courant), `ps -o pid,cmd -p $$`, `pstree -s $$`.

**À fournir :** la commande et la sortie montrant le PID et la commande associée.

---

### Question 4 — Forcer le kill du processus de votre terminal
> Depuis **une autre** session (ou un autre terminal), forcez la fermeture (kill) du processus de votre terminal. Expliquez la méthode et ce qui se passe.

**Indication :** récupérez le PID (question 3), puis depuis une autre session : `kill -TERM <PID>` ou `kill -9 <PID>` (forcer). Vous pouvez aussi utiliser `pkill -t <pty>` ou `killall -9 bash` (danger : peut tuer plusieurs shells).

**À fournir :** la commande utilisée, la justification du signal choisi (`SIGTERM` vs `SIGKILL`) et capture de l'effet sur la session cible.

> **Attention :** Ne tuez pas de processus essentiels du système. Faites cela sur une VM de test. Gardez une session de secours ouverte.

---

### Question 5 — Créer un utilisateur et vérifier les permissions
> Créez un nouvel utilisateur `tp1user`, créez un répertoire `/home/tp1user/project` et donnez-lui la propriété. Vérifiez les permissions.

**Indication :** `sudo adduser tp1user` / `sudo useradd -m tp1user`, `sudo mkdir -p /home/tp1user/project`, `sudo chown -R tp1user:tp1user /home/tp1user/project`, `ls -ld /home/tp1user/project`.

**À fournir :** commandes et sortie `ls -ld` montrant le propriétaire et permissions.

---

### Question 6 — Permissions octales et signification
> Pour le fichier `/home/tp1user/project/script.sh` (créez-le), appliquez les permissions `750`. Expliquez précisément la signification de `750` (pour u/g/o). Vérifiez avec `ls -l`.

**Indication :** `touch /home/tp1user/project/script.sh`, `chmod 750 ...`.

**À fournir :** la commande, la sortie `ls -l` et l'explication des bits (r=4, w=2, x=1 => somme pour chaque catégorie).

---

### Question 7 — Consommation mémoire et CPU
> Quel est l'état actuel de la mémoire et du CPU ? Donnez un aperçu (top 5 processus par mémoire et par CPU).

**Indication :** `top`, `htop`, `ps aux --sort=-%mem | head -n 10`, `ps aux --sort=-%cpu | head -n 10`, `free -h`.

**À fournir :** commandes et les listes demandées (top 5) avec explication courte.

---

### Question 8 — Services systemd
> Trouvez l'état du service SSH (`sshd`) et activez-le si nécessaire. Montrez comment démarrer, arrêter et activer le service au démarrage.

**Indication :** `sudo systemctl status sshd`, `sudo systemctl start sshd`, `sudo systemctl enable sshd --now`, `sudo systemctl stop sshd`.

**À fournir :** commandes et sorties montrant `active (running)` ou l'action réalisée.

---

### Question 9 — Réseau : IP et route par défaut
> Montrez l'adresse IP de la machine et la route par défaut (gateway).

**Indication :** `ip addr show`, `ip route show`, `nmcli device show`.

**À fournir :** commandes et sortie indiquant l'IP (interface utilisée) et la gateway.

---

### Question 10 — Lire des logs
> Affichez les 20 dernières lignes du journal système et filtrez les erreurs (keyword `error` ou `fail`). Utilisez `journalctl` et/ou `tail` sur `/var/log` selon la distribution.

**Indication :** `sudo journalctl -n 50 --no-pager`, `sudo journalctl -p err -b`, `sudo tail -n 50 /var/log/messages` ou `/var/log/syslog`.

**À fournir :** la commande et les lignes pertinentes trouvées (ou indiquer qu'il n'y a pas d'erreur récente).

---

## Travail supplémentaire / Bonus (optionnel)
- Configurer une connexion SSH locale entre deux terminaux (générer paire de clés, `ssh-copy-id`).  
- Installer `htop` et envoyer un screenshot d’un `top` personnalisé.  
- Initialiser un dépôt Git dans `~/TP1_linux` et committer un fichier `rapport.md`.  
- Créer une règle `ufw` (ou `firewalld`) pour autoriser le port 2222 et montrer son état.

---

## Livrables attendus
- Un fichier `rapport_TP1.md` dans lequel vous répondez **pour chaque question** : commande(s) utilisées, sortie(s) (texte ou capture d'écran), et explication courte.  
- Optionnel : captures d'écran dans un répertoire `screenshots/` attaché au rendu.  

---

## Grille d'évaluation (sur 20)
- Q1-Q4 : 8 points (2 pts chacune)  
- Q5-Q7 : 6 points (2 pts chacune)  
- Q8-Q10 : 6 points (2 pts chacune)  
- Présentation / qualité des explications : +2 bonus

---

## Corrigé (réponses indicatives)
> **Remarque :** ces réponses sont indicatives. Les sorties exactes peuvent varier selon la VM.

**Q1 (exemple)**
```bash
df -h /
# Exemple de sortie :
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda2        40G   12G   26G  32% /
```

**Q2 (exemple)**
```bash
getent passwd | awk -F: '{print $1, $3}'
# montre les utilisateurs et leur UID (UID >= 1000 => utilisateurs humains)
```

**Q3 (exemple)**
```bash
echo $$
# 2547
ps -o pid,cmd -p $$
# 2547  -bash
```

**Q4 (exemple depuis une autre session)**
```bash
kill -TERM 2547   # demande une terminaison propre
# ou
kill -9 2547      # SIGKILL (forcer), la session sera immédiatement terminée
```

**Q5–Q10** : voir indices dans les énoncés ci-dessus.

---

© 2025 — TP1 Linux Basics — Conçu pour l'apprentissage pratique
