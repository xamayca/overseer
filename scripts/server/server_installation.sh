#!/bin/bash
set -euo pipefail

server_installation(){

  server=(
    "install_steam_cmd"
    "install_server"
    "install_rcon_cli"
    "install_proton_ge"
    "install_command_line"
    "install_manager"
  )

  for install in "${server[@]}"; do
    log "OVERSEER" "CHARGEMENT DU SCRIPT D'INSTALLATION DU SERVEUR: $install"
    $install
  done

  log "OVERSEER" "L'INSTALLATION DU SERVEUR S'EST DÉROULÉE AVEC SUCCÈS SUR $HOSTNAME."
}