#!/bin/bash
set -euo pipefail

check_if_web_server_exist(){
  if [ -f "$WEB_SERVER_SERVICE_FILE" ]; then
    return 0
  else
    return 1
  fi
}

configure_cluster(){

  mount_nfs_cluster(){

    ping_mount_point(){
      log "LOG" "VÉRIFICATION & COMMUNICATION AVEC LE POINT DE MONTAGE NFS A L'ADRESSE: $NFS_IP_ADDRESS..."
      if sudo ping -c 3 -W 1 "$NFS_IP_ADDRESS" &>/dev/null; then
        log "SUCCESS" "LA COMMUNICATION AVEC LE POINT DE MONTAGE NFS A L'ADRESSE: $NFS_IP_ADDRESS EST ÉTABLIE."
        return 1
      else
        log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA COMMUNICATION AVEC LE POINT DE MONTAGE NFS."
        log "DEBUG" "VEUILLEZ VÉRIFIER L'ADRESSE IP DU $NFS_IP_ADDRESS ET LA CONNEXION RÉSEAU."
        exit 1
      fi
    }

    check_mount_point(){
      log "LOG" "VÉRIFICATION & MONTAGE DU POINT DE MONTAGE NFS POUR LE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE."
      if mount | grep -q "$NFS_IP_ADDRESS:$NFS_FOLDER_DIR on $CLUSTER_DIR_OVERRIDE type nfs" && [[ -d "$CLUSTER_DIR_OVERRIDE" ]]; then
        log "OK" "LE POINT DE MONTAGE NFS POUR LE CLUSTER EST MONTÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
        return 1
      else
        log "WARNING" "LE POINT DE MONTAGE NFS POUR LE CLUSTER N'EST PAS MONTÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
        return 0
      fi
    }

    auto_mount_cluster(){
      log "LOG" "VÉRIFICATION & CONFIGURATION DE L'AUTO MONTAGE DU CLUSTER NFS SUR LE SERVEUR $ARK_SERVER_SERVICE."
      if grep -q "$NFS_IP_ADDRESS:$NFS_FOLDER_DIR $CLUSTER_DIR_OVERRIDE nfs" /etc/fstab; then
        log "OK" "L'AUTO MONTAGE DU CLUSTER NFS EST DÉJÀ CONFIGURÉ DANS /etc/fstab."
      else
        log "WARNING" "L'AUTO MONTAGE DU CLUSTER NFS N'EST PAS CONFIGURÉ DANS /etc/fstab, CONFIGURATION EN COURS."
        if echo "$NFS_IP_ADDRESS:$NFS_FOLDER_DIR $CLUSTER_DIR_OVERRIDE nfs defaults 0 0" | sudo tee -a /etc/fstab && sudo mount -a; then
          log "SUCCESS" "L'AUTO MONTAGE DU CLUSTER NFS A ÉTÉ CONFIGURÉ AVEC SUCCÈS DANS /etc/fstab."
        else
          log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CONFIGURATION DE L'AUTO MONTAGE DU CLUSTER NFS DANS /etc/fstab."
          log "DEBUG" "VEUILLEZ CONFIGURER L'AUTO MONTAGE DU CLUSTER NFS DANS /etc/fstab À L'AIDE DE LA COMMANDE SUIVANTE:"
          log "DEBUG" "echo $NFS_IP_ADDRESS:$NFS_FOLDER_DIR $CLUSTER_DIR_OVERRIDE nfs defaults 0 0 | sudo tee -a /etc/fstab"
          exit 1
        fi
      fi
    }

    mount_cluster(){
      log "LOG" "MONTAGE DU CLUSTER NFS POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      if sudo mount -t nfs -o vers=3,rw,hard "$NFS_IP_ADDRESS:$NFS_FOLDER_DIR" "$CLUSTER_DIR_OVERRIDE"; then
        log "SUCCESS" "LE CLUSTER NFS A ÉTÉ MONTÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
      else
        log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU MONTAGE DU CLUSTER NFS SUR LE SERVEUR $ARK_SERVER_SERVICE."
        log "DEBUG" "VEUILLEZ VÉRIFIER L'ADRESSE IP DU $NFS_IP_ADDRESS ET LA CONNEXION RÉSEAU."
        exit 1
      fi
    }

    if check_mount_point && ping_mount_point; then
      log "LOG" "MONTAGE DU CLUSTER NFS POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      folder create "CLUSTER_DIR_OVERRIDE" "$CLUSTER_DIR_OVERRIDE" "777"
      permissions owner "CLUSTER_DIR_OVERRIDE" "$USER_ACCOUNT"
      mount_cluster
      auto_mount_cluster
      services_handler daemon_reload "nfs-cluster"
      log "SUCCESS" "LE CLUSTER NFS A ÉTÉ MONTÉ ET CONFIGURÉ AVEC SUCCÈS SUR LE SERVEUR $ARK_SERVER_SERVICE."
    fi

  }
  log "OVERSEER" "CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
  log "INFO" "LES PARAMÈTRES DE TRANSFERT DE CLUSTER PERMETTENT DE TRANSFÉRER DES DONNÉES ENTRE LES SERVEURS (DINOSAURES, OBJETS, ETC.)."
  if prompt_confirm "VOULEZ VOUS CONFIGURER LES PARAMÈTRES DE TRANSFERT DE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE ?"; then
    log "LOG" "CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    check_var_tools "MULTIHOME" "z" "192.168.1.XX"
    check_var_tools "CLUSTER_ID" "z" "YOURSERVERCLUSTERID"
    check_var_tools "CLUSTER_DIR_OVERRIDE" "z" "/mnt/cluster"
    check_var_tools "NFS_IP_ADDRESS" "z" "192.168.1.XX"
    check_var_tools "NFS_FOLDER_DIR" "z" "/volume1/CLUSTER"
    command_line_utils "add_flag_params" "clusterid" "$CLUSTER_ID"
    command_line_utils "add_flag_params" "ClusterDirOverride" "$CLUSTER_DIR_OVERRIDE"
    mount_nfs_cluster

      if prompt_confirm "VOULEZ-VOUS REDEMARRER LE SERVEUR $ARK_SERVER_SERVICE POUR APPLIQUER LES MODIFICATIONS ? [Oui/Non]"; then
        log "LOG" "REDEMARRAGE DU SERVEUR $ARK_SERVER_SERVICE EN COURS."
        service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
        service_handler edit "restart" "$ARK_SERVER_SERVICE" "on-failure" "$ARK_SERVER_SERVICE_FILE"
        service_handler "daemon_reload" "$ARK_SERVER_SERVICE"
        rcon_utils maintenance_msg_cmd_loop "$RCON_RESTART"
        service_handler restart "$ARK_SERVER_SERVICE"
      else
        log "OK" "LE SERVEUR $ARK_SERVER_SERVICE NE SERA PAS REDEMARRÉ."
        log "DEBUG" "POUR APPLIQUER LES MODIFICATIONS, VEUILLEZ REDEMARRER LE SERVEUR $ARK_SERVER_SERVICE AVEC LA COMMANDE SUIVANTE:"
        log "DEBUG" "overseer --server restart"
        exit 0
      fi

  else
    log "OK" "LA CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER NE SERA PAS EFFECTUÉE SUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "POUR CONFIGURER LES PARAMÈTRES DE TRANSFERT DE CLUSTER, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure cluster"
    exit 0
  fi
}

