#!/bin/bash
set -euo pipefail

validate_folder(){
  log "LOG" "VÉRIFICATION & VALIDATION DU RÉPERTOIRE $path."
  if [ ! -d "$path" ]; then
    log "ERROR" "LE RÉPERTOIRE $path N'EXISTE PAS SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ CRÉER LE RÉPERTOIRE $path AVANT DE CONTINUER."
    exit 1
  else
    log "SUCCESS" "LE RÉPERTOIRE $path EXISTE SUR $HOSTNAME."
  fi
}

validate_file(){
  log "LOG" "VÉRIFICATION & VALIDATION DU FICHIER $path."
  if [ ! -f "$path" ]; then
    log "ERROR" "LE FICHIER $path N'EXISTE PAS SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ CRÉER LE FICHIER $path AVANT DE CONTINUER."
    exit 1
  else
    log "SUCCESS" "LE FICHIER $path EXISTE SUR $HOSTNAME."
  fi
}

validate_variable(){
  log "LOG" "VÉRIFICATION & VALIDATION DE LA VARIABLE $var_name."
  VAR_VALUE=$(eval echo \$"$var_name")
  if [ -z "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name N'EST PAS DÉFINIE."
    log "DEBUG" "VEUILLEZ DÉFINIR LA VARIABLE $var_name AVANT DE CONTINUER."
    exit 1
  else
    log "SUCCESS" "LA VARIABLE $var_name EST DÉFINIE."
  fi
}

validate_empty_variable(){
  log "LOG" "VÉRIFICATION & VALIDATION DE LA VARIABLE $var_name."
  VAR_VALUE=$(eval echo \$"$var_name")
  if [ -n "$VAR_VALUE" ]; then
    log "ERROR" "LA VARIABLE $var_name EST DÉFINIE."
    log "DEBUG" "VEUILLEZ SUPPRIMER LA VALEUR DE LA VARIABLE $var_name AVANT DE CONTINUER."
    exit 1
  else
    log "SUCCESS" "LA VARIABLE $var_name N'EST PAS DÉFINIE."
  fi
}


# OUTIL DE VALIDATION DE FICHIER, RÉPERTOIRE, VARIABLE ET VARIABLE VIDE
validate(){
  local action=$1

  case $action in
    folder|file)
      local path=$2
      validate_"$action" "$path"
      ;;
    variable|empty_variable)
      local var_name=$2
      validate_"$action" "$var_name"
      ;;
    *)
      log "ERROR" "L'ACTION $action N'EST PAS RECONNUE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {folder|file|variable|empty_variable}."
      log "DEBUG" "EXEMPLE: validate folder <chemin_du_répertoire>"
      log "DEBUG" "EXEMPLE: validate file <chemin_du_fichier>"
      log "DEBUG" "EXEMPLE: validate variable <nom_de_la_variable>"
      log "DEBUG" "EXEMPLE: validate empty_variable <nom_de_la_variable>"
      exit 1
      ;;
  esac
}