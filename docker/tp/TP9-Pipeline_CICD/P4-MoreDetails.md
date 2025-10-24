# TP CI/CD - Part 4 : Étoffer la CI/CD (Environnement Local)

Dans ce TP, vous allez améliorer et enrichir votre pipeline CI/CD en travaillant **sur un GitLab self-hosted** sur votre machine locale. Tout se fera en SSH et sur cette machine, sans dépendre de services cloud.

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

---

## Index

* I. Hooks
* II. HTTPS (Local)

  * 1. Prérequis
  * 2. Manuel
  * 3. Automatisation
* III. Security tests

  * 1. Vulnérabilité
  * 2. SAST
  * 3. Unit testing

---

# I. Hooks

Les *hooks* git sont des scripts qui s'exécutent localement avant certaines actions git (commit, push, etc.) pour effectuer des vérifications.

### Pre-commit hook

* Lint le code
* Formate le code
* Détecte les secrets avant commit

> Astuce : écrivez-le en Python et utilisez `docker run` pour exécuter les outils dans des conteneurs, sans les installer sur votre machine.

Placez le hook dans `.git/hooks/pre-commit` et rendez-le exécutable :

```bash
chmod +x .git/hooks/pre-commit
```

---

# II. HTTPS (Local)

Même en local, il est possible de tester HTTPS avec des certificats auto-signés.

## 1. Prérequis

* Installer `openssl`
* Avoir un dépôt GitLab self-hosted accessible en SSH ou HTTP sur la machine locale

## 2. Manuel

* Générer un certificat auto-signé :

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt
```

* Placez `tls.key` et `tls.crt` dans le dossier de votre application
* Configurer votre application pour HTTPS en utilisant ces fichiers
* Définir deux variables d'environnement :

  * `TLS_CERT` : chemin du certificat
  * `TLS_KEY` : chemin de la clé

## 3. Automatisation

* Ajouter un job `cert` dans `.gitlab-ci.yml` sous le stage `deploy`
* Le job peut régénérer ou vérifier les certificats auto-signés si nécessaire

> Pour un vrai workflow de production, on utiliserait un reverse-proxy pour gérer HTTPS, mais ici tout se fait localement.

---

# III. Security tests

## 1. Vulnérabilité

* Stage `scan`, job `vuln`
* Exécuter après le `build`
* Utiliser `trivy` pour scanner l'image Docker construite localement
* Vérifier les vulnérabilités présentes
* Job non-bloquant

## 2. SAST

* Stage `scan`, job `sast`
* Analyse statique du code avec `semgrep` ou équivalent
* Recherche de patterns vulnérables dans votre code

## 3. Unit testing

* Stage `quality`, job `unit-test`
* Exécuter avant le `build`
* Ajouter un test unitaire minimal si vous n'en avez pas
* Lancer les tests unitaires en CI

---

### Conclusion

Avec ce TP local, votre pipeline CI/CD :

* S'exécute entièrement sur une machine GitLab self-hosted
* Dispose de hooks git pour garantir la qualité du code
* Peut tester HTTPS avec des certificats auto-signés
* Effectue des tests de sécurité et des tests unitaires
* Reste autonome et indépendant de services cloud
