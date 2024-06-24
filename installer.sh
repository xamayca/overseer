#!/bin/bash
set -euo pipefail

# Définir le chemin du répertoire des scripts et des fichiers de configuration
CURRENT_DIR=$(dirname "$(realpath "$0")")

INSTALLER_SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$CURRENT_DIR/config"

# Charge tous les scripts dans le répertoire des scripts et ses sous-répertoires.
while IFS= read -r -d '' file; do
  # shellcheck source=$file
  source "$file"
done < <(find "$INSTALLER_SCRIPTS_DIR" -type f -name "*.sh" -print0)


header "installer"
if dependencies_installation && account_installation && server_installation && install_service "ark_server"; then
  log "OVERSEER" "L'INSTALLATION EST TERMINÉE, VOUS POUVEZ MAINTENANT UTILISER L'OVERSEER."
  log "WARNING" "POUR UTILISER L'OVERSEER, CONNECTEZ-VOUS AU COMPTE $USER_ACCOUNT AVEC SA CLÉ PRIVÉE SSH."
  log "ATTENTION" "POUR TOUT PROBLÈME, VEUILLEZ CONSULTER LE DEPÔT GITHUB: $COMMUNITY_GITHUB_URL."
  exit 0
else
  log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DE L'OVERSEER."
  exit 1
fi


