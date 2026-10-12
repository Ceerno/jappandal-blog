#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Synchronise les pages de content/ vers WordPress, SANS écraser
#  les modifications faites dans l'admin.
#
#  Fichier → page : content/<slug>.html → page WordPress de slug <slug>
#  Règle : une page n'est réécrite que si son contenu actuel est encore
#  celui de la dernière synchronisation (empreinte stockée dans la méta
#  _jappandal_sync). Si elle a été modifiée dans l'admin, elle est
#  laissée telle quelle : l'admin a toujours le dernier mot.
#
#  Usage :
#    bash scripts/update-content.sh            # synchronisation prudente
#    bash scripts/update-content.sh --force    # réécrit tout depuis le dépôt
# ------------------------------------------------------------------
set -euo pipefail

DOCROOT="${DOCROOT:-$HOME/jappandal.org}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTHOR="${AUTHOR:-thierno}"
FORCE=0; [ "${1:-}" = "--force" ] && FORCE=1
BIO="Entrepreneur dans la tech et cofondateur de Volkeno. Passionné par l'innovation, la transmission du savoir et les solutions qui ont un impact réel. J'écris pour apprendre, construire et transmettre."

say() { printf '\033[1;32m▶ %s\033[0m\n' "$*"; }
die() { printf '\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }
fp()  { tr -d '[:space:]' | md5sum | cut -c1-32; }   # empreinte insensible aux espaces

if command -v wp >/dev/null; then WP=wp; elif [ -x "$HOME/bin/wp" ]; then WP="$HOME/bin/wp"; else die "WP-CLI introuvable."; fi
WP="$WP --path=$DOCROOT --skip-plugins --skip-themes"
$WP core is-installed || die "WordPress introuvable dans $DOCROOT."

for file in "$REPO_DIR"/content/*.html; do
  [ -e "$file" ] || continue
  slug="$(basename "$file" .html)"
  id="$($WP post list --post_type=page --name="$slug" --post_status=any --field=ID --posts_per_page=1)"

  if [ -z "$id" ]; then
    id="$($WP post create "$file" --post_type=page --post_status=publish --post_name="$slug" \
          --post_title="$(echo "$slug" | sed 's/-/ /g; s/^./\U&/')" --porcelain)"
    $WP post meta update "$id" _jappandal_sync "$($WP post get "$id" --field=post_content | fp)" >/dev/null
    say "$slug : page créée (#$id)"
    continue
  fi

  current="$($WP post get "$id" --field=post_content | fp)"
  synced="$($WP post meta get "$id" _jappandal_sync 2>/dev/null || true)"
  wanted="$(fp < "$file")"

  if [ "$current" = "$wanted" ]; then
    $WP post meta update "$id" _jappandal_sync "$current" >/dev/null
    say "$slug : déjà à jour"
    continue
  fi

  # Page jamais synchronisée mais encore dans son état d'installation
  # (un seul bloc pattern, ex. Projets) : pas touchée dans l'admin → on la prend en charge.
  if [ -z "$synced" ] && $WP post get "$id" --field=post_content | tr -d '[:space:]' \
       | grep -qE '^<!--wp:pattern\{"slug":"[a-z0-9/_-]+"\}/-->$'; then
    synced="$current"
  fi

  if [ "$FORCE" = 0 ] && [ "$current" != "$synced" ]; then
    say "$slug : modifiée dans l'admin WordPress → conservée (--force pour écraser)"
    continue
  fi

  $WP post update "$id" "$file" >/dev/null
  $WP post meta update "$id" _jappandal_sync "$($WP post get "$id" --field=post_content | fp)" >/dev/null
  say "$slug : mise à jour depuis le dépôt (#$id)"
done

# Profil auteur : rempli seulement s'il est vide (ou avec --force)
if [ "$FORCE" = 1 ] || [ -z "$($WP user meta get "$AUTHOR" description 2>/dev/null || true)" ]; then
  $WP user update "$AUTHOR" --first_name=Thierno --last_name=LO --display_name="Thierno LO" \
    --user_url="https://www.linkedin.com/in/tlolinkedin" --description="$BIO" >/dev/null
  say "profil auteur ($AUTHOR) rempli"
fi

$WP cache flush >/dev/null 2>&1 || true
