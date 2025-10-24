# Git — Guide pratique pour débutants → intermédiaires

![LaMeDuSe_LOGO](./img/LaMeDuSe_logo.webp)

Vous trouverez ici un guide clair et structuré sur **Git** : installation, création de dépôt, workflow, branches, résolution de conflits et bonnes pratiques. Le document contient des exemples concrets prêts à copier-coller.

---

## 📚 Sommaire

1. [I. Git c’est quoi ?](#i-git-cest-quoi)  
2. [II. Installer et configurer Git](#ii-installer-et-configurer-git)  
3. [III. Créer un dépôt Git](#iii-créer-un-dépôt-git)  
4. [IV. Travailler avec Git](#iv-travailler-avec-git)  
5. [V. Travailler avec GitHub / GitLab](#v-travailler-avec-github--gitlab)  
6. [VI. Branches et fusions](#vi-branches-et-fusions)  
7. [VII. Résolution de conflits](#vii-résolution-de-conflits)  
8. [VIII. Bonnes pratiques](#viii-bonnes-pratiques)  
9. [IX. Commandes utiles et astuces](#ix-commandes-utiles-et-astuces)

---

## I. Git c’est quoi ?

Git est un **système de gestion de versions décentralisé** permettant de suivre l’évolution de fichiers dans le temps, de collaborer et de revenir à n’importe quel état précédent.

➡️ **Concrètement :**  
- Git enregistre des *snapshots* (états) du projet.  
- Chaque modification est un *commit*.  
- On peut naviguer dans l’historique, créer des branches et fusionner.

---

## II. Installer et configurer Git

### Installation
```bash
# Debian / Ubuntu
sudo apt install git -y

# Fedora / CentOS / Rocky
sudo dnf install git -y

# macOS (brew)
brew install git
```

### Configuration
```bash
git config --global user.name "Ton Nom"
git config --global user.email "ton.email@exemple.com"
git config --global color.ui auto
git config --global core.editor vim
```

---

## III. Créer un dépôt Git

### Nouveau projet
```bash
mkdir mon_projet
cd mon_projet
git init
```

### Ajouter et committer
```bash
touch README.md
git add README.md
git commit -m "Initial commit"
```

---

## IV. Travailler avec Git

### Statut et historique
```bash
git status
git log --oneline --graph --decorate
```

### Modifier des fichiers
```bash
echo "Hello Git" > fichier.txt
git add fichier.txt
git commit -m "Ajout du fichier de test"
```

### Supprimer ou renommer
```bash
git rm fichier.txt
git mv ancien.txt nouveau.txt
```

---

## V. Travailler avec GitHub / GitLab

### Cloner un dépôt distant
```bash
git clone https://github.com/moncompte/monrepo.git
```

### Ajouter un dépôt distant
```bash
git remote add origin https://github.com/moncompte/monrepo.git
git push -u origin main
```

### Mettre à jour
```bash
git pull origin main
git push origin main
```

---

## VI. Branches et fusions

### Créer / changer de branche
```bash
git branch dev
git checkout dev
```

### Fusionner une branche
```bash
git checkout main
git merge dev
```

### Supprimer une branche
```bash
git branch -d dev
```

---

## VII. Résolution de conflits

```bash
<<<<<<< HEAD
Version de la branche main
=======
Version de la branche dev
>>>>>>> dev
```

- Éditer le fichier et choisir la bonne version.  
- Puis :
```bash
git add fichier_conflit.txt
git commit
```

---

## VIII. Bonnes pratiques

- Toujours **pull** avant de **push**.  
- Faire des **commits petits et clairs**.  
- Utiliser des **messages explicites**.  
- Ne jamais committer directement sur `main`.  
- Ajouter un `.gitignore` pour éviter les fichiers inutiles.  

Exemple `.gitignore` :
```
node_modules/
*.log
.env
```

---

## IX. Commandes utiles et astuces

| Commande | Description |
|-----------|-------------|
| `git diff` | Voir les changements avant un commit |
| `git stash` | Sauvegarde temporaire des modifications |
| `git restore` | Annule les modifications locales |
| `git tag` | Crée une version stable |
| `git reset --hard` | Annule tout et revient à un état précis |
| `git reflog` | Historique complet des actions locales |
| `git cherry-pick <commit>` | Applique un commit d’une autre branche |

---

© 2025 — Guide Git — Niveau Débutant → Intermédiaire
