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
    log "SUCCESS" "COMMANDE RCON EXÉCUTÉE AVEC SUCCÈS."
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
    log "SUCCESS" "MESSAGE RCON ENVOYÉ, PROCHAIN MESSAGE DANS $delay SECONDES."
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

  local delays=(5 5 5 5 5)

  send_maintenance_delayed_msg messages[@] delays[@]
  local commands=("SaveWorld" "DoExit")
  execute_cmd commands[@]
}

rcon() {
  action=$1

  case "$action" in
    execute-cmd)
      local commands=("${!2}")
      execute_cmd commands[@]
      ;;
    maintenance-msg-cmd-loop)
      local message_prefix=$2
      maintenance_msg_cmd_loop "$message_prefix"
      ;;
    maintenance-delayed-msg)
      local messages=("${!2}")
      local delays=("${!3}")
      send_maintenance_delayed_msg messages[@] delays[@]
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "INFO" "VEUILLEZ FOURNIR UNE DES ACTIONS SUIVANTES: {execute-cmd|maintenance-msg-cmd-loop|maintenance-delayed-msg}"
      log "INFO" "EXEMPLE: rcon execute-cmd commands[@]"
      log "INFO" "EXEMPLE: rcon maintenance-msg-cmd-loop message_prefix"
      log "INFO" "EXEMPLE: rcon maintenance-delayed-msg messages[@] delays[@]"
  esac
}