#!/bin/bash
set -euo pipefail

service_commands_infos(){
  alias=$1
  echo -e "\e[1;31m\e[4mUTILISATION DES COMMANDES SYSTEMCTL POUR LE SERVICE $alias:\e[0m\n\n\e[1;32mDÉMARRAGE DU SERVICE:\e[0m \e[1;34msudo systemctl start $alias\e[0m\n\n\e[1;32mARRÊT DU SERVICE:\e[0m \e[1;34msudo systemctl stop $alias\e[0m\n\n\e[1;32mREDÉMARRAGE DU SERVICE:\e[0m \e[1;34msudo systemctl restart $alias\e[0m\n\n\e[1;32mSTATUT DU SERVICE:\e[0m \e[1;34msudo systemctl status $alias\e[0m"
  echo
  echo -e "\e[1;31m\e[4mUTILISATION DES COMMANDES JOURNALCTL POUR LE SERVICE $alias:\e[0m\n\n\e[1;32mAFFICHAGE DES LOGS DU SERVICE:\e[0m \e[1;34msudo journalctl -u $alias\e[0m\n\n\e[1;32mAFFICHAGE DES LOGS DU SERVICE EN TEMPS RÉEL:\e[0m \e[1;34msudo journalctl -fu $alias\e[0m"
  echo
  echo -e "\e[1;31m\e[4mUTILISATION DES COMMANDES D'EDITION DU SERVICE $alias:\e[0m\n\n\e[1;32mOUVRIR LE FICHIER DE SERVICE DANS L'ÉDITEUR DE TEXTE:\e[0m \e[1;34msudo nano /etc/systemd/system/$alias\e[0m\n\n\e[1;32mRECHARGER LE DAEMON SYSTEMD:\e[0m \e[1;34msudo systemctl daemon-reload\e[0m"
}

is_service_exist(){
  local name="$1"
  local path="$2"

  if [ -f "$path" ]; then
    log "OK" "LE SERVICE $name EXISTE DÉJÀ SUR $HOSTNAME."
    service_commands_infos "$name"
    return 0
  else
    log "WARNING" "LE SERVICE $name N'EXISTE PAS SUR $HOSTNAME."
    return 1
  fi
}

install_service() {
  local type="$1"
  local name path alias

  # seul root peu lancer avec ark_server mais pas web_server
  if [ "$EUID" -ne 0 ] && [ "$type" == "ark_server" ]; then
    log "ERROR" "VOUS DEVEZ EXÉCUTER CE SCRIPT EN TANT QUE ROOT POUR INSTALLER LE SERVICE $ARK_SERVER_SERVICE."
    return
  else
    log "INFO" "INSTALLATION DU SERVICE $type SUR $HOSTNAME."
  fi

  if [ "$type" == "ark_server" ]; then
    name="$ARK_SERVER_SERVICE"
    path="$ARK_SERVER_SERVICE_FILE"
    alias="$ARK_SERVER_SERVICE_ALIAS"
  elif [ "$type" == "web_server" ]; then
    name="$WEB_SERVER_SERVICE"
    path="$WEB_SERVER_SERVICE_FILE"
    alias="$WEB_SERVER_SERVICE_ALIAS"
  else
    log "ERROR" "LE TYPE DE SERVICE $type N'EST PAS RECONNU."
    log "DEBUG" "VEUILLEZ FOURNIR UN TYPE DE SERVICE VALIDE: {ark_server|web_server}"
    log "DEBUG" "EXEMPLE: install_create ark_server"
    log "DEBUG" "EXEMPLE: install_create web_server"
    return
  fi

  if is_service_exist "$name" "$path"; then
    if prompt confirm "VOULEZ-VOUS SUPPRIMER LE SERVICE $name SUR $HOSTNAME POUR LE SERVEUR $ARK_SERVER_SERVICE? [Oui/Non]"; then
      log "WARNING" "LE SERVICE $name VA ÊTRE SUPPRIMÉ SUR $HOSTNAME."
      service_handler stop "$name"
      service_handler disable "$name"
      service_handler delete "$name"
      exit 1
    else
      log "SUCCESS" "LE SERVICE $name NE SERA PAS SUPPRIMÉ SUR $HOSTNAME."
    fi
  else
    units_create "$type"
    service_handler daemon_reload "$name"
    service_handler enable "$name"
    service_commands_infos "$alias"
  fi

}