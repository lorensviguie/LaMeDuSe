# Les Bases de Linux

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

Vous trouverez ici un large éventail de commandes à utiliser sur un terminal **bash Linux**.

> **Note :** pour plus d'informations, consultez le *man* de la commande correspondante (`man <commande>`).

---

## 📚 Sommaire

1. [Les commandes de base](#i-les-commandes-de-base)
2. [Comprendre un terminal bash](#ii-comprendre-un-terminal-bash)
3. [Les commandes avancées](#iii-les-commandes-avancées)
4. [Permissions](#iv-permissions)
5. [État de santé du système](#v-état-de-santé-du-système)
6. [Les services et processus](#vi-les-services-et-processus)
7. [Réseau](#vii-réseau)
8. [Les packages](#viii-les-packages)
9. [Debug](#ix-debug)

---

## I. Les commandes de base

### A) Se déplacer dans Linux
```bash
pwd        # Affiche le répertoire courant
cd /home   # Change de répertoire
ls -la     # Liste fichiers et dossiers avec détails
tree       # Affiche la structure des dossiers (nécessite le package tree)
```

### B) Afficher / créer / modifier des fichiers
```bash
cat fichier.txt          # Lire un fichier
touch nouveau.txt        # Créer un fichier vide
nano fichier.txt         # Modifier un fichier (éditeur simple)
cp source dest           # Copier un fichier
mv ancien.txt nouveau.txt # Renommer ou déplacer
rm fichier.txt           # Supprimer un fichier
```

### C) Gestion des utilisateurs
```bash
whoami       # Affiche l’utilisateur courant
sudo adduser testuser    # Crée un utilisateur
sudo deluser testuser    # Supprime un utilisateur
passwd testuser          # Change le mot de passe
groups                   # Affiche les groupes de l’utilisateur
```

---

## II. Comprendre un terminal bash

### A) Raccourcis bash

| Raccourci | Action |
|------------|---------|
| `↑` | Reprendre la dernière commande tapée |
| `Ctrl + L` | Effacer l’écran (clear le terminal) |
| `Ctrl + D` | Se déconnecter de la session actuelle / fermer le terminal |
| `Ctrl + A` | Aller au **début** de la ligne |
| `Ctrl + E` | Aller à la **fin** de la ligne (comme “End”) |
| `Alt + B` | Reculer d’un mot (comme “Backward”) |
| `Alt + F` | Avancer d’un mot (comme “Forward”) |
| `Alt + D` | Supprimer du curseur jusqu’à la **fin du mot actuel** (comme “Delete”) |
| `Ctrl + K` | Supprimer du curseur jusqu’à la **fin de la ligne** |
| `Ctrl + U` | Supprimer du curseur jusqu’au **début de la ligne** |
| `Ctrl + R` | Recherche dans l’historique des commandes |

### B) Lire un terminal
```bash
[root   @  localhost        ~]# 
username   nom du serveur  le chemin actuel
```
~ correspond au chemin par default du user la plupart du temps son dossier home /home/username ou /root pour le user root
---

## III. Les commandes avancées

### A) Combiner plusieurs commandes
```bash
ls; pwd              # Exécute successivement deux commandes
mkdir test && cd test # Continue seulement si la 1ère réussit
false || echo "Erreur détectée"  # Exécute la 2e si la 1ère échoue
echo "- - -" >> ./toto.txt # Redirige le resultat de la commande une vers un fichier choisi en ajoutant pas en ecrasant
echo "- - -" 2> ./toto.txt # Redirige le message d'erreur vers le fichier choisi (ecrase le contenu du fichier si deja existant)
```

### B) Filtres de texte
```bash
grep "root" /etc/passwd       # Recherche une ligne contenant 'root'
cut -d: -f1 /etc/passwd       # Extrait la 1re colonne
sort fichier.txt | uniq -c    # Trie et compte les doublons
awk '{print $1,$3}' fichier.txt # Extrait et affiche des colonnes
```

### C) vim

vim est un editeur de fichier bcp plus puissant que nano mais plus technique a utilisé
```bash
vim fichier.txt
```
ECHAP permet de sortir du mode actuelle pour taper une des commande cidessous ou une combinaison

| Raccourci / Commande | Description |
|------------------------|-------------|
| `i` | Passer en mode **INSERT** |
| `A` | Passer en mode **INSERT** à la **fin de la ligne actuelle** |
| `o` | Insère une **ligne vide sous** la ligne actuelle et passe en mode INSERT |
| `O` | Insère une **ligne vide au-dessus** de la ligne actuelle et passe en mode INSERT |
| `dd` | Supprime la **ligne actuelle** (et la place dans le presse-papier) |
| `dw` | Supprime le **mot sous le curseur** (et le place dans le presse-papier) |
| `x` | Supprime le **caractère sous le curseur** |
| `D` | Supprime **du curseur jusqu'à la fin de la ligne** |
| `yy` | Copie (**yank**) la **ligne actuelle** dans le presse-papier |
| `p` | **Colle** le contenu du presse-papier |
| `gg` | Aller au **début du fichier** |
| `G` | Aller à la **fin du fichier** |
| `:q` | Quitter **vim** |
| `:w` | **Sauvegarder** le fichier |
| `:q!` | **Forcer la fermeture** de vim sans sauvegarder |
---

## IV. Permissions

### A) POSIX, c’est quoi ?
POSIX définit la manière dont Linux gère les droits d’accès.  
Chaque fichier appartient à un **utilisateur** et un **groupe**, et possède des droits :

| Type | Droit | Signification |
|------|--------|----------------|
| r | read | lecture |
| w | write | écriture |
| x | execute | exécution |

ici on peut voir un dossier et un fichier le dossier est différencier par le d au debut 
puis ensuite les enchainement de 3 lettre ou tiret pour les permission du user du groupe et de tous le monde
```bash
[root@localhost mnt]# ls -al
total 12
drwxr-xr-x.  3 root        root 4096 Oct 18 22:21 firewall
-rw-r--r--. 1 qemu        qemu 7660371968 May 31 23:44 Rocky-10.0-x86_64-dvd1.iso
```

### B) Afficher / modifier les permissions

Les permissions sous Linux définissent **qui peut lire, écrire ou exécuter** un fichier ou un dossier.  
Elles se divisent en **trois catégories** :  

| Catégorie | Signification | Exemple |
|------------|----------------|----------|
| **u** | *user* → le propriétaire du fichier | `chmod u+x script.sh` |
| **g** | *group* → le groupe associé au fichier | `chmod g-w fichier.txt` |
| **o** | *others* → tous les autres utilisateurs | `chmod o+r fichier.txt` |
| **a** | *all* → s’applique à tous (u, g et o) | `chmod a-x fichier.sh` |

---

#### 🔍 Afficher les permissions

```bash
ls -l fichier.txt
-rwxr-xr--
│││ │ │ │
│││ │ │ └──> Autres : lecture seule
│││ │ └────> Groupe : lecture + exécution
│││ └──────> Propriétaire : lecture, écriture, exécution
││└────────> Type (d = dossier, - = fichier)
```
🔢 Comprendre le système octal (chmod 755)

Chaque catégorie (u, g, o) se voit attribuer une valeur numérique :

|Permission	|Valeur	|Signification|
|----|------|------|
|r (read)	|4	|Lecture du fichier ou liste du dossier|
|w (write)	|2	|Modification ou suppression|
|x (execute)|	1	|Exécution (ou accès au dossier)|


```bash
chmod 755 script.sh
# => u:7 (rwx), g:5 (r-x), o:5 (r-x)

chmod 644 fichier.txt
# => u:6 (rw-), g:4 (r--), o:4 (r--)

chmod 700 clé_privée.pem
# => u:7 (rwx), g:0 (---), o:0 (---)

chown user:group fichier
# Change le propriétaire et le groupe associés au fichier

chown -R admin:admin /var/www/
# L'option -R applique récursivement à tout le dossier
```
---

## V. État de santé du système

### A) Stockage
```bash
df -h          # Affiche l’espace disque disponible
du -sh *       # Taille des fichiers/dossiers du répertoire courant
lsblk          # Liste des disques et partitions
```

### B) RAM, CPU et GPU
```bash
top            # Affiche les processus actifs
htop           # Version améliorée de top
free -h        # Utilisation mémoire
lscpu          # Infos CPU
```

### C) Gestion du système
```bash
uptime         # Durée de fonctionnement du système
dmesg | less   # Messages du noyau
journalctl -xe # Logs système détaillés
```

---

## VI. Les services et processus

### A) C’est quoi un processus ?
Un processus est une instance d’un programme en cours d’exécution, identifiée par un **PID**. il peut tourner en arriere plan on parle alors de démon ou un premier plan
par exemple si vous etes dans un terminal c'est un processus de premier plan qui se coupe quand vous fermer le terminal

les processus peuvent etre crée par des services 

### B) Gestion des services
```bash
systemctl status ssh # voir l'etat du service ssh
systemctl start ssh # démare le service ssh
systemctl enable ssh # le service demarera au demarage du serveur
systemctl stop ssh # stop le service ssh
```

### C) Commandes utiles
```bash
ps aux | grep apache # liste les processus et avec grep cela affichera que ceux qui comporte apache
kill <PID>
pgrep nginx
nice -n 10 commande   # Exécute avec priorité réduite
```

---

## VII. Réseau

### A) Les commandes
```bash
ping 8.8.8.8           # Teste la connectivité
ip addr show           # Liste les interfaces réseau
ss -tulnp              # Affiche les ports ouverts
curl ifconfig.me       # Affiche votre IP publique
```

### B) La notion d’interface
Les interfaces réseau représentent les connexions physiques ou virtuelles (`eth0`, `wlan0`, `lo`...).

```bash
ip addr add 192.168.1.10/24 dev eth0
ip route show
```

### C) Le firewall
le firewall sert de filtre au connection entrante et sortante du serveur 
ci dessous un exemple de commandes a taper si votre machine possède le firewall ufw d'autre exist comme iptable ou firewalld
```bash
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw deny 80/tcp
```

---

## VIII. Les packages

### A) C’est quoi un package ?
Un **package** est un ensemble de fichiers permettant d’installer un logiciel. une distribution linux ce n'est qu'une suite de pacakge qui fonctionnent les un avec les autres

### B) Gestion des packages

selon votre distribution vous aurez une gestionnaire de paquet different les plus courant sont dnf et apt mais plein d'autre existe
il sont tres utilise pour gère les dépéndances 
par le logicielle docker a besoin de beaucoup d'autre paquet mais grace a votre gestionnaire avec seulement dnf install docker toutes les dépandance requise seront installé automatiquement 

```bash
sudo apt update
sudo apt install htop
sudo apt remove nano
```

### C) Installer / mettre à jour des logiciels
```bash
sudo apt upgrade
sudo dnf install httpd
```

### D) Choisir ses propres dépôts
Modifier `/etc/apt/sources.list` ou ajouter un PPA :  
```bash
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
```

---

## IX. DEBUG

### A) Les logs, c’est quoi ?
Les **logs** conservent un historique du système et des services pour diagnostiquer les erreurs.
Tres utile pour comprendre pourquoi un service ne fonctionne plus par exemple ou pour consulter l'active sur votre machines

### B) Gestion des logs
- Localisation : `/var/log/`
- Rotation automatique via `logrotate`

### C) Lire des logs
```bash
tail -f /var/log/syslog
journalctl -u ssh
grep "error" /var/log/apache2/error.log
```

---

© 2025 - Formation Linux LaMeDuSe- Niveau Débutant → Intermédiaire
