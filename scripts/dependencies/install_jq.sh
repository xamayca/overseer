#!/bin/bash
set -euo pipefail

install_jq(){

  log "LOG" "VÉRIFICATION & INSTALLATION DU PAQUET JQ SUR $HOSTNAME."
  if dpkg -l jq 2>/dev/null | grep -q "^ii"; then
    log "OK" "LE PAQUET JQ EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "WARNING" "LE PAQUET JQ N'EST PAS INSTALLÉ SUR $HOSTNAME."
    if sudo apt-get install jq -y; then
      log "SUCCESS" "LE PAQUET JQ A ÉTÉ INSTALLÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET JQ SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER D'INSTALLER LE PAQUET MANUELLEMENT À L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install jq -y"
      exit 1
    fi
  fi

}