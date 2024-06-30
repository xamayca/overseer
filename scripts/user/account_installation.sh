#!/bin/bash
set -euo pipefail

account_installation(){

  user=(
    "user_account_create"
    "user_account_grant_sudo"
    "user_account_cmd_no_pwd"
    "user_account_ssh_keys"
  )

  for install in "${user[@]}"; do
    log "OVERSEER" "CHARGEMENT DU SCRIPT D'INSTALLATION DE L'UTILISATEUR: $install"
    $install
  done

  log "OVERSEER" "L'INSTALLATION DE L'UTILISATEUR S'EST DÉROULÉE AVEC SUCCÈS SUR $HOSTNAME."
}