#!/bin/bash
set -euo pipefail

is_rcon_cli_installed(){
  log "LOG" "VÉRIFICATION DE L'INSTALLATION DE RCON CLI SUR LE SERVEUR $ARK_SERVER_SERVICE."
  if [[ -d "$RCON_DIR" ]] && [[ -x "$RCON_EXE_FILE" ]]; then
    log "OK" "RCON CLI EST DÉJÀ INSTALLÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
    return 1
  else
    log "WARNING" "RCON CLI N'EST PAS INSTALLÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
    return 0
  fi
}

create_rcon_cli_temp_dir(){
  log "LOG" "CRÉATION DU RÉPERTOIRE TEMPORAIRE POUR L'INSTALLATION DE RCON CLI."
  if rcon_temp_path=$(sudo -u "$USER_ACCOUNT" mktemp -d -t rcon_cli_install_XXXXX); then
    log "SUCCESS" "LE RÉPERTOIRE TEMPORAIRE POUR L'INSTALLATION DE RCON CLI A ÉTÉ CRÉÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DU RÉPERTOIRE TEMPORAIRE POUR L'INSTALLATION DE RCON CLI."
    log "DEBUG" "VEUILLEZ ESSAYER DE CRÉER LE RÉPERTOIRE TEMPORAIRE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo -u $USER_ACCOUNT mktemp -d -t rcon_cli_install_XXXXX"
    exit 1
  fi
}

move_to_rcon_cli_temp_dir(){
  log "LOG" "DÉPLACEMENT DANS LE RÉPERTOIRE TEMPORAIRE POUR L'INSTALLATION DE RCON CLI."
  if cd "$rcon_temp_path"; then
    log "SUCCESS" "DÉPLACEMENT DANS LE RÉPERTOIRE TEMPORAIRE RÉUSSI."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU DÉPLACEMENT DANS LE RÉPERTOIRE TEMPORAIRE POUR L'INSTALLATION DE RCON CLI."
    log "DEBUG" "VEUILLEZ ESSAYER DE VOUS DÉPLACER MANUELLEMENT DANS LE RÉPERTOIRE A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "cd $rcon_temp_path"
    exit 1
  fi
}

download_rcon_cli(){
  log "LOG" "TÉLÉCHARGEMENT DE L'ARCHIVE RCON CLI À PARTIR DE $RCON_URL."
  if curl -# -L "$RCON_URL" -o "$RCON_TGZ"; then
    log "SUCCESS" "ARCHIVE RCON CLI TÉLÉCHARGÉE À PARTIR DE $RCON_URL."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU TÉLÉCHARGEMENT DE L'ARCHIVE RCON CLI À PARTIR DE $RCON_URL."
    log "DEBUG" "VEUILLEZ ESSAYER DE TÉLÉCHARGER L'ARCHIVE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "curl -# -L $RCON_URL -o $RCON_TGZ"
    exit 1
  fi
}

verify_rcon_cli_integrity(){
  log "LOG" "VÉRIFICATION DE L'INTÉGRITÉ DE L'ARCHIVE RCON CLI."
  checksum=$(md5sum "$RCON_TGZ" | awk '{ print $1 }')
  if [ "$checksum" == "$RCON_CHECKSUM" ]; then
    log "SUCCESS" "L'INTÉGRITÉ DE L'ARCHIVE RCON CLI EST VÉRIFIÉE. Checksum: $checksum"
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA VÉRIFICATION DE L'INTÉGRITÉ DE L'ARCHIVE RCON CLI. Checksum attendu: $RCON_CHECKSUM / Checksum actuel: $checksum"
    log "DEBUG" "VEUILLEZ VÉRIFIER L'INTÉGRITÉ DE L'ARCHIVE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "md5sum $RCON_TGZ"
    exit 1
  fi
}

extract_rcon_cli(){
  log "LOG" "EXTRACTION DE L'ARCHIVE RCON CLI DANS LE RÉPERTOIRE D'INSTALLATION DE L'UTILISATEUR $USER_ACCOUNT."
  if tar -xzf "$RCON_TGZ" -C "$RCON_DIR" --strip-components=1; then
    log "SUCCESS" "L'ARCHIVE RCON CLI A ÉTÉ EXTRAITE DANS LE RÉPERTOIRE D'INSTALLATION DE L'UTILISATEUR $USER_ACCOUNT."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'EXTRACTION DE L'ARCHIVE RCON CLI DANS LE RÉPERTOIRE D'INSTALLATION."
    log "DEBUG" "VEUILLEZ ESSAYER D'EXTRAIRE L'ARCHIVE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "tar -xzf $RCON_TGZ -C $RCON_DIR --strip-components=1"
    exit 1
  fi
}

remove_rcon_cli_temp_dir(){
  log "LOG" "SUPPRESSION DU RÉPERTOIRE TEMPORAIRE D'INSTALLATION DE RCON CLI."
  if rm -rf "$rcon_temp_path"; then
    log "SUCCESS" "RÉPERTOIRE TEMPORAIRE D'INSTALLATION DE RCON CLI SUPPRIMÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SUPPRESSION DU RÉPERTOIRE TEMPORAIRE D'INSTALLATION DE RCON CLI."
    log "DEBUG" "VEUILLEZ ESSAYER DE SUPPRIMER LE RÉPERTOIRE TEMPORAIRE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "rm -rf $rcon_temp_path"
    exit 1
  fi
}

install_rcon_cli(){

  if is_rcon_cli_installed; then
    create_rcon_cli_temp_dir
    move_to_rcon_cli_temp_dir
    download_rcon_cli
    verify_rcon_cli_integrity
    folder create "rcon" "$RCON_DIR" "777"
    extract_rcon_cli
    remove_rcon_cli_temp_dir
    permissions executable "RCON Executable" "$RCON_EXE_FILE"
  fi

}