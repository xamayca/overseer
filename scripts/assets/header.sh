#!/bin/bash
set -euo pipefail

header(){

  community_name(){
    center "${BBLUE} ______ _____            _   _  _____ ______    _____ _    _ _______      _________      __     _      "
    center "${BBLUE}|  ____|  __ \     /\   | \ | |/ ____|  ____|  / ____| |  | |  __ \ \    / /_   _\ \    / /\   | |     "
    center "${BWHITE}| |__  | |__) |   /  \  |  \| | |    | |__    | (___ | |  | | |__) \ \  / /  | |  \ \  / /  \  | |     "
    center "${BWHITE}|  __| |  _  /   / /\ \ | . \` | |    |  __|    \___ \| |  | |  _  / \ \/ /   | |   \ \/ / /\ \ | |     "
    center "${BRED}| |    | | \ \  / ____ \| |\  | |____| |____   ____) | |__| | | \ \  \  /   _| |_   \  / ____ \| |____ "
    center "${BRED}|_|    |_|  \_\/_/    \_\_| \_|\_____|______| |_____/ \____/|_|  \_\  \/   |_____|   \/_/    \_\______|"
  }

  installation_script_subtitle() {
    community_name
    center "${BMAGENTA}    _    ____   ____ _____ _   _ ____  _____ ____    ____  _____ ______     _______ ____    ____   ____ ____  ___ ____ _____ "
    center "${BMAGENTA}   / \  / ___| / ___| ____| \ | |  _ \| ____|  _ \  / ___|| ____|  _ \ \   / / ____|  _ \  / ___| / ___|  _ \|_ _|  _ \_   _|"
    center "${BMAGENTA}  / _ \ \___ \| |   |  _| |  \| | | | |  _| | | | | \___ \|  _| | |_) \ \ / /|  _| | |_) | \___ \| |   | |_) || || |_) || |  "
    center "${BMAGENTA} / ___ \ ___) | |___| |___| |\  | |_| | |___| |_| |  ___) | |___|  _ < \ V / | |___|  _ <   ___) | |___|  _ < | ||  __/ | |  "
    center "${BMAGENTA}/_/   \_\____/ \____|_____|_| \_|____/|_____|____/  |____/|_____|_| \_\ \_/  |_____|_| \_\ |____/ \____|_| \_\___|_|    |_|  "
  }

  overseer_script_subtitle() {
    community_name
    center "${BMAGENTA}     _    ____   ____ _____ _   _ ____  _____ ____    ____  _____ ______     _______ ____     _____     _______ ____  ____  _____ _____ ____  "
    center "${BMAGENTA}    / \  / ___| / ___| ____| \ | |  _ \| ____|  _ \  / ___|| ____|  _ \ \   / / ____|  _ \   / _ \ \   / / ____|  _ \/ ___|| ____| ____|  _ \ "
    center "${BMAGENTA}   / _ \ \___ \| |   |  _| |  \| | | | |  _| | | | | \___ \|  _| | |_) \ \ / /|  _| | |_) | | | | \ \ / /|  _| | |_) \___ \|  _| |  _| | |_) |"
    center "${BMAGENTA}  / ___ \ ___) | |___| |___| |\  | |_| | |___| |_| |  ___) | |___|  _ < \ V / | |___|  _ <  | |_| |\ V / | |___|  _ < ___) | |___| |___|  _ < "
    center "${BMAGENTA} /_/   \_\____/ \____|_____|_| \_|____/|_____|____/  |____/|_____|_| \_\ \_/  |_____|_| \_\  \___/  \_/  |_____|_| \_\____/|_____|_____|_| \_\\"
  }

  script_infos(){
    center "${BGREY}[ Développé par xamayca, pour la communauté France Survival ]${RESET}${JUMP_LINE}"
    center "${BGREY}[ Script Version: $SCRIPT_VERSION ]${RESET}${JUMP_LINE}"
    center "${BWHITE}VISITEZ NOTRE SITE WEB:${RESET}"
    center "${UBLUE}${COMMUNITY_WEBSITE_URL}/${RESET}${JUMP_LINE}"
    center "${BWHITE}CONSULTEZ NOTRE DÉPÔT GITHUB:${RESET}"
    center "${UBLUE}${COMMUNITY_GITHUB_URL}${RESET}${JUMP_LINE}"
    center "${BWHITE}REJOIGNEZ NOTRE COMMUNAUTÉ DISCORD DE JOUEURS FRANÇAIS ARK :${RESET}"
    center "${UBLUE}${COMMUNITY_DISCORD_URL}${RESET}${JUMP_LINE}"
    center "${BWHITE}SUIVEZ-NOUS SUR INSTAGRAM:${RESET}"
    center "${UBLUE}${COMMUNITY_INSTAGRAM_URL}${RESET}${JUMP_LINE}"
    center "${BWHITE}AIMEZ NOTRE PAGE FACEBOOK:${RESET}"
    center "${UBLUE}${COMMUNITY_FACEBOOK_URL}${RESET}${JUMP_LINE}"
  }

  system_infos(){
    if [ "$SHOW_HEADER_SYSTEM_INFO" == "True" ]; then
      center "${BGREY}Système d'exploitation: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2- | tr -d '\"')"
      center "Version du noyau: $(uname -r)"
      center "Architecture du système: $(uname -m)"
      if [ -n "${USER:-}" ]; then
          center "Utilisateur actuel: $USER"
      fi
      center "Hôte actuel: $HOSTNAME"
      center "PID du script: $$"
      center "PID du processus parent: $PPID"
      center "Date et heure actuelles: $(date)"
      center "Utilisation de la mémoire: $(free -h | awk '/^Mem/ {print $3 "/" $2}')"
      center "Utilisation de l'espace disque: $(df -h | awk '$NF=="/"{print $3 "/" $2}')"
      center "Nombre de processeurs: $(nproc)"
      center "Nom du modèle du processeur: $(lscpu | grep '^Model name:' | awk -F: '{$1=""; print $0}' | sed 's/^[ \t]*//')"
      center "Nombre de coeurs par processeur: $(lscpu | grep "Core(s) per socket:" | awk -F: '{$1=""; print $0}' | sed 's/^[ \t]*//')"
      center "Nombre de threads par coeur: $(lscpu | grep 'Thread(s) per core:' | awk -F: '{$1=""; print $0}' | sed 's/^[ \t]*//')"
      center "Fréquence maximale du processeur: $(lscpu | grep 'CPU max MHz:' | awk -F: '{$1=""; print $0}' | sed 's/^[ \t]*//')"
      center "Fréquence minimale du processeur: $(lscpu | grep 'CPU min MHz:' | awk -F: '{$1=""; print $0}' | sed 's/^[ \t]*//')"
      center "Adresse IP V4 publique: $(wget -qO- https://api.ipify.org)"
      center "Adresse IP V4 locale: $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1')"
      center "Adresse MAC: $(ip link | awk '/link\/ether/ {print $2}')${RESET}${JUMP_LINE}"
      center "${BBLUE} LE SCRIPT VA DÉMARRER DANS QUELQUES INSTANTS, VEUILLEZ PATIENTER${BLINK_START}...${BLINK_END}${RESET}${JUMP_LINE}"
    elif [ "$SHOW_HEADER_SYSTEM_INFO" == "False" ]; then
      center "${BBLUE} LE SCRIPT VA DÉMARRER DANS QUELQUES INSTANTS, VEUILLEZ PATIENTER${BLINK_START}...${BLINK_END}${RESET}${JUMP_LINE}"
    fi
  }


  if [ "$1" == "installer" ]; then
    SCRIPT_VERSION="$INSTALLER_SCRIPT_VERSION"
    clear
    installation_script_subtitle
    echo
    script_infos
    system_infos
  elif [ "$1" == "overseer" ]; then
    SCRIPT_VERSION="$OVERSEER_SCRIPT_VERSION"
    clear
    overseer_script_subtitle
    echo
    script_infos
    system_infos
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'APPEL DE LA FONCTION 'script_header'."
    log "DEBUG" "VEUILLEZ FOURNIR UN ARGUMENT VALIDE: 'installer' OU 'overseer'."
    log "DEBUG" "EXEMPLE: script_header installer"
    log "DEBUG" "EXEMPLE: script_header overseer"
    exit 1
  fi

  center "${BRED}ATTENTION, TOUTES MODIFICATIONS APPORTÉES À CE SCRIPT PEUVENT ENTRAÎNER DES DISFONCTIONNEMENTS ET LE RENDRE INUTILISABLE.${RESET}"
  echo
  sleep 3
  system_update
}





