#!/bin/bash
set -euo pipefail

install_curl(){

  log "LOG" "VÉRIFICATION & INSTALLATION DU PAQUET CURL SUR $HOSTNAME."
  if command -v curl &>/dev/null; then
    log "OK" "LE PAQUET CURL EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "WARNING" "LE PAQUET CURL N'EST PAS INSTALLÉ SUR $HOSTNAME."
    if apt-get install curl -y; then
      log "SUCCESS" "LE PAQUET CURL A ÉTÉ INSTALLÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET CURL SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER À NOUVEAU OU INSTALLER LE PAQUET MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install curl -y"
      exit 1
    fi
  fi

}

