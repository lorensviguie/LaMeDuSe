# Partie 4 – Vérification et finalisation du clone

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Valider automatiquement la configuration de la VM, comprendre ce qui rend un clone « propre », puis éteindre la VM : elle devient votre **clone source**.

---

## 🧩 1. Télécharger le script de vérification

Le script est disponible ici :

```
https://raw.githubusercontent.com/lorensviguie/LaMeDuSe/main/virtualisation/tp/TP1-CloneSourcePropre/check_vm.sh
```

* Téléchargez-le **sur la VM** (pas sur votre PC) avec un outil en ligne de commande.
* **Lisez-le avant de l'exécuter.**

⚠️ **Bonne pratique** : on ne lance **jamais** en root un script récupéré sur Internet sans l'avoir lu. Ici, vérifiez par vous-même que le script ne fait que **lire** l'état du système et ne modifie rien.

❓ **Question :** pourquoi la pratique `curl … | sudo bash` est-elle considérée comme dangereuse ?

---

## 🧩 2. Lancer le script

* Exécutez le script **en tant que root** (via sudo).
* Lisez le résultat section par section :

| Statut | Signification |
|--------|---------------|
| `[ OK ]` | Exigence respectée |
| `[ KO ]` | Exigence **non respectée** : à corriger obligatoirement |
| `[WARN]` | Recommandation ou bonus : non bloquant, mais à étudier |
| `[INFO]` | Information sur votre configuration |

* Corrigez chaque `KO`, puis relancez le script jusqu'à obtenir **0 KO**.
* Essayez aussi de traiter les `WARN`.

💡 Le script a deux options : `--offline` (ignore les tests Internet) et `--no-color`. Trouvez comment afficher son aide.

---

## 🧩 3. Préparer le clonage (réflexion)

Un clone source va être **dupliqué** plusieurs fois. Certaines informations doivent pourtant être **uniques** pour chaque machine.

❓ **Questions (à rédiger dans le carnet de bord) :**
* Que se passe-t-il sur un réseau si deux VM ont la même **adresse MAC** ? Quelle option de votre hyperviseur permet de l'éviter au moment du clonage ?
* Qu'est-ce que le fichier `/etc/machine-id` ? Quels problèmes pose un `machine-id` identique sur deux machines ?
* Les **clés d'hôte SSH** (`/etc/ssh/ssh_host_*`) sont-elles identiques entre deux clones ? Quel risque de sécurité cela représente-t-il ? Comment le client SSH de votre PC réagira-t-il ?
* Que faudrait-il changer en premier sur chaque nouveau clone ?

💡 **Pour aller plus loin** : renseignez-vous sur la notion de « **sceller** » (*seal*) une image, sur l'outil `virt-sysprep` et sur **cloud-init**. Comment les fournisseurs cloud règlent-ils ce problème ?

---

## 🧩 4. Éteindre proprement

* Nettoyez ce qui n'a rien à faire dans un modèle (historique de commandes, fichiers temporaires, script de test…).
* **Éteignez la VM proprement** depuis le système (pas en « coupant le courant » depuis l'hyperviseur).
* *(Recommandé)* Prenez un **instantané** (*snapshot*) de la VM éteinte, ou exportez-la (format OVA).

❓ **Questions :**
* Quelle différence entre éteindre la VM depuis le système et « arrêter la machine » brutalement depuis l'hyperviseur ?
* Quelle différence entre un **clone lié** et un **clone intégral** ? Avantages et inconvénients de chacun ?
* Un **snapshot** est-il une sauvegarde ? Justifiez.

---

## 🧰 Vérifications finales

| Test | Résultat attendu |
|------|------------------|
| `check_vm.sh` | **0 KO** |
| SSH utilisateur depuis le PC | ✅ par clé |
| SSH root | ❌ refusé |
| Partitionnement | `/`, `/home`, `/var`, `/var/log`, `/tmp`, `swap` sur LVM, `/boot` séparé |
| Hostname | Explicite et persistant |
| Bannière SSH | Affichée avant l'authentification |
| NTP | Synchronisé |
| Système | À jour, plus de redémarrage en attente |
| Podman | Installé et fonctionnel en rootless |
| VM | Éteinte proprement ✅ |

---

## 🚀 Étape suivante

🎉 Vous avez un **clone source propre**. Clonez-le pour attaquer le [TP3 Linux – Service web sécurisé & conteneurs](/linux/tp/TP3-ServiceWebEtConteneurs/README.md).

> 💡 **Conseil :** gardez votre carnet de bord. Vous venez de rédiger, sans le savoir, la procédure d'installation standard de votre futur parc de serveurs.
