# Correction – TP1 Virtualisation : Clone source propre (Rocky Linux 10.2)

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

> 📌 Cette correction propose **une** solution valide. D'autres choix (tailles de volumes, mode réseau, noms…) sont acceptables s'ils sont **justifiés** et si `check_vm.sh` ne remonte aucun KO.
>
> Conventions utilisées : utilisateur `lorens`, hostname `tpl-rocky10.lab.lan`, réseau host-only `192.168.56.0/24`, VM en `192.168.56.10`.

---

## Partie 1 – Création de la VM

### 1. ISO et intégrité

Téléchargement depuis https://rockylinux.org/download → `Rocky-10.2-x86_64-minimal.iso` + fichier `CHECKSUM` du même dossier.

L'algorithme utilisé est **SHA-256**.

```powershell
# Windows (PowerShell)
Get-FileHash .\Rocky-10.2-x86_64-minimal.iso -Algorithm SHA256
```
```bash
# Linux
sha256sum Rocky-10.2-x86_64-minimal.iso
# macOS
shasum -a 256 Rocky-10.2-x86_64-minimal.iso
```

On compare l'empreinte obtenue avec la ligne correspondante du fichier `CHECKSUM`.

**Réponses :**
* **Minimal** : contient uniquement les paquets nécessaires à une installation minimale, installable hors ligne (~1,7 Go). **DVD** : tous les paquets BaseOS + AppStream, pour installer n'importe quel environnement hors ligne (~8 Go). **Boot** : juste l'installeur, tous les paquets sont téléchargés depuis le réseau.
* Vérifier l'empreinte garantit que le fichier n'est **ni corrompu** (téléchargement incomplet) **ni modifié** (miroir compromis, ISO piégée). Pour une garantie d'**authenticité**, on vérifie aussi la signature GPG du fichier `CHECKSUM`.

### 2. Compatibilité processeur

Rocky Linux 10 exige le niveau **x86-64-v3** (≈ Intel Haswell 2013 / AMD Excavator 2015 et plus récents : AVX, AVX2, BMI1/2, FMA, MOVBE…).

Vérification depuis un Linux existant :
```bash
/lib64/ld-linux-x86-64.so.2 --help | grep supported
# x86-64-v3 (supported, searched)
```

Sous Windows, si la VM affiche *« CPU not supported »* alors que le CPU est récent : VirtualBox tourne au-dessus de **Hyper-V** (mode NEM, tortue verte dans la barre d'état de la VM) et certaines instructions (AVX2…) ne sont pas exposées à la VM. Solutions :
* Désactiver **l'intégrité de la mémoire** (Sécurité Windows → Sécurité de l'appareil → Isolation du noyau) ;
* Désactiver les fonctionnalités Windows *Hyper-V*, *Plateforme de machine virtuelle*, *Plateforme de l'hyperviseur Windows* ;
* `bcdedit /set hypervisorlaunchtype off` (en administrateur) puis redémarrer le PC.

⚠️ Cela désactive aussi WSL2 / Docker Desktop. Alternative : utiliser Hyper-V ou VMware Workstation.

### 3. Création de la VM (VirtualBox 7)

| Paramètre | Valeur |
|-----------|--------|
| Type / Version | Linux / Red Hat (64-bit) |
| « Skip Unattended Installation » | ✅ coché |
| RAM / CPU | 2048 Mo / 1 vCPU |
| EFI | au choix (voir ci-dessous) |
| Disque | VDI, 10 Go, **alloué dynamiquement** |

