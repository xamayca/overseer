#!/bin/bash
set -euo pipefail

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
ExecStartPre=$STEAM_CMD_EXE_FILE +force_install_dir $ARK_SERVER_EXE_FILE +login anonymous +app_update $ARK_APP_ID validate +quit
WorkingDirectory=$ARK_SERVER_EXE_DIR
Environment="XDG_RUNTIME_DIR=/run/user/$(id -u)"
Environment="STEAM_COMPAT_CLIENT_INSTALL_PATH=$STEAM_COMPAT_CLIENT_INSTALL_PATH"
Environment="STEAM_COMPAT_DATA_PATH=$STEAM_COMPAT_DATA_PATH"
ExecStart=$PROTON_GE_EXE_FILE run $ARK_SERVER_EXE_FILE $COMMAND_LINE >> $ARK_SERVER_LOG_FILE.log 2>&1
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
WorkingDirectory=$WEB_SERVER_WORKING_DIR
ExecStart=$WEB_SERVER_START_COMMAND >> $WEB_SERVER_LOG_FILE.log 2>&1
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

units_create(){
  unit_name=$1

  case $unit_name in
    "ark_server")
      ark_server_unit
      ;;
    "web_server")
      web_server_unit
      ;;
    *)
      log "ERROR" "LE NOM DE L'UNITÉ $unit_name QUE VOUS AVEZ FOURNI N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UN NOM D'UNITÉ VALIDE: ark_server OU web_server."
  esac

}