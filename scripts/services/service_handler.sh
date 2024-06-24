#!/bin/bash
set -euo pipefail

service_start(){
  service_name=$1

  log "LOG" "DÉMARRAGE DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl start "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ DÉMARRÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU DÉMARRAGE DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER DE DÉMARRER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl start $service_name"
    exit 1
  fi
}

service_stop(){
  service_name=$1

  log "LOG" "ARRÊT DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl stop "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ ARRÊTÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'ARRÊT DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER D'ARRÊTER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl stop $service_name"
    exit 1
  fi
}

service_restart(){
  service_name=$1

  log "LOG" "REDÉMARRAGE DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl restart "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ REDÉMARRÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU REDÉMARRAGE DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER DE REDÉMARRER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl restart $service_name"
    exit 1
  fi
}

service_daemon_reload(){
  service_name=$1

  log "LOG" "RECHARGEMENT DU DAEMON $service_name SUR $HOSTNAME."
  if sudo systemctl daemon-reload; then
    log "SUCCESS" "LE DAEMON A ÉTÉ RECHARGÉ POUR LE SERVICE $service_name SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU RECHARGEMENT DU DAEMON POUR LE SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER DE RECHARGER LE DAEMON MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl daemon-reload"
    exit 1
  fi
}

service_enable(){
  service_name=$1

  log "LOG" "ACTIVATION DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl enable --now "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ ACTIVÉ SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'ACTIVATION DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER D'ACTIVER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl enable --now $service_name"
    exit 1
  fi
}

service_disable(){
  service_name=$1

  log "LOG" "DÉSACTIVATION DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl disable --now "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ DÉSACTIVÉ."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA DÉSACTIVATION DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER DE DÉSACTIVER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl disable --now $service_name"
    exit 1
  fi
}

service_delete(){
    service_name=$1
    service_path=$2

    service_stop "$service_name"

    log "LOG" "SUPPRESSION DU FICHIER DE SERVICE $service_name A L'EMPLACEMENT $service_path SUR $HOSTNAME."
    if sudo rm -f "$service_path"; then
      log "SUCCESS" "LE SERVICE $service_name A ÉTÉ SUPPRIMÉ."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SUPPRESSION DU SERVICE $service_name."
      log "DEBUG" "VEUILLEZ ESSAYER DE SUPPRIMER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo rm -f $service_name"
    fi
  }

service_edit_exec_stop(){
  local service_name="$1"
  local exec_stop_value="$2"
  local service_path="$3"

  log "LOG" " VÉRIFICATION & MODIFICATION DE LA VALEUR DE ExecStop POUR LE SERVICE $service_name."
  if grep -q "ExecStop=$exec_stop_value" "$service_path"; then
    log "OK" "LA VALEUR DE ExecStop POUR LE SERVICE $service_name EST DÉJÀ DÉFINIE À: $exec_stop_value."
  else
    log "WARNING" "LA VALEUR DE ExecStop POUR LE SERVICE $service_name N'EST PAS DÉFINIE À: $exec_stop_value."
    log "LOG" " MODIFICATION DE LA VALEUR DE ExecStop POUR LE SERVICE $service_name."
    if sudo sed -i "s|^ExecStop=.*|ExecStop=$exec_stop_value" -f "$service_path"; then
      log "SUCCESS" "MODIFICATION DE ExecStop POUR LE SERVICE $service_name RÉUSSIE."
    else
      log "ERROR" "ERREUR LORS DE LA MODIFICATION DE ExecStop POUR LE SERVICE $service_name."
      log "DEBUG" "VÉRIFIEZ LE FICHIER DE SERVICE $service_name À L'EMPLACEMENT: $service_path."
      log "DEBUG" "VÉRIFIEZ LA VALEUR DE ExecStop: $exec_stop_value."
    fi
  fi
}

service_edit_restart(){
  local service_name="$1"
  local restart_value="$2"
  local service_path="$3"

  log "LOG" " VÉRIFICATION & MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name."
  if grep -q "Restart=$restart_value" "$service_path"; then
    log "OK" "LA VALEUR DE Restart POUR LE SERVICE $service_name EST DÉJÀ DÉFINIE À: $restart_value."
  else
    log "WARNING" "LA VALEUR DE Restart POUR LE SERVICE $service_name N'EST PAS DÉFINIE À: $restart_value."
    log "LOG" " MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name."
    if sudo sed -i "s|Restart=.*|Restart=$restart_value|" "$service_path"; then
      log "SUCCESS" "MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name RÉUSSIE."
    else
      log "ERROR" "ERREUR LORS DE LA MODIFICATION DE Restart POUR LE SERVICE $service_name."
      log "DEBUG" "VÉRIFIEZ LE FICHIER DE SERVICE $service_name À L'EMPLACEMENT: $service_path."
      log "DEBUG" "VÉRIFIEZ LA VALEUR DE Restart: $restart_value."
    fi
  fi
}

service_handler () {
  local action=$1
  local service_name=$2

  local service_path="/etc/systemd/system/$service_name.service"

  case $action in
    start)
      service_start "$service_name"
      ;;
    stop)
      service_stop "$service_name"
      ;;
    restart)
      service_restart "$service_name"
      ;;
    daemon_reload)
      service_daemon_reload "$service_name"
      ;;
    enable)
      service_enable "$service_name"
      ;;
    disable)
      service_disable "$service_name"
      ;;
    delete)
      service_delete "$service_name" "$service_path"
      ;;
    edit)
      local edit_action=$2
      local edit_service_name=$3
      local edit_value=$4
      local edit_service_path=$5

      case $edit_action in
        "exec_stop")
          service_edit_exec_stop "$edit_service_name" "$edit_value" "$edit_service_path"
          ;;
        "restart")
          service_edit_restart "$edit_service_name" "$edit_value" "$edit_service_path"
          ;;
        *)
          log "ERROR" "LA FONCTION $edit_action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
          log "DEBUG" "VEUILLEZ FOURNIR UNE FONCTION VALIDE: exec_stop OU restart."
          log "DEBUG" "EXEMPLE: services_handler edit exec_stop <service_name> <exec_stop_value> <service_path>"
          log "DEBUG" "EXEMPLE: services_handler edit restart <service_name> <restart_value> <service_path>"
          ;;
      esac
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {start|stop|restart|reload|enable|disable|delete|edit}"
      log "DEBUG" "EXEMPLE: services_handler start <service_name>"
      log "DEBUG" "EXEMPLE: services_handler stop <service_name>"
      log "DEBUG" "EXEMPLE: services_handler restart <service_name>"
      log "DEBUG" "EXEMPLE: services_handler reload <service_name>"
      log "DEBUG" "EXEMPLE: services_handler enable <service_name>"
      log "DEBUG" "EXEMPLE: services_handler disable <service_name>"
      log "DEBUG" "EXEMPLE: services_handler delete <service_name>"
      log "DEBUG" "EXEMPLE: services_handler edit <edit_action> <service_name> <edit_value> <service_path>"
      ;;
  esac
}
