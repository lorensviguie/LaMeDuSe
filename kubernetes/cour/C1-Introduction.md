# 🌐 Introduction à Kubernetes

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 1. Qu’est-ce que Kubernetes ?

**Kubernetes** (ou **K8s**) est un **orchestrateur de conteneurs**.  
Son rôle est de **gérer automatiquement le déploiement, la mise à l’échelle et la supervision** d’applications conteneurisées.

> Aujourd’hui, Kubernetes peut également gérer des **machines virtuelles**, mais son cœur reste la gestion de **conteneurs Docker**.

Kubernetes permet de regrouper plusieurs serveurs (physiques ou virtuels) dans un **cluster** qui assure que **la configuration voulue tourne en permanence** — même si un nœud tombe.

---

## 2. Prérequis avant Kubernetes

Avant de se lancer avec Kubernetes, il est **essentiel de maîtriser** :
- **Linux** (commandes, services, réseau, permissions)
- **Docker** ou un autre moteur de conteneurs

Kubernetes ne crée pas les conteneurs lui-même — il **les orchestre** à travers des outils comme **containerd** ou **Docker Engine**.

---

## 3. Architecture de base : Master / Worker

Kubernetes repose sur une architecture **maître / nœud (master / worker)** :

### 🧠 Master Node (ou Control Plane)
Ce sont les serveurs d’administration du cluster.  
Ils hébergent les **composants essentiels** :
- **API Server** : point d’entrée du cluster (via `kubectl` ou les API REST)
- **Controller Manager** : surveille l’état des objets et agit pour atteindre l’état désiré
- **Scheduler** : attribue les pods aux nœuds disponibles
- **etcd** : base de données clé/valeur qui stocke la configuration du cluster

> Les masters **ne font pas tourner les applications**, mais orchestrent leur déploiement.

### ⚙️ Worker Nodes
Ce sont les serveurs qui exécutent réellement vos conteneurs.  
Ils hébergent :
- **kubelet** : agent local qui communique avec le master
- **kube-proxy** : gère le réseau interne entre les pods et services
- **container runtime** (ex: Docker ou containerd)

Les workers **hébergent vos pods** — les unités de base des applications.

---

## 4. Les concepts fondamentaux de Kubernetes

### 🧩 Pod
Le **pod** est la plus petite unité déployable dans Kubernetes.  
Il contient **un ou plusieurs conteneurs** qui partagent :
- le **même réseau interne**
- les **mêmes volumes** (stockage)
- et souvent la **même mission** (ex : un app + un sidecar)

### 🏷️ Namespace
Un **namespace** sert à **isoler les ressources** dans un même cluster.  
Cela permet d’avoir plusieurs environnements (dev, test, prod) dans le même cluster, sans qu’ils se mélangent.

### 🏗️ Deployment
Un **Deployment** décrit **comment déployer et maintenir** un ensemble de pods identiques (réplicas).  
Il gère automatiquement les mises à jour et les redémarrages.

### 🔁 ReplicaSet
Gère le **nombre de pods actifs** pour un deployment.  
Si un pod tombe, ReplicaSet le recrée.

### 🌍 Service
Un **Service** expose un ensemble de pods sur un **point d’accès stable (IP + port)**.  
Il peut aussi servir de **load balancer interne**.

### 🧭 Ingress
L’**Ingress** permet d’exposer vos services **vers l’extérieur** du cluster (ex: via HTTPS, Nginx, Traefik, etc.).

### 💾 Volume
Un **Volume** permet de **persister des données** même si les pods sont recréés.

### ⚡ ConfigMap & Secret
- **ConfigMap** : pour injecter des variables de configuration non sensibles.
- **Secret** : pour stocker des données sensibles (mots de passe, tokens...).

---

## 5. Communication entre les composants

1. **kubectl** communique avec l’**API Server** du master.
2. Le **Scheduler** décide sur quel worker exécuter les pods.
3. Le **kubelet** du worker crée et surveille les conteneurs.
4. Le **kube-proxy** relie le réseau du pod au reste du cluster.
5. **etcd** conserve l’état global du cluster.

---

## 6. Exemple simplifié

```bash
# Voir les nodes du cluster
kubectl get nodes

# Lister les pods
kubectl get pods -A

# Créer un pod à partir d'une image Docker
kubectl run hello --image=nginx

# Exposer le pod sur un port externe
kubectl expose pod hello --port=80 --type=NodePort
```

---

## 7. Schéma simplifié

```
+--------------------+        +---------------------+
|     Master Node    |        |     Worker Node     |
|--------------------|        |---------------------|
| API Server         | <----> | kubelet             |
| Controller Manager |        | kube-proxy          |
| Scheduler          |        | container runtime   |
| etcd               |        | (Docker/containerd) |
+--------------------+        +---------------------+
```

---

## 8. Conclusion

Kubernetes est une **plateforme d’orchestration** qui vise la **fiabilité, la scalabilité et l’automatisation**.  
Avant de s’y plonger, il est crucial de maîtriser :
- Le fonctionnement des **conteneurs (Docker)**
- Les **commandes Linux**
- Les notions de **réseau et de volumes**

> Dans les prochains chapitres, on abordera les **Deployments**, **Services**, **Ingress**, et la **gestion des volumes persistants**.
