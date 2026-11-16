# TP3 – Service web sécurisé & conteneurs

![LaMeDuSe_LOGO](/img/LaMeDuSe_logo.webp)

## Description

Dans ce TP, vous allez découvrir l'environnement Linux en partant d'un cas concret : publier un service web.
Vous installerez **Nginx** comme service système, vous le **durcirez**, vous ferez tourner une application dans un **conteneur isolé**, puis vous utiliserez Nginx comme **reverse proxy** pour y accéder. En bonus, vous migrerez Nginx lui-même dans un conteneur.

> ⚠️ Peu de commandes sont données volontairement : cherchez dans `man`, `--help`, la documentation Nginx, systemd et Podman. Notez vos commandes, vos erreurs et vos solutions dans votre carnet de bord.

## Prérequis

- Un clone de la VM obtenue au [TP1 Virtualisation – Clone source propre](/virtualisation/tp/TP1-CloneSourcePropre/README.md)
  (Rocky Linux 10.2, accès SSH par clé, SELinux et firewalld actifs, podman installé)
- Un hostname et une adresse adaptés à ce nouveau clone

## Architecture visée

```
                    Votre PC
                       │  HTTP (port 80)
                       ▼
   ┌──────────────── VM Rocky ─────────────────┐
   │                                           │
   │   Nginx (service durci)                   │
   │      │                                    │
   │      │ reverse proxy                      │
   │      ▼                                    │
   │   Conteneur podman  ← injoignable depuis  │
   │   (votre service)     le PC et Internet   │
   └───────────────────────────────────────────┘
```

## Contenu du TP

- [Partie 1 – Installer Nginx et publier une page personnalisée](P1-InstallationNginx.md)
- [Partie 2 – Durcir le service Nginx](P2-DurcissementNginx.md)
- [Partie 3 – Lancer un service conteneurisé isolé](P3-ServiceConteneurise.md)
- [Partie 4 – Nginx en reverse proxy vers le conteneur](P4-ReverseProxy.md)
- [Partie 5 – Bonus : migrer Nginx dans un conteneur](P5-Bonus-NginxConteneur.md)

## Technologies utilisées

- Nginx, systemd, SELinux, firewalld
- Podman (ou Docker), Quadlet
