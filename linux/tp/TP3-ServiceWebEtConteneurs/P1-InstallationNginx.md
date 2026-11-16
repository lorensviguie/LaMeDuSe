# Partie 1 – Installer Nginx et publier une page personnalisée

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Installer Nginx en tant que **service système**, le rendre accessible depuis votre PC, et lui faire servir **votre propre page** depuis **votre propre dossier**.

---

## 🧩 1. Installation et service

* Installez Nginx depuis les dépôts officiels.
* Démarrez le service et faites en sorte qu'il **démarre automatiquement** au boot.
* Vérifiez son état, puis testez la page par défaut **depuis la VM**.

💡 **Indices** : `dnf`, `systemctl` (sous-commandes `status`, `enable`, `start`…), `curl`.

❓ **Questions :**
* Dans quel dépôt se trouve le paquet `nginx` ? Quelle version est installée ?
* Où se trouve le **fichier d'unité systemd** de Nginx ? Que fait la ligne `ExecStartPre` ?
* Combien de processus Nginx tournent ? Sous **quel utilisateur** tourne chacun d'eux ? Pourquoi y a-t-il un processus *master* et des *workers* ?
* Sur quel(s) port(s) et quelle(s) adresse(s) Nginx écoute-t-il ? (Cherchez la commande `ss`.)

---

## 🧩 2. Accès depuis votre PC

* Ouvrez un navigateur sur votre PC et essayez d'afficher la page de la VM.
* Si cela ne fonctionne pas, trouvez **ce qui bloque** et corrigez-le **proprement**.

💡 **Indices** :
* Le service écoute, mais quelque chose filtre les connexions entrantes. Lequel des mécanismes découverts au TP1 ?
* Une modification de pare-feu doit **survivre à un redémarrage**.
* Avec votre configuration réseau du TP1 (NAT, host-only…), quelle adresse ou quel port utiliser depuis le PC ?

---

## 🧩 3. Page personnalisée

Objectif : **ne pas** modifier la page par défaut, mais créer **votre propre site**.

* Créez un dossier dédié à votre site **en dehors** du dossier par défaut de Nginx (par exemple sous `/srv`).
* Créez-y une page HTML personnalisée (nom de la machine, votre nom, ce que vous voulez).
* Créez un **fichier de configuration dédié** à votre site (un bloc `server`), sans toucher au fichier `nginx.conf` principal plus que nécessaire.
* Faites en sorte que votre site soit celui affiché par défaut.

💡 **Indices** :
* Quel dossier est inclus automatiquement par `nginx.conf` pour les configurations additionnelles ?
* Nginx possède une option pour **tester sa configuration** avant de la recharger. Prenez l'habitude de l'utiliser.
* Quelle différence entre `restart` et `reload` d'un service ? Lequel provoque une coupure ?
* Si vous obtenez une erreur **403 Forbidden** alors que les permissions Unix semblent correctes… pensez à **SELinux**. Comparez le *contexte* de votre dossier avec celui du dossier par défaut (`ls -Z`). Cherchez comment définir un contexte **de façon persistante** (`semanage fcontext`, `restorecon`).
* Que signifie `default_server` dans une directive `listen` ?

❓ **Questions :**
* Où se trouvent les logs d'accès et d'erreur de Nginx ? Retrouvez dans les logs vos requêtes faites depuis le PC.
* Pourquoi faut-il éviter `chcon` pour corriger un contexte SELinux ?
* À qui doivent appartenir les fichiers de votre site ? Nginx a-t-il besoin de pouvoir les **modifier** ?

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Service | `nginx` actif et activé au démarrage |
| Pare-feu | HTTP autorisé de façon persistante |
| Depuis le PC | Votre page personnalisée s'affiche |
| SELinux | Toujours en `Enforcing` ✅ |
| Configuration | `nginx -t` ne remonte aucune erreur |
| Redémarrage | Après un reboot de la VM, tout fonctionne encore |

➡️ [Partie 2 – Durcir le service Nginx](P2-DurcissementNginx.md)
