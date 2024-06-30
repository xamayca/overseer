#!/bin/bash
set -euo pipefail

install_curl(){

  log "LOG" "VÉRIFICATION & INSTALLATION DU PAQUET CURL SUR $HOSTNAME."
  if dpkg -l | grep -q "curl"; then
    log "OK" "LE PAQUET CURL EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "WARNING" "LE PAQUET CURL N'EST PAS INSTALLÉ SUR $HOSTNAME."
    log "LOG" "INSTALLATION DU PAQUET CURL SUR $HOSTNAME."
    if apt-get install -y curl; then
      log "SUCCESS" "LE PAQUET CURL A ÉTÉ INSTALLÉ AVEC SUCCÈS SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET CURL SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ INSTALL LE PAQUET CURL MANUELLEMENT À L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install -y curl"
      exit 1
    fi
  fi
}

