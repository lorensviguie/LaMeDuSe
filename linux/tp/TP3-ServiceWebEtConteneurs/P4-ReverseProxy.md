# Partie 4 – Nginx en reverse proxy vers le conteneur

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Rendre le service conteneurisé accessible depuis votre PC **uniquement en passant par Nginx**. Le conteneur reste injoignable en direct.

---

## 🧩 1. Comprendre le reverse proxy

❓ **Questions (avant de configurer) :**
* Qu'est-ce qu'un **reverse proxy** ? Quelle différence avec un proxy « classique » (forward proxy) ?
* Citez au moins trois intérêts d'un reverse proxy devant une application (sécurité, TLS, logs, cache, répartition de charge…).

---

## 🧩 2. Configurer Nginx

Choisissez **une** des deux approches (ou les deux) :

* **Par chemin** : `http://<vm>/app/` → votre service ;
* **Par nom** : `http://app.<votre-domaine>/` → votre service (il faudra que votre PC sache résoudre ce nom).

Puis :

* Ajoutez la configuration de proxy dans **un fichier dédié** (ou dans votre bloc `server` existant).
* Transmettez à l'application les **en-têtes** utiles sur le client d'origine.
* Testez la configuration, rechargez Nginx, testez depuis le PC.

💡 **Indices** :
* Directives `proxy_pass`, `proxy_set_header` (`Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`).
* Avec l'approche par chemin, attention au **slash final** dans `location` et dans `proxy_pass` : faites des essais et observez quelle URL reçoit réellement l'application.
* Certaines applications utilisent des **WebSockets** : quels en-têtes supplémentaires faut-il alors transmettre ?
* Pour l'approche par nom, quel fichier modifier sur votre PC pour résoudre un nom sans serveur DNS ?

---

## 🧩 3. Déboguer (vous allez en avoir besoin)

Il est très probable que vous obteniez d'abord une erreur **502 Bad Gateway**. C'est normal : c'est le cœur de l'exercice.

💡 **Méthode** : remontez la chaîne, maillon par maillon.

1. Le conteneur répond-il depuis la VM ? (partie 3)
2. Que dit le **log d'erreur** de Nginx ? Le message exact est un indice précieux.
3. **SELinux** autorise-t-il le processus Nginx à ouvrir des connexions réseau ? Cherchez dans le journal d'audit (`ausearch`, `/var/log/audit/audit.log`) et dans la liste des **booléens** SELinux liés à `httpd` (`getsebool`, `setsebool`). Comment rendre le changement **persistant** ?
4. Votre **durcissement systemd** (partie 2) autorise-t-il encore la bonne famille d'adresses réseau ? Pensez à `RestrictAddressFamilies=` et à d'éventuelles restrictions IP.

❓ **Question :** pourquoi SELinux bloque-t-il par défaut un serveur web qui veut se connecter à un autre service ? Quel type d'attaque cela limite-t-il ?

⚠️ Interdit de « résoudre » le problème en passant SELinux en `Permissive` ou en retirant tout le durcissement de la partie 2.

---

## 🧩 4. Bonus : HTTPS

* Générez un **certificat auto-signé** (ou utilisez votre propre autorité de certification).
* Servez votre site et votre application en **HTTPS**, et redirigez HTTP vers HTTPS.
* N'oubliez pas le pare-feu.

💡 **Indices** : `openssl req`, directives `listen 443 ssl`, `ssl_certificate`, `ssl_certificate_key`, `return 301`. Où stocker la clé privée, avec quelles permissions et quel contexte SELinux ?

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Depuis le PC via Nginx | Le service répond ✅ |
| Depuis le PC en direct (port du conteneur) | Injoignable ❌ |
| Logs | La requête apparaît dans le log d'accès de Nginx **et** dans les logs du conteneur |
| Adresse client | L'application reçoit l'adresse réelle du client (en-têtes) |
| SELinux | `Enforcing`, changement persistant ✅ |
| Durcissement | Score `systemd-analyze security` toujours < 4.0 |
| Reboot | Tout fonctionne après un redémarrage de la VM |

➡️ [Partie 5 – Bonus : migrer Nginx dans un conteneur](P5-Bonus-NginxConteneur.md)
