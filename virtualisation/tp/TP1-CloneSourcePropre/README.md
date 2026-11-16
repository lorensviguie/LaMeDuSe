# TP1 – Construire un clone source propre (Rocky Linux 10.2)

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## Description

Dans ce TP, vous allez installer **from scratch** une machine virtuelle Rocky Linux 10.2 à partir de l'ISO *Minimal*, puis la configurer proprement pour en faire un **clone source** (aussi appelé *golden image* ou *template*).

Ce clone servira de base à tous les TP suivants (notamment ceux de la catégorie Linux) : chaque fois que vous aurez besoin d'une machine, vous clonerez celle-ci au lieu de tout réinstaller.

> ⚠️ Peu de commandes sont données volontairement. C'est à vous de chercher (`man`, `--help`, documentation officielle Rocky / Red Hat). Notez tout ce que vous faites dans un carnet de bord : vous en aurez besoin.

## Technologies utilisées

- VirtualBox (recommandé) ou tout autre hyperviseur (VMware, Hyper-V, Proxmox, KVM…)
- Rocky Linux 10.2 – ISO Minimal
- LVM, SSH, firewalld, SELinux, chrony, dnf, podman

## Objectif final

À la fin du TP, votre VM doit respecter **tous** les points suivants :

| # | Exigence |
|---|----------|
| 1 | VM avec **2 Go de RAM**, **1 vCPU**, **un disque de 10 Go** |
| 2 | Connexion **SSH** possible depuis votre PC sur un **compte non-root** qui peut administrer la machine |
| 3 | Le compte **root n'est pas accessible via SSH** |
| 4 | Un **partitionnement propre** : chaque zone du système est séparée dans un **volume logique (LVM)** adapté |
| 5 | Un **nom d'hôte** propre et cohérent |
| 6 | Une **bannière de sécurité** affichée lors d'une connexion SSH |
| 7 | Un service **NTP** fonctionnel et l'heure synchronisée |
| 8 | Des **dépôts** vérifiés et un système **à jour** |
| 9 | **Podman** installé par défaut |
| 10 | Un **accès à Internet** fonctionnel |
| 11 | Le script de vérification passe **sans aucun KO** |
| 12 | La VM est **éteinte proprement** : c'est votre clone source |

## Contenu du TP

- [Partie 1 – Création de la VM](P1-CreationVM.md)
- [Partie 2 – Installation de Rocky Linux](P2-InstallationRocky.md)
- [Partie 3 – Configuration post-installation](P3-ConfigurationPostInstall.md)
- [Partie 4 – Vérification et finalisation du clone](P4-VerificationEtClone.md)

Script de vérification : [`check_vm.sh`](check_vm.sh)

## Et après ?

Le clone obtenu est le prérequis du [TP3 Linux – Service web sécurisé & conteneurs](/linux/tp/TP3-ServiceWebEtConteneurs/README.md).
