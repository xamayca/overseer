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

  log "OVERSEER" "MISE À JOUR DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  if check_server_build_id && check_latest_build_id && compare_build_ids; then
    rcon_utils maintenance_msg_cmd_loop "RCON_UPDATE"
    service_handler edit "restart" "$ARK_SERVER_SERVICE"
  fi
  log "SUCCESS" "MISE À JOUR DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉE."

}

restart_server(){
  log "OVERSEER" "REDEMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
  service_handler edit "restart" "$ARK_SERVER_SERVICE" "on-failure" "$ARK_SERVER_SERVICE_FILE"
  service_handler daemon_reload "$ARK_SERVER_SERVICE"
  rcon maintenance_msg_cmd_loop "RCON_RESTART"
  log "SUCCESS" "REDEMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉ."
}

stop_server(){
  log "OVERSEER" "ARRÊT DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
  service_handler edit "restart" "$ARK_SERVER_SERVICE" "no" "$ARK_SERVER_SERVICE_FILE"
  service_handler daemon_reload "$ARK_SERVER_SERVICE"
  rcon maintenance_msg_cmd_loop "RCON_STOP"
  log "SUCCESS" "ARRÊT DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉ."
}

start_server(){
  log "OVERSEER" "DÉMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE EN COURS."
  service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
  service_handler edit "restart" "$ARK_SERVER_SERVICE" "on-failure" "$ARK_SERVER_SERVICE_FILE"
  service_handler daemon_reload "$ARK_SERVER_SERVICE"
  service_handler start "$ARK_SERVER_SERVICE"
  log "SUCCESS" "DÉMARRAGE DU SERVEUR: $ARK_SERVER_SERVICE TERMINÉ."
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
    command_line_utils edit edit_params "PreventOfflinePvP" "$pvp_value"
    service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
    service_handler edit "restart" "$ARK_SERVER_SERVICE" "on-failure" "$ARK_SERVER_SERVICE_FILE"
    service_handler "daemon_reload" "$ARK_SERVER_SERVICE"
    rcon_utils maintenance_msg_cmd_loop "$message_prefix"
    service_handler restart "$ARK_SERVER_SERVICE"
    log "SUCCESS" "PURGE PVP $action SUR LE SERVEUR $ARK_SERVER_SERVICE TERMINÉE."
  fi
}

command_handler() {
  local command=$1

  case "$command" in
    start | stop | restart | update)
      "$command""_server"
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
          log "ERROR" "LA COMMANDE OVERSEER FOURNIE N'EST PAS VALIDE."
          log "INFO" "LES COMMANDES VALIDES SONT: {start|stop}"
          log "INFO" "EXEMPLE: commands_handler purge start"
      esac
      ;;
    *)
      log "ERROR" "LA COMMANDE OVERSEER FOURNIE N'EST PAS VALIDE."
      log "INFO" "LES COMMANDES VALIDES SONT: {start|stop|restart|update}"
      log "INFO" "EXEMPLE: commands_handler start"
      log "INFO" "EXEMPLE: commands_handler stop"
      log "INFO" "EXEMPLE: commands_handler restart"
      log "INFO" "EXEMPLE: commands_handler update"
      exit 1
  esac
}

