#!/bin/bash
set -euo pipefail

install_non_free_repo(){
  local non_free_repo="http://deb.debian.org/debian/ bookworm main non-free non-free-firmware"

  log "LOG" "VÉRIFICATION & INSTALLATION DES DÉPÔTS NON FREE SUR $HOSTNAME."
  if grep -q "$non_free_repo" /etc/apt/sources.list; then
    log "OK" "LES DÉPÔTS NON FREE SONT DÉJÀ AJOUTÉS SUR $HOSTNAME."
  else
    log "WARNING" "LES DÉPÔTS NON FREE NE SONT PAS AJOUTÉS SUR $HOSTNAME."
    if sudo add-apt-repository "deb $non_free_repo" -y; then
      log "SUCCESS" "LES DÉPÔTS NON FREE ONT ÉTÉ AJOUTÉS SUR $HOSTNAME."
      system_update
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DES DÉPÔTS NON FREE SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER D'AJOUTER LES DÉPÔTS NON FREE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo add-apt-repository 'deb $non_free_repo'"
      exit 1
    fi
  fi

}