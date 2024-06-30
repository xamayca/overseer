#!/bin/bash
set -euo pipefail

reset_and_update_dynamic(){
  local day="$1"
  local commands=("ForceUpdateDynamicConfig")

  if compare_dynamic "$day"; then
    file delete "dyn.ini (active)" "$DYNAMIC_CONFIG_DIR/current/dyn.ini"
    file copy "dyn.ini (reset)" "$DYNAMIC_CONFIG_DIR/reset/dyn.ini" "$DYNAMIC_CONFIG_DIR/current"
    rcon execute_commands commands[@]
    file copy "dyn.ini (new)" "$DYNAMIC_CONFIG_DIR/$day/dyn.ini" "$DYNAMIC_CONFIG_DIR/current"
  fi
}

compare_dynamic(){
  day="$1"

  log "LOG" "COMPARAISON DES FICHIERS DE CONFIGURATION DYNAMIQUE ACTUEL ET DU JOUR: $day SUR LE SERVEUR $ARK_SERVER_SERVICE."
  if sudo diff -q "$DYNAMIC_CONFIG_DIR/current/dyn.ini" "$DYNAMIC_CONFIG_DIR/$day/dyn.ini"; then
    log "OK" "LES FICHIERS DE CONFIGURATION DYNAMIQUE ACTUEL ET DU JOUR: $day SONT IDENTIQUES, AUCUNE MODIFICATION N'EST NÉCESSAIRE."
    return 1
  else
    log "WARNING" "LES FICHIERS DE CONFIGURATION DYNAMIQUE ACTUEL ET DU JOUR: $day SONT DIFFÉRENTS, DES MODIFICATIONS SONT NÉCESSAIRES."
    return 0
  fi
}

set_dynamic_config(){
  local day="$1"
  local destroy_wild_dinos="$2"

  log "WARNING" "CONFIGURATION DYNAMIQUE POUR LE JOUR: $day SUR LE SERVEUR $ARK_SERVER_SERVICE."

  if reset_and_update_dynamic "$day"; then

    local messages=()

    for i in {1..5}; do
      message_var="DYNAMIC_${day^^}_MSG_$i"
      message="${!message_var}"
      if [ -n "$message" ]; then
        messages+=("$message")
      fi
    done

    local delays=(5 5 5 5 5)

    rcon send_messages messages[@] delays[@]

    local commands=("ForceUpdateDynamicConfig")
    if [ "$destroy_wild_dinos" = "Yes" ]; then
      commands+=("DestroyWildDinos")
    fi
    rcon execute_commands commands[@]
  fi

  log "SUCCESS" "LA CONFIGURATION DYNAMIQUE POUR LE JOUR: $day SUR LE SERVEUR $ARK_SERVER_SERVICE A ÉTÉ APPLIQUÉE AVEC SUCCÈS."
}

dynamic_config(){
  local day="$1"
  local destroy_wild_dinos="DYNAMIC_${day^^}_DESTROY_WILD_DINOS"


  case "$day" in
    monday)
      set_dynamic_config "monday" "$destroy_wild_dinos"
      ;;
    tuesday)
      set_dynamic_config "tuesday" "$destroy_wild_dinos"
      ;;
    wednesday)
      set_dynamic_config "wednesday" "$destroy_wild_dinos"
      ;;
    thursday)
      set_dynamic_config "thursday" "$destroy_wild_dinos"
      ;;
    friday)
      set_dynamic_config "friday" "$destroy_wild_dinos"
      ;;
    saturday)
      set_dynamic_config "saturday" "$destroy_wild_dinos"
      ;;
    sunday)
      set_dynamic_config "sunday" "$destroy_wild_dinos"
      ;;
    *)
      log "ERROR" "L'OPTION FOURNIE: $day N'EST PAS VALIDE POUR LA GESTION DYNAMIQUE DU SERVEUR"
      log "INFO" "LES OPTIONS VALIDES SONT: {monday|tuesday|wednesday|thursday|friday|saturday|sunday}"
      log "INFO" "EXEMPLE: dynamic_config monday"
      exit 1
      ;;
  esac
}


