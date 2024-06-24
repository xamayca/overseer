#!/bin/bash
set -euo pipefail

install_32_bit_arch(){

  log "LOG" "VÉRIFICATION & ACTIVATION DE L'ARCHITECTURE 32 BITS SUR $HOSTNAME."
  if dpkg --print-foreign-architectures | grep -q "i386"; then
    log "OK" "L'ARCHITECTURE 32 BITS EST DÉJÀ ACTIVÉE SUR $HOSTNAME."
  else
    log "WARNING" "L'ARCHITECTURE 32 BITS N'EST PAS ACTIVÉE SUR $HOSTNAME."
    if dpkg --add-architecture i386; then
      log "SUCCESS" "L'ARCHITECTURE 32 BITS A ÉTÉ ACTIVÉE SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE L'ACTIVATION DE L'ARCHITECTURE 32 BITS SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ VÉRIFIER LE JOURNAL AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "cat /var/log/dpkg.log"
      log "DEBUG" "OU ACTIVER L'ARCHITECTURE 32 BITS MANUELLEMENT AVEC LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo dpkg --add-architecture i386"
      exit 1
    fi
  fi

}