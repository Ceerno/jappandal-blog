#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Met à jour le contenu éditorial depuis le dépôt :
#   - page « À propos » (content/a-propos.html)
#   - nom affiché et biographie de l'auteur (carte auteur des articles)
#  Usage : bash ~/repositories/jappandal-blog/scripts/update-content.sh
# ------------------------------------------------------------------
set -euo pipefail

DOCROOT="${DOCROOT:-$HOME/jappandal.org}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTHOR="${AUTHOR:-thierno}"
BIO="Entrepreneur dans la tech et cofondateur de Volkeno. Passionné par l'innovation, la transmission du savoir et les solutions qui ont un impact réel. J'écris pour apprendre, construire et transmettre."

say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

if command -v wp >/dev/null; then WP=wp; elif [ -x "$HOME/bin/wp" ]; then WP="$HOME/bin/wp"; else die "WP-CLI introuvable."; fi
WP="$WP --path=$DOCROOT --skip-plugins --skip-themes"
$WP core is-installed || die "WordPress introuvable dans $DOCROOT."

say "Page À propos"
PAGE_ID="$($WP post list --post_type=page --name=a-propos --field=ID --posts_per_page=1)"
[ -n "$PAGE_ID" ] || PAGE_ID="$($WP post create --post_type=page --post_status=publish --post_title='À propos' --post_name=a-propos --porcelain)"
$WP post update "$PAGE_ID" "$REPO_DIR/content/a-propos.html" >/dev/null
echo "   page #$PAGE_ID mise à jour"

say "Profil auteur ($AUTHOR)"
$WP user update "$AUTHOR" --first_name=Thierno --last_name=LO --display_name="Thierno LO" \
  --user_url="https://www.linkedin.com/in/tlolinkedin" --description="$BIO" >/dev/null
echo "   nom affiché et biographie mis à jour"

$WP cache flush >/dev/null 2>&1 || true
say "Terminé — vérifiez https://jappandal.org/a-propos/"
