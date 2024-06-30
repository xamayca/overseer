#!/bin/bash
set -euo pipefail
# ExecStart=$WEB_SERVER_START_COMMAND
ark_server_unit() {

  COMMAND_LINE="${QUERY_PARAMS}${FLAG_PARAMS}"

  if sudo tee "$ARK_SERVER_SERVICE_FILE" > /dev/null <<EOF

[Unit]
Description="$ARK_SERVER_SERVICE"
After=syslog.target network.target network-online.target nss-lookup.target

[Service]
Type=simple
LimitNOFILE=100000
User=$USER_ACCOUNT
Group=$USER_ACCOUNT
ExecStartPre=$STEAM_CMD_EXE_FILE +force_install_dir $ARK_SERVER_DIR +login anonymous +app_update $ARK_APP_ID validate +quit
WorkingDirectory=$ARK_SERVER_EXE_DIR
Environment="XDG_RUNTIME_DIR=/run/user/$(id -u)"
Environment="STEAM_COMPAT_CLIENT_INSTALL_PATH=$STEAM_COMPAT_CLIENT_INSTALL_PATH"
Environment="STEAM_COMPAT_DATA_PATH=$STEAM_COMPAT_DATA_PATH"
ExecStart=$PROTON_GE_EXE_FILE run $ARK_SERVER_EXE_FILE $COMMAND_LINE
ExecStop=/usr/bin/pkill -f $ARK_SERVER_EXE_FILE
Restart=on-failure
TimeoutStopSec=20

[Install]
Alias=$ARK_SERVER_SERVICE_ALIAS
WantedBy=multi-user.target

EOF
  then
    log "SUCCESS" "L'UNITÉ $ARK_SERVER_SERVICE A ÉTÉ CRÉÉE SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DE L'UNITÉ $ARK_SERVER_SERVICE."
  fi
}

web_server_unit() {

  if sudo tee "$WEB_SERVER_SERVICE_FILE" > /dev/null <<EOF

[Unit]
Description="$WEB_SERVER_SERVICE"
After=syslog.target network.target network-online.target nss-lookup.target

[Service]
Type=simple
User=$USER_ACCOUNT
Group=$USER_ACCOUNT
WorkingDirectory=$WEB_SERVER_DIR
ExecStart=$WEB_SERVER_START_COMMAND
Restart=on-failure
RestartSec=5
KillSignal=SIGINT

[Install]
Alias=$WEB_SERVER_SERVICE_ALIAS
WantedBy=multi-user.target

EOF
  then
    log "SUCCESS" "L'UNITÉ $WEB_SERVER_SERVICE A ÉTÉ CRÉÉE SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DE L'UNITÉ $WEB_SERVER_SERVICE."
  fi

}

install_unit(){
  unit_name=$1

  case $unit_name in
    ark)
      ark_server_unit
      ;;
    web)
      web_server_unit
      ;;
    *)
      log "ERROR" "LE NOM DE L'UNITÉ $unit_name QUE VOUS AVEZ FOURNI N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UN NOM D'UNITÉ VALIDE: {ark|web}"
      log "INFO" "EXEMPLE: install_unit ark"
      exit 1
      ;;
  esac
}