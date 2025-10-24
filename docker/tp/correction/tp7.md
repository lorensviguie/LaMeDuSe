# TP6 : Docker Swarm - Gestion de Cluster et Haute Disponibilité

## Objectifs pédagogiques

À la fin de ce TP, vous serez capable de :

* Comprendre le fonctionnement de Docker Swarm et sa différence avec Docker Compose.
* Créer et administrer un cluster Swarm multi-nœuds (manager / worker).
* Déployer des services répliqués et les mettre à jour.
* Gérer les volumes, les réseaux et la haute disponibilité.
* Appliquer les bonnes pratiques de sécurité Swarm.

---

## 1. Pré-requis

* 3 machines Linux (ou VM) avec Docker installé :

  * `manager01`
  * `worker01`
  * `worker02`
* Un réseau fonctionnel entre les trois machines.
* Accès root ou sudo.

---

## 2. Introduction à Docker Swarm

Docker Swarm est l’orchestrateur de conteneurs natif de Docker. Il permet de :

* Gérer un cluster de serveurs Docker.
* Déployer des applications distribuées.
* Assurer la haute disponibilité et la réplication automatique.

### Différence avec Docker Compose

| Fonctionnalité      | Docker Compose   | Docker Swarm        |
| ------------------- | ---------------- | ------------------- |
| Portée              | Machine unique   | Cluster multi-hôtes |
| Commande            | `docker-compose` | `docker stack`      |
| Haute disponibilité | Non              | Oui                 |
| Scalabilité         | Manuelle         | Automatique         |
| Load balancing      | Non              | Oui (intégré)       |

---

## 3. Création du cluster Swarm

### 3.1 Initialisation du cluster

Sur la machine `manager01` :

```bash
docker swarm init --advertise-addr <IP_MANAGER>
```

### 3.2 Ajout des workers

Sur chaque `worker`, exécutez la commande affichée lors de l’init :

```bash
docker swarm join --token <TOKEN> <IP_MANAGER>:2377
```

### 3.3 Vérification du cluster

Sur le manager :

```bash
docker node ls
```

Vous devriez voir vos nœuds `manager` et `workers` dans la liste.

---

## 4. Déploiement d’un service Swarm

### 4.1 Créer un service répliqué

```bash
docker service create --name web --replicas 3 -p 8080:80 nginx
```

### 4.2 Vérifier le déploiement

```bash
docker service ls
docker service ps web
```

### 4.3 Tester le load balancing

Depuis un navigateur ou avec `curl` :

```bash
curl http://<IP_MANAGER>:8080
```

Chaque requête est servie par un conteneur différent.

---

## 5. Déploiement via fichier YAML (Stack Swarm)

### 5.1 Exemple : `stack-nginx.yml`

```yaml
version: '3.8'
services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      placement:
        constraints: [node.role == worker]
    volumes:
      - nginx_data:/usr/share/nginx/html
volumes:
  nginx_data:
```

### 5.2 Déploiement de la stack

```bash
docker stack deploy -c stack-nginx.yml nginx_stack
```

### 5.3 Vérification

```bash
docker stack ls
docker stack services nginx_stack
```

---

## 6. Mise à jour et rollback d’un service

### 6.1 Mise à jour d’une image

```bash
docker service update --image nginx:alpine nginx_stack_nginx
```

### 6.2 Rollback

```bash
docker service rollback nginx_stack_nginx
```

---

## 7. Gestion du stockage et des volumes partagés

### 7.1 Création d’un volume partagé (ex: NFS)

```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.10.10,rw \
  --opt device=:/srv/docker_data shared_data
```

### 7.2 Utilisation dans un service

```yaml
volumes:
  - shared_data:/data
```

---

## 8. Monitoring du cluster

### 8.1 Commandes utiles

```bash
docker node ls
docker service ps web
docker service logs web
```

### 8.2 Déploiement d’un outil de monitoring (Portainer)

```bash
docker service create \
  --name portainer \
  --publish 9000:9000 \
  --constraint 'node.role == manager' \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  portainer/portainer-ce
```

Accédez à : http://<IP_MANAGER>:9000

---

## 9. Sécurité dans Swarm

### Bonnes pratiques :

1. **Chiffrer les communications internes :**

   * Swarm chiffre automatiquement les communications inter-nœuds.
2. **Limiter les rôles :**

   * N’utilisez pas le rôle `manager` pour les tâches applicatives.
3. **Stocker les secrets dans Swarm :**

   ```bash
   echo "password123" | docker secret create db_pass -
   ```

   Et dans votre YAML :

   ```yaml
   secrets:
     - db_pass
   ```
4. **Ne pas exposer inutilement les ports :**

   * Évitez `0.0.0.0` pour les bindings sensibles.
5. **Mettre à jour les nœuds régulièrement :**

   * `docker node update --availability drain` avant maintenance.

---

## 10. Comparaison rapide avec Kubernetes

| Critère                | Docker Swarm | Kubernetes                  |
| ---------------------- | ------------ | --------------------------- |
| Installation           | Très simple  | Complexe                    |
| Courbe d’apprentissage | Faible       | Élevée                      |
| Scalabilité            | Bonne        | Excellente                  |
| Load balancing         | Intégré      | Avancé (Ingress Controller) |
| Écosystème             | Limité       | Très riche                  |

---

## 11. Nettoyage du cluster

```bash
docker stack rm nginx_stack
docker service rm web
docker swarm leave --force
```

---

## 🧩 Pour aller plus loin

* Intégrer un registry privé pour le déploiement Swarm.
* Mettre en place un réseau overlay sécurisé entre plusieurs sites.
* Ajouter une stack de monitoring complète (Prometheus + Grafana).

---

### 🕓 Durée estimée : 4 heures
