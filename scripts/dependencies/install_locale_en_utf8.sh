#!/bin/bash
set -euo pipefail

is_locale_en_utf8_present(){
  log "LOG" "VÉRIFICATION & INSTALLATION DE LA LOCALE EN_US.UTF-8 SUR $HOSTNAME."
  if locale -a | grep -iq '^en_US\.utf8$'; then
    log "OK" "LA LOCALE EN_US.UTF-8 EST DÉJÀ AJOUTÉE SUR $HOSTNAME."
    return 1
  else
    log "WARNING" "LA LOCALE EN_US.UTF-8 N'EST PAS AJOUTÉE SUR $HOSTNAME."
    return 0
  fi
}

uncomment_locale_in_gen(){
  log "LOG" "VÉRIFICATION & DÉCOMMENTAIRE DE LA LOCALE EN_US.UTF-8 DANS LE FICHIER /etc/locale.gen SUR $HOSTNAME."
  if sudo grep -q '^# *en_US.UTF-8 UTF-8' /etc/locale.gen; then
    uncomment_locale
  else
    log "OK" "LA LOCALE EN_US.UTF-8 EST DÉJÀ DÉCOMMENTÉE DANS LE FICHIER /etc/locale.gen SUR $HOSTNAME."
  fi
}

uncomment_locale(){
  log "WARNING" "LA LOCALE EN_US.UTF-8 EST COMMENTÉE DANS LE FICHIER /etc/locale.gen."
  if sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; then
    log "SUCCESS" "LA LOCALE EN_US.UTF-8 A ÉTÉ DÉCOMMENTÉE DANS LE FICHIER /etc/locale.gen."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU DÉCOMMENTAIRE DE LA LOCALE EN_US.UTF-8 DANS LE FICHIER /etc/locale.gen SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER DE DÉCOMMENTER LA LOCALE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen"
    exit 1
  fi
}

generate_locale(){
  log "LOG" "GÉNÉRATION DE LA LOCALE EN_US.UTF-8 SUR $HOSTNAME."
  if sudo locale-gen en_US.UTF-8; then
    log "SUCCESS" "LA LOCALE EN_US.UTF-8 A ÉTÉ GÉNÉRÉE SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA GÉNÉRATION DE LA LOCALE EN_US.UTF-8 SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER DE GÉNÉRER LA LOCALE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo locale-gen en_US.UTF-8"
    exit 1
  fi
}

update_locale(){
  log "LOG" "MISE À JOUR DE LA LOCALE EN_US.UTF-8 SUR $HOSTNAME."
  if sudo update-locale; then
    log "SUCCESS" "LA LOCALE EN_US.UTF-8 A ÉTÉ MISE À JOUR SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA MISE À JOUR DE LA LOCALE EN_US.UTF-8 SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER DE METTRE À JOUR LA LOCALE MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo update-locale"
    exit 1
  fi
}

install_locale_en_utf8(){
  if is_locale_en_utf8_present; then
    uncomment_locale_in_gen
    generate_locale
    update_locale
  fi
}