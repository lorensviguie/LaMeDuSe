# Partie 1 – Création de la machine virtuelle

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## 🎯 Objectif

Préparer l'hyperviseur et créer une VM vide, prête à démarrer sur l'ISO de Rocky Linux 10.2.

---

## 🧩 1. Récupérer l'ISO

* Téléchargez l'ISO **Rocky Linux 10.2 – Minimal** pour l'architecture `x86_64` depuis le site **officiel** de Rocky Linux.
* Vérifiez l'**intégrité** de l'ISO téléchargée avant de vous en servir.

💡 **Indice** : sur la page de téléchargement, cherchez le fichier `CHECKSUM`. Quel algorithme est utilisé ? Quelle commande (sous Windows, Linux ou macOS) permet de calculer cette empreinte sur votre fichier ?

❓ **Questions :**
* Quelle est la différence entre les ISO *Minimal*, *DVD* et *Boot* ?
* Pourquoi est-il important de vérifier l'empreinte d'une ISO ?

---

## 🧩 2. Vérifier la compatibilité du processeur

Rocky Linux 10 n'accepte plus tous les processeurs x86_64.

* Renseignez-vous sur le **niveau de micro-architecture** minimal exigé par Rocky Linux 10 (cherchez « x86-64-v3 »).
* Vérifiez que votre processeur est compatible.

💡 **Indice** : si la VM refuse de démarrer avec un message du type *« CPU not supported »* alors que votre processeur est récent, le problème vient souvent de l'**hyperviseur** et non du processeur. Sous Windows, renseignez-vous sur les interactions entre VirtualBox et **Hyper-V / VBS (sécurité basée sur la virtualisation)**.

---

## 🧩 3. Créer la VM

Créez une nouvelle VM avec les caractéristiques suivantes :

| Ressource | Valeur |
|-----------|--------|
| Type / version | Linux – Red Hat (64-bit) ou équivalent |
| Mémoire vive | **2 Go** |
| Processeur | **1 vCPU** |
| Disque | **10 Go** |
| Lecteur optique | l'ISO Rocky 10.2 Minimal |

⚠️ Si votre hyperviseur propose une **installation automatique / « unattended installation »**, **désactivez-la** : l'objectif est d'installer le système vous-même.

❓ **Questions :**
* Disque **alloué dynamiquement** ou **taille fixe** : quelle différence ? Lequel choisissez-vous et pourquoi ?
* Quel format de disque utilisez-vous (VDI, VMDK, VHD, qcow2…) ? Qu'est-ce que cela change ?
* Firmware **BIOS** ou **UEFI** ? Ce choix aura une conséquence sur le partitionnement (partie 2) : laquelle ?

---

## 🧩 4. Configurer le réseau de la VM

La VM doit répondre à **deux besoins** :

1. Accéder à **Internet** (mises à jour, téléchargement d'images…) ;
2. Être **joignable en SSH depuis votre PC**.

* Étudiez les modes réseau proposés par votre hyperviseur (NAT, réseau NAT, accès par pont / bridge, réseau privé hôte / host-only, réseau interne).
* Choisissez une configuration qui répond aux deux besoins.

💡 **Indices** :
* En mode NAT simple, votre PC peut-il joindre la VM directement ? Si non, quel mécanisme de l'hyperviseur permet de contourner cela ?
* Une VM peut avoir **plusieurs cartes réseau**.
* Le mode « pont » fonctionne-t-il sur tous les réseaux (Wi-Fi d'école, réseau d'entreprise) ?

❓ **Question :** justifiez votre choix de configuration réseau dans votre carnet de bord.

---

## ✅ Point de contrôle

| Vérification | Attendu |
|--------------|---------|
| Empreinte de l'ISO | Identique à celle du fichier `CHECKSUM` officiel |
| Ressources de la VM | 2 Go RAM / 1 vCPU / 10 Go de disque |
| Réseau | Une config permettant Internet **et** SSH depuis le PC |
| Démarrage | La VM démarre sur l'installeur de Rocky Linux |

➡️ [Partie 2 – Installation de Rocky Linux](P2-InstallationRocky.md)
