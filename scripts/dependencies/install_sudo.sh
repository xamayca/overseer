#!/bin/bash
set -euo pipefail

install_sudo(){

  log "LOG" "VÉRIFICATION DE L'INSTALLATION DU PAQUET SUDO SUR $HOSTNAME."
  if dpkg -l sudo &> /dev/null; then
    log "OK" "LE PAQUET SUDO EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "WARNING" "LE PAQUET SUDO N'EST PAS INSTALLÉ SUR $HOSTNAME."
    if apt-get install sudo -y; then
      log "SUCCESS" "LE PAQUET SUDO A ÉTÉ INSTALLÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET SUDO SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER À NOUVEAU OU INSTALLER LE PAQUET MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install sudo -y"
      exit 1
    fi
  fi

}