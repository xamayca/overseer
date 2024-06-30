#!/bin/bash
set -euo pipefail

user_manager_bashrc() {
  log "LOG" "VÉRIFICATION & AJOUT DE L'IMPORTATION DU SCRIPT DE MANAGEMENT DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT..."
  if grep -q "alias overseer=\"$OVERSEER_SCRIPT_FILE\"" "$USER_DIR/.bashrc"; then
    log "OK" "L'IMPORTATION DU SCRIPT DE MANAGEMENT EST DÉJÀ PRÉSENTE DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT."
  else
    log "WARNING" "L'IMPORTATION DU SCRIPT DE MANAGEMENT EST MANQUANTE DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT."
    log "LOG" "AJOUT DE L'IMPORTATION DU SCRIPT DE MANAGEMENT DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT."
    # shellcheck source=/home/${USER_ACCOUNT}/.bashrc
    if echo "alias overseer=\"$OVERSEER_SCRIPT_FILE\"" >> "$USER_DIR/.bashrc" && source "$USER_DIR/.bashrc"; then
      log "SUCCESS" "L'IMPORTATION DU SCRIPT DE MANAGEMENT A ÉTÉ AJOUTÉE AVEC SUCCÈS DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'AJOUT DE L'IMPORTATION DU SCRIPT DE MANAGEMENT DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT."
      log "DEBUG" "VEUILLEZ AJOUTER L'IMPORTATION DU SCRIPT DE MANAGEMENT DANS LE FICHIER .BASHRC DE L'UTILISATEUR $USER_ACCOUNT À L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "echo 'alias overseer=\"$OVERSEER_SCRIPT_FILE\"' >> $USER_DIR/.bashrc"
      exit 1
    fi
  fi
}

install_manager() {
  log "LOG" "VÉRIFICATION & COPIE DE L'OUTIL DE MANAGEMENT DANS LE RÉPERTOIRE DE L'UTILISATEUR $USER_ACCOUNT."
  if sudo -u "$USER_ACCOUNT" command -v overseer.sh &> /dev/null; then
    log "OK" "LE SCRIPT DE MANAGEMENT EST DÉJÀ PRÉSENT DANS LE RÉPERTOIRE DE L'UTILISATEUR $USER_ACCOUNT."
  else
    log "WARNING" "LE SCRIPT DE MANAGEMENT EST MANQUANT DANS LE RÉPERTOIRE DE L'UTILISATEUR $USER_ACCOUNT."
    folder create "overseer" "$OVERSEER_INSTALL_DIR" "755"
    folder copy "Config" "$CONFIG_DIR" "$OVERSEER_INSTALL_DIR"
    folder copy "Scripts" "$SCRIPTS_DIR" "$OVERSEER_INSTALL_DIR"
    folder copy "Manager" "$MANAGER_DIR" "$OVERSEER_INSTALL_DIR"
    file copy "overseer.sh" "$BASE_DIR/overseer.sh" "$OVERSEER_INSTALL_DIR"
    permissions executable "overseer.sh" "$OVERSEER_SCRIPT_FILE"
    permissions owner "overseer" "$OVERSEER_INSTALL_DIR" "$USER_ACCOUNT"

    user_manager_bashrc

  fi
}
