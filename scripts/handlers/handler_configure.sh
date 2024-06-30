#!/bin/bash
set -euo pipefail

check_if_web_server_exist(){
  if [ -f "$WEB_SERVER_SERVICE_FILE" ]; then
    return 0
  else
    log "ERROR" "LE SERVEUR WEB $WEB_SERVER_SERVICE N'EXISTE PAS SUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "VEUILLEZ CONFIGURER LE SERVEUR WEB AVANT DE CONTINUER."
    log "DEBUG" "POUR CONFIGURER LE SERVEUR WEB, VEUILLER UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure web-server"
    exit 1
  fi
}

configure_cluster(){

  mount_nfs_cluster(){

    ping_mount_point(){
      log "LOG" "VÉRIFICATION & COMMUNICATION AVEC LE POINT DE MONTAGE NFS A L'ADRESSE $NFS_IP_ADDRESS."
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
      folder create "Cluster Dir" "$CLUSTER_DIR_OVERRIDE" "777"
      permissions owner "Cluster Dir" "$CLUSTER_DIR_OVERRIDE" "$USER_ACCOUNT"
      mount_cluster
      auto_mount_cluster
      service daemon-reload "nfs-cluster"
      log "SUCCESS" "LE CLUSTER NFS A ÉTÉ MONTÉ ET CONFIGURÉ AVEC SUCCÈS SUR LE SERVEUR $ARK_SERVER_SERVICE."
    fi

  }

  log "OVERSEER" "CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
  log "INFO" "LES PARAMÈTRES DE TRANSFERT DE CLUSTER PERMETTENT DE TRANSFÉRER DES DONNÉES ENTRE LES SERVEURS (DINOSAURES, OBJETS, ETC.)."
  log "WARNING" "LE SERVEUR REDEMARRERA AUTOMATIQUEMENT APRÈS LA CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER."
  if prompt confirm "VOULEZ-VOUS CONFIGURER LES PARAMÈTRES DE TRANSFERT DE CLUSTER POUR LE SERVEUR $ARK_SERVER_SERVICE ? [Oui/Non]"; then
    log "LOG" "CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER SUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    validate variable "MULTIHOME"
    validate variable "CLUSTER_ID"
    validate variable "NFS_IP_ADDRESS"
    validate variable "NFS_FOLDER_DIR"
    validate variable "CLUSTER_DIR_OVERRIDE"
    validate file "$ARK_SERVER_SERVICE_FILE"
    command_line edit add-flag-params "clusterid" "$CLUSTER_ID"
    command_line edit add-flag-params "ClusterDirOverride" "$CLUSTER_DIR_OVERRIDE"
    mount_nfs_cluster
    service edit exec-stop "$ARK_SERVER_SERVICE" "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
    service edit restart "$ARK_SERVER_SERVICE" "on-failure"
    service daemon-reload "Service ARK"
    rcon maintenance-msg-cmd-loop "RCON_RESTART"
    service restart "$ARK_SERVER_SERVICE"
    log "OVERSEER" "LE CLUSTER A ÉTÉ CONFIGURÉ AVEC SUCCÈS SUR LE SERVEUR $ARK_SERVER_SERVICE."
  else
    log "OK" "LA CONFIGURATION DES PARAMÈTRES DE TRANSFERT DE CLUSTER NE SERA PAS EFFECTUÉE SUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "POUR CONFIGURER LES PARAMÈTRES DE TRANSFERT DE CLUSTER, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure cluster"
    exit 0
  fi
}

configure_web_server(){
  log "OVERSEER" "CONFIGURATION DU SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE SUR $HOSTNAME."
  log "INFO" "LE SERVEUR WEB EST UTILISÉ POUR LA CONFIGURATION DYNAMIQUE & D'AUTRES FONCTIONNALITÉS."
  if prompt confirm "VOULEZ-VOUS CONFIGURER LE SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE ? [Oui/Non]"; then
    log "LOG" "CONFIGURATION DU SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
    validate variable "WEB_SERVER_SERVICE"
    validate variable "DYNAMIC_CONFIG_URL"
    validate folder "$WEB_SERVER_DIR"
    if install_service web; then
      log "OVERSEER" "LE SERVEUR WEB A ÉTÉ CRÉÉ AVEC SUCCÈS POUR LE SERVEUR $ARK_SERVER_SERVICE."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DU SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE."
      log "DEBUG" "VEUILLEZ ESSAYER DE CRÉER LE SERVEUR WEB POUR LE SERVEUR $ARK_SERVER_SERVICE MANUELLEMENT."
      log "DEBUG" "sudo cp $WEB_SERVER_SERVICE_FILE $WEB_SERVER_SERVICE_ALIAS"
      exit 1
    fi
  else
    log "OK" "LA CONFIGURATION DU SERVEUR WEB NE SERA PAS EFFECTUÉE POUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "DEBUG" "POUR CONFIGURER LE SERVEUR WEB, VEUILLEZ UTILISER LA COMMANDE SUIVANTE:"
    log "DEBUG" "overseer --configure web-server"
    exit 0
  fi
}

configure_dynamic_config(){
  if check_if_web_server_exist; then
    log "OVERSEER" "CONFIGURATION DE LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE SUR $HOSTNAME."
    log "INFO" "LA CONFIGURATION DYNAMIQUE PERMET DE MODIFIER LES PARAMÈTRES DE GameUserSettings SANS REDÉMARRER LE SERVEUR."
    log "WARNING" "LE SERVEUR REDEMARRERA AUTOMATIQUEMENT APRÈS LA CONFIGURATION DE LA DYNAMIC CONFIG."
    if prompt confirm "VOULEZ-VOUS CONFIGURER LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE ? [Oui/Non]"; then
      log "LOG" "CONFIGURATION DE LA DYNAMIC CONFIG POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      validate variable "DYNAMIC_CONFIG_DIR"
      validate variable "DYNAMIC_CONFIG_URL"
      validate variable "EVENT_COLORS_CHANCE_OVERRIDE"
      validate file "$ARK_SERVER_SERVICE_FILE"
      validate folder "$DYNAMIC_CONFIG_DIR"
      rcon maintenance-msg-cmd-loop "RCON_RESTART"
      service stop "$ARK_SERVER_SERVICE"
      gus edit "CustomDynamicConfigUrl" "\"${DYNAMIC_CONFIG_URL}\""
      command_line edit add-simple-flag-params "UseDynamicConfig" ""
      command_line edit add-query-params "EventColorsChanceOverride" "$EVENT_COLORS_CHANCE_OVERRIDE"
      service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
      service edit "$ARK_SERVER_SERVICE" restart "on-failure"
      service daemon-reload "$ARK_SERVER_SERVICE"
      service restart "$ARK_SERVER_SERVICE"
      log "OVERSEER" "LA DYNAMIC CONFIG A ÉTÉ CONFIGURÉE AVEC SUCCÈS POUR LE SERVEUR $ARK_SERVER_SERVICE."
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
    log "OVERSEER" "CONFIGURATION DE LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE SUR $HOSTNAME."
    log "INFO" "LA LISTE BLANCHE ADMIN PERMET D'AJOUTER DES JOUEURS À LA LISTE BLANCHE ADMIN SANS REDÉMARRER LE SERVEUR."
    log "WARNING" "LE SERVEUR REDEMARRERA AUTOMATIQUEMENT APRÈS LA CONFIGURATION DE LA LISTE BLANCHE ADMIN."
    if prompt confirm "VOULEZ-VOUS CONFIGURER LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE ? [Oui/Non]"; then
      log "LOG" "CONFIGURATION DE LA LISTE BLANCHE ADMIN POUR LE SERVEUR $ARK_SERVER_SERVICE EN COURS."
      validate folder "$ADMIN_WHITE_LIST_DIR"
      validate variable "ADMIN_LIST_URL"
      service edit "$ARK_SERVER_SERVICE" exec-stop "/usr/bin/pkill -f $ARK_SERVER_EXE_FILE"
      service edit "$ARK_SERVER_SERVICE" restart "on-failure"
      service daemon-reload "$ARK_SERVER_SERVICE"
      rcon maintenance-msg-cmd-loop "RCON_RESTART"
      service stop "$ARK_SERVER_SERVICE"
      gus edit "AdminListURL" "\"${ADMIN_LIST_URL}\""
      service start "$ARK_SERVER_SERVICE"
      log "OVERSEER" "LA LISTE BLANCHE ADMIN A ÉTÉ CONFIGURÉE AVEC SUCCÈS POUR LE SERVEUR $ARK_SERVER_SERVICE."
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

configure(){
  local type=$1

  case $type in
    dynamic)
      configure_dynamic_config
      ;;
    admin-list)
      configure_admin_list
      ;;
    web-server)
      configure_web_server
      ;;
    cluster)
      configure_cluster
      ;;
    *)
      log "ERROR" "LE TYPE DE CONFIGURATION: $type N'EST PAS PRIS EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UN TYPE DE CONFIGURATION VALIDE: {dynamic-config|web-server|cluster}"
      log "DEBUG" "EXEMPLE: configure dynamic-config"
      log "DEBUG" "EXEMPLE: configure web-server"
      log "DEBUG" "EXEMPLE: configure cluster"
      ;;
  esac
}


