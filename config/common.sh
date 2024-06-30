#!/bin/bash
set -euo pipefail

# [ System ]
USER_ACCOUNT="overseer"
USER_DIR="/home/${USER_ACCOUNT}"
SYSTEM_TIMEZONE="Europe/Paris"

# [ Script Versioning ]
SHOW_HEADER_SYSTEM_INFO="True"
INSTALLER_SCRIPT_VERSION="0.4.0"
OVERSEER_SCRIPT_VERSION="0.3.1"

# [ Community URLs ]
COMMUNITY_WEBSITE_URL="https://www.france-survival.fr/"
COMMUNITY_GITHUB_URL="https://github.com/xamayca/ASCENDED-SERVER-DEBIAN12-PROTONGE"
COMMUNITY_DISCORD_URL="https://discord.gg/F7pQyrRDd8"
COMMUNITY_INSTAGRAM_URL="https://www.instagram.com/francesurvival/"
COMMUNITY_FACEBOOK_URL="https://www.facebook.com/profile.php?id=61553584645099"

# [ Dynamic Configuration & Admin White List URLs ]
ADMIN_LIST_URL="http://127.0.0.1:8080/admins/admins.txt"
DYNAMIC_CONFIG_URL="http://127.0.0.1:8080/dynamic/current/dyn.ini"

# [ ARK: Server Directory ]
ARK_APP_ID="2430930"
ARK_SERVER_DIR="/home/${USER_ACCOUNT}/ARK-Server"

# [ ARK: Server Executable ]
ARK_SERVER_EXE="ArkAscendedServer.exe"
ARK_SERVER_EXE_DIR="${ARK_SERVER_DIR}/ShooterGame/Binaries/Win64"
ARK_SERVER_EXE_FILE="${ARK_SERVER_EXE_DIR}/${ARK_SERVER_EXE}"

# [ ARK: Server Manifest ]
ARK_SERVER_MANIFEST_FILE="${ARK_SERVER_DIR}/steamapps/appmanifest_${ARK_APP_ID}.acf"
ARK_LATEST_BUILD_ID="https://api.steamcmd.net/v1/info/${ARK_APP_ID}"

# [ ARK: Server Configuration Files ]
ARK_CONFIG_DIR="${ARK_SERVER_DIR}/ShooterGame/Saved/Config/WindowsServer"
GUS_INI_FILE="${ARK_CONFIG_DIR}/GameUserSettings.ini"
GAME_INI_FILE="${ARK_CONFIG_DIR}/Game.ini"

# [ Overseer Manager ]
OVERSEER_INSTALL_DIR="/home/${USER_ACCOUNT}/OverseerManager"
OVERSEER_SCRIPT_FILE="${OVERSEER_INSTALL_DIR}/overseer.sh"
OVERSEER_MANAGER_DIR="${OVERSEER_INSTALL_DIR}/manager"

# [ Overseer Logs ]
WEB_SERVER_LOG_FILE="${OVERSEER_MANAGER_DIR}/logs/web-server.log"
ARK_SERVER_LOG_FILE="${OVERSEER_MANAGER_DIR}/logs/ark-server.log"
CRONTAB_LOG_FILE="${OVERSEER_MANAGER_DIR}/logs/cron-overseer.log"

# [ Systemd: Service Directory ]
SERVICE_DIR="/etc/systemd/system"

# [ Service: Server ]
ARK_SERVER_SERVICE="AscendedServer${MAP_NAME}"
ARK_SERVER_SERVICE_ALIAS="${MAP_NAME}.service"
ARK_SERVER_SERVICE_FILE="${SERVICE_DIR}/${ARK_SERVER_SERVICE}.service"

# [ Service: Web server ]
WEB_SERVER_START_COMMAND="/usr/bin/python3 -m http.server --bind 127.0.0.1 8080"
WEB_SERVER_SERVICE="AscendedServer${MAP_NAME}-web"
WEB_SERVER_SERVICE_ALIAS="${MAP_NAME}-web.service"

# [ Service: Web server Folders ]
WEB_SERVER_DIR="${OVERSEER_INSTALL_DIR}/manager/web"
WEB_SERVER_SERVICE_FILE="${SERVICE_DIR}/${WEB_SERVER_SERVICE}.service"

# [ Service: Dynamic Config & Admin White List Folder ]
DYNAMIC_CONFIG_DIR="${WEB_SERVER_DIR}/dynamic"
ADMIN_WHITE_LIST_DIR="${WEB_SERVER_DIR}/admins"

# [ Dependencies: Steam CMD ]
STEAM_CMD_EXE_FILE="/usr/games/steamcmd"
STEAM_COMPAT_DATA_PATH="${ARK_SERVER_DIR}/steamapps/compatdata/${ARK_APP_ID}"
STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/${USER_ACCOUNT}/.steam/steam/steamapps"

# [ Dependencies: PROTON GE ]
PROTON_GE_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
PROTON_GE_COMPATIBILITY_TOOLS_DIR="/home/${USER_ACCOUNT}/.steam/root/compatibilitytools.d"
PROTON_GE_EXE_FILE="${PROTON_GE_COMPATIBILITY_TOOLS_DIR}/proton"

# [ Dependencies: RCON Cli ]
RCON_URL="https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz"
RCON_TGZ="$(basename $RCON_URL)"
RCON_CHECKSUM="8601c70dcab2f90cd842c127f700e398"
RCON_DIR="${ARK_SERVER_DIR}/RCON"
RCON_EXE_FILE="${RCON_DIR}/rcon"

# [ Colors ]
WHITE="\033[0;37m"
GREY="\033[0;37m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
BWHITE="\033[1;37m"
BGREY="\033[1;30m"
BGREEN="\033[1;32m"
BYELLOW="\033[1;33m"
BRED="\033[1;31m"
BBLUE="\033[1;34m"
BCYAN="\033[1;36m"
BMAGENTA="\033[1;35m"
UWHITE="\033[4;37m"
UGREY="\033[4;30m"
UGREEN="\033[4;32m"
UYELLOW="\033[4;33m"
URED="\033[4;31m"
UBLUE="\033[4;34m"
UCYAN="\033[4;36m"
UMAGENTA="\033[4;35m"
RESET="\033[0m"
BOLD="\033[1m"
BLINK_START="\033[5m"
BLINK_END="\033[25m"
JUMP_LINE="\n"

