#!/bin/bash
set -euo pipefail

file_touch() {
  log "LOG" "VÉRIFICATION & CRÉATION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
  if [[ -f "$file_path" ]]; then
    log "OK" "LE FICHIER $file_name EXISTE DÉJÀ SUR $HOSTNAME ET NE PEUT PAS ÊTRE CRÉÉ."
  else
    log "WARNING" "LE FICHIER $file_name N'EXISTE PAS SUR $HOSTNAME ET SERA CRÉÉ."
    log "LOG" "CRÉATION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
    if sudo touch "$file_path"; then
      log "SUCCESS" "LE FICHIER $file_name A ÉTÉ CRÉÉ A L'EMPLACEMENT $file_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ CRÉER MANUELLEMENT LE FICHIER $file_name A L'EMPLACEMENT $file_path A L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo -u $USER_ACCOUNT touch $file_path"
    fi
  fi
}

file_delete() {
  log "LOG" "VÉRIFICATION & SUPPRESSION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
  if [[ ! -f "$file_path" ]]; then
    log "OK" "LE FICHIER $file_name N'EXISTE PAS SUR $HOSTNAME ET NE PEUT PAS ÊTRE SUPPRIMÉ."
  else
    log "WARNING" "LE FICHIER $file_name EXISTE SUR $HOSTNAME ET SERA SUPPRIMÉ."
    log "LOG" "SUPPRESSION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
    if sudo rm -f "$file_path"; then
      log "SUCCESS" "LE FICHIER $file_name A ÉTÉ SUPPRIMÉ A L'EMPLACEMENT $file_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SUPPRESSION DU FICHIER $file_name A L'EMPLACEMENT $file_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ SUPPRIMER MANUELLEMENT LE FICHIER $file_name A L'EMPLACEMENT $file_path A L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo -u $USER_ACCOUNT rm -f $file_path"
    fi
  fi
}

file_copy() {
  log "LOG" "COPIE DU FICHIER $file_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  if sudo cp -r "$file_path" "$target_path"; then
    log "SUCCESS" "COPIE DU FICHIER $file_name RÉUSSIE DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA COPIE DU FICHIER $file_name DANS LE RÉPERTOIRE $target_path DE $USER_ACCOUNT."
    log "DEBUG" "VEUILLEZ COPIER LE FICHIER $file_name DANS LE RÉPERTOIRE $target_path À L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo cp -r $file_path $target_path"
    exit 1
  fi
}

file_move(){
  log "LOG" "VÉRIFICATION & DÉPLACEMENT DU FICHIER $file_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  echo "file_name: $file_name"
  echo "file_path: $file_path"
  echo "target_path: $target_path"
  if [[ -f "$target_path" ]]; then
    log "WARNING" "LE FICHIER $file_name EXISTE DÉJÀ DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    exit 1
  else
    log "LOG" "DÉPLACEMENT DU FICHIER $file_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    if sudo mv -f "$file_path" "$target_path"; then
      log "SUCCESS" "LE FICHIER $file_name A ÉTÉ DÉPLACÉ DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU DÉPLACEMENT DU FICHIER $file_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ DÉPLACER MANUELLEMENT LE FICHIER $file_name DANS LE RÉPERTOIRE $target_path À L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo mv $file_path $target_path"
      exit 1
    fi
  fi
}

file () {
  local action=$1
  local file_name=$2
  local file_path=$3

  case $action in
    touch|delete)
      file_"$action" "$file_name" "$file_path"
      ;;
    copy|move)
      local target_path=$4
      file_"$action" "$file_name" "$file_path" "$target_path"
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNI N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {touch|delete|copy}."
      log "DEBUG" "EXEMPLE: file touch <nom_du_fichier> <chemin_du_fichier>"
      log "DEBUG" "EXEMPLE: file delete <nom_du_fichier> <chemin_du_fichier>"
      log "DEBUG" "EXEMPLE: file copy <nom_du_fichier> <chemin_du_fichier> <chemin_cible>"
  esac
}