# Correction – TP3 Linux : Service web sécurisé & conteneurs

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

> 📌 Cette correction propose **une** solution valide parmi d'autres. Le service conteneurisé d'exemple est `traefik/whoami` (il renvoie les en-têtes HTTP reçus, ce qui est très pratique pour vérifier le reverse proxy).
>
> Conventions : VM `web01.lab.lan` en `192.168.56.20`, utilisateur `lorens`, site dans `/srv/www/lamedu`.

---

## Partie 1 – Installer Nginx et publier une page personnalisée

### 1. Installation et service

```bash
sudo dnf install -y nginx
sudo systemctl enable --now nginx
systemctl status nginx
curl -I http://localhost
dnf info nginx              # dépôt : appstream ; version : 1.26.x (selon les mises à jour)
systemctl cat nginx         # /usr/lib/systemd/system/nginx.service
ps -eo user,pid,ppid,cmd | grep [n]ginx
sudo ss -tlnp | grep nginx  # 0.0.0.0:80 et [::]:80
```

Extrait de l'unité livrée :
```ini
[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
PrivateTmp=true
```

**Réponses :**
* Paquet `nginx` du dépôt **AppStream**.
* `ExecStartPre` : supprime un ancien fichier PID puis **teste la configuration** (`nginx -t`). Si la config est invalide, le service ne démarre pas.
* Un **master** (utilisateur `root`) et des **workers** (utilisateur `nginx`), un par vCPU avec `worker_processes auto` → 1 worker ici. Le master lit la config, ouvre les ports privilégiés et les logs, puis gère les workers (rechargement sans coupure, redémarrage d'un worker planté). Les workers, non privilégiés, traitent les requêtes.
* Écoute sur **toutes les adresses** IPv4 et IPv6, port **80**.

### 2. Accès depuis le PC

C'est **firewalld** qui bloque (zone `public` : seuls `ssh`, `cockpit` et `dhcpv6-client` sont ouverts).

```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
sudo firewall-cmd --list-services
```

Depuis le PC : `http://192.168.56.20` (IP host-only). En NAT seul, il faut une redirection de port VirtualBox (ex : hôte 8080 → invité 80).

### 3. Page personnalisée

```bash
sudo mkdir -p /srv/www/lamedu
sudo tee /srv/www/lamedu/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="utf-8"><title>LaMeDuSe - web01</title></head>
<body><h1>Bienvenue sur web01.lab.lan</h1><p>TP3 Linux - Lorens</p></body>
</html>
EOF
sudo chown -R root:root /srv/www
sudo chmod -R u=rwX,go=rX /srv/www
```

`/etc/nginx/conf.d/lamedu.conf` (le dossier `conf.d/*.conf` est inclus par `nginx.conf`) :
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name web01.lab.lan _;

    root /srv/www/lamedu;
    index index.html;

    access_log /var/log/nginx/lamedu.access.log;
    error_log  /var/log/nginx/lamedu.error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
sudo nginx -t
```
Si `nginx -t` signale `a duplicate default server for 0.0.0.0:80`, retirer `default_server` des directives `listen` du bloc `server` présent dans `/etc/nginx/nginx.conf` (ou commenter ce bloc entier).

```bash
sudo systemctl reload nginx
curl http://localhost       # → 403 Forbidden !
```

**Le 403 vient de SELinux** : `/srv/www` a le contexte `var_t`, alors que Nginx (domaine `httpd_t`) ne peut lire que `httpd_sys_content_t`.

```bash
ls -Zd /usr/share/nginx/html /srv/www/lamedu
sudo ausearch -m avc -ts recent | tail
sudo dnf install -y policycoreutils-python-utils     # fournit semanage (absent d'une Minimal)
sudo semanage fcontext -a -t httpd_sys_content_t "/srv/www(/.*)?"
sudo restorecon -Rv /srv/www
curl http://localhost       # → votre page
```

* `restart` arrête puis relance le service (**coupure**) ; `reload` demande au master de relire la config et de remplacer les workers progressivement (**sans coupure**). Si la nouvelle config est invalide, `reload` garde l'ancienne.
* `default_server` : bloc utilisé quand l'en-tête `Host` de la requête ne correspond à aucun `server_name` (accès par IP, par exemple).

**Réponses :**
* Logs : `/var/log/nginx/access.log` et `error.log` (ici `lamedu.access.log` / `lamedu.error.log`). `sudo tail -f /var/log/nginx/lamedu.access.log` en rafraîchissant la page depuis le PC.
* `chcon` change le contexte **immédiatement mais pas durablement** : un `restorecon` ou un *relabel* complet du système (`/.autorelabel`) le remet à la valeur de la politique. `semanage fcontext` modifie la **politique** elle-même, et `restorecon` l'applique.
* Les fichiers du site appartiennent à **root** (ou à un compte de déploiement) ; Nginx n'a besoin que de **lire**. Si le site appartenait à `nginx`, une faille dans Nginx permettrait de **modifier** le site (défiguration, dépôt de code malveillant).

---

## Partie 2 – Durcissement du service

### 1. Mesure initiale

```bash
systemd-analyze security nginx
# → Overall exposure level for nginx.service: 9.x UNSAFE 😨
```

### 2. Drop-in

```bash
sudo systemctl edit nginx      # crée /etc/systemd/system/nginx.service.d/override.conf
systemctl cat nginx            # unité finale = fichier livré + surcharges
sudo systemctl daemon-reload   # après une modification manuelle d'un fichier d'unité
```

**Réponse :** `/usr/lib/systemd/system/` appartient au **paquet**. À la prochaine mise à jour de nginx, le fichier est **écrasé** et les modifications perdues. `/etc/systemd/system/` appartient à l'administrateur et a priorité.

### 3 & 4. Nginx sans root + bac à sable

**Modifications de `/etc/nginx/nginx.conf` :**
```nginx
# user nginx;                 ← commenté : n'a de sens que si le master démarre en root
pid /run/nginx/nginx.pid;     # /run/nginx sera créé par systemd et appartiendra à nginx
```

**`/etc/systemd/system/nginx.service.d/override.conf` :**
```ini
[Service]
# --- Exécution sans root ---
User=nginx
Group=nginx
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

# Le fichier PID change d'emplacement ; on remplace les ExecStartPre d'origine
# (le "rm -f /run/nginx.pid" échouerait sans droits sur /run)
PIDFile=/run/nginx/nginx.pid
ExecStartPre=
ExecStartPre=/usr/sbin/nginx -t

# Dossiers créés / attribués automatiquement à User= et rendus inscriptibles
RuntimeDirectory=nginx
RuntimeDirectoryMode=0750
LogsDirectory=nginx
StateDirectory=nginx
UMask=0027

# --- Système de fichiers ---
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes

# --- Privilèges ---
NoNewPrivileges=yes
RestrictSUIDSGID=yes

# --- Noyau / matériel ---
PrivateDevices=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHostname=yes
ProtectProc=invisible
ProcSubset=pid

# --- Réseau ---
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6

# --- Divers ---
LockPersonality=yes
RestrictNamespaces=yes
RestrictRealtime=yes
MemoryDenyWriteExecute=yes
RemoveIPC=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources
SystemCallErrorNumber=EPERM
```

```bash
sudo systemctl daemon-reload
sudo nginx -t
sudo systemctl restart nginx
systemctl status nginx
journalctl -u nginx -n 30        # en cas d'échec : lire l'erreur exacte
ps -eo user,pid,cmd | grep [n]ginx   # nginx … master / nginx … worker — aucun root
curl http://localhost
systemd-analyze security nginx   # ≈ 2 à 3 (OK / MEDIUM) selon la version de systemd
```

Erreurs typiques rencontrées en chemin :

| Erreur dans le journal | Cause | Solution |
|------------------------|-------|----------|
| `bind() to 0.0.0.0:80 failed (13: Permission denied)` | Pas de capability | `AmbientCapabilities=CAP_NET_BIND_SERVICE` |
| `open() "/run/nginx.pid" failed (13: Permission denied)` | `/run` appartient à root | `RuntimeDirectory=` + directive `pid` + `PIDFile=` |
| `open() "/var/log/nginx/error.log" failed (13…)` | Logs créés par root | `LogsDirectory=nginx` (ré-attribue le dossier) |
| `mkdir() "/var/lib/nginx/tmp/client_body" failed (30: Read-only file system)` | `ProtectSystem=strict` | `StateDirectory=nginx` (ou `ReadWritePaths=`) |
| Processus tué par `SIGSYS` | Appel système filtré | Ajuster `SystemCallFilter=` ou garder `SystemCallErrorNumber=` |
| `open() "/var/log/nginx/xxx.log" failed` après un `sudo nginx -t` | `nginx -t` lancé en root a créé un nouveau fichier de log appartenant à root | `sudo chown nginx:nginx /var/log/nginx/*` ; désormais tester avec `sudo -u nginx nginx -t` |

**Réponses :**
* Avec `ProtectSystem=strict`, **toute l'arborescence est montée en lecture seule** pour le service, sauf `/dev`, `/proc`, `/sys` (eux-mêmes restreints par d'autres directives) et les chemins explicitement autorisés : `RuntimeDirectory`, `StateDirectory`, `LogsDirectory`, `CacheDirectory`, `ReadWritePaths`. Ici Nginx n'écrit que dans `/run/nginx`, `/var/lib/nginx` et `/var/log/nginx`.
* Familles réseau : **`AF_INET` / `AF_INET6`** pour écouter et pour joindre le service local en TCP (partie 4), **`AF_UNIX`** pour le journal/systemd (et pour un éventuel `proxy_pass` vers un socket Unix).
* **`CapabilityBoundingSet`** = la **limite maximale** des capabilities que le processus et ses enfants pourront jamais obtenir (tout le reste est supprimé définitivement). **`AmbientCapabilities`** = capabilities **réellement accordées** à un processus non-root et conservées à l'`execve`. L'ambient doit être inclus dans le bounding set.

### 5. Configuration Nginx

Dans le bloc `http` de `nginx.conf` :
```nginx
server_tokens off;
```

Dans `/etc/nginx/conf.d/lamedu.conf` :
```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name web01.lab.lan _;
    root /srv/www/lamedu;
    index index.html;

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'" always;

    location / {
        limit_except GET { deny all; }     # GET implique HEAD
        try_files $uri $uri/ =404;
    }
}
```

Permissions :
```bash
sudo chown -R root:root /etc/nginx /srv/www
sudo find /etc/nginx /srv/www -type d -exec chmod 755 {} \;
sudo find /etc/nginx /srv/www -type f -exec chmod 644 {} \;
```

Tests :
```bash
sudo nginx -t && sudo systemctl reload nginx
curl -I http://localhost                 # Server: nginx   (sans numéro de version) + en-têtes
curl -X POST -I http://localhost         # 403 Forbidden
curl -I http://localhost/inexistant      # 404 sans version dans la page
```

---

## Partie 3 – Service conteneurisé isolé

### 1. Choix du service

`docker.io/traefik/whoami` : image officielle de l'éditeur Traefik, très légère.

**Réponses :**
* Privilégier les images **officielles** ou d'éditeurs vérifiés, sur un registre connu (`docker.io`, `quay.io`, `ghcr.io`), et vérifier leur maintenance (date de mise à jour, Dockerfile public).
* Le **tag** identifie une version de l'image. `latest` est **mobile** : le même nom désigne une image différente demain → déploiements non reproductibles, mises à jour non maîtrisées. En production : tag de version précis, voire **digest** (`@sha256:…`).
* **Short-names** : sans registre, podman consulte les alias de `/etc/containers/registries.conf.d/000-shortnames.conf`, sinon les registres de `unqualified-search-registries` dans `/etc/containers/registries.conf` (et demande lequel choisir en mode `enforcing`). Bonne pratique : **toujours** écrire le nom complet, pour éviter le *typosquatting* sur un autre registre.

### 2–3. Lancement rootless et isolation

En tant que `lorens` :
```bash
podman run -d --name whoami -p 127.0.0.1:8080:80 docker.io/traefik/whoami:v1.10
podman ps
podman logs whoami
podman port whoami          # 80/tcp -> 127.0.0.1:8080
curl http://127.0.0.1:8080  # OK depuis la VM
ss -tln | grep 8080         # LISTEN 127.0.0.1:8080 uniquement
```

Depuis le PC :
```bash
curl http://192.168.56.20:8080    # Connection refused
```

**Réponses :**
* `-p 8080:80` écoute par défaut sur **`0.0.0.0`** (toutes les interfaces) → exposé. La forme `-p IP:port_hôte:port_conteneur` choisit l'adresse : `127.0.0.1` = joignable **uniquement depuis la VM**.
* Sans port publié, un conteneur rootless n'est **pas** joignable depuis l'hôte : son réseau est dans un namespace séparé (pasta/slirp4netns) sans route depuis l'hôte. On peut alors le joindre depuis un **autre conteneur** du même réseau podman ou du même **pod** (c'est l'approche de la partie 5).
* **Le pare-feu ne suffit pas forcément** : **Docker** (et podman en **root**, via netavark) publie les ports en ajoutant ses propres règles **DNAT** dans iptables/nftables, traitées **avant** les règles de filtrage de firewalld → un port publié sur `0.0.0.0` est joignable même si firewalld ne l'autorise pas. En **rootless**, le port est ouvert par un processus utilisateur sur l'hôte (pasta / rootlessport) : le trafic passe par la chaîne INPUT classique, donc firewalld s'applique.
* Ne **pas exposer** est la défense la plus sûre : rien n'écoute, donc rien à filtrer, aucune dépendance à une règle de pare-feu qui peut être modifiée, contournée ou oubliée (défense en profondeur).

### 4. Persistance avec Quadlet

```bash
podman rm -f whoami
mkdir -p ~/.config/containers/systemd
```

`~/.config/containers/systemd/whoami.container` :
```ini
[Unit]
Description=Service whoami (TP3)

[Container]
Image=docker.io/traefik/whoami:v1.10
ContainerName=whoami
PublishPort=127.0.0.1:8080:80

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload          # le générateur Quadlet crée whoami.service
systemctl --user start whoami.service   # (pas de "enable" : la section [Install] s'en charge)
systemctl --user status whoami.service
sudo loginctl enable-linger lorens      # services utilisateur démarrés au boot, sans session
sudo reboot
# après reboot, sans se connecter à la console : depuis une session SSH
curl http://127.0.0.1:8080
```

* Données persistantes (si le service en a) : `Volume=whoami-data:/data` (volume nommé) ou `Volume=%h/whoami:/data:Z`. **`:Z`** ré-étiquette le dossier avec un label SELinux **privé** au conteneur (`:z` = label partagé entre plusieurs conteneurs). Sans cela, SELinux interdit au conteneur d'accéder au dossier.

**Réponse :** `podman generate systemd` produisait un fichier d'unité **figé** à partir d'un conteneur existant : à régénérer à chaque changement, verbeux, facile à désynchroniser. **Quadlet** est **déclaratif** : on décrit le conteneur dans un fichier court, et un générateur systemd produit l'unité à chaque `daemon-reload`. Déprécié depuis podman 4.4.

---

## Partie 4 – Reverse proxy

### 1. Réponses

* **Reverse proxy** : serveur placé **devant** une ou plusieurs applications, qui reçoit les requêtes des clients et les relaie vers le bon service. Le client ne voit que le proxy. Un **forward proxy** est placé côté **clients** et relaie leurs requêtes vers Internet (filtrage, cache, anonymisation).
* Intérêts : un seul point d'entrée exposé, **terminaison TLS** centralisée, masquage des services internes, **logs** et contrôle d'accès centralisés, cache, compression, **répartition de charge**, réécriture d'URL, limitation de débit.

### 2. Configuration

**Approche par chemin**, dans `/etc/nginx/conf.d/lamedu.conf` (bloc `server` existant) :
```nginx
    location /app/ {
        limit_except GET { deny all; }
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
```

* **Slash final** : avec `proxy_pass http://127.0.0.1:8080/;` (URI présente), Nginx **remplace** le préfixe `/app/` par `/` → `/app/test` arrive en `/test`. Avec `proxy_pass http://127.0.0.1:8080;` (sans URI), l'URL est transmise **telle quelle** → `/app/test`. whoami affiche la ligne `GET /…` reçue, ce qui permet de le constater.
* **WebSockets** :
  ```nginx
  proxy_http_version 1.1;
  proxy_set_header Upgrade    $http_upgrade;
  proxy_set_header Connection "upgrade";
  ```

**Approche par nom**, `/etc/nginx/conf.d/app.conf` :
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name app.lab.lan;
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Sur le PC, fichier hosts (`C:\Windows\System32\drivers\etc\hosts` en administrateur, ou `/etc/hosts`) :
```
192.168.56.20  web01.lab.lan app.lab.lan
```

### 3. Débogage du 502

```bash
sudo nginx -t && sudo systemctl reload nginx
curl -i http://localhost/app/                     # 502 Bad Gateway
sudo tail /var/log/nginx/lamedu.error.log
# connect() to 127.0.0.1:8080 failed (13: Permission denied) while connecting to upstream
sudo ausearch -m avc -ts recent
# avc: denied { name_connect } for comm="nginx" dest=8080 scontext=…httpd_t tcontext=…http_cache_port_t
sudo ausearch -m avc -ts recent | audit2why      # indique le booléen à activer
getsebool -a | grep httpd_can_network
```

Correction **persistante** (`-P`) :
```bash
sudo setsebool -P httpd_can_network_relay 1     # autorise httpd vers les ports « proxy » (http_port_t, http_cache_port_t…) dont 8080
# ou, plus large :
sudo setsebool -P httpd_can_network_connect 1   # autorise httpd vers n'importe quel port TCP
curl -i http://localhost/app/                   # 200 + sortie de whoami
```

`httpd_can_network_relay` est le choix le plus restrictif ici car 8080 est étiqueté `http_cache_port_t` (`sudo semanage port -l | grep 8080`). Si le service écoute sur un port non standard, on peut aussi lui attribuer un type : `sudo semanage port -a -t http_port_t -p tcp 9123`.

Côté systemd : `RestrictAddressFamilies` contient bien `AF_INET`, aucun `IPAddressDeny=` n'a été ajouté → rien à changer. (Si un élève a mis `IPAddressDeny=any`, il faut `IPAddressAllow=localhost`.)

**Réponse :** par défaut, un serveur web ne fait que **répondre**. S'il ouvre des connexions sortantes, c'est souvent le signe d'une **compromission** : rebond vers d'autres services internes (mouvement latéral, base de données), exploitation **SSRF**, envoi de spam, connexion vers un serveur de commande (*reverse shell*). SELinux limite ce que peut faire un Nginx compromis.

### 4. Bonus HTTPS

```bash
sudo openssl req -x509 -newkey rsa:4096 -nodes -days 365 \
  -keyout /etc/pki/tls/private/web01.key \
  -out /etc/pki/tls/certs/web01.crt \
  -subj "/CN=web01.lab.lan" \
  -addext "subjectAltName=DNS:web01.lab.lan,DNS:app.lab.lan,IP:192.168.56.20"
sudo chown root:nginx /etc/pki/tls/private/web01.key   # nginx n'est plus root → doit pouvoir lire la clé
sudo chmod 640 /etc/pki/tls/private/web01.key
sudo restorecon -v /etc/pki/tls/private/web01.key /etc/pki/tls/certs/web01.crt   # cert_t
sudo firewall-cmd --permanent --add-service=https && sudo firewall-cmd --reload
```

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    http2 on;
    server_name web01.lab.lan;

    ssl_certificate     /etc/pki/tls/certs/web01.crt;
    ssl_certificate_key /etc/pki/tls/private/web01.key;

    # … root, add_header, location / et location /app/ comme avant
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

---

## Partie 5 – Bonus : Nginx conteneurisé

### 1. Préparation

* Besoins : configuration (`conf.d/lamedu.conf`), site (`/srv/www/lamedu`), éventuellement certificats, logs (envoyés sur stdout/stderr dans l'image → `podman logs`), port 80.
* **`nginx`** (officielle) : le master démarre en **root** dans le conteneur et écoute sur 80. **`nginxinc/nginx-unprivileged`** : tout tourne en **UID 101**, écoute sur **8080** (un non-root ne peut pas lier un port < 1024), PID dans `/tmp`. → Cohérente avec la partie 2.

### 2–3. Réseau et montages

On copie la configuration dans le home de `lorens` : un conteneur rootless ne peut pas ré-étiqueter (`:Z`) des fichiers appartenant à root, et ré-étiqueter `/srv/www` casserait le Nginx système pendant la migration.

```bash
mkdir -p ~/web/conf.d ~/web/html
cp /srv/www/lamedu/* ~/web/html/
```

`~/web/conf.d/default.conf` :
```nginx
server_tokens off;

server {
    listen 8080 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        limit_except GET { deny all; }
        try_files $uri $uri/ =404;
    }

    location /app/ {
        proxy_pass http://whoami:80/;           # nom du conteneur, résolu par aardvark-dns
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Test manuel :
```bash
podman network create webnet          # réseau dédié → DNS interne entre conteneurs
systemctl --user stop whoami.service
podman run -d --name whoami --network webnet docker.io/traefik/whoami:v1.10      # aucun port publié
podman run -d --name nginx --network webnet -p 8080:8080 \
  -v ~/web/conf.d:/etc/nginx/conf.d:ro,Z \
  -v ~/web/html:/usr/share/nginx/html:ro,Z \
  docker.io/nginxinc/nginx-unprivileged:1.27-alpine
podman exec nginx nginx -t
curl http://127.0.0.1:8080/app/
```

* Sur le réseau par défaut `podman`, **pas de DNS** entre conteneurs ; sur un réseau créé (`webnet`), chaque conteneur est joignable **par son nom**.
* **Pod** : les conteneurs d'un même pod partagent le **namespace réseau** (même IP, `localhost` commun) → `proxy_pass http://127.0.0.1:80`. On publie les ports au niveau du pod.
* `:z` = label SELinux **partagé** (plusieurs conteneurs peuvent lire) ; `:Z` = label **privé** (un seul conteneur). `ro` = lecture seule.

### 4. Port 80 en rootless

Option retenue : abaisser le premier port non privilégié.
```bash
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/90-unprivileged-ports.conf
sudo sysctl --system
```
→ on publie `-p 80:8080`.

* Alternative : garder `-p 8080:8080` et rediriger avec firewalld :
  `sudo firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080 && sudo firewall-cmd --reload` (fonctionne pour le trafic entrant, pas pour `curl localhost`).
* Conteneur rootful : simple, mais on perd l'isolation rootless (un échappement du conteneur donne root sur l'hôte) et les ports publiés contournent firewalld.

### 5. Bascule et persistance Quadlet

```bash
podman rm -f nginx whoami
sudo systemctl disable --now nginx      # le paquet reste installé : retour arrière possible
rm ~/.config/containers/systemd/whoami.container
```

`~/.config/containers/systemd/webnet.network` :
```ini
[Network]
NetworkName=webnet
```

`~/.config/containers/systemd/whoami.container` :
```ini
[Unit]
Description=Service whoami (TP3)

[Container]
Image=docker.io/traefik/whoami:v1.10
ContainerName=whoami
Network=webnet.network

[Service]
Restart=always

[Install]
WantedBy=default.target
```

`~/.config/containers/systemd/nginx.container` :
```ini
[Unit]
Description=Nginx reverse proxy conteneurisé (TP3)
Requires=whoami.service
After=whoami.service

[Container]
Image=docker.io/nginxinc/nginx-unprivileged:1.27-alpine
ContainerName=nginx
Network=webnet.network
PublishPort=80:8080
Volume=%h/web/conf.d:/etc/nginx/conf.d:ro,Z
Volume=%h/web/html:/usr/share/nginx/html:ro,Z
ReadOnly=true
Tmpfs=/tmp
DropCapability=ALL
NoNewPrivileges=true

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```bash
podman network rm webnet 2>/dev/null     # recréé et géré par Quadlet
systemctl --user daemon-reload
systemctl --user start nginx.service     # démarre aussi webnet-network.service et whoami.service
systemctl --user status nginx whoami
curl -I http://localhost/                # Server: nginx (sans version)
sudo reboot                              # puis vérifier depuis le PC
```

Depuis le PC : `http://192.168.56.20/` et `http://192.168.56.20/app/` fonctionnent ; whoami n'a **aucun** port publié (`ss -tln` ne montre que `*:80` et `*:22`).

**Alternative compose** (`podman compose` ou `docker compose`) :
```yaml
services:
  whoami:
    image: docker.io/traefik/whoami:v1.10
    restart: always
  nginx:
    image: docker.io/nginxinc/nginx-unprivileged:1.27-alpine
    restart: always
    ports: ["80:8080"]
    depends_on: [whoami]
    read_only: true
    tmpfs: [/tmp]
    volumes:
      - ./conf.d:/etc/nginx/conf.d:ro,Z
      - ./html:/usr/share/nginx/html:ro,Z
```
Compose est plus portable (même fichier sous Docker) et lisible d'un bloc ; Quadlet s'intègre nativement à systemd (démarrage au boot, dépendances, `journalctl`, `systemctl status`) sans outil supplémentaire.

### 6. Bilan

| Critère | Nginx système durci | Nginx conteneurisé |
|---------|--------------------|--------------------|
| Isolation | Bac à sable systemd + SELinux, mais partage le système de fichiers de l'hôte | Namespaces (FS, réseau, PID, users) + SELinux + rootless |
| Mises à jour | `dnf upgrade` avec l'OS, version figée par la distribution | Changer le tag de l'image, retour arrière immédiat, version au choix |
| Déploiement | Paquet + config sur chaque machine | Image + fichiers de config, identique partout |
| Logs | `/var/log/nginx`, journald | `podman logs` / journald |
| Débogage | Outils de l'hôte directement disponibles | Image minimale, il faut `podman exec` ou des outils externes |

* **Système** : serveur dédié simple, équipe habituée aux paquets, besoin de support éditeur (version RHEL maintenue), performances maximales.
* **Conteneur** : plusieurs applications sur la même machine, besoin de versions différentes, déploiement reproductible, CI/CD, préparation à Kubernetes.
* Pour reproduire sur une 2ᵉ VM : cloner le modèle du TP1, puis appliquer automatiquement la configuration (dépôt Git avec les fichiers Quadlet et la config Nginx + un script, un playbook **Ansible** ou **cloud-init**).
