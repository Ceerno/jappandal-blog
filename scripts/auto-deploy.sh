#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Déploiement automatique de jappandal.org depuis la branche deploy-prod
#  Lancé par cron (voir scripts/install-auto-deploy.sh). Ne fait rien
#  s'il n'y a pas de nouveau commit sur origin/deploy-prod.
#
#  - thème    : theme/ → wp-content/themes/jappandal (rsync --delete)
#  - contenu  : content/ → pages WordPress, uniquement si content/ a changé
#  Journal    : ~/logs/jappandal-deploy.log
# ------------------------------------------------------------------
set -euo pipefail

BRANCH="${BRANCH:-deploy-prod}"
DOCROOT="${DOCROOT:-$HOME/jappandal.org}"
REPO_DIR="${REPO_DIR:-$HOME/repositories/jappandal-blog}"
LOCK="$HOME/.jappandal-deploy.lock"
STATE="$HOME/.jappandal-deployed"        # dernier commit déployé avec succès

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

# Tout le travail est dans main() : bash lit la fonction entière avant de
# l'exécuter, donc le script peut se mettre à jour lui-même sans casser.
main() {
  exec 9>"$LOCK"
  if ! flock -n 9; then log "déploiement déjà en cours, on passe"; return 0; fi

  cd "$REPO_DIR"
  git fetch --quiet origin "$BRANCH"

  local deployed target changed
  target="$(git rev-parse "origin/$BRANCH")"
  deployed="$(cat "$STATE" 2>/dev/null || true)"
  [ "$deployed" = "$target" ] && return 0   # rien de nouveau

  if [ -n "$deployed" ] && git cat-file -e "$deployed^{commit}" 2>/dev/null; then
    log "nouveau commit sur $BRANCH : ${deployed:0:7} → ${target:0:7}"
    changed="$(git diff --name-only "$deployed" "$target" || true)"
  else
    log "premier déploiement de $BRANCH (${target:0:7}) : thème complet"
    changed="theme/"
  fi

  # Copie de déploiement : on s'aligne exactement sur la branche distante
  git checkout --quiet -B "$BRANCH" "origin/$BRANCH"
  git reset --quiet --hard "origin/$BRANCH"

  [ -f "$DOCROOT/wp-config.php" ] || { log "ERREUR : WordPress absent de $DOCROOT"; return 1; }

  if grep -q '^theme/' <<<"$changed"; then
    local dest="$DOCROOT/wp-content/themes/jappandal"
    mkdir -p "$dest"
    if command -v rsync >/dev/null; then
      rsync -a --delete --exclude=THEME.md theme/ "$dest/"
    else
      local tmp="$dest.new.$$"
      rm -rf "$tmp" && cp -R theme "$tmp" && rm -f "$tmp/THEME.md"
      rm -rf "$dest.old" && mv "$dest" "$dest.old" && mv "$tmp" "$dest" && rm -rf "$dest.old"
    fi
    log "thème déployé"
  fi

  if grep -qE '^(content/|scripts/update-content\.sh)' <<<"$changed"; then
    bash scripts/update-content.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g; s/^/    /'
    log "contenu synchronisé (pages modifiées dans l'admin conservées)"
  fi

  echo "$target" > "$STATE"
  log "OK — $(git log -1 --format='%h %s')"
}

main "$@"
exit $?