**Réponses :**
* **Dynamique** : le fichier grossit au fur et à mesure (économise l'espace hôte, création instantanée, légèrement plus lent, risque de sur-allocation si plusieurs VM grossissent). **Fixe** : tout l'espace est réservé immédiatement (un peu plus performant, pas de mauvaise surprise). Pour un labo et un modèle à cloner : **dynamique**.
* **VDI** : format natif VirtualBox. **VMDK** : VMware (aussi lu par VirtualBox). **VHD/VHDX** : Hyper-V. **qcow2** : KVM/QEMU, supporte snapshots internes et compression. Le format conditionne la portabilité vers un autre hyperviseur.
* **UEFI** impose une partition **`/boot/efi`** (FAT32, ~600 Mo) en plus de `/boot`. En BIOS legacy sur disque GPT, l'installeur ajoute une petite partition **BIOS boot** (1 Mo).

### 4. Réseau

Solution recommandée : **2 cartes réseau**.

| Carte | Mode | Rôle |
|-------|------|------|
| Carte 1 | **NAT** | Accès Internet |
| Carte 2 | **Réseau privé hôte (host-only)** `192.168.56.0/24` | SSH depuis le PC |

**Justification :**
* En NAT simple, le PC **ne peut pas** joindre la VM directement (elle est derrière la NAT de VirtualBox). Alternative valide : NAT + **redirection de port** (ex : hôte `127.0.0.1:2222` → invité `22`), puis `ssh -p 2222 lorens@127.0.0.1`.
* Le **pont (bridge)** met la VM directement sur le réseau physique : simple, mais souvent bloqué sur les Wi-Fi d'école/entreprise (filtrage MAC, isolation client, 802.1X) et expose la VM au réseau local.
* NAT + host-only fonctionne **partout**, même hors ligne, et l'IP host-only reste stable.

---

## Partie 2 – Installation

### 1. Localisation

* Langue : Français (ou English), Clavier : **Français (azerty)**, Fuseau : **Europe/Paris**.
* « Heure réseau » activée dans *Date & heure* (active chronyd).

**Réponse :** une horloge décalée casse **TLS** (certificats « pas encore valides » ou « expirés »), **Kerberos/AD** (tolérance de 5 min), rend les **logs** inexploitables (corrélation entre machines impossible), casse les tâches planifiées, les **TOTP/2FA**, les sauvegardes incrémentales, `make`, les bases de données répliquées…

### 2. Logiciels

**Minimal Install**, aucun add-on.

**Réponse :** chaque paquet installé est un paquet à **mettre à jour**, une **surface d'attaque** supplémentaire (vulnérabilités, services en écoute) et de la RAM/du disque consommés. On n'installe que ce dont on a besoin.

### 3. Réseau et hostname

* Activer **les deux** interfaces (`enp0s3` NAT en DHCP, `enp0s8` host-only en DHCP ou en IP fixe `192.168.56.10/24` sans passerelle).
* Hostname : `tpl-rocky10.lab.lan`.

**Réponses :**
* **Hostname court** : `tpl-rocky10`. **FQDN** (*Fully Qualified Domain Name*) : `tpl-rocky10.lab.lan` = nom + domaine DNS.
* Règles (RFC 1123) : lettres `a-z`, chiffres, tiret `-` (pas en début ni en fin), points pour séparer les labels ; 63 caractères max par label, 253 max au total ; pas d'underscore ni d'accent. Éviter `.local` (réservé à mDNS).

### 4. Partitionnement

*Destination d'installation → Personnalisé → LVM → « Cliquez ici pour les créer automatiquement »* puis on ajuste, ou création à la main avec le bouton `+`.

Exemple pour un disque de 10 Go (10 240 Mio) :

| Point de montage | Type | Taille | FS | Justification |
|------------------|------|--------|----|---------------|
| `/boot/efi` | partition | 600 Mio | vfat | Uniquement en UEFI |
| `/boot` | partition | 1 Gio | xfs | Noyaux + initramfs (3 noyaux conservés) |
| `/` | LV `rl/root` | 2,5 Gio | xfs | Système minimal ≈ 1,5 Go + marge |
| `/home` | LV `rl/home` | 2 Gio | xfs | Images **podman rootless** stockées dans `~/.local/share/containers` |
| `/var` | LV `rl/var` | 1,5 Gio | xfs | Cache dnf, base RPM, images podman **root** (`/var/lib/containers`) |
| `/var/log` | LV `rl/var_log` | 768 Mio | xfs | Logs isolés |
| `/tmp` | LV `rl/tmp` | 512 Mio | xfs | Fichiers temporaires isolés |
| `swap` | LV `rl/swap` | 1 Gio | swap | Filet de sécurité pour 2 Go de RAM |

Il reste quelques centaines de Mio **libres dans le VG** (davantage en BIOS) : volontaire, pour agrandir à chaud le volume qui en aura besoin.

**Bonus – options de montage** (`/etc/fstab`) :
```
/dev/mapper/rl-tmp   /tmp   xfs   defaults,nodev,nosuid,noexec   0 0
```
* `nodev` : interdit les fichiers de périphérique ; `nosuid` : ignore les bits SUID/SGID ; `noexec` : interdit l'exécution de binaires.
* Pertinents sur `/tmp` (et `/var/tmp`, `/dev/shm`) : écrits par tout le monde, cible classique pour déposer un exécutable malveillant. `nodev` a aussi du sens sur `/home`.
* Après modification : `sudo systemctl daemon-reload && sudo mount -o remount /tmp`.

**Réponses :**
* **Podman** : en root → `/var/lib/containers/storage` ; en rootless → `~/.local/share/containers/storage` (donc dans `/home`).
* **XFS** (système par défaut) peut être **agrandi à chaud** (`xfs_growfs`) mais **jamais réduit**. D'où l'intérêt de ne pas tout allouer : il est facile d'ajouter de l'espace, impossible d'en reprendre.
* **`/var/log` séparé** : si un service s'emballe et remplit les logs, seul `/var/log` est plein. Sans séparation, `/` ou `/var` se remplit → dnf, rpm, bases de données, `sshd` (sessions) et parfois le démarrage même échouent.
* **`/home` séparé** : un utilisateur ne peut pas saturer le système ; on peut réinstaller l'OS sans toucher aux données. **`/tmp` séparé** : même logique + options de montage restrictives.
* **`/boot` hors LVM** : le chargeur de démarrage (GRUB) et surtout le firmware doivent lire le noyau **avant** que LVM soit activé. GRUB2 sait lire LVM, mais une partition simple est plus robuste, plus facile à réparer, et c'est indispensable pour `/boot/efi` (le firmware UEFI ne lit que du FAT).
* **Intérêts de LVM** : redimensionner à chaud, ajouter un disque dans un VG existant, snapshots LVM, déplacer des données entre disques (`pvmove`), noms stables (`/dev/rl/var`).
* **Swap** : 1 Go pour 2 Go de RAM. Il évite les arrêts brutaux par l'OOM-killer lors d'un pic (ex : `dnf upgrade`). Pas d'hibernation sur un serveur, donc pas besoin de swap ≥ RAM.

### 5. Comptes

* **Création d'utilisateur** : `lorens`, cocher **« Ajouter des privilèges d'administration à ce compte utilisateur (appartenance au groupe wheel) »**.
* **Compte root** : choisir **« Désactiver le compte root »** (recommandé), ou l'activer avec un mot de passe fort **sans** cocher **« Autoriser la connexion SSH de root avec un mot de passe »**.

**Réponses :**
* L'utilisateur est ajouté au groupe **`wheel`**, autorisé par `/etc/sudoers` (`%wheel ALL=(ALL) ALL`).
* **Désactiver root** = verrouiller son mot de passe : personne ne peut se connecter en root avec un mot de passe (ni console, ni SSH), on passe par `sudo`. **Interdire la connexion SSH de root** (`PermitRootLogin no`) = root peut exister et se connecter en console, mais sshd refuse toute connexion root, **même par clé**. Les deux sont complémentaires.

### 6. Autres options

* **KDUMP** : capture la mémoire du noyau en cas de *kernel panic* pour analyse. Il **réserve** de la RAM au démarrage (paramètre `crashkernel`, ~256 Mo par défaut) qui devient inutilisable. Sur une VM de 2 Go de labo → **désactivé**.
* **Profil de sécurité** : applique un profil **SCAP** (OpenSCAP) dès l'installation (CIS, ANSSI BP-028, PCI-DSS, STIG…) : partitionnement, options de montage, configuration SSH, audit… Utile en production, découverte seulement ici.

### Point de contrôle

```bash
lsblk            # arborescence disques / partitions / LV
lsblk -f         # + systèmes de fichiers et UUID
df -hT           # occupation par point de montage
findmnt          # arborescence des montages
pvs ; vgs ; lvs  # volumes physiques, groupes de volumes, volumes logiques
cat /etc/fstab
sudo id          # test des droits d'administration
```

---

## Partie 3 – Post-installation

### 1. Réseau

```bash
ip -br a                 # adresses
ip r                     # route par défaut
cat /etc/resolv.conf     # DNS utilisés
nmcli device show enp0s3 | grep DNS
ping -c2 1.1.1.1         # connectivité IP
ping -c2 rockylinux.org  # DNS
curl -I https://rockylinux.org
```

* Rocky 10 : le réseau est géré **uniquement par NetworkManager** (plus de scripts `ifcfg`). Les connexions sont stockées au format *keyfile* dans `/etc/NetworkManager/system-connections/*.nmconnection`.

Si besoin, IP fixe sur la carte host-only :
```bash
sudo nmcli con mod enp0s8 ipv4.method manual ipv4.addresses 192.168.56.10/24
sudo nmcli con up enp0s8
```

**Réponse :** si `ping 1.1.1.1` fonctionne, la pile IP, la route et la passerelle sont bonnes. Si `ping rockylinux.org` échoue, c'est que le **nom ne peut pas être converti en IP** : le problème est le DNS (serveur absent ou injoignable dans `resolv.conf`).

### 2. Accès SSH par clé

Sur le **PC** :
```bash
ssh-keygen -t ed25519 -C "lorens@pc"
```

Copie de la clé :
```bash
# Linux / macOS
ssh-copy-id lorens@192.168.56.10
```
```powershell
# Windows (pas de ssh-copy-id)
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh lorens@192.168.56.10 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

Test : `ssh lorens@192.168.56.10` → aucune demande de mot de passe (éventuellement la passphrase de la clé).

Dépannage côté VM :
```bash
sudo journalctl -u sshd -f
ls -ld ~/.ssh ; ls -l ~/.ssh/authorized_keys   # 700 et 600, propriétaire lorens
restorecon -Rv ~/.ssh                           # contexte SELinux si le dossier a été copié
```

* Type recommandé : **Ed25519** (court, rapide, sûr). RSA seulement en 3072/4096 bits pour la compatibilité.

**Réponse :** la **clé publique** est déposée sur les serveurs, elle peut être diffusée librement. La **clé privée** prouve votre identité : elle ne doit **jamais** quitter votre PC (et devrait être protégée par une passphrase).

### 3. Durcissement SSH

Lire **tous** les fichiers de configuration :
```bash
grep -i include /etc/ssh/sshd_config
# Include /etc/ssh/sshd_config.d/*.conf   (en tête de fichier)
ls /etc/ssh/sshd_config.d/
# 01-permitrootlogin.conf  ← créé par l'installeur si la case « SSH root » a été cochée
# 40-redhat-crypto-policies.conf  50-redhat.conf
```

Pour sshd, **la première valeur lue l'emporte**. Les fichiers inclus sont lus par ordre alphabétique **avant** le reste de `sshd_config`. On crée donc un fichier qui passe en premier :

```bash
sudo rm -f /etc/ssh/sshd_config.d/01-permitrootlogin.conf   # s'il existe
sudo vi /etc/ssh/sshd_config.d/00-hardening.conf
```
```
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
Banner /etc/issue.net
```

```bash
sudo sshd -t                                        # test de syntaxe (aucune sortie = OK)
sudo sshd -T | grep -Ei 'permitroot|passwordauth|banner'
sudo systemctl reload sshd
```

* `PermitRootLogin no` : root ne peut pas se connecter du tout. `prohibit-password` (valeur par défaut) : root peut encore se connecter **par clé**. L'exigence du TP impose donc `no`.

Test depuis le PC, **dans une nouvelle session** (garder l'ancienne ouverte) :
```bash
ssh root@192.168.56.10                                       # Permission denied
ssh -o PubkeyAuthentication=no lorens@192.168.56.10          # Permission denied (bonus)
ssh lorens@192.168.56.10                                     # OK
```

### 4. Bannière et messages

| Fichier | Affiché quand |
|---------|---------------|
| `/etc/issue` | Console locale (tty), **avant** le login. Supporte des séquences (`\S`, `\r`, `\4`…) |
| `/etc/issue.net` | Telnet historiquement ; en SSH **seulement** s'il est référencé par la directive `Banner` → **avant** l'authentification |
| `/etc/motd` et `/etc/motd.d/*` | **Après** une connexion réussie (console et SSH, via `pam_motd`) |

```bash
sudo tee /etc/issue.net > /dev/null <<'EOF'
***************************************************************************
                        ACCES RESERVE - AVERTISSEMENT
  L'acces a ce systeme est reserve aux personnes autorisees.
  Toutes les actions sont journalisees et peuvent etre utilisees comme
  preuve. Toute tentative d'acces non autorise est passible de poursuites
  (articles 323-1 et suivants du Code penal).
***************************************************************************
EOF
sudo cp /etc/issue.net /etc/issue    # même avertissement en console

sudo tee /etc/motd > /dev/null <<'EOF'
 Machine : tpl-rocky10.lab.lan  -  Modele Rocky Linux 10.2 (LaMeDuSe)
 Role    : clone source - ne pas utiliser en production
 Contact : admin@lab.lan
EOF
```

#### Découverte des politiques de sécurité

| Mécanisme | Commandes | Résultat attendu |
|-----------|-----------|------------------|
| SELinux | `getenforce`, `sestatus` | `Enforcing`, politique `targeted` |
| firewalld | `sudo firewall-cmd --get-default-zone`, `sudo firewall-cmd --list-all` | Zone `public` ; services `cockpit dhcpv6-client ssh` |
| Crypto-policies | `update-crypto-policies --show` | `DEFAULT` |
| sudo | `sudo journalctl _COMM=sudo`, `sudo grep sudo /var/log/secure` | Chaque commande sudo est tracée |

* **SELinux** : contrôle d'accès **obligatoire** (MAC) qui s'ajoute aux permissions Unix. `Enforcing` = applique et bloque ; `Permissive` = ne bloque pas mais journalise ; `Disabled` = inactif. Refus visibles dans `/var/log/audit/audit.log` (`sudo ausearch -m avc -ts recent`).
* **Crypto-policies** : politique **système** qui fixe les algorithmes autorisés pour OpenSSL, OpenSSH, GnuTLS, NSS… Autres politiques : `LEGACY`, `FUTURE`, `FIPS`, plus des sous-modules (ex : `DEFAULT:SHA1`). Avec Rocky 10, des sous-politiques post-quantiques apparaissent.
* Bonus : retirer `cockpit` de la zone si on ne l'utilise pas : `sudo firewall-cmd --permanent --remove-service=cockpit && sudo firewall-cmd --reload`.

### 5. Hostname

```bash
hostnamectl
sudo hostnamectl set-hostname tpl-rocky10.lab.lan     # si à corriger
echo "192.168.56.10  tpl-rocky10.lab.lan tpl-rocky10" | sudo tee -a /etc/hosts
getent hosts tpl-rocky10.lab.lan
```

* **static** : nom persistant stocké dans `/etc/hostname`. **transient** : nom courant du noyau, éventuellement fourni par DHCP. **pretty** : nom libre « humain » (espaces, accents) pour l'affichage.

### 6. NTP

```bash
systemctl status chronyd
sudo systemctl enable --now chronyd
timedatectl                       # System clock synchronized: yes / NTP service: active
sudo timedatectl set-timezone Europe/Paris
grep -E '^(pool|server)' /etc/chrony.conf   # pool 2.rocky.pool.ntp.org iburst
chronyc sources -v                # la source précédée de ^* est sélectionnée
chronyc tracking                  # décalage, stratum, dernière correction
```

**Réponse :** un **pool** NTP est un nom DNS qui renvoie plusieurs serveurs différents (pool.ntp.org) : chrony en interroge plusieurs, élimine ceux qui sont faux (*falsetickers*) et continue de fonctionner si l'un disparaît. Un serveur unique est un point de défaillance unique et ne permet pas de détecter une heure fausse.

### 7. Dépôts et mises à jour

```bash
dnf repolist            # activés : baseos, appstream, extras
dnf repolist --all      # + désactivés : crb, devel, plus, *-debuginfo, *-source…
ls /etc/yum.repos.d/    # rocky.repo, rocky-addons.repo, rocky-devel.repo, rocky-extras.repo
grep -E 'gpgcheck|gpgkey' /etc/yum.repos.d/rocky.repo
ls /etc/pki/rpm-gpg/    # RPM-GPG-KEY-Rocky-10
rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n'

sudo dnf check-update   # code retour 100 = mises à jour disponibles
sudo dnf upgrade -y
sudo dnf needs-restarting -r   # « Reboot is required… » → redémarrer
sudo reboot
```

**Réponses :**
* **BaseOS** : cœur du système (noyau, glibc, systemd, outils de base), cycle de vie long. **AppStream** : applications, langages, serveurs (nginx, podman, python…), parfois en plusieurs versions. **extras** : paquets complémentaires maintenus par Rocky (ex : `epel-release`, `elrepo-release`, outils de configuration de dépôts tiers).
* **EPEL** (*Extra Packages for Enterprise Linux*) : dépôt communautaire Fedora qui ajoute des milliers de paquets absents de RHEL. **Pas** sur le clone source : il n'est pas nécessaire, il augmente la surface et ses paquets ne bénéficient pas du même support. On l'active plus tard, au cas par cas.
* **GPG** : chaque paquet est signé par Rocky. dnf vérifie la signature → garantit **l'authenticité** (vient bien de Rocky) et **l'intégrité** (non modifié), même si le miroir est compromis.

### 8. Podman

```bash
sudo dnf install -y podman
podman --version
grep lorens /etc/subuid /etc/subgid       # lorens:524288:65536
podman run --rm quay.io/podman/hello      # en tant que lorens, sans sudo
podman info --format '{{.Store.GraphRoot}}'   # /home/lorens/.local/share/containers/storage
```

* **Rootless** : les conteneurs tournent avec les droits de l'utilisateur, sans démon root. Grâce aux **user namespaces**, le root du conteneur est mappé sur l'utilisateur, et les autres UID du conteneur sur la plage définie dans `/etc/subuid` / `/etc/subgid`.
* Les images rootless sont dans `/home` → cohérent avec un `/home` de taille suffisante.

**Réponse :** **Docker** repose sur un **démon** (`dockerd`) qui tourne en root, et le client lui parle via un socket. **Podman** est **sans démon** (chaque conteneur est un processus fils, gérable par systemd) et **rootless** par conception. La CLI est compatible (`alias docker=podman` fonctionne dans la plupart des cas), podman sait aussi gérer des **pods** (concept Kubernetes) et générer/lire du YAML Kubernetes.

---

## Partie 4 – Vérification et finalisation

### 1–2. Script de vérification

```bash
curl -O https://raw.githubusercontent.com/lorensviguie/LaMeDuSe/main/virtualisation/tp/TP1-CloneSourcePropre/check_vm.sh
less check_vm.sh             # lecture AVANT exécution
bash check_vm.sh --help      # affiche l'aide
sudo bash check_vm.sh
```

`wget` n'est pas installé sur une Rocky Minimal, `curl` oui.

**Réponse :** `curl … | sudo bash` exécute en root un contenu **que personne n'a lu**. Si le serveur est compromis, si l'URL est détournée, ou si le téléchargement est **interrompu** au milieu (une ligne `rm -rf /tmp/dossier` coupée en `rm -rf /`), le résultat s'exécute directement avec tous les droits. Le serveur peut même détecter un `curl | bash` et servir un contenu différent de celui affiché dans le navigateur.

Erreurs fréquentes remontées par le script :

| KO | Cause habituelle | Correction |
|----|------------------|-----------|
| Connexion SSH de root encore possible | `01-permitrootlogin.conf` ou valeur `prohibit-password` | Voir P3 §3 |
| Aucune bannière avant l'authentification | `Banner` absent ou fichier vide | `Banner /etc/issue.net` |
| `/var/log` n'est pas un point de montage séparé | Partitionnement automatique | Voir ci-dessous |
| Horloge non synchronisée | NAT sans NTP, chronyd arrêté | `systemctl enable --now chronyd`, attendre, `chronyc makestep` |
| X paquets peuvent être mis à jour | Pas de `dnf upgrade` | `sudo dnf upgrade -y` |
| podman n'est pas installé | — | `sudo dnf install -y podman` |

Rattrapage d'un volume oublié (ex : `/var/log`) **sans réinstaller**, s'il reste de l'espace libre dans le VG (sinon il faudrait réduire un autre volume, ce qui est impossible en XFS → réinstallation) :
```bash
sudo lvcreate -L 768M -n var_log rl
sudo mkfs.xfs /dev/rl/var_log
sudo mount /dev/rl/var_log /mnt
sudo rsync -aAX /var/log/ /mnt/
sudo umount /mnt
echo '/dev/mapper/rl-var_log /var/log xfs defaults 0 0' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload && sudo mount /var/log && sudo restorecon -R /var/log
sudo reboot
```

### 3. Préparer le clonage

**Réponses :**
* **Adresse MAC identique** : deux machines sur le même segment avec la même MAC → les switchs et tables ARP oscillent entre les deux, pertes de paquets, conflits DHCP. VirtualBox : au clonage, choisir **« Générer de nouvelles adresses MAC pour toutes les cartes réseau »**.
* **`/etc/machine-id`** : identifiant unique de l'installation, généré au premier démarrage. Utilisé par **journald** (journaux nommés par machine-id), par **NetworkManager** pour calculer l'identifiant client DHCP/DUID (→ deux clones peuvent recevoir **la même IP** du DHCP), par D-Bus, par certains outils de supervision/inventaire. Deux machines avec le même machine-id sont confondues.
* **Clés d'hôte SSH** : oui, identiques entre clones. Risque : une personne qui récupère la clé privée d'un clone peut **usurper tous les autres** (attaque de l'homme du milieu sans alerte). Le client SSH, lui, verra la même empreinte pour plusieurs IP… ou au contraire, si on régénère, l'alerte `REMOTE HOST IDENTIFICATION HAS CHANGED`.
* Sur chaque nouveau clone : **hostname**, **IP** (si fixe), **machine-id**, **clés d'hôte SSH**.

Scellement manuel juste avant l'extinction (à faire **après** le script) :
```bash
sudo truncate -s 0 /etc/machine-id        # vidé (pas supprimé) → régénéré au prochain boot
sudo rm -f /etc/ssh/ssh_host_*            # régénérées au boot par sshd-keygen@.service
```
* **`virt-sysprep`** (paquet `guestfs-tools`) fait tout cela automatiquement sur une image éteinte (machine-id, clés SSH, logs, historique, utilisateurs…).
* **cloud-init** : les fournisseurs cloud partent d'une image scellée ; au premier démarrage, cloud-init lit les métadonnées de l'instance (hostname, clé SSH, réseau, scripts) et personnalise la machine.

### 4. Extinction

```bash
rm -f ~/check_vm.sh
sudo dnf clean all
sudo rm -rf /tmp/* /var/tmp/*
history -c && cat /dev/null > ~/.bash_history
sudo poweroff
```
Puis dans VirtualBox : **Instantanés → Prendre un instantané** (« clone-source-propre »), ou *Fichier → Exporter un appareil virtuel* (`.ova`).

**Réponses :**
* **Extinction depuis le système** : les services s'arrêtent proprement, les caches sont écrits sur disque, les systèmes de fichiers démontés. **Arrêt brutal** (« Éteindre la machine » dans l'hyperviseur) = coupure de courant : risque de fichiers corrompus, journal XFS à rejouer, données perdues.
* **Clone lié** : partage le disque du parent (différentiel) → instantané et léger, mais dépend du parent (le supprimer casse tous les clones) et les performances peuvent baisser. **Clone intégral** : copie complète et indépendante → plus lent et plus gros, mais autonome et déplaçable.
* **Un snapshot n'est pas une sauvegarde** : il est stocké **au même endroit** que la VM et dépend de son disque. Si le disque hôte meurt ou si le fichier de base est corrompu, le snapshot disparaît avec. Une sauvegarde est une copie **indépendante**, idéalement sur un autre support (règle 3-2-1).
