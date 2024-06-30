#!/bin/bash
set -euo pipefail

edit_gus_ini() {
  local params="$1"
  local value="$2"

  log "LOG" "VÉRIFICATION DE LA PRÉSENCE DE $params DANS LE FICHIER $GUS_INI_FILE..."
  if grep -q "$params" "$GUS_INI_FILE"; then
    log "OK" "$params EST DÉJÀ DÉFINI DANS LE FICHIER $GUS_INI_FILE."
  else
    log "WARNING" "$params N'EST PAS DÉFINI DANS LE FICHIER $GUS_INI_FILE."
    log "LOG" "AJOUT DE $params DANS LE FICHIER $GUS_INI_FILE."
    # Ajout de $params dans le fichier GUS sous [ServerSettings]
    if sudo sed -i "/\[ServerSettings\]/a $params=$value" "$GUS_INI_FILE"; then
      log "SUCCESS" "$params A ÉTÉ AJOUTÉ AVEC SUCCÈS DANS LE FICHIER $GUS_INI_FILE."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'AJOUT DE $params DANS LE FICHIER $GUS_INI_FILE."
      log "DEBUG" "VEUILLEZ VÉRIFIER LE FICHIER DE CONFIGURATION $GUS_INI_FILE."
      exit 1
    fi
  fi
}

gus(){

  case "$1" in
    "edit")
      edit_gus_ini "$2" "$3"
      ;;
    *)
      log "ERROR" "L'ARGUMENT $1 N'EST PAS VALIDE POUR LA FONCTION gus."
      log "DEBUG" "VEUILLEZ FOURNIR UNE DES VALEURS SUIVANTES: {update}"
      exit 1
      ;;
  esac
}
