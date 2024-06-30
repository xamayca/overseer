#!/bin/bash
set -euo pipefail

prompt_confirm() {
  while true; do
    log "QUESTION" "$prompt"
      read -r response
      case $response in
        [oO][uU][iI]|[oO])
          return 0
          ;;
        [nN][oO]|[nN])
          return 1
          ;;
        *)
          log "ERROR" "VEUILLEZ RÉPONDRE PAR 'OUI' OU 'NON'."
          ;;
      esac
  done
}

prompt_enter(){
  log "QUESTION" "$prompt"
  read -r REPLY
  case $REPLY in
    "");;
    *)
      log "ERROR" "VEUILLEZ APPUYER SUR LA TOUCHE 'ENTRÉE' POUR CONTINUER."
      prompt_enter_to_continue ;;
  esac
}

prompt(){
  local action=$1
  local prompt=$2

  case $action in
    confirm|enter)
      prompt_"$action" "$prompt"
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: 'confirm', 'enter'."
      log "DEBUG" "EXEMPLE: prompt confirm <question>"
      log "DEBUG" "EXEMPLE: prompt enter <question>"
      exit 1
  esac

}









