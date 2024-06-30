#!/bin/bash
set -euo pipefail

check_privileges() {
  log "INFO" "VÉRIFICATION DES PRIVILÈGES DE L'UTILISATEUR $USER."
  if [ "$(id -u)" != "0" ] && [ "$USER" != "$USER_ACCOUNT" ]; then
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA VÉRIFICATION DES PRIVILÈGES DE $USER."
    exit 1
  else
    log "SUCCESS" "LA VÉRIFICATION DES PRIVILÈGES DE L'UTILISATEUR $USER SUR $HOSTNAME A RÉUSSI."
  fi
}

check_update() {
  log "INFO" "VÉRIFICATION DES MISES À JOUR DISPONIBLES POUR $HOSTNAME."
  if $1 apt-get update && $1 apt-get upgrade --simulate && $1 apt-get dist-upgrade --simulate | grep -q "The following packages will be upgraded"; then
    log "WARNING" "DES MISES À JOUR SONT DISPONIBLES POUR $HOSTNAME."
  else
    log "OK" "AUCUNE MISE À JOUR N'EST DISPONIBLE POUR $HOSTNAME."
    return 0
  fi

  # Si des mises à jour sont disponibles, procéder à leur installation
  if $1 apt-get update && $1 apt-get upgrade -y && $1 apt-get dist-upgrade -y; then
    log "SUCCESS" "LES MISES À JOUR ONT ÉTÉ INSTALLÉES AVEC SUCCÈS SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DES MISES À JOUR SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER À NOUVEAU OU INSTALLER LES MISES À JOUR MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y"
    exit 1
  fi
}

system_update() {
  check_privileges
  if [ "$(id -u)" = "0" ]; then
    check_update ""
  elif [ "$USER" = "$USER_ACCOUNT" ]; then
    check_update "sudo"
  elif [ -n "$USER" ]; then
    check_update "sudo -u $USER_ACCOUNT"
  fi
}