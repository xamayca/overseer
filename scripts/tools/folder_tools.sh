#!/bin/bash
set -euo pipefail

folder_create() {
  log "LOG" "VÉRIFICATION & CRÉATION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
  if [[ -d "$folder_path" ]]; then
    log "WARNING" "LE DOSSIER $folder_name EXISTE DÉJÀ SUR $HOSTNAME ET NE PEUT PAS ÊTRE CRÉÉ."
  else
    log "WARNING" "LE DOSSIER $folder_name N'EXISTE PAS SUR $HOSTNAME ET SERA CRÉÉ."
    log "LOG" "CRÉATION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
    if sudo mkdir -p -m "$permission" "$folder_path"; then
      log "SUCCESS" "LE DOSSIER $folder_name A ÉTÉ CRÉÉ A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA CRÉATION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ CRÉER MANUELLEMENT LE DOSSIER $folder_name A L'EMPLACEMENT $folder_path A L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo -u $USER_ACCOUNT mkdir -p $folder_path"
    fi
  fi
}

folder_delete() {
  log "LOG" "VÉRIFICATION & SUPPRESSION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
  if [[ ! -d "$folder_path" ]]; then
    log "WARNING" "LE DOSSIER $folder_name N'EXISTE PAS SUR $HOSTNAME ET NE PEUT PAS ÊTRE SUPPRIMÉ."
  else
    log "WARNING" "LE DOSSIER $folder_name EXISTE SUR $HOSTNAME ET SERA SUPPRIMÉ."
    log "LOG" "SUPPRESSION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
    if sudo rm -rf "$folder_path"; then
      log "SUCCESS" "LE DOSSIER $folder_name A ÉTÉ SUPPRIMÉ A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA SUPPRESSION DU DOSSIER $folder_name A L'EMPLACEMENT $folder_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ SUPPRIMER MANUELLEMENT LE DOSSIER $folder_name A L'EMPLACEMENT $folder_path A L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo -u $USER_ACCOUNT rm -rf $folder_path"
    fi
  fi
}

folder_copy() {
  log "LOG" "COPIE DU DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  if sudo cp -r "$folder_path" "$target_path"; then
    log "SUCCESS" "COPIE DU DOSSIER $folder_name RÉUSSIE DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  else
    log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DE LA COPIE DU DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path DE $USER_ACCOUNT."
    log "DEBUG" "VEUILLEZ COPIER LE DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path À L'AIDE DE LA COMMANDE SUIVANTE:"
    log "DEBUG" "sudo cp -r $folder_path $target_path"
    exit 1
  fi
}

folder_move() {
  log "LOG" "VÉRIFICATION & DÉPLACEMENT DU DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
  if [[ -d "$target_path" ]]; then
    log "WARNING" "LE DOSSIER $folder_name EXISTE DÉJÀ DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    exit 1
  else
    log "LOG" "DÉPLACEMENT DU DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    if sudo mv -f "$folder_path" "$target_path"; then
      log "SUCCESS" "LE DOSSIER $folder_name A ÉTÉ DÉPLACÉ DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
    else
      log "ERROR" "UNE ERREUR S'EST PRODUITE LORS DU DÉPLACEMENT DU DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path SUR $HOSTNAME."
      log "DEBUG" "VEUILLEZ DÉPLACER MANUELLEMENT LE DOSSIER $folder_name DANS LE RÉPERTOIRE $target_path À L'AIDE DE LA COMMANDE SUIVANTE :"
      log "DEBUG" "sudo mv $folder_path $target_path"
      exit 1
    fi
  fi
}

folder () {
  local action=$1
  local folder_name=$2
  local folder_path=$3

  case $action in
    create)
      local permission=$4
      folder_create "$folder_name" "$folder_path" "$permission"
      ;;
    delete)
      folder_delete "$folder_name" "$folder_path"
      ;;
    copy|move)
      local target_path=$4
      folder_"$action" "$folder_name" "$folder_path" "$target_path"
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {create|delete|copy}."
      log "DEBUG" "EXEMPLE: folder create <nom_dossier> <chemin_dossier> <permission>"
      log "DEBUG" "EXEMPLE: folder delete <nom_dossier> <chemin_dossier>"
      log "DEBUG" "EXEMPLE: folder copy <nom_dossier> <chemin_dossier> <chemin_cible>"
      exit 1
    esac
}
