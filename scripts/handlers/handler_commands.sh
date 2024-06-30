#!/bin/bash
set -euo pipefail

update_server(){

  check_server_build_id(){
    log "LOG" "VÉRIFICATION DU BUILD ID DU SERVEUR $ARK_SERVER_SERVICE DU FICHIER MANIFEST."
    if server_build_id=$(grep -E "^\s+\"buildid\"\s+" "$ARK_SERVER_MANIFEST_FILE" | grep -o '[[:digit:]]*'); then
    log "OK" "LE BUILD ID DU SERVEUR $ARK_SERVER_SERVICE EST: $server_build_id"
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA RÉCUPÉRATION DU BUILD ID DU SERVEUR $ARK_SERVER_SERVICE."
      log "DEBUG" "VEUILLEZ ESSAYER DE RÉCUPÉRER LE BUILD ID DU SERVEUR $ARK_SERVER_SERVICE A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "grep -E \"^\\s+\\\"buildid\\\"\\s+\" \"$ARK_SERVER_MANIFEST_FILE\" | grep -o '[[:digit:]]*'"
      exit 1
    fi
  }

  check_latest_build_id(){
    log "LOG" "VÉRIFICATION DU BUILD ID DU SERVEUR $ARK_SERVER_SERVICE DU SITE STEAM."
    if latest_build_id=$(curl -sX GET "$ARK_LATEST_BUILD_ID" | jq -r ".data.\"$ARK_APP_ID\".depots.branches.public.buildid"); then
      log "OK" "LE DERNIER BUILD ID DU JEU $ARK_APP_ID EST: $latest_build_id"
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA RÉCUPÉRATION DU DERNIER BUILD ID DU JEU $ARK_APP_ID."
      log "DEBUG" "VEUILLEZ ESSAYER DE RÉCUPÉRER LE DERNIER BUILD ID DU JEU $ARK_APP_ID A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "curl -sX GET \"$ARK_LATEST_BUILD_ID\" | jq -r \".data.\"$ARK_APP_ID\".depots.branches.public.buildid\""
      exit 1
    fi
  }

  compare_build_ids(){
    log "OVERSEER" "VÉRIFICATION DE LA CONCORDANCE DES BUILD ID DU SERVEUR $ARK_SERVER_SERVICE ET STEAM."
    if [ "$server_build_id" -eq "$latest_build_id" ]; then
      log "OK" "LES BUILD ID DU SERVEUR: $ARK_SERVER_SERVICE ET STEAM SONT IDENTIQUES, AUCUNE MISE À JOUR N'EST NÉCESSAIRE."
      return 1
    else
      log "WARNING" "LE SERVEUR: $ARK_SERVER_SERVICE N'EST PAS À JOUR, MISE À JOUR EN COURS."
      return 0
    fi
  }

  log "OVERSEER" "MISE À JOUR DU SERVEUR $ARK_SERVER_SERVICE EN COURS."
  if check_server_build_id && check_latest_build_id && compare_build_ids; then
    rcon maintenance-msg-cmd-loop "RCON_UPDATE"
    service edit "$ARK_SERVER_SERVICE" restart "on-failure"
  fi
  log "SUCCESS" "MISE À JOUR DU SERVEUR $ARK_SERVER_SERVICE TERMINÉE."

}

restart_server(){
  log "OVERSEER" "REDEMARRAGE DU SERVEUR $ARK_SERVER_SERVICE EN COURS."
  service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
  service edit "$ARK_SERVER_SERVICE" restart "on-failure"
  service daemon-reload "$ARK_SERVER_SERVICE"
  rcon maintenance-msg-cmd-loop "RCON_RESTART"
  service restart "$ARK_SERVER_SERVICE"
  log "OVERSEER" "REDEMARRAGE DU SERVEUR $ARK_SERVER_SERVICE TERMINÉ."
}

stop_server(){
  log "OVERSEER" "ARRÊT DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
  service edit "$ARK_SERVER_SERVICE" restart "no"
  service daemon-reload "$ARK_SERVER_SERVICE"
  rcon maintenance-msg-cmd-loop "RCON_STOP"
  service stop "$ARK_SERVER_SERVICE"
  log "OVERSEER" "ARRÊT DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉ."
}

start_server(){
  log "OVERSEER" "DÉMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
  service edit "$ARK_SERVER_SERVICE" restart "on-failure"
  service daemon-reload "$ARK_SERVER_SERVICE"
  service start "$ARK_SERVER_SERVICE"
  log "OVERSEER" "DÉMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉ."
}

