#!/bin/bash
set -euo pipefail

# Définir le chemin du répertoire des scripts et des fichiers de configuration
BASE_DIR="$(dirname "$(realpath "$0")")"

export SCRIPTS_DIR="$BASE_DIR/scripts/"
export CONFIG_DIR="$BASE_DIR/config/"
export MANAGER_DIR="$BASE_DIR/manager/"

source "$CONFIG_DIR/server.sh"

# Charge tous les fichiers de configuration et de script
while IFS= read -r -d '' file; do
  # shellcheck source=$file
  source "$file"
done < <(find "$CONFIG_DIR" "$SCRIPTS_DIR" "$MANAGER_DIR" -type f -name "*.sh" -print0)

# Si aucun argument n'est fourni, lancer l'installation du serveur
if [ $# -eq 0 ]; then

  if [ "$EUID" -ne 0 ] && [ "$USER" == "$USER_ACCOUNT" ]; then
      log "ERROR" "LE SCRIPT D'INSTALLATION DU SERVEUR EST RÉSERVÉ À L'UTILISATEUR ROOT."
      log "DEBUG" "VEUILLEZ EXÉCUTER LE SCRIPT D'INSTALLATION DU SERVEUR EN TANT QU'UTILISATEUR ROOT."
      log "DEBUG" "EXEMPLE: sudo ./overseer.sh"
      exit 1
  fi

  header "installer"
  if dependencies_installation && account_installation && server_installation && install_service ark; then
    log "OVERSEER" "L'INSTALLATION EST TERMINÉE, VOUS POUVEZ MAINTENANT UTILISER L'OVERSEER."
    log "WARNING" "POUR UTILISER L'OVERSEER, CONNECTEZ-VOUS AU COMPTE $USER_ACCOUNT AVEC SA CLÉ PRIVÉE SSH."
    log "ATTENTION" "POUR TOUT PROBLÈME, VEUILLEZ CONSULTER LE DEPÔT GITHUB: $COMMUNITY_GITHUB_URL."
    exit 0
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DE L'OVERSEER."
    exit 1
  fi

else

  header "overseer"

    SHORT_OPTS="vhs:r:p:u:d:c:t:"
    LONG_OPTS="version,help,server:,purge:,update,dynamic:,configure:,task:"

    OPTIONS=$(getopt -o "$SHORT_OPTS" --long "$LONG_OPTS" -n "$(basename "$0")" -- "$@")

    eval set -- "$OPTIONS"

    while true; do
      option="$1"
      case "$option" in
        -v | --version)
          echo "OVERSEER VERSION: $OVERSEER_SCRIPT_VERSION"
          echo "INSTALLATION VERSION: $INSTALLER_SCRIPT_VERSION"
          exit 0
          ;;
        -h | --help)
          help
          exit 0
          ;;
        -s | --server)
          action="$2"
          case "$action" in
            start|stop|restart|update)
              command "$action"
              shift 2
              ;;
            edit)
              command edit
              shift 2
              ;;
            *)
              log "ERROR" "L'ACTION FOURNIE: $action N'EST PAS VALIDE POUR LE SERVEUR"
              log "INFO" "LES ACTIONS VALIDES SONT: {start|stop|restart|update|edit}"
              log "INFO" "EXEMPLE: overseer --server start"
              log "INFO" "EXEMPLE: overseer --server stop"
              log "INFO" "EXEMPLE: overseer --server restart"
              log "INFO" "EXEMPLE: overseer --server update"
              log "INFO" "EXEMPLE: overseer --server edit"
          esac
          ;;
        -p | --purge)
          action="$2"
          case "$action" in
            start | stop)
              command purge "$action"
              shift 2
              ;;
            *)
              log "ERROR" "L'ACTION FOURNIE: $action N'EST PAS VALIDE POUR LA PURGE"
              log "INFO" "LES ACTIONS VALIDES SONT: {start|stop}"
              log "INFO" "EXEMPLE: overseer --purge start"
              log "INFO" "EXEMPLE: overseer --purge stop"
              shift 2
              ;;
          esac
          ;;
        -d | --dynamic)
          day="$2"
          case "$day" in
            monday|tuesday|wednesday|thursday|friday|saturday|sunday)
              dynamic "$day"
              shift 2
              ;;
            *)
              log "ERROR" "LE JOUR FOURNI: $day N'EST PAS VALIDE POUR LA PLANIFICATION DYNAMIQUE"
              log "INFO" "LES JOURS VALIDES SONT: {monday|tuesday|wednesday|thursday|friday|saturday|sunday}"
              log "INFO" "EXEMPLE: overseer --dynamic monday"
              log "INFO" "EXEMPLE: overseer --dynamic tuesday"
              log "INFO" "EXEMPLE: overseer --dynamic wednesday"
              log "INFO" "EXEMPLE: overseer --dynamic thursday"
              log "INFO" "EXEMPLE: overseer --dynamic friday"
              log "INFO" "EXEMPLE: overseer --dynamic saturday"
              log "INFO" "EXEMPLE: overseer --dynamic sunday"
              shift 2
              ;;
          esac
          ;;
        -c | --configure)
          action="$2"
          case "$action" in
            web-server|cluster|dynamic|admin-list)
              configure "$action"
              shift 2
              ;;
            *)
              log "ERROR" "L'ACTION FOURNIE: $action N'EST PAS VALIDE POUR LA CONFIGURATION"
              log "INFO" "LES ACTIONS VALIDES SONT: {web-server|cluster|dynamic|admin-list}"
              log "INFO" "EXEMPLE: overseer --configure web-server"
              log "INFO" "EXEMPLE: overseer --configure cluster"
              log "INFO" "EXEMPLE: overseer --configure dynamic"
              log "INFO" "EXEMPLE: overseer --configure admin-list"
              shift 2
              ;;
          esac
          ;;
        -t | --task)
          action="$2"
          case "$action" in
            create)
              task "$action"
              shift 2
              ;;
            *)
              log "ERROR" "L'ACTION FOURNIE: $action N'EST PAS VALIDE POUR LA GESTION DES TÂCHES PLANIFIÉES"
              log "INFO" "LES ACTIONS VALIDES SONT: {create}"
              log "INFO" "EXEMPLE: overseer --task create"
              shift 2
              ;;
          esac
          ;;
        --)
          shift
          break
          ;;
        *)
          log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'ANALYSE DES OPTIONS."
          log "INFO" "VEUILLEZ CONSULTER L'AIDE POUR PLUS D'INFORMATIONS."
          log "INFO" "EXEMPLE: overseer --help"
          exit 1
          ;;
      esac
    done

fi



