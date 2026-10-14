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

# Sous cron, le PATH se réduit à /usr/bin:/bin : wp et php (cPanel) n'y sont pas.
export PATH="$HOME/bin:/usr/local/bin:/opt/cpanel/composer/bin:$PATH"
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

# ------------------------------------------------------------------
#  Articles : content/articles/<slug>.html → article publié de slug <slug>
#  En tête du fichier :  <!-- titre: … -->  et  <!-- rubrique: slug ou nom -->
#  (rubrique créée si elle n'existe pas). Même règle : l'admin a le dernier mot.
#  Facultatif : <!-- image: fichier.jpg --> (dans content/articles/images/)
#  devient l'image à la une, seulement si l'article n'en a pas déjà une.
# ------------------------------------------------------------------
AUTHOR_ID="$($WP user get "$AUTHOR" --field=ID 2>/dev/null || echo 1)"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT

featured() {   # featured <id> <slug> <image>
  [ -n "$3" ] || return 0
  [ -z "$($WP post meta get "$1" _thumbnail_id 2>/dev/null || true)" ] || return 0
  local img="$REPO_DIR/content/articles/images/$3"
  [ -f "$img" ] || { say "article $2 : image $3 introuvable → ignorée"; return 0; }
  $WP media import "$img" --post_id="$1" --featured_image --title="$title" --alt="$title" >/dev/null
  say "article $2 : image à la une ajoutée"
}

for file in "$REPO_DIR"/content/articles/*.html; do
  [ -e "$file" ] || continue
  slug="$(basename "$file" .html)"
  title="$(sed -n 's/^<!-- *titre: *\(.*[^ ]\) *-->$/\1/p' "$file" | head -n 1)"
  rubrique="$(sed -n 's/^<!-- *rubrique: *\(.*[^ ]\) *-->$/\1/p' "$file" | head -n 1)"
  image="$(sed -n 's/^<!-- *image: *\(.*[^ ]\) *-->$/\1/p' "$file" | head -n 1)"
  [ -n "$title" ] || { say "article $slug : <!-- titre: … --> manquant → ignoré"; continue; }
  grep -vE '^<!-- *(titre|rubrique|image):' "$file" > "$TMP" || true

  cat_args=()
  if [ -n "$rubrique" ]; then
    # slug d'abord (ex. reflexions), puis nom (ex. Réflexions)
    cat_id="$($WP term list category --slug="$rubrique" --field=term_id --hide_empty=0 | head -n 1)"
    [ -n "$cat_id" ] || cat_id="$($WP term list category --name="$rubrique" --field=term_id --hide_empty=0 | head -n 1)"
    if [ -z "$cat_id" ]; then
      cat_id="$($WP term create category "$rubrique" --porcelain)"
      say "rubrique « $rubrique » créée (#$cat_id)"
    fi
    cat_args=(--post_category="$cat_id")
  fi

  id="$($WP post list --post_type=post --name="$slug" --post_status=any --field=ID --posts_per_page=1)"
  if [ -z "$id" ]; then
    id="$($WP post create "$TMP" --post_type=post --post_status=publish --post_name="$slug" \
          --post_title="$title" --post_author="$AUTHOR_ID" ${cat_args[@]+"${cat_args[@]}"} --porcelain)"
    $WP post meta update "$id" _jappandal_sync "$($WP post get "$id" --field=post_content | fp)" >/dev/null
    say "article $slug : publié (#$id)"
    featured "$id" "$slug" "$image"
    continue
  fi

  current="$($WP post get "$id" --field=post_content | fp)"
  synced="$($WP post meta get "$id" _jappandal_sync 2>/dev/null || true)"
  if [ "$current" = "$(fp < "$TMP")" ]; then
    $WP post meta update "$id" _jappandal_sync "$current" >/dev/null
    $WP post update "$id" --post_title="$title" ${cat_args[@]+"${cat_args[@]}"} >/dev/null   # titre / rubrique
    say "article $slug : déjà à jour"
    featured "$id" "$slug" "$image"
    continue
  fi
  if [ "$FORCE" = 0 ] && [ "$current" != "$synced" ]; then
    say "article $slug : modifié dans l'admin WordPress → conservé (--force pour écraser)"
    featured "$id" "$slug" "$image"
    continue
  fi
  $WP post update "$id" "$TMP" --post_title="$title" ${cat_args[@]+"${cat_args[@]}"} >/dev/null
  $WP post meta update "$id" _jappandal_sync "$($WP post get "$id" --field=post_content | fp)" >/dev/null
  say "article $slug : mis à jour depuis le dépôt (#$id)"
  featured "$id" "$slug" "$image"
done

# Profil auteur : rempli seulement s'il est vide (ou avec --force)
if [ "$FORCE" = 1 ] || [ -z "$($WP user meta get "$AUTHOR" description 2>/dev/null || true)" ]; then
  $WP user update "$AUTHOR" --first_name=Thierno --last_name=LO --display_name="Thierno LO" \
    --user_url="https://www.linkedin.com/in/tlolinkedin" --description="$BIO" >/dev/null
  say "profil auteur ($AUTHOR) rempli"
fi

$WP cache flush >/dev/null 2>&1 || true