pvp_purge() {
  local action=$1
  local pvp_value=$2
  local message_prefix=$3

  log "OVERSEER" "PURGE PVP $action SUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
  log "LOG" "VÉRIFICATION DE LA VALEUR DE PreventOfflinePvP DANS LE FICHIER DE CONFIGURATION DE SERVICE $ARK_SERVER_SERVICE."

  if grep "PreventOfflinePvP=$pvp_value" "$ARK_SERVER_SERVICE_FILE"; then
    log "OK" "LA PURGE EST DÉJÀ RÉGLÉE SUR PreventOfflinePvP=$pvp_value, AUCUNE ACTION N'EST NÉCESSAIRE."
    return 0
  else
    log "WARNING" "LA PURGE N'EST PAS RÉGLÉE SUR PreventOfflinePvP=$pvp_value, MISE À JOUR EN COURS."

    command_line edit edit-params "PreventOfflinePvP" "$pvp_value"
    service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
    service edit "$ARK_SERVER_SERVICE" restart "on-failure"
    service daemon-reload "$ARK_SERVER_SERVICE"
    rcon maintenance-msg-cmd-loop "$message_prefix"
    service restart "$ARK_SERVER_SERVICE"
    log "OVERSEER" "PURGE PVP $action SUR LE SERVEUR $ARK_SERVER_SERVICE TERMINÉE."
  fi
}

get_service_command_line_params() {
  local params=()
  local command_line
  command_line=$(grep "ExecStart=" "$ARK_SERVER_SERVICE_FILE" | cut -d= -f2-)

  # Extraire la commande après 'ArkAscendedServer.exe'
  command_line="${command_line#*ArkAscendedServer.exe }"
  # Délimiter les paramètres par un '?'
  IFS='?' read -r -a question_params <<< "$command_line"
  for param in "${question_params[@]}"; do
    if [[ "$param" == *'='* ]]; then
      # Extrait le nom et la valeur du paramètre avec un signe '=' entre eux
      param_name="${param%%=*}"
      param_value="${param#*=}"
      params+=("$param_name=$param_value")
    else
      # Prise en charge des paramètres sans valeur
      params+=("$param")
    fi
  done

  echo "${params[@]}"
}

edit_selected_params() {
  local server_param
  local options
  read -r -a options <<< "$(get_service_command_line_params)"

  PS3="VEUILLEZ ENTRER LE NUMÉRO DU PARAMÈTRE À MODIFIER: "

  log "WARNING" "VEUILLEZ SÉLECTIONNER UN PARAMÈTRE À MODIFIER DANS LA LISTE SUIVANTE:"
  select server_param_with_value in "${options[@]}"; do
    if [ -n "$server_param_with_value" ]; then
      server_param="${server_param_with_value%%=*}"
      current_value="${server_param_with_value#*=}"
      echo
      log "INFO" "LE PARAMÈTRE SÉLECTIONNÉ EST: $server_param"
      log "INFO" "VALEUR ACTUELLE: $current_value"
      log "QUESTION" "VEUILLEZ SAISIR LA NOUVELLE VALEUR POUR LE PARAMÈTRE: $server_param"
      read -r new_value
      command_line edit edit-params "$server_param" "$new_value"
      sudo systemctl daemon-reload
      break
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SÉLECTION DU PARAMÈTRE."
      log "INFO" "VEUILLEZ ENTREZ UN NUMÉRO DE PARAMÈTRE A MODIFIER."
    fi
  done
}

command() {
  local command=$1

  case "$command" in
    start|stop|restart|update)
      "$command""_server"
      ;;
    edit)
      edit_selected_params
      ;;
    purge)
      local type=$2
      case "$type" in
        start)
          pvp_purge "start" "false" "RCON_PURGE_START"
          ;;
        stop)
          pvp_purge "stop" "true" "RCON_PURGE_STOP"
          ;;
        *)
          log "ERROR" "LA COMMANDE OVERSEER FOURNIE N'EST PAS VALIDE POUR LA PURGE PVP."
          log "INFO" "LES COMMANDES VALIDES SONT: {start|stop}"
          log "INFO" "EXEMPLE: command purge start"
          log "INFO" "EXEMPLE: command purge stop"
      esac
      ;;
    *)
      log "ERROR" "LA COMMANDE OVERSEER FOURNIE N'EST PAS VALIDE POUR LE SERVEUR."
      log "INFO" "LES COMMANDES VALIDES SONT: {start|stop|restart|update|edit}"
      log "INFO" "EXEMPLE: command start"
      log "INFO" "EXEMPLE: command stop"
      log "INFO" "EXEMPLE: command restart"
      log "INFO" "EXEMPLE: command update"
      log "INFO" "EXEMPLE: command edit"
      ;;
  esac
}