configure_web_server(){
  log "OVERSEER" "CONFIGURATION DU SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
  log "INFO" "LE SERVEUR WEB EST UTILISÉ POUR LA CONFIGURATION DYNAMIQUE & D'AUTRES FONCTIONNALITÉS."
  if prompt_confirm "VOULEZ-VOUS CONFIGURER LE SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE ?"; then
    log "LOG" "CONFIGURATION DU SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    check_var_tools "WEB_SERVICE_FILE" "f" "/etc/systemd/system/${ARK_SERVER_SERVICE}-web.service"
    check_var_tools "WEB_SERVER_SERVICE_ALIAS" "f" "${MAP_NAME}-web.service"
    check_var_tools "WEB_SERVER_DIR" "d" "/home/overseer/manager/web"
    install_service "web_server"
    service_handler restart "$WEB_SERVER_SERVICE"
    log "SUCCESS" "LE SERVEUR WEB A ÉTÉ CRÉÉ AVEC SUCCÈS POUR LE SERVEUR $ARK_SERVER_SERVICE."
  else
    log "OK" "LA CONFIGURATION DU SERVEUR WEB NE SERA PAS EFFECTUÉE POUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "POUR CONFIGURER LE SERVEUR WEB, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure web-server"
    exit 0
  fi
}

