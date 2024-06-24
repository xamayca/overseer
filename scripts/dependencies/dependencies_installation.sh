#!/bin/bash
set -euo pipefail

dependencies_installation(){

  dependencies=(
    "install_timezone"
    "install_32_bit_arch"
    "install_sudo"
    "install_jq"
    "install_curl"
    "install_spc"
    "install_lib_free_type_6"
    "install_wine_hq"
    "install_non_free_repo"
    "install_locale_en_utf8"
    "install_nfs_common"
  )

  for install in "${dependencies[@]}"; do
    log "OVERSEER" "CHARGEMENT DU SCRIPT D'INSTALLATION DE DÉPENDANCES: $install"
    $install
  done

  log "OVERSEER" "L'INSTALLATION DES DÉPENDANCES S'EST DÉROULÉE AVEC SUCCÈS SUR $HOSTNAME."
}