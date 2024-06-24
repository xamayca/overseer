#!/bin/bash
set -euo pipefail

install_lib_free_type_6(){
  log "LOG" "VÉRIFICATION & INSTALLATION DU PAQUET LIBFREETYPE6 SUR $HOSTNAME."
  if dpkg -l | grep -q "libfreetype6"; then
    log "OK" "LE PAQUET LIBFREETYPE6 EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "LOG" "INSTALLATION DU PAQUET LIBFREETYPE6 SUR $HOSTNAME."
    if sudo apt-get install -y libfreetype6; then
      log "SUCCESS" "LE PAQUET LIBFREETYPE6 A ÉTÉ INSTALLÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET LIBFREETYPE6 SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER D'INSTALLER LE PAQUET MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install -y libfreetype6"
      exit 1
    fi
  fi
}
