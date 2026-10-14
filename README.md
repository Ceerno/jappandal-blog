# jappandal.org — blog de Thierno LO

Thème WordPress (bloc / FSE) et outillage de déploiement cPanel du blog jappandal.org.

```
theme/                  Thème « Jappandal » (theme.json, templates, parts, patterns)
scripts/deploy-jappandal.sh   Installation initiale de WordPress + thème (WP-CLI, uapi)
.cpanel.yml             Déploiement continu du thème via cPanel Git Version Control
```

## 1. Relier le dépôt à cPanel (une fois)
**Automatique** (dépôt privé, clé dédiée qui ne touche pas aux autres projets) — dans le Terminal cPanel :
```bash
curl -fsSL -o setup-github-ssh.sh https://raw.githubusercontent.com/Ceerno/jappandal-blog/main/scripts/setup-github-ssh.sh  # si le dépôt est public
bash setup-github-ssh.sh
```
(Dépôt privé : déposer `scripts/setup-github-ssh.sh` dans le dossier personnel via le Gestionnaire de fichiers.)

**Manuel :**
1. cPanel › **Git™ Version Control** › Créer.
2. Activer **Cloner un dépôt**, URL : l'URL HTTPS (ou SSH si dépôt privé) de ce dépôt GitHub.
3. Chemin : `repositories/jappandal-blog`. Nom : `jappandal-blog`.

> Dépôt privé : ajouter d'abord la clé SSH du compte cPanel (Terminal : `ssh-keygen -t ed25519`, puis `cat ~/.ssh/id_ed25519.pub`) comme **Deploy key** dans GitHub › Settings › Deploy keys, et cloner avec l'URL `git@github.com:…`.

## 2. Installer WordPress (une fois)
Dans le Terminal cPanel :
```bash
bash ~/repositories/jappandal-blog/scripts/deploy-jappandal.sh
```
Le script crée la base MySQL, installe WordPress en français, active le thème, crée les pages (Accueil, Blog, Projets, À propos), les rubriques (Expertise, Projets, Réflexions), le menu et les permaliens. Il refuse de tourner si le dossier du site n'est pas vide. Adapter `DOCROOT` en haut du script (et dans `.cpanel.yml`) si la racine de jappandal.org n'est pas `~/jappandal.org`.

## 3. Déploiement automatique (branche `deploy-prod`)
La branche **`deploy-prod`** est la production : tout commit poussé dessus est publié sur jappandal.org en 5 minutes maximum.

Activation (une fois), dans le Terminal cPanel :
```bash
bash ~/repositories/jappandal-blog/scripts/install-auto-deploy.sh
```
Une tâche cron lance `scripts/auto-deploy.sh` toutes les 5 minutes. S'il y a un nouveau commit sur `origin/deploy-prod`, le script :
- aligne le dépôt cPanel sur la branche ;
- redéploie le thème si `theme/` a changé ;
- met à jour les pages si `content/` a changé (`scripts/update-content.sh`).

Il mémorise le dernier commit déployé avec succès (`~/.jappandal-deployed`) : un échec est retenté au passage suivant.

**Publier** : travailler sur `main`, puis fusionner dans `deploy-prod` (pull request GitHub ou `git push origin main:deploy-prod`).

- Journal : `tail -f ~/logs/jappandal-deploy.log`
- Fréquence : `SCHEDULE="*/2 * * * *" bash scripts/install-auto-deploy.sh`
- Désactiver : `bash scripts/install-auto-deploy.sh --remove`

### Pages de `content/` et admin WordPress
Chaque fichier `content/<slug>.html` alimente la page WordPress de même slug. **L'admin a le dernier mot** :
- page jamais modifiée dans WordPress → mise à jour depuis le dépôt à chaque déploiement ;
- page modifiée dans l'admin → conservée, le déploiement la saute (et le note dans le journal) ;
- pour réimposer la version du dépôt : `bash scripts/update-content.sh --force`.

La biographie de l'auteur n'est remplie que si elle est vide (ou avec `--force`).

### Articles de `content/articles/`
Chaque fichier `content/articles/<slug>.html` (en-tête `<!-- titre: … -->`, `<!-- rubrique: … -->` et, facultatif, `<!-- image: … -->` pris dans `content/articles/images/`) devient un article publié ; même règle « l'admin a le dernier mot ». État du projet et pièges connus : `HANDOFF.md`.

Déploiement manuel toujours possible : cPanel › Git Version Control › Pull or Deploy › *Deploy HEAD Commit* (`.cpanel.yml`).

Détails du thème : voir `theme/THEME.md`.
