#!/usr/bin/env bash
# ------------------------------------------------------------------
#  Clé SSH dédiée (deploy key) + clonage du dépôt jappandal-blog dans cPanel
#  N'affecte pas les clés / dépôts existants (alias SSH séparé).
#  Usage (Terminal cPanel) :
#    bash setup-github-ssh.sh
# ------------------------------------------------------------------
set -euo pipefail

GH_REPO="Ceerno/jappandal-blog"
ALIAS="github-jappandal"
KEY="$HOME/.ssh/jappandal_blog"
REPO_DIR="$HOME/repositories/jappandal-blog"
REMOTE="$ALIAS:$GH_REPO.git"

say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

# 1. Clé dédiée ------------------------------------------------------
if [ -f "$KEY" ]; then
  say "Clé existante réutilisée : $KEY"
else
  say "Génération de la clé $KEY"
  ssh-keygen -t ed25519 -N "" -C "cpanel-jappandal-blog" -f "$KEY" >/dev/null
fi
chmod 600 "$KEY"

# 2. Alias SSH -------------------------------------------------------
touch "$HOME/.ssh/config" && chmod 600 "$HOME/.ssh/config"
if grep -qE "^Host[[:space:]]+$ALIAS\$" "$HOME/.ssh/config"; then
  say "Alias $ALIAS déjà présent dans ~/.ssh/config"
else
  say "Ajout de l'alias $ALIAS dans ~/.ssh/config"
  cat >> "$HOME/.ssh/config" <<EOF

Host $ALIAS
  HostName github.com
  User git
  IdentityFile $KEY
  IdentitiesOnly yes
EOF
fi

# 3. Empreinte GitHub ------------------------------------------------
touch "$HOME/.ssh/known_hosts" && chmod 600 "$HOME/.ssh/known_hosts"
if ! ssh-keygen -F github.com >/dev/null 2>&1; then
  ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

# 4. Ajout sur GitHub ------------------------------------------------
say "Ajoutez cette clé dans GitHub › $GH_REPO › Settings › Deploy keys › Add deploy key"
echo "   (titre : cPanel, laisser « Allow write access » décoché)"
echo
cat "$KEY.pub"
echo
read -rp "Appuyez sur Entrée une fois la clé ajoutée sur GitHub… " _

# 5. Test ------------------------------------------------------------
say "Test de connexion"
if ssh -T "$ALIAS" 2>&1 | grep -q "successfully authenticated"; then
  echo "   Connexion GitHub OK"
else
  ssh -T "$ALIAS" || true
  die "Authentification refusée : vérifiez que la clé est bien ajoutée au dépôt $GH_REPO."
fi
git ls-remote "$REMOTE" >/dev/null || die "Le dépôt $GH_REPO n'est pas accessible avec cette clé."

# 6. Clonage via cPanel ---------------------------------------------
if [ -d "$REPO_DIR/.git" ]; then
  say "Dépôt déjà présent dans $REPO_DIR : mise à jour"
  git -C "$REPO_DIR" remote set-url origin "$REMOTE"
  git -C "$REPO_DIR" pull --ff-only
else
  say "Création du dépôt dans cPanel Git Version Control"
  mkdir -p "$(dirname "$REPO_DIR")"
  if command -v uapi >/dev/null && \
     uapi VersionControl create type=git name=jappandal-blog \
       repository_root="$REPO_DIR" \
       source_repository="{\"remote_name\":\"origin\",\"url\":\"$REMOTE\"}" | grep -q "status: 1"; then
    # Le clonage cPanel est asynchrone : attendre qu'il se termine
    for _ in $(seq 1 30); do [ -f "$REPO_DIR/.cpanel.yml" ] && break; sleep 2; done
  fi
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo "   (création cPanel indisponible, clonage direct)"
    git clone "$REMOTE" "$REPO_DIR"
  fi
fi

say "Terminé"
echo "   Dépôt : $REPO_DIR"
echo "   Installation de WordPress :"
echo "     bash $REPO_DIR/scripts/deploy-jappandal.sh"
echo
