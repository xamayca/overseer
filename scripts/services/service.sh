#!/bin/bash
set -euo pipefail

service_daemon_reload(){
  log "LOG" "RECHARGEMENT DU DAEMON SUR $HOSTNAME POUR LE SERVICE $service_name."
  if sudo systemctl daemon-reload; then
    log "SUCCESS" "LE DAEMON A ÉTÉ RECHARGÉ AVEC SUCCÈS SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU RECHARGEMENT DU DAEMON."
    log "DEBUG" "VEUILLEZ ESSAYER DE RECHARGER LE DAEMON MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl daemon-reload"
    exit 1
  fi
}

service_action(){
  log "LOG" "EXÉCUTION DE L'ACTION $action POUR LE SERVICE $service_name."
  if sudo systemctl "$action" "$service_name"; then
    log "SUCCESS" "L'ACTION $action POUR LE SERVICE $service_name A ÉTÉ EXÉCUTÉE."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'EXÉCUTION DE L'ACTION $action POUR LE SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER D'EXÉCUTER L'ACTION MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl $action $service_name"
    exit 1
  fi
}

service_enable_now(){
  log "LOG" "ACTIVATION IMMÉDIATE DU SERVICE $service_name SUR $HOSTNAME."
  if sudo systemctl enable --now "$service_name"; then
    log "SUCCESS" "LE SERVICE $service_name A ÉTÉ ACTIVÉ IMMÉDIATEMENT."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'ACTIVATION IMMÉDIATE DU SERVICE $service_name."
    log "DEBUG" "VEUILLEZ ESSAYER D'ACTIVER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo systemctl enable --now $service_name"
    exit 1
  fi
}

service_delete(){
  log "LOG" "VÉRIFICATION DE L'EXISTENCE DU FICHIER DE SERVICE $service_name A L'EMPLACEMENT $service_path SUR $HOSTNAME."
  if [ -f "$service_path" ]; then
    log "WARNING" "LE FICHIER DE SERVICE $service_name EXISTE DÉJÀ."
    log "LOG" "SUPPRESSION DU FICHIER DE SERVICE $service_name A L'EMPLACEMENT $service_path SUR $HOSTNAME."
    if sudo rm -f "$service_path"; then
      log "SUCCESS" "LE SERVICE $service_name A ÉTÉ SUPPRIMÉ."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SUPPRESSION DU SERVICE $service_name."
      log "DEBUG" "VEUILLEZ ESSAYER DE SUPPRIMER LE SERVICE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo rm -f $service_path"
    fi
  else
    log "OK" "LE FICHIER DE SERVICE $service_name N'EXISTE PAS."
  fi
}

service_edit_exec_stop(){
  log "LOG" "VÉRIFICATION & MODIFICATION DE LA VALEUR DE ExecStop POUR LE SERVICE $service_name."
  if grep -q "ExecStop=$new_value" "$service_path"; then
    log "OK" "LA VALEUR DE ExecStop POUR LE SERVICE $service_name EST DÉJÀ DÉFINIE À: $new_value."
  else
    log "WARNING" "LA VALEUR DE ExecStop POUR LE SERVICE $service_name N'EST PAS DÉFINIE À: $new_value."
    log "LOG" "MODIFICATION DE LA VALEUR DE ExecStop POUR LE SERVICE $service_name."
    if sudo sed -i "s|^ExecStop=.*|ExecStop=$new_value|" "$service_path"; then
      log "SUCCESS" "MODIFICATION DE ExecStop POUR LE SERVICE $service_name RÉUSSIE."
    else
      log "ERROR" "ERREUR LORS DE LA MODIFICATION DE ExecStop POUR LE SERVICE $service_name."
      log "DEBUG" "VÉRIFIEZ LE FICHIER DE SERVICE $service_name À L'EMPLACEMENT: $service_path."
      log "DEBUG" "VÉRIFIEZ LA VALEUR DE ExecStop: $new_value."
    fi
  fi
}

service_edit_restart(){
  log "LOG" "VÉRIFICATION & MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name."
  if grep -q "Restart=$new_value" "$service_path"; then
    log "OK" "LA VALEUR DE Restart POUR LE SERVICE $service_name EST DÉJÀ DÉFINIE À: $new_value."
  else
    log "WARNING" "LA VALEUR DE Restart POUR LE SERVICE $service_name N'EST PAS DÉFINIE À: $new_value."
    log "LOG" "MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name."
    if sudo sed -i "s|Restart=.*|Restart=$new_value|" "$service_path"; then
      log "SUCCESS" "MODIFICATION DE LA VALEUR DE Restart POUR LE SERVICE $service_name RÉUSSIE."
    else
      log "ERROR" "ERREUR LORS DE LA MODIFICATION DE Restart POUR LE SERVICE $service_name."
      log "DEBUG" "VÉRIFIEZ LE FICHIER DE SERVICE $service_name À L'EMPLACEMENT: $service_path."
      log "DEBUG" "VÉRIFIEZ LA VALEUR DE Restart: $new_value."
    fi
  fi
}

service(){
  local action="$1"
  local service_name="$2"

  local service_path="/etc/systemd/system/$service_name.service"

  case "$action" in
    daemon-reload)
      service_daemon_reload "$service_name"
      ;;
    start|stop|restart|reload)
      service_action "$action" "$service_name"
      ;;
    enable-now)
      service_enable_now "$service_name"
      ;;
    delete)
      service_delete "$service_name"
      ;;
    edit)
      local type="$3"
      local new_value="$4"
      case "$type" in
        exec-stop)
          service_edit_exec_stop "$service_name" "$new_value"
          ;;
        restart)
          service_edit_restart "$service_name" "$new_value"
          ;;
        *)
          log "ERROR" "LE TYPE DE MODIFICATION $type N'EST PAS PRIS EN CHARGE."
          log "DEBUG" "VEUILLEZ FOURNIR UN TYPE DE MODIFICATION VALIDE: {exec-stop|restart}"
          log "DEBUG" "EXEMPLE: service edit <nom_du_service> exec-stop <nouvelle_valeur>"
          log "DEBUG" "EXEMPLE: service edit <nom_du_service> restart <nouvelle_valeur>"
          exit 1
          ;;
      esac
      ;;
    *)
      log "ERROR" "L'ACTION FOURNIE: $action N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {daemon-reload|start|stop|restart|reload|enable-now|delete|edit}"
      log "DEBUG" "EXEMPLE: service daemon-reload <nom_du_service>"
      log "DEBUG" "EXEMPLE: service start <nom_du_service>"
      log "DEBUG" "EXEMPLE: service stop <nom_du_service>"
      log "DEBUG" "EXEMPLE: service restart <nom_du_service>"
      log "DEBUG" "EXEMPLE: service reload <nom_du_service>"
      log "DEBUG" "EXEMPLE: service enable-now <nom_du_service>"
      log "DEBUG" "EXEMPLE: service delete <nom_du_service>"
      log "DEBUG" "EXEMPLE: service edit <nom_du_service> exec-stop <nouvelle_valeur>"
      log "DEBUG" "EXEMPLE: service edit <nom_du_service> restart <nouvelle_valeur>"
  esac
}