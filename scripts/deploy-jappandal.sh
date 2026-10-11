#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Déploiement de jappandal.org sur cPanel (WordPress + thème Jappandal)
#  Installation initiale (une seule fois), depuis le Terminal cPanel :
#    bash ~/repositories/jappandal-blog/scripts/deploy-jappandal.sh
#  Les mises à jour du thème passent ensuite par .cpanel.yml (Deploy HEAD Commit).
# ------------------------------------------------------------------
set -euo pipefail

# ====== À ADAPTER SI BESOIN ======================================
DOMAIN="jappandal.org"
DOCROOT="${DOCROOT:-$HOME/jappandal.org}"   # racine du domaine ; surcharge : DOCROOT=~/xxx bash …
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # dépôt cloné par cPanel
THEME_SRC="$REPO_DIR/theme"
SITE_TITLE="jappandal"
SITE_TAGLINE="Le carnet de Thierno LO"
ADMIN_USER="thierno"
DB_SUFFIX="jpblog"                   # la base sera <utilisateur cpanel>_jpblog
# =================================================================

CPUSER="$(whoami)"
DB_NAME="${CPUSER}_${DB_SUFFIX}"
DB_USER="${CPUSER}_${DB_SUFFIX}"
say()  { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }
die()  { printf '\n\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }
trap 'printf "\n\033[1;31m✖ Échec ligne %s : %s\033[0m\n" "$LINENO" "$BASH_COMMAND" >&2' ERR

say "Déploiement de $DOMAIN (utilisateur $CPUSER)"
# Mot de passe BDD aléatoire (lecture bornée : pas de SIGPIPE sous pipefail)
DB_PASS="$(head -c 48 /dev/urandom | base64 | LC_ALL=C tr -dc 'A-Za-z0-9' | cut -c1-24)"
[ ${#DB_PASS} -ge 20 ] || die "Impossible de générer le mot de passe de la base."

# --- 0. Vérifications ------------------------------------------------
[ -f "$THEME_SRC/style.css" ] || die "Thème introuvable dans $THEME_SRC : lancez le script depuis le dépôt cloné (bash ~/repositories/jappandal-blog/scripts/deploy-jappandal.sh)."
mkdir -p "$DOCROOT"
if [ -n "$(ls -A "$DOCROOT" 2>/dev/null | grep -vE '^(cgi-bin|\.well-known|\.htaccess|default\.html?|index\.html?)$' || true)" ]; then
  die "$DOCROOT n'est pas vide. Sauvegardez/videz-le, ou changez DOCROOT en haut du script."
fi
command -v uapi >/dev/null || die "La commande uapi est absente : créez la base via cPanel > Bases de données MySQL, puis relancez avec DB_NAME/DB_USER/DB_PASS renseignés."

read -rp  "E-mail administrateur : " ADMIN_EMAIL
read -rsp "Mot de passe administrateur WordPress : " ADMIN_PASS; echo
[ ${#ADMIN_PASS} -ge 12 ] || die "Mot de passe trop court (12 caractères minimum)."

# --- 1. WP-CLI -------------------------------------------------------
say "Préparation de WP-CLI"
if command -v wp >/dev/null; then
  WP="wp"
else
  mkdir -p "$HOME/bin"
  curl -sSL -o "$HOME/bin/wp" https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x "$HOME/bin/wp"
  WP="$HOME/bin/wp"
fi
WP="$WP --path=$DOCROOT --skip-plugins --skip-themes"

# --- 2. Base de données ---------------------------------------------
say "Création de la base $DB_NAME"
uapi Mysql create_database name="$DB_NAME" >/dev/null
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null
uapi Mysql set_privileges_on_database user="$DB_USER" database="$DB_NAME" privileges=ALL >/dev/null

# --- 3. WordPress ----------------------------------------------------
say "Téléchargement de WordPress (français)"
$WP core download --locale=fr_FR

say "Configuration"
$WP config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --dbhost=localhost --locale=fr_FR
$WP config set DISALLOW_FILE_EDIT true --raw
$WP config set WP_POST_REVISIONS 10 --raw

SCHEME="https"
curl -sI "https://$DOMAIN" >/dev/null 2>&1 || { SCHEME="http"; echo "  (SSL pas encore actif : installation en http, à basculer ensuite)"; }

say "Installation"
$WP core install --url="$SCHEME://$DOMAIN" --title="$SITE_TITLE" \
  --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASS" --admin_email="$ADMIN_EMAIL" --skip-email

# --- 4. Thème --------------------------------------------------------
say "Installation du thème Jappandal"
mkdir -p "$DOCROOT/wp-content/themes/jappandal"
cp -R "$THEME_SRC/." "$DOCROOT/wp-content/themes/jappandal/"
$WP theme activate jappandal
$WP theme delete twentytwentythree twentytwentyfour >/dev/null 2>&1 || true
$WP plugin delete hello akismet >/dev/null 2>&1 || true

# --- 5. Réglages -----------------------------------------------------
say "Réglages du site"
$WP option update blogdescription "$SITE_TAGLINE"
$WP option update timezone_string "Africa/Dakar"
$WP option update date_format "j F Y"
$WP option update default_comment_status closed
$WP rewrite structure '/%postname%/' --category-base=categorie --hard
$WP post delete 1 2 --force >/dev/null 2>&1 || true   # article et page d'exemple

say "Pages et rubriques"
HOME_ID=$($WP post create --post_type=page --post_status=publish --post_title="Accueil" --porcelain)
BLOG_ID=$($WP post create --post_type=page --post_status=publish --post_title="Blog" --post_name=blog --porcelain)
$WP post create --post_type=page --post_status=publish --post_title="À propos" --post_name=a-propos \
  --post_content='<!-- wp:paragraph --><p>[Votre présentation ici.]</p><!-- /wp:paragraph -->' >/dev/null
$WP post create --post_type=page --post_status=publish --post_title="Projets" --post_name=projets \
  --post_content='<!-- wp:pattern {"slug":"jappandal/projets"} /-->' --page_template=page-pleine-largeur >/dev/null
$WP option update show_on_front page
$WP option update page_on_front "$HOME_ID"
$WP option update page_for_posts "$BLOG_ID"

$WP term create category "Expertise"  --slug=expertise  >/dev/null
$WP term create category "Projets"    --slug=projets    >/dev/null
$WP term create category "Réflexions" --slug=reflexions >/dev/null
$WP term update category 1 --name="Non classé" >/dev/null 2>&1 || true

say "Menu principal"
NAV='<!-- wp:navigation-link {"label":"Articles","url":"/blog/"} /--><!-- wp:navigation-link {"label":"Projets","url":"/projets/"} /--><!-- wp:navigation-link {"label":"Réflexions","url":"/categorie/reflexions/"} /--><!-- wp:navigation-link {"label":"À propos","url":"/a-propos/"} /-->'
$WP post create --post_type=wp_navigation --post_status=publish --post_title="Menu principal" --post_content="$NAV" >/dev/null

$WP rewrite flush --hard
$WP cache flush >/dev/null 2>&1 || true

# --- 6. Récapitulatif ------------------------------------------------
CRED="$HOME/.jappandal-db.txt"
printf 'DB_NAME=%s\nDB_USER=%s\nDB_PASS=%s\n' "$DB_NAME" "$DB_USER" "$DB_PASS" > "$CRED"
chmod 600 "$CRED"

say "Terminé !"
echo "  Site        : $SCHEME://$DOMAIN"
echo "  Admin       : $SCHEME://$DOMAIN/wp-admin  (identifiant : $ADMIN_USER)"
echo "  Accès BDD   : enregistrés dans $CRED"
[ "$SCHEME" = "http" ] && echo "  ⚠ Après émission du certificat SSL :  $WP search-replace 'http://$DOMAIN' 'https://$DOMAIN' --all-tables"
echo