configure_dynamic_config(){
  if check_if_web_server_exist; then
    log "OVERSEER" "CONFIGURATION DE LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    log "INFO" "LA CONFIGURATION DYNAMIQUE PERMET DE MODIFIER LES PARAMÈTRES DE GameUserSettings SANS REDÉMARRER LE SERVEUR."
    if prompt_confirm "VOULEZ-VOUS CONFIGURER LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE ?"; then
      log "LOG" "CONFIGURATION DE LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      check_var_tools "DYNAMIC_CONFIG_DIR" "d" "/home/overseer/manager/web/dynamic"
      check_var_tools "DYNAMIC_CONFIG_URL" "z" "http://127.0.0.1:8080/dynamic-config/current/dyn.ini"
      update_gus_ini "CustomDynamicConfigUrl" "\"${DYNAMIC_CONFIG_URL}\""
      command_line_utils "add_simple_flag_params" "UseDynamicConfig"

      if prompt_confirm "VOULEZ-VOUS REDEMARRER LE SERVEUR $ARK_SERVER_SERVICE POUR APPLIQUER LES MODIFICATIONS ? [Oui/Non]"; then
        log "LOG" "REDEMARRAGE DU SERVEUR $ARK_SERVER_SERVICE EN COURS."
        service_handler edit "exec_stop" "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE" "$ARK_SERVER_SERVICE_FILE"
        service_handler edit "restart" "$ARK_SERVER_SERVICE" "on-failure" "$ARK_SERVER_SERVICE_FILE"
        service_handler "daemon_reload" "$ARK_SERVER_SERVICE"
        rcon_utils maintenance_msg_cmd_loop "$RCON_RESTART"
        service_handler restart "$ARK_SERVER_SERVICE"
      else
        log "OK" "LE SERVEUR $ARK_SERVER_SERVICE NE SERA PAS REDEMARRÉ."
        log "DEBUG" "POUR APPLIQUER LES MODIFICATIONS, VEUILLEZ REDEMARRER LE SERVEUR $ARK_SERVER_SERVICE AVEC LA COMMANDE SUIVANTE:"
        log "DEBUG" "overseer --server restart"
        exit 0
      fi

    else
      log "OK" "LA CONFIGURATION DE LA DYNAMIC CONFIG NE SERA PAS EFFECTUÉE POUR LE SERVEUR $ARK_SERVER_SERVICE."
      log "DEBUG" "POUR CONFIGURER LA DYNAMIC CONFIG, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
      log "DEBUG" "overseer --configure dynamic-config"
      exit 0
    fi
  else
    log "ERROR" "LE SERVEUR WEB N'EST PAS CONFIGURÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "VEUILLEZ CONFIGURER LE SERVEUR WEB AVANT DE CONFIGURER LA DYNAMIC CONFIG."
    log "DEBUG" "POUR CONFIGURER LE SERVEUR WEB, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure web-server"
    exit 1
  fi
}

configure_admin_list(){
  if check_if_web_server_exist; then
    log "OVERSEER" "CONFIGURATION DE LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    log "INFO" "LA LISTE BLANCHE ADMIN PERMET DE GÉRER LES ADMINISTRATEURS DU SERVEUR."

    if prompt_confirm "VOULEZ-VOUS CONFIGURER LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE ?"; then
      log "LOG" "CONFIGURATION DE LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      check_var_tools "ADMIN_WHITE_LIST_DIR" "d" "/home/overseer/manager/web/admins"
      check_var_tools "ADMIN_LIST_URL" "z" "http://127.0.0.1:8080/admin-list/admins.txt"
      update_gus_ini "AdminListUrl" "\"${ADMIN_LIST_URL}\""
      log "SUCCESS" "LA LISTE BLANCHE ADMIN A ÉTÉ CONFIGURÉE AVEC SUCCÈS POUR LE SERVEUR $ARK_SERVER_SERVICE."
    else
      log "OK" "LA CONFIGURATION DE LA LISTE BLANCHE ADMIN NE SERA PAS EFFECTUÉE POUR LE SERVEUR $ARK_SERVER_SERVICE."
      log "DEBUG" "POUR CONFIGURER LA LISTE BLANCHE ADMIN, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
      log "DEBUG" "overseer --configure admin-list"
      exit 0
    fi

  else
    log "ERROR" "LE SERVEUR WEB N'EST PAS CONFIGURÉ SUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "VEUILLEZ CONFIGURER LE SERVEUR WEB AVANT DE CONFIGURER LA LISTE BLANCHE ADMIN."
    log "DEBUG" "POUR CONFIGURER LE SERVEUR WEB, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure web-server"
    exit 1
  fi
}

configure_handler(){
  type=$1

  case $type in
    "dynamic-config")
      configure_dynamic_config
      ;;
    "admin-list")
      configure_admin_list
      ;;
    "web-server")
      configure_web_server
      ;;
    "cluster")
      configure_cluster
      ;;
    *)
      log "ERROR" "LE TYPE DE CONFIGURATION: $type N'EST PAS RECONNU."
      log "DEBUG" "VEUILLEZ FOURNIR UN TYPE DE CONFIGURATION VALIDE: {dynamic-config|web-server|cluster}"
      log "DEBUG" "EXEMPLE: configuration_handler dynamic-config"
      log "DEBUG" "EXEMPLE: configuration_handler web-server"
      log "DEBUG" "EXEMPLE: configuration_handler cluster"
      ;;
  esac
}


