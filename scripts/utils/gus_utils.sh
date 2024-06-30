#!/bin/bash
set -euo pipefail

edit_gus_ini() {
  log "LOG" "VÉRIFICATION DE LA PRÉSENCE DE $params DANS LE FICHIER $GUS_INI_FILE."
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
      log "DEBUG" "VEUILLEZ ESSAYER D'AJOUTER $params DANS LE FICHIER $GUS_INI_FILE A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo sed -i \"/\[ServerSettings\]/a $params=$value\" $GUS_INI_FILE"
      exit 1
    fi
  fi
}

gus(){
  local action=$1
  local params=$2
  local value=$3

  case "$action" in
    edit)
      edit_gus_ini "$params" "$value"
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE DES ACTIONS SUIVANTES: {edit}"
      log "DEBUG" "EXEMPLE: gus edit <paramètre> <valeur>"
      exit 1
  esac
}