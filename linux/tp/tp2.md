# TP2 : How to Manage My Services 🧠

## 📋 Objectifs
Dans ce TP, vous allez apprendre à :
- Installer, démarrer et configurer un service sous Linux
- Vérifier l’état d’un service avec `systemctl`
- Modifier un fichier de configuration système
- Créer et tester votre propre service

---

## 🧱 Prérequis

1. Une machine virtuelle **Linux** (de préférence Rocky 9.6 ou équivalent)
2. Un accès réseau fonctionnel (test : `ping google.com` doit répondre)
3. Les droits **sudo**

---

## 🧩 Sommaire
1. [Installation et création d’un service SSH](#1-installation-et-création-dun-service-ssh)  
2. [Installation d’un service Nginx (Reverse Proxy)](#2-installation-dun-service-nginx-reverse-proxy)  
3. [Création de votre propre service](#3-création-de-votre-propre-service)  
4. [Questions à rendre](#4-questions-à-rendre)

---

## 1️⃣ Installation et création d’un service SSH

### Étape 1 : Installation du paquet

Sous Rocky Linux / RHEL :
```bash
sudo dnf install openssh-server -y
```

Sous Debian / Ubuntu :
```bash
sudo apt install openssh-server -y
```

👉 Une fois installé :
- Le service `sshd` est ajouté au système
- Un fichier de configuration est créé : `/etc/ssh/sshd_config`

---

### Étape 2 : Lancement du service

Démarrer et activer le service au démarrage :
```bash
sudo systemctl start sshd
sudo systemctl enable sshd
```

Vérifiez qu’il fonctionne :
```bash
sudo systemctl status sshd
```

💡 **Astuce :**
Un service *actif (running)* signifie qu’il tourne correctement.

---

### Étape 3 : Test de connexion

Depuis votre VM :
```bash
ssh localhost
```
👉 Si tout fonctionne, vous êtes connecté à vous-même via SSH !

---

### Étape 4 : Modification de la configuration

Éditez le fichier de configuration :
```bash
sudo nano /etc/ssh/sshd_config
```

Quelques options intéressantes :
```ini
Port 2222               # Change le port d’écoute
PermitRootLogin no      # Interdit la connexion du compte root
PasswordAuthentication no  # Désactive la connexion par mot de passe
```

Rechargez ensuite le service :
```bash
sudo systemctl reload sshd
```

---

## 2️⃣ Installation d’un service Nginx (Reverse Proxy)

### Étape 1 : Installation

```bash
sudo dnf install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Étape 2 : Vérification

Ouvrez un navigateur ou utilisez `curl` :
```bash
curl http://localhost
```
👉 Vous devriez voir la page par défaut de Nginx.

### Étape 3 : Configuration de base

Les fichiers de configuration se trouvent dans :
```
/etc/nginx/nginx.conf
/etc/nginx/conf.d/
```

Essayez d’ajouter un **nouveau site** :
```bash
sudo nano /etc/nginx/conf.d/test.conf
```

Exemple de configuration minimale :
```nginx
server {
    listen 8080;
    server_name localhost;

    location / {
        root /var/www/html;
        index index.html;
    }
}
```

Redémarrez ensuite :
```bash
sudo systemctl reload nginx
```

Testez :
```bash
curl http://localhost:8080
```

---

## 3️⃣ Création de votre propre service

Un service est décrit par un fichier **systemd**.

### Étape 1 : Créez un script simple

```bash
sudo nano /usr/local/bin/hello_service.sh
```

Contenu :
```bash
#!/bin/bash
while true; do
    echo "Hello from my service!" >> /var/log/hello_service.log
    sleep 10
done
```

Rendez-le exécutable :
```bash
sudo chmod +x /usr/local/bin/hello_service.sh
```

---

### Étape 2 : Créez le fichier systemd

```bash
sudo nano /etc/systemd/system/hello.service
```

Contenu :
```ini
[Unit]
Description=Mon premier service systemd
After=network.target

[Service]
ExecStart=/usr/local/bin/hello_service.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Rechargez la configuration :
```bash
sudo systemctl daemon-reload
```

Activez et démarrez votre service :
```bash
sudo systemctl enable hello.service
sudo systemctl start hello.service
```

Vérifiez :
```bash
sudo systemctl status hello.service
tail -f /var/log/hello_service.log
```

---

## 4️⃣ Questions à rendre 📝

1. Quelle commande permet de voir si un service est **activé au démarrage** ?
2. Quelle est la différence entre `start`, `enable` et `restart` ?
3. Que fait la directive `WantedBy=multi-user.target` dans un fichier service ?
4. Quel est le port utilisé par SSH par défaut ?
5. Comment changer ce port ?
6. Que fait `systemctl reload` comparé à `systemctl restart` ?
7. Donnez un exemple de log produit par votre service personnalisé.
8. Comment forcer le redémarrage automatique d’un service en cas de crash ?
9. Où sont stockés les fichiers de configuration système sous Linux ?
10. Quelle commande permet de voir tous les services actifs ?

---

✅ **Fin du TP2 – Bravo !**
