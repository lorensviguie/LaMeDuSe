# TP CI/CD - Part 3 : Push, Build & Deploy

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

## Sommaire

1. **Linting**

   * A. Introduction
   * B. Lint me baby
   * C. Format me baby
2. **Secret Scanning**

   * A. Introduction
   * B. Find a tool
3. **Building**
4. **Publishing**
5. **Some manual tests**

---

## 1. Linting

### A. Introduction

Le **linting** permet de vérifier la qualité du code automatiquement. Il détecte les erreurs de syntaxe, les mauvaises pratiques et les incohérences dans le code.

### B. Lint me baby

Créez un job GitLab CI pour lancer le linting :

```yaml
lint-job:
  stage: lint
  image: node:18
  script:
    - npm install eslint
    - npx eslint .
```

### C. Format me baby

Ajoutez un job pour formatter automatiquement le code :

```yaml
format-job:
  stage: lint
  image: node:18
  script:
    - npm install prettier
    - npx prettier --write .
```

---

## 2. Secret scanning

### A. Introduction

Le **secret scanning** permet de détecter des informations sensibles (tokens, mots de passe) dans votre code.

### B. Find a tool

Exemple avec [Gitleaks](https://github.com/zricethezav/gitleaks) :

```yaml
secret-scan-job:
  stage: secret_scan
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source .
```

---

## 3. Building

Créez un job de build Docker :

```yaml
build-job:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t myapp:${CI_COMMIT_SHA} .
```

---

## 4. Publishing

Publiez l'image sur un registry (ex: GitLab Container Registry) :

```yaml
publish-job:
  stage: publish
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push myapp:${CI_COMMIT_SHA}
```

---

## 5. Some manual tests

Créez un job manuel pour effectuer des tests :

```yaml
test-job:
  stage: test
  image: node:18
  script:
    - npm install
    - npm test
  when: manual
```

---

### Next steps

Après cette partie, vous avez mis en place une **pipeline complète** qui :

* Lint votre code
* Scanne les secrets
* Build et publie une image Docker
* Permet d’exécuter des tests manuels

