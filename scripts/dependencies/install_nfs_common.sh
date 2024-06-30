#!/bin/bash
set -euo pipefail

install_nfs_common(){

  log "LOG" "VÉRIFICATION & INSTALLATION DU PAQUET NFS-COMMON SUR $HOSTNAME."
  if dpkg -l nfs-common &> /dev/null; then
    log "OK" "LE PAQUET NFS-COMMON EST DÉJÀ INSTALLÉ SUR $HOSTNAME."
  else
    log "WARNING" "LE PAQUET NFS-COMMON N'EST PAS INSTALLÉ SUR $HOSTNAME."
    if sudo apt-get install nfs-common -y; then
      log "SUCCESS" "LE PAQUET NFS-COMMON A ÉTÉ INSTALLÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET NFS-COMMON SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER D'INSTALLER LE PAQUET MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo apt-get install nfs-common -y"
      exit 1
    fi
  fi

}