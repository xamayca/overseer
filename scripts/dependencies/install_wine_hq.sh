#!/bin/bash
set -euo pipefail

is_wine_hq_installed(){
  log "LOG" "VÉRIFICATION DE L'INSTALLATION DU PAQUET WINE HQ STABLE SUR $HOSTNAME."
  if dpkg -s wine-stable &> /dev/null; then
    log "OK" "LE PAQUET WINE HQ STABLE EST INSTALLÉ SUR $HOSTNAME."$
    return 1
  else
    log "WARNING" "LE PAQUET WINE HQ STABLE N'EST PAS INSTALLÉ SUR $HOSTNAME."
    return 0
  fi
}

check_debian_version(){
  log "LOG" "VÉRIFICATION & VALIDATION DE LA VERSION DE DEBIAN SUR $HOSTNAME."
  if debian_version=$(grep -oP '(?<=VERSION=").*(?=")' /etc/os-release) && [ "$debian_version" == "12 (bookworm)" ]; then
    log "OK" "LA VERSION DE DEBIAN SUR $HOSTNAME EST ${debian_version^^}."
  else
    log "ERROR" "LA VERSION DE DEBIAN SUR $HOSTNAME N'EST PAS BOOKWORM."
    log "DEBUG" "VEUILLEZ METTRE À JOUR VOTRE SYSTÈME VERS DEBIAN BOOKWORM AVANT D'INSTALLER WINE HQ STABLE."
    log "DEBUG" "VEUILLEZ CONSULTER LE LIEN SUIVANT POUR PLUS D'INFORMATIONS: https://wiki.debian.org/DebianBookworm"
    exit 1
  fi
}

check_wine_apt_keys(){
  log "LOG" "VÉRIFICATION & TÉLÉCHARGEMENT DE LA CLÉ WINE HQ STABLE SUR $HOSTNAME."
  if [[ -f /etc/apt/keyrings/winehq-archive.key ]]; then
    log "OK" "LA CLÉ WINE HQ STABLE EST DÉJÀ AJOUTÉE SUR $HOSTNAME."
  else
    log "WARNING" "LA CLÉ WINE HQ STABLE N'EST PAS ENCORE AJOUTÉE SUR $HOSTNAME."
    if sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key; then
      log "SUCCESS" "LA CLÉ WINE HQ STABLE A ÉTÉ TÉLÉCHARGÉE ET AJOUTÉE SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU TÉLÉCHARGEMENT ET DE L'AJOUT DE LA CLÉ WINE HQ STABLE."
      log "DEBUG" "VEUILLEZ AJOUTER LA CLÉ WINE HQ STABLE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key"
      exit 1
    fi
  fi
}

check_sources_list(){
  log "LOG" "VÉRIFICATION & TÉLÉCHARGEMENT DU FICHIER SOURCES.LIST POUR WINE HQ STABLE SUR $HOSTNAME."
  if [[ -f /etc/apt/sources.list.d/winehq-bookworm.sources ]]; then
    log "OK" "LE FICHIER SOURCES.LIST POUR WINE HQ STABLE EST DÉJÀ EXISTANT SUR $HOSTNAME."
  else
    log "WARNING" "LE FICHIER SOURCES.LIST POUR WINE HQ STABLE N'EST PAS ENCORE EXISTANT SUR $HOSTNAME."
    if sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources; then
      log "SUCCESS" "LE FICHIER SOURCES.LIST POUR WINE HQ STABLE A ÉTÉ TÉLÉCHARGÉ ET AJOUTÉ SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU TÉLÉCHARGEMENT ET DE L'AJOUT DU FICHIER SOURCES.LIST POUR WINE HQ STABLE."
      log "DEBUG" "VEUILLEZ AJOUTER LE FICHIER SOURCES.LIST POUR WINE HQ STABLE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources"
      exit 1
    fi
  fi
}

wine_hq_install(){
  log "LOG" "INSTALLATION DU PAQUET WINE HQ STABLE SUR $HOSTNAME."
  if sudo apt-get install --install-recommends winehq-stable -y; then
    log "OK" "LE PAQUET WINE HQ STABLE A ÉTÉ INSTALLÉ SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'INSTALLATION DU PAQUET WINE HQ STABLE SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ RÉESSAYER OU INSTALLER LE PAQUET WINE HQ STABLE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo apt-get install --install-recommends winehq-stable -y"
    exit 1
  fi
}

install_wine_hq(){
  if is_wine_hq_installed; then
    check_debian_version
    check_wine_apt_keys
    check_sources_list
    system_update
    wine_hq_install
  fi
}