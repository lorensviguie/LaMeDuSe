# Partie 3 – Lancer un service conteneurisé isolé

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Faire tourner un service dans un **conteneur** (podman recommandé, docker accepté) qui soit **injoignable** depuis votre PC et depuis Internet. Seule la VM elle-même doit pouvoir le contacter.

---

## 🧩 1. Choisir un service

Le choix est libre, tant que c'est un service accessible en HTTP. Quelques idées :

* une petite application web de démonstration (ex : `traefik/whoami`, `nginxdemos/hello`) ;
* un outil auto-hébergé (ex : Uptime Kuma, Gitea, IT-Tools, Vaultwarden…) ;
* votre propre image construite lors des TP Docker.

❓ **Questions :**
* D'où vient l'image ? Le **registre** est-il de confiance ? L'image est-elle officielle ?
* Que signifie le *tag* d'une image ? Pourquoi éviter `latest` en production ?
* Lorsque vous ne précisez pas de registre, lequel podman utilise-t-il ? (Regardez `/etc/containers/registries.conf` et la notion de *short-name*.)

---

## 🧩 2. Lancer le conteneur en rootless

* Lancez le conteneur **avec votre utilisateur**, sans sudo.
* Vérifiez qu'il tourne, consultez ses logs, et testez-le **depuis la VM**.

💡 **Indices** : `podman run`, `podman ps`, `podman logs`, `podman inspect`, `podman port`.

---

## 🧩 3. Isoler le service

Contrainte : le service doit répondre **depuis la VM**, mais **pas** depuis votre PC, ni depuis Internet.

* Faites en sorte que le service ne soit **pas exposé** à l'extérieur de la VM.
* **Prouvez-le** : un test depuis la VM doit réussir, le même test depuis votre PC doit échouer.

💡 **Indices** :
* Quand on publie un port avec `-p`, sur quelle **adresse** de la VM le port écoute-t-il par défaut ? Peut-on choisir l'adresse d'écoute ?
* Vérifiez avec `ss` sur quelles adresses votre service écoute réellement.
* Un conteneur rootless sans port publié est-il joignable depuis la VM ? Renseignez-vous sur les réseaux podman, les *pods*, et l'option `--network`.

❓ **Questions :**
* Le **pare-feu** suffit-il à lui seul à protéger un port publié ? Renseignez-vous sur le comportement de **Docker** vis-à-vis des règles du pare-feu (Docker et `iptables`/`nftables`). Podman rootless se comporte-t-il de la même façon ?
* Pourquoi est-il préférable de ne **pas exposer** le service plutôt que de compter uniquement sur le pare-feu ?

---

## 🧩 4. Rendre le service persistant

Un conteneur lancé à la main disparaît au redémarrage de la VM. Faites en sorte qu'il soit géré comme un **vrai service**.

💡 **Indices** :
* Renseignez-vous sur **Quadlet** : un fichier `.container` placé dans le bon dossier de votre utilisateur génère automatiquement un service systemd.
* Les services systemd d'un utilisateur s'arrêtent quand il se déconnecte… sauf si on active le **lingering** (`loginctl`).
* `systemctl --user` permet de gérer les services de votre utilisateur.
* Pour les données du service : volume nommé ou dossier monté ? Que signifie le suffixe `:Z` sur un montage avec SELinux ?

❓ **Question :** pourquoi `podman generate systemd` est-il déprécié au profit de Quadlet ?

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Conteneur | Tourne en **rootless** (votre utilisateur) |
| Depuis la VM | Le service répond ✅ |
| Depuis le PC | Le service est **injoignable** ❌ |
| Écoute réseau | Aucune écoute sur une interface externe (`ss`) |
| Persistance | Le conteneur redémarre après un reboot de la VM, sans connexion de votre part |

➡️ [Partie 4 – Nginx en reverse proxy vers le conteneur](P4-ReverseProxy.md)
