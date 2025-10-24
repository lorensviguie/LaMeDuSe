# TP Docker : Créer son propre registre Docker

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## Objectif
Mettre en place un **Docker Registry privé** sur une machine locale et y stocker vos propres images Docker.

---

## Prérequis
- Une machine avec **Docker installé**.
- Connaissance de base des commandes Docker (`docker pull`, `docker run`, `docker push`, `docker pull`).

---

## 1. Lancer un registre Docker privé

Docker fournit une image officielle `registry` pour créer un registre local.

```bash
# Créer un conteneur Registry local sur le port 5000
docker run -d -p 5000:5000 --name registry registry:2
```

- `-d` : détaché (background)
- `-p 5000:5000` : expose le port 5000
- `registry:2` : image officielle Docker Registry version 2

Vérifier que le conteneur tourne :

```bash
docker ps
```

---

## 2. Taguer une image pour le registre local

Prenons l’image `alpine` comme exemple.

```bash
docker pull alpine
docker tag alpine localhost:5000/alpine
```

- `localhost:5000/alpine` : nom de l’image avec le registre local

---

## 3. Pousser l’image dans le registre local

```bash
docker push localhost:5000/alpine
```

Si tout se passe bien, l’image est maintenant dans votre **registre privé**.

---

## 4. Récupérer une image depuis le registre local

Supprimez d’abord l’image locale pour tester le pull :

```bash
docker rmi alpine
docker pull localhost:5000/alpine
```

Vous venez de **récupérer l’image depuis votre propre registre**.

---

## 5. (Optionnel) Accéder à l’interface Web du registre

Vous pouvez ajouter un conteneur avec l’interface **Portus** ou **Docker Registry UI**, mais pour un TP simple, utilisez juste `curl` pour vérifier :

```bash
curl http://localhost:5000/v2/_catalog
```

- Cela affichera les images présentes dans votre registre local.

---

## 6. Nettoyer le registre

Pour arrêter et supprimer le registre :

```bash
docker stop registry
docker rm registry
```

---

## Conclusion

Vous avez créé votre **registre Docker privé**, tagué une image, poussé et récupéré cette image.  
Vous pouvez maintenant héberger vos propres images Docker et partager vos développements localement ou sur un réseau interne.
