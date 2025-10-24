# TP CI/CD - Part 2 : First CI GitLab

![logo](/img/LaMeDuSe_logo.webp)

Dans cette première partie, vous allez mettre en place **une pipeline de CI** sur GitLab pour exécuter des tâches automatiquement à chaque push.

Nous allons travailler sur **le dépôt du TP2**.

---

## 1. Créer le fichier `gitlab-ci.yml`

Une pipeline GitLab se compose de **stages**, et chaque stage contient un ou plusieurs **jobs**. Chaque job exécute des commandes dans un environnement spécifique.

À la racine de votre dépôt, créez un fichier `gitlab-ci.yml` :

```yaml
image: debian:latest

stages:
  - meow

meow-job:
  stage: meow
  before_script:
    - apt-get update -qq
    - apt-get install -y cowsay
  script:
    - /usr/games/cowsay "Meoooow"
```

---

## 2. Ajouter et pousser le fichier

```bash
git add gitlab-ci.yml
git commit -m "Add GitLab CI pipeline"
git push origin main
```

---

## 3. Vérifier la pipeline

1. Allez sur la **WebUI GitLab**.
2. Vérifiez que le fichier `gitlab-ci.yml` est bien présent.
3. Dans le menu `CI / CD` > `Pipelines`, vous devriez voir votre job en cours d'exécution.
4. Ouvrez le job pour consulter l'output console.

> Le job s'exécute dans un conteneur Docker éphémère clonant votre dépôt pour réaliser les tests.

---

## 4. Résultat attendu

Vous devriez voir dans l'output :

```
 _________
< Meoooow >
 ---------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

---

## 5. Suite

Après avoir vérifié que votre job s'exécute correctement, passez à la partie suivante :

👉 [**Part 2 : Test then Build**](./part2.md)


