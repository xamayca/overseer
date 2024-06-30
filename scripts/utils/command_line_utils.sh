#!/bin/bash
set -euo pipefail

add_query_params() {
  local params="$1"
  local value="$2"
  local insert_at="?ServerAdminPassword"
  local insert_text="?$params=$value"

  update_command_line_on_service "$insert_text" "/ExecStart/s|\(.*\)$insert_at|\1$insert_text$insert_at|"
}

add_flag_params() {
  local params="$1"
  local value="$2"
  update_command_line_on_service "-$params=$value" "/ExecStart/s|$| -$params=$value|"
}

add_simple_flag_params() {
  local params="$1"
  update_command_line_on_service "-$params" "/ExecStart/s|$| -$params|"
}

edit_params() {
  local params="$1"
  local value="$2"
  update_command_line_on_service "$params=$value" "s|\($params=\)[^?]*|\1$value|"
}



update_command_line_on_service() {
  local param="$1"
  local sed_command="$2"

  log "LOG" "VÉRIFICATION & MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE_FILE."

  if grep -q "$param" "$ARK_SERVER_SERVICE_FILE"; then
    log "OK" "LE PARAMÈTRE DE $param EST DÉJÀ PRÉSENT DANS LE SERVICE $ARK_SERVER_SERVICE_FILE."
  else
    log "WARNING" "LE PARAMÈTRE DE $param N'EST PAS PRÉSENT DANS LE SERVICE $ARK_SERVER_SERVICE_FILE."
  fi

  log "LOG" "MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE_FILE."

  if sudo sed -i "$sed_command" "$ARK_SERVER_SERVICE_FILE"; then
    log "SUCCESS" "MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE_FILE RÉUSSIE."
  else
    log "ERROR" "ÉCHEC DE LA MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE_FILE."
    log "DEBUG" "COMMANDE SED: sudo sed -i \"$sed_command\" \"$ARK_SERVER_SERVICE_FILE\""
    exit 1
  fi
}




command_line(){
  local action="$1"
  local function_name="$2"
  local param="$3"

  case "$action" in
    edit)
      case "$function_name" in
        add-query-params)
          local value="$4"
          add_query_params "$param" "$value"
          ;;
        add-flag-params)
          local value="$4"
          add_flag_params "$param" "$value"
          ;;
        add-simple-flag-params)
          add_simple_flag_params "$param"
          ;;
        edit-params)
          local value="$4"
          edit_params "$param" "$value"
          ;;
        *)
          log "ERROR" "L'OPTION FOURNIE: $function_name N'EST PAS VALIDE POUR L'ÉDITION DE LA LIGNE DE COMMANDE."
          log "INFO" "LES OPTIONS VALIDES SONT: {add-query-params|add-flag-params|add-simple-flag-params|edit-params}"
          log "INFO" "EXEMPLE: command_line edit add-query-params \"?param\" \"value\""
          log "INFO" "EXEMPLE: command_line edit add-flag-params \"param\" \"value\""
          log "INFO" "EXEMPLE: command_line edit add-simple-flag-params \"param\""
          log "INFO" "EXEMPLE: command_line edit edit-params \"param\" \"value\""
          exit 1
          ;;
      esac
      ;;
    *)
      log "ERROR" "L'OPTION FOURNIE: $action N'EST PAS VALIDE POUR LA GESTION DE LA LIGNE DE COMMANDE."
      log "INFO" "LES ACTIONS VALIDES SONT: {edit}"
      exit 1
      ;;
  esac
}


