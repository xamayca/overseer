#!/bin/bash
set -euo pipefail

check_var_tools(){
  var_name=$1
  check_type=$2
  example=$3

  VAR_VALUE=$(eval echo \$"$var_name")
  log "LOG" "VÉRIFICATION & VALIDATION DE LA VARIABLE DE CONFIGURATION $var_name..."

  # Z: Verifie si la variable est vide
  if [ "$check_type" = "z" ] && [ -z "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name N'EST PAS DÉFINIE DANS LE FICHIER DE CONFIGURATION."
    log "DEBUG" "EXEMPLE D'UTILISATION DE LA VARIABLE $var_name: $example"
    exit 1
  # F: Verifie si le fichier existe
  elif [ "$check_type" = "f" ] && [ ! -f "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name N'EST PAS DÉFINIE DANS LE FICHIER DE CONFIGURATION."
    log "DEBUG" "EXEMPLE D'UTILISATION DE LA VARIABLE $var_name: $example"
    exit 1
  # D: Verifie si le dossier existe
  elif [ "$check_type" = "d" ] && [ ! -d "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name N'EST PAS DÉFINIE DANS LE FICHIER DE CONFIGURATION."
    log "DEBUG" "EXEMPLE D'UTILISATION DE LA VARIABLE $var_name: $example"
    exit 1
  # N: Verifie si la variable est vide
  elif [ "$check_type" = "n" ] && [ -n "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name N'EST PAS DÉFINIE DANS LE FICHIER DE CONFIGURATION."
    log "DEBUG" "EXEMPLE D'UTILISATION DE LA VARIABLE $var_name: $example"
    exit 1
  else
    log "SUCCESS" "LA VARIABLE DE CONFIGURATION $var_name EST DÉFINIE CORRECTEMENT."
  fi
}