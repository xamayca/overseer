#!/bin/bash
set -euo pipefail

send_to_server() {
  local command="$1"
  $RCON_EXE_FILE -a 127.0.0.1:"$RCON_PORT" -p "$SERVER_ADMIN_PASSWORD" "$command"
}

execute_cmd() {
  local commands=("${!1}")
  for command in "${commands[@]}"; do
    log "OVERSEER" "EXECUTION DE LA COMMANDE RCON: $command"
    send_to_server "$command"
  done
}

send_maintenance_delayed_msg() {
  local messages=("${!1}")
  local delays=("${!2}")

  while [ ${#messages[@]} -gt 0 ]; do
    local message="${messages[0]}"
    local delay="${delays[0]}"
    log "OVERSEER" "ENVOI DU MESSAGE RCON: $message"
    send_to_server "ServerChat $message"
    sleep "$delay"
    #for delay in $(seq "$delay" -1 1); do
    #  log "INFO"TEMPS RESTANT AVANT L'ENVOI DU PROCHAIN MESSAGE RCON: $delay SECONDES"
    #  sleep 1
    #done
    messages=("${messages[@]:1}")
    delays=("${delays[@]:1}")
  done
}

maintenance_msg_cmd_loop() {
  local message_prefix=$1

  local messages=()
  for i in {1..5}; do
    message_var="${message_prefix}_MSG_$i"
    if [ -n "${!message_var}" ]; then
      messages+=("${!message_var}")
    fi
  done

  local delays=(300 240 60 10 5)
  send_maintenance_delayed_msg messages delays
  local commands=("SaveWorld" "DoExit")
  execute_cmd commands
}

rcon_utils() {

  case "$1" in
    execute_cmd)
      execute_cmd "$2"
      ;;
    maintenance_msg_cmd_loop)
      maintenance_msg_cmd_loop "$2"
      ;;
    *)
      log "ERROR" "L'OPTION FOURNIE: $1 N'EST PAS VALIDE POUR LA GESTION RCON."
      log "INFO" "LES OPTIONS VALIDES SONT: {execute_cmd|maintenance_msg_cmd_loop}"
      log "INFO" "EXEMPLE: rcon utils execute_cmd \"command1\" \"command2\" \"command3\""
      log "INFO" "EXEMPLE: rcon utils maintenance_msg_cmd_loop \"RCON_MAINTENANCE\""
      exit 1
      ;;
  esac

}