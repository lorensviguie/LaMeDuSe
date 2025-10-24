# 🐳 TP – Préparation et Configuration de son Environnement Docker

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Mettre en place un environnement de travail Docker propre et sécurisé, prêt à accueillir vos futurs conteneurs et projets.  
Ce TP s’adresse aux étudiants ou administrateurs souhaitant utiliser Docker dans un environnement Linux ou Windows.

---

## 🧩 1. Choix de l’environnement

### Option 1 — Sous **Linux (recommandé ✅)**  
C’est la solution la plus stable et la plus proche d’un environnement de production.

- Utilisez une **petite machine virtuelle Linux** (Ubuntu, Debian, Rocky, CentOS, etc.)
- Allouez au minimum :
  - **2 vCPU**
  - **2 Go de RAM**
  - **10 Go d’espace disque**
- Assurez-vous que la machine a accès à Internet.

### Option 2 — Sous **Windows (avec Docker Desktop)**  
Si vous êtes sur Windows sans hyperviseur (ni WSL2, ni VirtualBox), installez **Docker Desktop**.  
> ⚠️ Cette option est pratique pour découvrir Docker, mais **moins adaptée** pour des environnements de production ou pour certains TP réseau.

---

## ✅ 2. Prérequis – Checklist

Avant de démarrer, assurez-vous de valider chaque point suivant :

### 🔐 Utilisateur et accès SSH

- Créez un **utilisateur dédié** à Docker (évitez d’utiliser `root`) :
  ```bash
  sudo adduser dockeruser
  sudo usermod -aG sudo dockeruser
  ```
- Configurez un **accès SSH** avec clé :
  ```bash
  ssh-keygen -t ed25519
  ssh-copy-id dockeruser@docker1
  ```
- Vérifiez la connexion :
  ```bash
  ssh dockeruser@docker1
  ```

### 🧱 Installation de Docker

1. **Installer Docker Engine** :
   ```bash
   sudo apt update
   sudo apt install -y ca-certificates curl gnupg lsb-release
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   echo      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]      https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io
   ```

2. **Vérifier l’installation** :
   ```bash
   docker --version
   sudo systemctl enable --now docker
   sudo systemctl status docker
   ```

3. **Tester Docker** :
   ```bash
   sudo docker run hello-world
   ```

### 👤 Droits utilisateur Docker

- Ajoutez votre utilisateur au groupe Docker :
  ```bash
  sudo usermod -aG docker dockeruser
  ```
- Déconnectez-vous et reconnectez-vous, puis testez :
  ```bash
  docker ps
  ```
> Vous ne devez **plus avoir besoin de `sudo`** pour exécuter les commandes Docker.

---

## 🔥 3. Sécurité et configuration système

### 🧱 Pare-feu
Assurez-vous que le **pare-feu est actif** et que le port SSH est ouvert :

```bash
sudo ufw enable
sudo ufw allow OpenSSH
sudo ufw status
```

### 🚫 SELinux (si activé par défaut)
Certaines distributions (Rocky, CentOS, Fedora) activent SELinux par défaut.  
Cela peut bloquer certaines actions Docker.  
Pour le désactiver temporairement :
```bash
sudo setenforce 0
```
Pour le désactiver de façon permanente :
```bash
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

### 🧩 Vérification réseau
Assurez-vous que Docker crée bien son réseau interne :
```bash
docker network ls
```

---

## 🧰 4. Vérifications finales

| Test | Commande | Résultat attendu |
|------|-----------|------------------|
| Docker fonctionne | `docker ps` | Liste vide (pas d’erreur) |
| Version Docker | `docker --version` | Affiche la version installée |
| Connexion SSH | `ssh dockeruser@docker1` | Accès sans mot de passe |
| Pare-feu actif | `sudo ufw status` | "active" |
| SELinux désactivé | `getenforce` | "Permissive" ou "Disabled" |

---

## 🚀 5. Étape suivante

Vous êtes prêt à :
- Créer vos premiers conteneurs (`docker run nginx`)
- Gérer vos images (`docker images`)
- Monter un Swarm ou Compose

---

> 💡 **Conseil :** prenez un instant pour créer un *snapshot* ou une *sauvegarde* de votre VM maintenant que votre environnement est prêt.
