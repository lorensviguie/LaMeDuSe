# Cours : Introduction à Docker Swarm

## 🐳 Qu’est-ce que Docker Swarm ?

Docker Swarm est une solution d’orchestration native de Docker.  
Elle permet de regrouper plusieurs hôtes Docker (machines physiques ou virtuelles) en un **cluster** appelé *Swarm*, sur lequel vous pouvez déployer des services conteneurisés de manière **haute disponibilité**, **scalable**, et **résiliente**.

Swarm transforme un ensemble de nœuds Docker en une seule entité logique que l’on administre comme un tout.

---

## ⚙️ Architecture de Docker Swarm

### 1. **Manager (ou Master)**

- C’est le cerveau du cluster.
- Il gère :
  - l’état global du cluster (services, conteneurs, réseau),
  - la planification (quel conteneur va sur quel nœud),
  - les communications internes.
- Un cluster peut avoir plusieurs managers, dont **un seul leader** (élu automatiquement).

### 2. **Worker (ou Slave)**

- Exécute les conteneurs ordonnés par le manager.
- Il ne prend **aucune décision d’orchestration**.
- Communique avec le manager pour recevoir des tâches.

---

## 🏗️ Création d’un Cluster Swarm

### Étape 1 : Initialiser le manager

Sur la première machine (ex : `docker1`) :

```bash
docker swarm init --advertise-addr <IP_MANAGER>
```

Cela renvoie une commande du type :

```bash
docker swarm join --token <TOKEN> <IP_MANAGER>:2377
```

### Étape 2 : Ajouter des workers

Sur les autres nœuds :

```bash
docker swarm join --token <TOKEN> <IP_MANAGER>:2377
```

Vérification sur le manager :

```bash
docker node ls
```

---

## 🚀 Déployer un Service Répliqué

Exemple : lancer **nginx** avec **2 replicas**

```bash
docker service create --name web --replicas 2 -p 80:80 nginx
```

Vérifier les services :

```bash
docker service ls
```

Vérifier où sont placés les conteneurs :

```bash
docker service ps web
```

Chaque nœud (worker) héberge une ou plusieurs copies du service.

---

## 📦 Particularités des fichiers YAML Swarm

Les fichiers `docker-compose.yml` peuvent être adaptés pour Swarm avec :

```bash
docker stack deploy -c docker-compose.yml mystack
```

### Exemple :

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
    volumes:
      - web_data:/usr/share/nginx/html

volumes:
  web_data:
```

👉 Le mot-clé `deploy` est **spécifique à Swarm** et ignoré en mode Docker Compose classique.

---

## 💾 Gestion et Réplication du Stockage

Par défaut, chaque conteneur répliqué a son propre système de fichiers.  
Pour partager les mêmes données entre replicas ou entre nœuds :

### 1. **Volumes partagés (NFS, GlusterFS, Ceph, etc.)**
- Permettent d’avoir un répertoire monté de manière identique sur plusieurs hôtes.

Exemple d’un montage NFS :

```yaml
volumes:
  web_data:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.1.10,rw"
      device: ":/data/web"
```

### 2. **Docker Volume Plugin**
- Certains plugins permettent la **réplication automatique** des volumes entre nœuds.

### 3. **Objectif :**
- Assurer que chaque instance du service ait **accès aux mêmes données** (contenu web, configuration, logs...)

---

## ✅ Résumé

| Élément | Rôle |
|----------|------|
| **Swarm** | Cluster d’orchestration Docker |
| **Manager** | Gère l’état global et la planification |
| **Worker** | Exécute les conteneurs |
| **Service** | Application distribuée sur plusieurs nœuds |
| **Replica** | Instance d’un conteneur d’un service |
| **Stack** | Ensemble de services décrits dans un YAML |
| **Volume partagé** | Données communes aux replicas |

---

## 🧠 À retenir

- Docker Swarm est **simple**, **intégré à Docker**, et **rapide à déployer**.
- Idéal pour de petits clusters ou labos.
- Pour les environnements de production plus complexes, **Kubernetes** offre plus de fonctionnalités (autoscaling, configuration avancée, etc.).
