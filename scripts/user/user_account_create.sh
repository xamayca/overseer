#!/bin/bash
set -euo pipefail

user_account_create(){
  log "LOG" "VÉRIFICATION & CRÉATION DE L'UTILISATEUR $USER_ACCOUNT SUR $HOSTNAME."
  if id "$USER_ACCOUNT" &>/dev/null; then
    log "OK" "L'UTILISATEUR $USER_ACCOUNT EXISTE DÉJÀ SUR $HOSTNAME."
  else
    log "WARNING" "L'UTILISATEUR $USER_ACCOUNT N'EXISTE PAS SUR $HOSTNAME."
    if useradd -m -s /bin/bash "$USER_ACCOUNT"; then
      log "OK" "L'UTILISATEUR $USER_ACCOUNT A ÉTÉ CRÉÉ SUR $HOSTNAME."
    else
      log "ERROR" "ÉCHEC DE LA CRÉATION DE L'UTILISATEUR $USER_ACCOUNT SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER DE CRÉER L'UTILISATEUR $USER_ACCOUNT MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo useradd -m -s /bin/bash $USER_ACCOUNT"
      exit 1
    fi
  fi
}