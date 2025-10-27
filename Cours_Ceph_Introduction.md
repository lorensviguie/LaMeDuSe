# 📘 Cours : Introduction et mise en place de Ceph

## 1. Présentation de Ceph

Ceph est une **solution de stockage distribué open source** conçue pour offrir :
- **Haute disponibilité**
- **Tolérance aux pannes**
- **Évolutivité horizontale** (on peut ajouter des nœuds sans interruption)

Il permet de fournir trois types de stockage :
1. **Ceph Block Storage (RBD)** : disques virtuels pour les VM (OpenNebula, OpenStack, etc.)
2. **Ceph Object Storage (RGW)** : compatible S3 / Swift
3. **Ceph File System (CephFS)** : système de fichiers distribué

---

## 2. Architecture et composants Ceph

Un cluster Ceph est constitué de plusieurs **daemons** et **rôles** :

### 🧱 2.1. MON (Monitor)
- Maintient la **topologie du cluster** (qui est en ligne, qui est mort).
- Stocke la **carte du cluster** (cluster map).
- Nécessaire : **3 MON minimum** pour une haute disponibilité (quorum).

### 💾 2.2. OSD (Object Storage Daemon)
- C’est le cœur du stockage.
- Chaque OSD gère **un disque**.
- Les données sont **répliquées ou dispersées** entre plusieurs OSD pour assurer la résilience.
- Exemple : 3 OSD ⇒ 3 disques ⇒ réplication 3×.

### 🧠 2.3. MGR (Manager)
- Fournit des informations de **statistiques** et **tableaux de bord Web (ceph-mgr-dashboard)**.
- Nécessaire à partir de Ceph Luminous.

### 📁 2.4. MDS (Metadata Server)
- Utilisé uniquement pour **CephFS**.
- Gère les métadonnées du système de fichiers (permissions, arborescence, etc.).

### 🌐 2.5. RGW (RADOS Gateway)
- Fournit une **API de stockage objet** compatible avec S3 / Swift.

---

## 3. Principe de fonctionnement

1. Les données sont stockées dans un **pool** (ensemble logique).
2. Le pool est divisé en **Placement Groups (PG)**.
3. Les PG sont distribués entre les **OSD** selon une **carte CRUSH**.
4. Le client (VM, serveur, etc.) écrit directement sur les OSD via les librairies Ceph — pas besoin de passer par un serveur central !

---

## 4. Schéma simplifié

```
+-----------------------+
|        Client         |
| (VM / OpenNebula RBD) |
+----------+------------+
           |
           v
+-------------------------------+
|         Ceph Cluster          |
| +------+  +------+  +------+  |
| | MON  |  | MGR  |  | MDS  |  |
| +------+  +------+  +------+  |
| +--------+ +--------+ +--------+
| |  OSD1  | |  OSD2  | |  OSD3  |
| +--------+ +--------+ +--------+
+-------------------------------+
```

---

## 5. Installation de Ceph

### 🔧 5.1. Pré-requis
- Au moins **3 serveurs** pour un vrai cluster.
- OS : **Rocky Linux 9 / Ubuntu 22.04**.
- SSH root sans mot de passe (par clé ssh) entre les nœuds.
- Chaque disque dédié au Ceph doit être **vide** (pas de partition).

### 🔩 5.2. Installation via Cephadm

#### Étape 1 : Installation du bootstrap
```bash
dnf install -y cephadm
cephadm bootstrap --mon-ip <IP_MON_PRINCIPAL> --initial-dashboard-user admin --initial-dashboard-password admin
```

#### Étape 2 : Ajouter les hôtes
```bash
ceph orch host add <nom_hote> <ip_hote>
ceph orch host label add <nom_hote> osd
```

#### Étape 3 : Ajouter les OSD
```bash
ceph orch daemon add osd <nom_hote>:<chemin_du_disque>
# Exemple :
ceph orch daemon add osd node1:/dev/sdb
```

#### Étape 4 : Vérifier l’état du cluster
```bash
ceph -s
```

---

## 6. Commandes de base

| Commande | Description |
|-----------|-------------|
| `ceph -s` | État général du cluster |
| `ceph osd tree` | Affiche la hiérarchie des OSD |
| `ceph osd df` | Espace disque par OSD |
| `ceph health` | Santé du cluster |
| `ceph mon stat` | Statut des moniteurs |
| `ceph df` | Espace total utilisé / disponible |
| `rbd ls` | Liste des volumes RBD |
| `rbd create <nom> --size <taille> --pool <pool>` | Crée un disque RBD |
| `rbd info <nom>` | Détails sur un disque RBD |

---

## 7. Bonnes pratiques

- Minimum **3 MON + 3 OSD** pour la redondance.
- Utiliser des **disques dédiés** pour les OSD (pas de partage avec le système).
- Configurer un **réseau séparé pour Ceph (backend)**.
- Surveiller régulièrement via le **Ceph Dashboard** ou Prometheus/Grafana.

---

## 8. Intégration avec OpenNebula

OpenNebula peut utiliser Ceph comme **datastore principal** :
- Les **images, templates et snapshots** sont stockés dans un **pool RBD**.
- Les **VM KVM** utilisent ces volumes directement comme disques.
- En cas de migration, OpenNebula n’a pas besoin de copier le disque — il est déjà partagé via Ceph.

Exemple de datastore Ceph dans OpenNebula :
```bash
one datastore create ceph_system --type SYSTEM --ds_mad ceph --tm_mad ceph --safe_dirs /var/tmp --pool ceph-pool
```

---

## 9. Conclusion

Ceph est une brique **clé** pour tout environnement cloud distribué (OpenNebula, OpenStack, Kubernetes).
Il assure un **stockage partagé, résilient et évolutif**, idéal pour des infrastructures pédagogiques ou de production.

---

✍️ **Prochain TP : Déploiement complet d’un cluster Ceph 3 nœuds avec OpenNebula + KVM**
