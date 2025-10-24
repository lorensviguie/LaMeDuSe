# 🖥️ Introduction à la Virtualisation et à la Conteneurisation

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## 1. Qu’est-ce que la Virtualisation ?

La **virtualisation** est une technologie qui permet de **faire fonctionner plusieurs systèmes ou environnements isolés sur une même machine physique**.  
L’objectif est d’**optimiser l’utilisation des ressources matérielles** (CPU, RAM, stockage) tout en **isolant les systèmes** les uns des autres.

En résumé, la virtualisation consiste à **simuler un ordinateur dans un ordinateur**.

### 🔹 Exemple concret :
Un serveur physique peut héberger :
- Une machine virtuelle (VM) Windows pour les utilisateurs,
- Une autre VM Linux pour les développeurs,
- Et une VM spécialisée pour héberger une base de données.

Chaque VM fonctionne **comme si elle avait son propre matériel**, alors qu’elle partage en réalité celui du serveur hôte.

---

## 2. Pourquoi virtualiser ?

- **Optimiser les ressources matérielles** : une seule machine physique héberge plusieurs systèmes.  
- **Réduire les coûts** : moins de serveurs physiques à entretenir.  
- **Faciliter la maintenance et les tests** : possibilité de créer, sauvegarder, cloner et restaurer facilement des environnements.  
- **Isolation** : un problème sur une VM n’affecte pas les autres.  
- **Sécurité** : cloisonnement entre environnements.

---

## 3. Les trois grands types de virtualisation

Il existe **trois approches principales** de la virtualisation moderne :

---

### 🧱 3.1. La Virtualisation Complète (Type 1)

#### 🔹 Principe :
Le système d’exploitation invité tourne **directement sur le matériel physique** grâce à un **hyperviseur de type 1**, aussi appelé **hyperviseur natif**.

#### 🔹 Fonctionnement :
L’hyperviseur s’installe **en dessous des systèmes d’exploitation**.  
Il gère directement le matériel et distribue les ressources entre les différentes machines virtuelles.

#### 🔹 Exemples :
- **VMware ESXi**
- **Microsoft Hyper-V**
- **KVM (Kernel Virtual Machine)**

#### 🔹 Avantages :
- Isolation **forte** entre les VM.
- Performances proches du matériel natif.
- Haute stabilité et fiabilité.

#### 🔹 Inconvénients :
- Plus complexe à administrer.
- Nécessite du matériel dédié (souvent utilisé en data center).

---

### 💻 3.2. La Virtualisation de Type 2 (via VirtualBox, VMware Workstation...)

#### 🔹 Principe :
Ici, l’hyperviseur s’exécute **au-dessus d’un système d’exploitation hôte** (Windows, Linux, macOS).  
On parle de **virtualisation logicielle** ou **hébergée**.

#### 🔹 Exemple :
- **VirtualBox**
- **VMware Workstation**
- **Parallels Desktop**

#### 🔹 Fonctionnement :
L’OS hôte gère le matériel, et l’hyperviseur crée des machines virtuelles **comme des applications classiques**.  
Chaque VM contient un OS invité complet (Windows, Linux, etc.).

#### 🔹 Avantages :
- Facile à installer et à utiliser.  
- Parfait pour les tests et la formation.  
- Supporte plusieurs OS invités.

#### 🔹 Inconvénients :
- Moins performant (car dépend du système hôte).  
- Moins adapté à la production.

---

### 🐳 3.3. La Virtualisation via les Namespaces (Conteneurisation)

#### 🔹 Principe :
Au lieu de simuler un matériel complet, on **isole des processus** dans le même système d’exploitation.  
C’est ce qu’on appelle la **conteneurisation**.

Les conteneurs partagent **le même noyau Linux**, mais ont leur propre :
- espace réseau,
- système de fichiers,
- gestion des utilisateurs,
- ressources CPU/mémoire (via les **cgroups**).

#### 🔹 Outils typiques :
- **LXC / LXD** : conteneurs Linux “natifs”.
- **Docker** : abstraction et automatisation de la gestion des conteneurs.
- **Podman**, **rkt**, etc.

#### 🔹 Avantages :
- Très léger (pas d’OS complet dans chaque conteneur).
- Démarrage instantané.
- Parfait pour le **déploiement d’applications modernes** et les **microservices**.

#### 🔹 Inconvénients :
- Isolation moins forte qu’une VM (même noyau partagé).
- Moins adapté à l’exécution d’OS différents (pas de Windows dans un conteneur Linux).

---

## 4. La Conteneurisation en Détail

### 🧩 Les technologies fondamentales :
- **Namespaces** : isolent les ressources (PID, réseau, système de fichiers...).  
- **Control Groups (cgroups)** : limitent les ressources (CPU, mémoire, I/O...).  
- **UnionFS (OverlayFS)** : gère les couches de fichiers superposées.

### 🐳 Le positionnement de Docker :
Docker est une **surcouche pratique à LXC** qui :
- Automatise la création et la gestion des conteneurs,
- Simplifie le partage d’images et la reproductibilité,
- Fournit un écosystème complet (Docker Hub, Docker Compose, etc.).

### ⚖️ Docker versus Virtualisation classique :
| Critère | Machine virtuelle | Conteneur Docker |
|----------|------------------|------------------|
| Noyau | Propre à chaque VM | Partagé (même OS hôte) |
| Poids | Lourd (OS complet) | Léger |
| Démarrage | Lent (secondes à minutes) | Instantané |
| Isolation | Forte | Moyenne |
| Usage typique | Serveurs multiples, environnements hétérogènes | Microservices, CI/CD, cloud |

---

## 5. En résumé

| Type | Technologie | Noyau utilisé | Performance | Isolation | Exemple d’usage |
|------|--------------|---------------|--------------|------------|----------------|
| Type 1 | Hyperviseur natif | Propre à chaque VM | Haute | Très forte | Data center, production |
| Type 2 | Hyperviseur hébergé | Propre à chaque VM | Moyenne | Bonne | Formation, tests |
| Conteneur | Namespaces / Cgroups | Noyau partagé | Très haute | Moyenne | Déploiement applicatif |

---

## 6. Conclusion

- La **virtualisation complète** permet de faire tourner **plusieurs OS différents** sur le même serveur.
- La **virtualisation de type 2** est pratique pour **tester et expérimenter** facilement.
- La **conteneurisation** (Docker, LXC) est la solution **moderne, rapide et légère** pour déployer des applications à grande échelle.

> 🎯 En résumé : les machines virtuelles simulent du **matériel**, tandis que les conteneurs isolent du **logiciel**.  
> Ces deux approches sont **complémentaires** : on peut exécuter des conteneurs Docker **dans** des VM pour combiner flexibilité et isolation.
