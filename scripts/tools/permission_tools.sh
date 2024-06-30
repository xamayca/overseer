#!/bin/bash
set -euo pipefail

permissions_executable(){
  log "LOG" "ACTIVATION DES PERMISSIONS D'EXÉCUTION DU SCRIPT $file_name POUR L'UTILISATEUR $USER_ACCOUNT."
  if sudo chmod +x "$path"; then
    log "SUCCESS" "LE SCRIPT $file_name EST MAINTENANT EXÉCUTABLE POUR L'UTILISATEUR $USER_ACCOUNT."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU RENDU EXÉCUTABLE DU SCRIPT $path POUR L'UTILISATEUR $USER_ACCOUNT."
    log "DEBUG" "VEUILLEZ RENDRE EXÉCUTABLE LE SCRIPT $path POUR L'UTILISATEUR $USER_ACCOUNT À L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo -u $USER_ACCOUNT chmod +x $path"
    exit 1
  fi
}

permissions_chmod() {
  log "LOG" "VÉRIFICATION & MODIFICATION DES PERMISSIONS DE $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
  if [[ $(stat -c "%a" "$path") == "$permissions" ]]; then
    log "OK" "LES PERMISSIONS DE $file_name DANS $path SONT DÉJÀ CORRECTES POUR L'UTILISATEUR $USER_ACCOUNT."
  else
    log "WARNING" "LES PERMISSIONS DE $file_name DANS $path NE SONT PAS CORRECTES POUR L'UTILISATEUR $USER_ACCOUNT."
    log "LOG" "MODIFICATION DES PERMISSIONS DE $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
    if sudo chmod "$permissions" "$path"; then
      log "SUCCESS" "LES PERMISSIONS DE $file_name DANS $path ONT ÉTÉ MODIFIÉES POUR L'UTILISATEUR $USER_ACCOUNT."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA MODIFICATION DES PERMISSIONS DE $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
      log "DEBUG" "VEUILLEZ ESSAYER DE MODIFIER MANUELLEMENT LES PERMISSIONS DE $file_name À L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo chmod $permissions $path"
      exit 1
    fi
  fi
}

permissions_owner(){
  log "LOG" "VÉRIFICATION & MODIFICATION DU PROPRIÉTAIRE DE $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
  if [[ $(stat -c "%U" "$path") == "$owner" ]]; then
    log "OK" "LE PROPRIÉTAIRE DU FICHIER $file_name DANS $path EST DÉJÀ CORRECT POUR L'UTILISATEUR $USER_ACCOUNT."
  else
    log "WARNING" "LE PROPRIÉTAIRE DU FICHIER $file_name DANS $path N'EST PAS CORRECT POUR L'UTILISATEUR $USER_ACCOUNT."
    log "LOG" "MODIFICATION DU PROPRIÉTAIRE DU FICHIER $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
    if sudo chown -R "$owner:$owner" "$path"; then
      log "SUCCESS" "LE PROPRIÉTAIRE DU FICHIER $file_name DANS $path A ÉTÉ MODIFIÉ POUR L'UTILISATEUR $USER_ACCOUNT."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA MODIFICATION DU PROPRIÉTAIRE DU FICHIER $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT."
      log "DEBUG" "VEUILLEZ MODIFIER MANUELLEMENT LE PROPRIÉTAIRE DU FICHIER $file_name DANS $path POUR L'UTILISATEUR $USER_ACCOUNT À L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo chown $owner:$owner $path"
      exit 1
    fi
  fi
}

permissions(){
  local action=$1
  local file_name=$2
  local path=$3

  case $action in

    executable)
      permissions_executable "$file_name" "$path"
      ;;
    chmod)
      local permissions=$4
      permissions_chmod "$file_name" "$path" "$permissions"
      ;;
    owner)
      local owner=$4
      permissions_owner "$file_name" "$path" "$owner"
      ;;

    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {executable|chmod|owner}"
      log "DEBUG" "EXEMPLE: permissions executable <nom_du_fichier> <chemin_du_fichier>"
      log "DEBUG" "EXEMPLE: permissions chmod <nom_du_fichier> <chemin_du_fichier> <permissions>"
      log "DEBUG" "EXEMPLE: permissions owner <nom_du_fichier> <chemin_du_fichier> <propriétaire>"
      exit 1
  esac

}
