#!/bin/bash
set -euo pipefail

install_timezone(){

  local server_timezone
  server_timezone=$(timedatectl show --property=Timezone --value)

  log "LOG" "VÉRIFICATION & CONFIGURATION DU FUSEAU HORAIRE DE $HOSTNAME."
  if [[ "$server_timezone" == "$SYSTEM_TIMEZONE" ]];then
    log "OK" "LE FUSEAU HORAIRE DE $HOSTNAME EST DÉJÀ CONFIGURÉ SUR $SYSTEM_TIMEZONE."
  else
    log "WARNING" "LE FUSEAU HORAIRE N'EST PAS CONFIGURÉ SUR $HOSTNAME."
    if timedatectl set-timezone "$SYSTEM_TIMEZONE"; then
      log "SUCCESS" "LE FUSEAU HORAIRE A ÉTÉ CONFIGURÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CONFIGURATION DU FUSEAU HORAIRE DE $HOSTNAME."
      log "DEBUG" "VEUILLEZ ESSAYER DE CONFIGURER LE FUSEAU HORAIRE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo timedatectl set-timezone $SYSTEM_TIMEZONE"
      exit 1
    fi
  fi

}