#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Active le déploiement automatique (cron) de la branche deploy-prod.
#  Usage :  bash ~/repositories/jappandal-blog/scripts/install-auto-deploy.sh
#  Désactiver : bash … /install-auto-deploy.sh --remove
# ------------------------------------------------------------------
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEDULE="${SCHEDULE:-*/5 * * * *}"     # toutes les 5 minutes
MARK="# jappandal-auto-deploy"
LINE="$SCHEDULE /bin/bash $REPO_DIR/scripts/auto-deploy.sh >> \$HOME/logs/jappandal-deploy.log 2>&1 $MARK"

say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }

CURRENT="$(crontab -l 2>/dev/null || true)"
CLEAN="$(grep -v "$MARK" <<<"$CURRENT" || true)"

if [ "${1:-}" = "--remove" ]; then
  printf '%s\n' "$CLEAN" | crontab -
  say "Déploiement automatique désactivé"
  exit 0
fi

mkdir -p "$HOME/logs"
chmod +x "$REPO_DIR/scripts/auto-deploy.sh"

say "Premier passage (aligne le dépôt sur deploy-prod)"
bash "$REPO_DIR/scripts/auto-deploy.sh" | tee -a "$HOME/logs/jappandal-deploy.log" || true

{ [ -n "$CLEAN" ] && printf '%s\n' "$CLEAN"; printf '%s\n' "$LINE"; } | crontab -
say "Tâche planifiée installée"
crontab -l | grep "$MARK"
echo
echo "   Journal : tail -f ~/logs/jappandal-deploy.log"
echo "   Désactiver : bash $REPO_DIR/scripts/install-auto-deploy.sh --remove"
