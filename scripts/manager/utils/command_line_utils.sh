#!/bin/bash
set -euo pipefail

add_query_params() {
  local params="$1"
  local value="$2"
  update_command_line_service "?$params=$value" "/ServerAdminPassword/a ?$params=$value" "REQUÊTE"
}

add_flag_params() {
  local params="$1"
  local value="$2"
  update_command_line_service "-$params=$value" "/ExecStart/s|$| -$params=$value|"
}

add_simple_flag_params() {
  local params="$1"
  update_command_line_service "-$params" "/ExecStart/s|$| -$params|"
}

edit_params() {
  local params="$1"
  local value="$2"
  update_command_line_service "$params=$value" "s|\($params=\)[^?]*|\1$value|"
}

update_command_line_service() {
  local param="$1"
  local sed_command="$2"

  log "LOG" "VÉRIFICATION & MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE."
  if grep -q "$param" "$ARK_SERVER_SERVICE_FILE"; then
    log "OK" "LE PARAMÈTRE DE $param EST DÉJÀ DÉFINI CORRECTEMENT DANS LE SERVICE $ARK_SERVER_SERVICE."
  else
    log "WARNING" "LE PARAMÈTRE DE $param N'EST PAS DÉFINI CORRECTEMENT DANS LE SERVICE $ARK_SERVER_SERVICE."
    log "LOG" "MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE."
    if sudo sed -i "$sed_command" "$ARK_SERVER_SERVICE_FILE"; then
      log "SUCCESS" "MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE RÉUSSIE."
    else
      log "ERROR" "ERREUR LORS DE LA MISE À JOUR DU PARAMÈTRE DE $param DANS LE SERVICE $ARK_SERVER_SERVICE."
      log "DEBUG" "VÉRIFIEZ LE FICHIER DE SERVICE $ARK_SERVER_SERVICE À L'EMPLACEMENT: $ARK_SERVER_SERVICE_FILE."
      log "DEBUG" "VÉRIFIEZ LE PARAMÈTRE DE $param."
    fi
  fi
}

command_line_utils(){
  local action="$1"
  local function_name="$2"
  local param="$3"
  local value="$4"

  case "$action" in
    edit)
      case "$function_name" in
        add_query_params|add_flag_params|edit_params)
          $function_name "$param" "$value"
          ;;
        add_simple_flag_params)
          $function_name "$param"
          ;;
        *)
          log "ERROR" "L'OPTION FOURNIE: $function_name N'EST PAS VALIDE POUR L'ÉDITION DE LA LIGNE DE COMMANDE."
          log "INFO" "LES FONCTIONS VALIDES SONT: {add_query_params|add_flag_params|add_simple_flag_params|edit_params}"
          log "INFO" "EXEMPLE: command_line_utils edit add_query_params \"?listen\" \"1\""
          log "INFO" "EXEMPLE: command_line_utils edit add_flag_params \"exclusivejoin\" \"1\""
          log "INFO" "EXEMPLE: command_line_utils edit add_simple_flag_params \"exclusivejoin\""
          log "INFO" "EXEMPLE: command_line_utils edit edit_params \"ServerAdminPassword\" \"password\""
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

