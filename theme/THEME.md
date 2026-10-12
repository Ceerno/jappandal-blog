# Thème Jappandal — jappandal.org

Thème bloc WordPress (édition complète du site) tiré de la maquette Claude Design « Blog jappandal.org ».

## Contenu
- `theme.json` : palette (teal profond #00564B, ocre, encre, sable), typos (Bricolage Grotesque, Source Serif 4, JetBrains Mono), espacements.
- `templates/` : accueil (`front-page`), liste des articles (`index`), rubrique (`archive`), article (`single`), page, page pleine largeur, page Projets (`page-projets`, forcée pour le slug `projets` : son contenu admin est ignoré, les fiches se modifient dans `patterns/projets-liste.php`, logos dans `assets/logos/`), recherche, 404.
- `parts/` : en-tête et pied de page (avec bloc newsletter).
- `patterns/` : Hero, Rubriques, Grille d'articles, Projets Jappandal, Citation, Newsletter — insérables partout via l'inserteur > Compositions > Jappandal.
- Shortcode `[temps_lecture]` : temps de lecture estimé.

## Mise en ligne — checklist
1. **Hébergement + domaine** : WordPress 6.5+ / PHP 7.4+ sur jappandal.org (HTTPS activé).
2. **Installer le thème** : Apparence › Thèmes › Ajouter › Téléverser `jappandal-theme.zip` › Activer.
3. **Réglages › Lecture** : « Une page statique » — Accueil : page « Accueil » (vide), Articles : page « Blog ». Le modèle `front-page` habille l'accueil automatiquement.
4. **Réglages › Permaliens** : « Titre de la publication ».
5. **Catégories** : créer `Expertise`, `Projets`, `Réflexions` (slugs : `expertise`, `projets`, `reflexions`). Si la base des catégories reste `category`, mettre à jour les liens du bloc Rubriques (ou régler « Préfixe des catégories » = `categorie` dans Permaliens).
6. **Menu** : Apparence › Éditeur › Navigation : Articles (/blog/), Projets, Réflexions, À propos.
7. **Profil** : Utilisateurs › Profil — nom affiché « Thierno LO », biographie, photo (Gravatar) → alimentent la carte auteur des articles.
8. **Newsletter** : activer MailPoet et créer un formulaire (champ e-mail + bouton). Le bloc Newsletter affiche automatiquement le premier formulaire actif ; pour en imposer un autre : `add_filter( 'jappandal_mailpoet_form_id', fn() => 3 );`. Désactiver dans MailPoet les affichages automatiques du formulaire (sous les articles, pop-up…) pour éviter les doublons.
9. **Réseaux** : éditer le pied de page pour mettre les vraies URL LinkedIn / GitHub / X.
10. **Essentiels** : Yoast SEO ou Rank Math, une extension de cache, sauvegardes (UpdraftPlus), anti-spam.

## Polices
Chargées depuis Google Fonts (`functions.php`). Pour héberger localement, utiliser Apparence › Éditeur › Styles › Typographie (bibliothèque de polices de WordPress) et retirer l'appel Google Fonts.
