#!/bin/bash
set -euo pipefail

is_user_ssh_authorized_keys_installed(){
  log "LOG" "VÉRIFICATION DE L'EXISTENCE DE SSH AUTHORIZED_KEYS DE L'UTILISATEUR $USER_ACCOUNT SUR $HOSTNAME."
  if [[ -f "/home/$USER_ACCOUNT/.ssh/authorized_keys" ]]; then
    log "OK" "LES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT EXISTENT DÉJÀ SUR $HOSTNAME."
    return 1
  else
    log "WARNING" "LES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT N'EXISTENT PAS SUR $HOSTNAME."
    return 0
  fi
}

copy_public_key_to_authorized_keys(){
  log "LOG" "COPIE DE LA CLÉ PUBLIQUE DE L'UTILISATEUR $USER_ACCOUNT DANS LE FICHIER SSH AUTHORIZED_KEYS SUR $HOSTNAME."
  if sudo cp "/home/$USER_ACCOUNT/.ssh/id_rsa.pub" "/home/$USER_ACCOUNT/.ssh/authorized_keys"; then
    log "SUCCESS" "LA CLÉ PUBLIQUE DE L'UTILISATEUR $USER_ACCOUNT A ÉTÉ COPIÉE DANS LE FICHIER SSH AUTHORIZED_KEYS SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA COPIE DE LA CLÉ PUBLIQUE DE L'UTILISATEUR $USER_ACCOUNT DANS LE FICHIER SSH AUTHORIZED_KEYS SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER DE COPIER LA CLÉ PUBLIQUE MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE :"
    log "DEBUG" "sudo cp /home/$USER_ACCOUNT/.ssh/id_rsa.pub /home/$USER_ACCOUNT/.ssh/authorized_keys"
  fi
}

generate_user_ssh_keys(){
  log "LOG" "GÉNÉRATION DES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT SUR $HOSTNAME."
  if sudo -u "$USER_ACCOUNT" ssh-keygen -t rsa -b 4096 -C "$USER_ACCOUNT@$HOSTNAME" -f "/home/$USER_ACCOUNT/.ssh/id_rsa" -N ""; then
    log "SUCCESS" "LES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT ONT ÉTÉ GÉNÉRÉES SUR $HOSTNAME."

    log "INFO" "CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT :${JUMP_LINE}$(cat "/home/$USER_ACCOUNT/.ssh/id_rsa")"

    log "WARNING" "LA CLÉ PRIVÉE VOUS PERMET DE VOUS CONNECTER À VOTRE SERVEUR ET DOIT ÊTRE PROTÉGÉE."
    log "INFO" "SI VOUS PERDEZ LA CLÉ PRIVÉE, VOUS NE POURREZ PLUS VOUS CONNECTER À VOTRE SERVEUR."
    log "INFO" "IL EST OBLIGATOIRE DE SAUVEGARDER LA CLÉ PRIVÉE DE L'UTILISATEUR $USER_ACCOUNT."
    log "INFO" "VEUILLEZ NE PAS PARTAGER LA CLÉ PRIVÉE AVEC DES PERSONNES NON AUTORISÉES."
    log "ATTENTION" "LES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT SERONT SUPPRIMÉES APRÈS LA CONFIRMATION."

    if prompt enter "APPUYEZ SUR LA TOUCHE [ENTRÉE] POUR VALIDER LA SAUVEGARDE DE LA CLÉ PRIVÉE & LA SUPPRESSION DES CLÉS SSH"; then
      copy_public_key_to_authorized_keys
      permissions chmod ".ssh" "/home/$USER_ACCOUNT/.ssh/" "700"
      permissions chmod "authorized_keys" "/home/$USER_ACCOUNT/.ssh/authorized_keys" "600"
      permissions owner "authorized_keys" "/home/$USER_ACCOUNT/.ssh/authorized_keys" "$USER_ACCOUNT"
      file delete "CLÉS SSH PUBLIQUE: id_rsa.pub" "/home/$USER_ACCOUNT/.ssh/id_rsa.pub"
      file delete "CLÉS SSH PRIVÉES: id_rsa" "/home/$USER_ACCOUNT/.ssh/id_rsa"
    fi

  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA GÉNÉRATION DES CLÉS SSH DE L'UTILISATEUR $USER_ACCOUNT SUR $HOSTNAME."
    log "DEBUG" "VEUILLEZ ESSAYER DE GENERER LES CLÉS SSH MANUELLEMENT A L'AIDE DE LA COMMANDE SUIVANTE :"
    log "DEBUG" "sudo -u $USER_ACCOUNT ssh-keygen -t rsa -b 4096 -C $USER_ACCOUNT@$HOSTNAME -f /home/$USER_ACCOUNT/.ssh/id_rsa -N ''"
  fi
}

user_account_ssh_keys() {

  if is_user_ssh_authorized_keys_installed; then

    generate_user_ssh_keys

  fi

}