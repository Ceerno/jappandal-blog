# Handoff — jappandal.org

Dernière mise à jour : **2026-10-13** · `main` = `deploy-prod` @ `2febeb1` · thème **1.4.1**.

---

## 0. Prochaine action

Rien de bloquant côté code. Restent des réglages dans l'admin WordPress (à faire par Thierno) :

1. **À propos** : supprimer le paragraphe « À propos de moi » sous le titre (étiquette en double).
   La page a été modifiée dans l'admin le 2026-10-12 → la synchro ne la touche plus (§4).
   Le dépôt dit « deux associés », l'admin « trois » : aligner `content/a-propos.html` si on veut un jour `--force`.
2. **Premier article** : ajouter une image à la une, renseigner la méta-description Rank Math.
3. **MailPoet** : désactiver les affichages automatiques du formulaire (doublons), vérifier double opt-in
   et envoi ; vérifier si une notification « nouvel article » est partie.

---

## 1. Où en est le site

| Élément | État |
|---|---|
| Thème FSE `theme/` | 1.4.1, audit UI/UX appliqué (contraste, focus, mobile 320 px, menu) |
| Menu | Articles (/blog/) · Projets · À propos, page courante marquée (filtre PHP) |
| Projets | page `/projets/` = bandeau sombre pleine largeur de l'accueil, logos des 4 applis |
| Newsletter | formulaire MailPoet n° 1 rendu dans le pattern (vérifié en ligne) ; rendu visuel mobile à contrôler |
| Articles | 1 publié : « L'école publique se perd, l'excellence se privatise » (Réflexions, #18) |
| Logo / favicon | `assets/brand/`, `assets/favicon/` ; favicon servi tant qu'aucune icône du site n'est définie |
| SEO | Rank Math installé (réglages à faire) |

Rubriques : Expertise, Projets, Réflexions (slugs identiques, base `/categorie/`). **Pas** de rubrique « Constat » (décision : l'article va dans Réflexions).

---

## 2. Publier

- Travailler sur `main`, puis `git push origin main:deploy-prod`.
- Cron cPanel toutes les 5 min (`scripts/auto-deploy.sh`) : rsync de `theme/`, puis `scripts/update-content.sh`
  **seulement si** `content/` ou ce script ont changé.
- Journal serveur : `~/logs/jappandal-deploy.log` (pas d'accès SSH depuis le poste : demander à Thierno via le Terminal cPanel).
- Vérifier un déploiement : `curl -s https://jappandal.org/ | grep -o 'style.css?ver=[0-9.]*'` (bumper `Version:` dans `theme/style.css` à chaque changement de thème).

---

## 3. Écrire un article

Fichier `content/articles/<slug>.html` :

```html
<!-- titre: Le titre -->
<!-- rubrique: reflexions -->
<!-- wp:paragraph --><p>…</p><!-- /wp:paragraph -->
```

- Rubrique : slug ou nom ; créée si absente.
- Publié sous l'auteur `thierno`, statut publié, date du déploiement.
- Phrase forte mise en avant : `<!-- wp:paragraph {"className":"jp-emphase"} -->` (grand corps, barre ocre).

---

## 4. Règle « l'admin a le dernier mot »

Pages (`content/<slug>.html`) et articles : empreinte du contenu stockée dans la méta `_jappandal_sync`.
Contenu modifié dans l'admin → la synchro le saute. `bash scripts/update-content.sh --force` réimpose le dépôt
(**attention** : écraserait À propos, cf. §0).

---

## 5. Pièges connus (ne pas re-découvrir)

- **Shortcodes dans un pattern** : non exécutés dans un thème bloc (do_shortcode passe avant l'expansion des patterns) → appeler `do_shortcode()` en PHP dans le pattern (cf. `patterns/newsletter.php`).
- **`backdrop-filter` sur l'en-tête** piège le menu mobile `position: fixed` → le flou est sur `::before`.
- **Template assigné dans l'admin** (« Pleine largeur » sur Projets) prioritaire sur `page-{slug}.html`, même avec `page_template_hierarchy` → ne pas compter dessus ; modifier le template assigné.
- **page-pleine-largeur** : le `main` doit rester en layout `default`, sinon tout le contenu est bridé à 720 px.
- **Grille « Derniers articles »** : `offset` 1 (le hero montre déjà le dernier) seulement s'il y a au moins 2 articles, sinon la grille serait vide.
- **Marges des titres d'article** limitées aux enfants directs de `.wp-block-post-content` (sinon elles cassent les patterns insérés dans une page).
- **Push vers `deploy-prod`** : refusé à l'agent par la politique d'auto-mode → c'est Thierno qui lance `! git push origin main:deploy-prod`.
- Pas de PHP local : valider le rendu via un aperçu statique (HTML live + `style.css` local) ou directement en ligne.

---

## 6. Fichiers clés

- `theme/functions.php` : temps de lecture, « À lire ensuite » sans l'article courant, menu actif, favicon, formulaire MailPoet.
- `theme/patterns/` : hero, rubriques, derniers-articles, projets (logos dans `assets/logos/`), citation, newsletter, etat-vide.
- `scripts/update-content.sh` : synchro pages + articles.
- `theme/THEME.md` : checklist de mise en service du thème.
- Logos des applis : Al hafiz, Jàng Yi, Ñu Lay Gis repris de leurs sites ; **Kurus Tijaan = logo provisoire** (chapelet) à remplacer dans `theme/assets/logos/kurustijaan.svg`.
