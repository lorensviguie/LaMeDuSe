# Partie 2 – Durcir le service Nginx

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Réduire au maximum ce que Nginx a le **droit de faire** sur le système : plus aucun processus root, accès restreint au système de fichiers, capacités minimales. On travaille sur deux niveaux :

1. Le **service systemd** (le « bac à sable » dans lequel tourne Nginx) ;
2. La **configuration Nginx** elle-même.

---

## 🧩 1. Mesurer avant d'agir

systemd sait évaluer le niveau d'exposition d'un service.

* Trouvez la sous-commande de `systemd-analyze` qui donne un **score de sécurité** pour un service.
* Lancez-la sur `nginx` et **notez le score initial** et son niveau (`UNSAFE`, `EXPOSED`, `MEDIUM`, `OK`…).
* Lisez la liste : chaque ligne correspond à une directive systemd que vous pouvez activer.

🎯 **Objectif chiffré** : faire passer le score de Nginx **sous 4.0** sans casser le service. Notez chaque étape (directive ajoutée → nouveau score).

---

## 🧩 2. Modifier le service… sans modifier le fichier d'origine

* Ne modifiez **jamais** le fichier d'unité livré par le paquet.
* Utilisez un **fichier de surcharge** (*drop-in*).

💡 **Indices** :
* `systemctl edit` : où crée-t-il le fichier ? Comment voir l'unité finale résultant de la fusion (`systemctl cat`) ?
* Après une modification d'unité, quelle commande faut-il lancer pour que systemd la prenne en compte ?

❓ **Question :** pourquoi ne pas modifier directement le fichier dans `/usr/lib/systemd/system/` ? Que se passerait-il à la prochaine mise à jour du paquet ?

---

## 🧩 3. Nginx sans root (rootless)

Par défaut, le processus *master* de Nginx tourne en **root** (pour pouvoir écouter sur le port 80), puis lance des *workers* non privilégiés.
Objectif : que **plus aucun processus Nginx ne tourne en root**, tout en continuant d'écouter sur le port **80**.

💡 **Indices** :
* Directives systemd `User=` et `Group=`.
* Pourquoi un utilisateur normal ne peut-il pas écouter sur un port < 1024 ? Renseignez-vous sur les **capabilities** Linux, en particulier celle qui autorise à lier un port privilégié, et sur les directives `AmbientCapabilities=` et `CapabilityBoundingSet=`.
* Une fois non-root, Nginx va échouer à écrire certains fichiers. Lisez les erreurs (`journalctl -u nginx`) : **fichier PID**, **logs**, **dossiers temporaires**… Pour chacun, trouvez une solution propre (`RuntimeDirectory=`, permissions, directives `pid` et `user` de `nginx.conf`, valeur `PIDFile=` de l'unité…).
* La directive `user` de `nginx.conf` a-t-elle encore un sens si Nginx ne démarre plus en root ?

✅ **Test** : `ps` ne doit montrer **aucun** processus Nginx appartenant à root, et votre page doit toujours s'afficher.

---

## 🧩 4. Restreindre le bac à sable systemd

Ajoutez progressivement des directives de **confinement**. Après **chaque** ajout : rechargez, redémarrez, testez la page, recalculez le score.

Pistes à étudier (à vous de comprendre ce que fait chacune et de choisir les bonnes valeurs) :

| Thème | Directives à étudier |
|-------|----------------------|
| Système de fichiers | `ProtectSystem=`, `ProtectHome=`, `ReadWritePaths=`, `PrivateTmp=` |
| Privilèges | `NoNewPrivileges=`, `CapabilityBoundingSet=`, `RestrictSUIDSGID=` |
| Noyau & matériel | `PrivateDevices=`, `ProtectKernelTunables=`, `ProtectKernelModules=`, `ProtectKernelLogs=`, `ProtectControlGroups=`, `ProtectClock=`, `ProtectHostname=` |
| Réseau | `RestrictAddressFamilies=` |
| Divers | `LockPersonality=`, `RestrictNamespaces=`, `RestrictRealtime=`, `MemoryDenyWriteExecute=`, `SystemCallFilter=`, `SystemCallArchitectures=` |

⚠️ Certaines directives peuvent **casser** Nginx ou **le futur reverse proxy** (partie 4). Gardez-le en tête : si plus tard quelque chose ne marche plus, revenez ici.

❓ **Questions :**
* Avec `ProtectSystem=strict`, que devient l'arborescence vue par Nginx ? Où a-t-il encore le droit d'écrire ?
* Quelle famille d'adresses réseau Nginx doit-il garder pour joindre un service local ? Et pour communiquer avec systemd ?
* Quelle différence entre `AmbientCapabilities` et `CapabilityBoundingSet` ?

---

## 🧩 5. Durcir la configuration Nginx

Côté Nginx lui-même :

* Masquez la **version** de Nginx dans les en-têtes et les pages d'erreur.
* Ajoutez des **en-têtes de sécurité** HTTP (cherchez : `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`, `Referrer-Policy`).
* Restreignez les **méthodes HTTP** acceptées par votre site à celles qui sont utiles.
* Vérifiez les **permissions** : Nginx doit pouvoir **lire** sa configuration et votre site, mais **pas les modifier**.

💡 **Indices** : `server_tokens`, `add_header`, `limit_except`. Testez les en-têtes avec `curl -I`.

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Fichier d'unité d'origine | Non modifié, surcharge via drop-in |
| Processus | Aucun processus Nginx en root |
| Score `systemd-analyze security` | < 4.0 (noter avant / après) |
| Version Nginx | Non visible dans les réponses HTTP |
| En-têtes de sécurité | Présents (`curl -I`) |
| Site | Toujours accessible depuis le PC |
| Reboot | Le service redémarre correctement |

➡️ [Partie 3 – Lancer un service conteneurisé isolé](P3-ServiceConteneurise.md)
