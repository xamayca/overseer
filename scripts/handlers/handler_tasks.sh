#!/bin/bash
set -euo pipefail

set_environment_variable(){
  local var_name="$1"
  local var_value="$2"
  log "LOG" "VÉRIFICATION & AJOUT DE LA VARIABLE $var_name DANS LA CRONTAB DE $USER_ACCOUNT."
  if sudo -u "$USER_ACCOUNT" crontab -l | grep -q "$var_name=$var_value"; then
    log "OK" "LA VARIABLE $var_name EST DÉFINIE DANS LA CRONTAB DE $USER_ACCOUNT."
  else
    log "WARNING" "LA VARIABLE $var_name N'EST PAS DÉFINIE DANS LA CRONTAB DE $USER_ACCOUNT."
    log "LOG" "AJOUT DE LA VARIABLE $var_name DANS LA CRONTAB DE $USER_ACCOUNT."
    if sudo -u "$USER_ACCOUNT" crontab -l | { cat; echo "$var_name=$var_value"; } | sudo -u "$USER_ACCOUNT" crontab -; then
      log "SUCCESS" "VARIABLE $var_name AJOUTÉE AVEC SUCCÈS DANS LA CRONTAB DE $USER_ACCOUNT."
    else
      log "ERROR" "ERREUR LORS DE L'AJOUT DE LA VARIABLE $var_name DANS LA CRONTAB DE $USER_ACCOUNT."
      log "DEBUG" "VÉRIFIEZ SI LA VARIABLE $var_name EST DÉFINIE DANS LA CRONTAB DE $USER_ACCOUNT A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo -u $USER_ACCOUNT crontab -l"
    fi
  fi
}

new_cron_task_create(){
  local new_cron_task="$task_minute $task_hour $task_day_of_month $task_month $task_day $OVERSEER_SCRIPT_FILE $task_function >> $CRONTAB_LOG_FILE 2>&1 # $task_name - $task_description"

  log "LOG" "VÉRIFICATION & AJOUT DE LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE DANS LA CRONTAB DE $USER_ACCOUNT."
  if sudo -u "$USER_ACCOUNT" crontab -l | grep -Fxq "$new_cron_task"; then
    log "OK" "LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE EXISTE DÉJÀ DANS LA CRONTAB DE $USER_ACCOUNT."
    log "INFO" "VOICI LA TÂCHE PLANIFIÉE EXISTANTE: $new_cron_task"
  else
    log "WARNING" " LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE N'EXISTE PAS DANS LA CRONTAB DE $USER_ACCOUNT."
    log "LOG" "AJOUT DE LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE DANS LA CRONTAB DE $USER_ACCOUNT."
    if sudo -u "$USER_ACCOUNT" crontab -l | { cat; echo "$new_cron_task"; } | sudo -u "$USER_ACCOUNT" crontab -; then
      log "SUCCESS" "TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE AJOUTÉE AVEC SUCCÈS DANS LA CRONTAB DE $USER_ACCOUNT."
      log "INFO" "VOICI LA TÂCHE PLANIFIÉE AJOUTÉE: $new_cron_task"
    else
      log "ERROR" "ERREUR LORS DE L'AJOUT DE LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE DANS LA CRONTAB DE $USER_ACCOUNT."
      log "DEBUG" "VÉRIFIEZ SI LA TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE EST BIEN AJOUTÉE DANS LA CRONTAB A L'AIDE DE LA COMMANDE SUIVANTE:"
      log "DEBUG" "sudo -u $USER_ACCOUNT crontab -l"
    fi
  fi
}

create_scheduled_task(){
  if prompt_confirm "VOULEZ VOUS CRÉER UNE TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE? [Oui/Non]"; then
    log "OVERSEER" "CRÉATION D'UNE TÂCHE PLANIFIÉE POUR LE SERVEUR $ARK_SERVER_SERVICE."
    log "INFO" "POUR CRÉER UNE TÂCHE PLANIFIÉE, VEUILLEZ RÉPONDRE AUX QUESTIONS SUIVANTES."
    log "QUESTION" "QUEL NOM VOULEZ VOUS DONNER À LA TÂCHE PLANIFIÉE?" task_name
    if read -r task_name; then
      log "QUESTION" "QUELLE EST LA DESCRIPTION DE LA TÂCHE PLANIFIÉE?"
      if read -r task_description; then
        log "QUESTION" "QUELLE EST LA MINUTE DE LA TÂCHE PLANIFIÉE? (0-59)"
        log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUTES LES MINUTES, VEUILLEZ SAISIR *."
        log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUTES LES 5 MINUTES, VEUILLEZ SAISIR */5."
        log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUTES LES 10 MINUTES, VEUILLEZ SAISIR */10."
        log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUTES LES 15 MINUTES, VEUILLEZ SAISIR */15."
        if read -r task_minute; then
          log "QUESTION" "QUELLE EST L'HEURE DE LA TÂCHE PLANIFIÉE? (0-23)"
          log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUTES LES HEURES, VEUILLEZ SAISIR *."
          if read -r task_hour; then
            log "QUESTION" "QUEL JOUR DU MOIS POUR LA TÂCHE PLANIFIÉE? (1-31)"
            log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUS LES JOURS DU MOIS, VEUILLEZ SAISIR *."
            log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUS LES JOURS DE LA SEMAINE, VEUILLEZ SAISIR ?."
            if read -r task_day_of_month; then
              log "QUESTION" "QUEL MOIS POUR LA TÂCHE PLANIFIÉE? (1-12)"
              log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUS LES MOIS, VEUILLEZ SAISIR *."
              if read -r task_month; then
                log "QUESTION" "QUEL JOUR DE LA SEMAINE POUR LA TÂCHE PLANIFIÉE? (0-6) (0 POUR DIMANCHE)"
                log "INFO" "POUR PLANIFIÉ UNE TÂCHE TOUS LES JOURS DE LA SEMAINE, VEUILLEZ SAISIR *."
                if read -r task_day; then
                  log "QUESTION" "QUELLE FONCTION DE TÂCHE PLANIFIÉE VOULEZ-VOUS EXÉCUTER?"
                  log "INFO" "VEUILLEZ SÉLECTIONNER UNE OPTION DANS LA LISTE SUIVANTE:"
                  log "INFO" "1) overseer --purge start - Purge PVP Start"
                  log "INFO" "2) overseer --purge stop - Purge PVP Stop"
                  log "INFO" "3) overseer --server start - Server Start"
                  log "INFO" "4) overseer --server stop - Server Stop"
                  log "INFO" "5) overseer --server restart - Server Restart"
                  log "INFO" "6) overseer --server update - Server Update"
                  log "INFO" "7) overseer --dynamic monday - Dynamic Config Monday"
                  log "INFO" "8) overseer --dynamic tuesday - Dynamic Config Tuesday"
                  log "INFO" "9) overseer --dynamic wednesday - Dynamic Config Wednesday"
                  log "INFO" "10) overseer --dynamic thursday - Dynamic Config Thursday"
                  log "INFO" "11) overseer --dynamic friday - Dynamic Config Friday"
                  log "INFO" "12) overseer --dynamic saturday - Dynamic Config Saturday"
                  log "INFO" "13) overseer --dynamic sunday - Dynamic Config Sunday"
                    options=("overseer --purge start" "overseer --purge stop" "overseer --server start" "overseer --server stop" "overseer --server restart" "overseer --server update" "overseer --dynamic monday" "overseer --dynamic tuesday" "overseer --dynamic wednesday" "overseer --dynamic thursday" "overseer --dynamic friday" "overseer --dynamic saturday" "overseer --dynamic sunday" "Quit")
                    select task_function in "${options[@]}"; do
                      if [[ " ${options[*]} " == *" $task_function "* ]]; then
                        set_environment_variable "TERM" "xterm-256color"
                        set_environment_variable "SHELL" "/bin/bash"
                        set_environment_variable "PATH" "/sbin:/bin:/usr/sbin:/usr/bin"
                        new_cron_task_create
                        break
                      elif [[ "$task_function" == "Quit" ]]; then
                        log "OVERSEER" "LA TÂCHE PLANIFIÉE POUR LE SERVEUR: $SERVER_SERVICE_NAME N'A PAS ÉTÉ CRÉÉE."
                        exit 0
                      else
                        log "ERROR" "CHOIX INVALIDE. VEUILLEZ SÉLECTIONNER UNE OPTION VALIDE."
                        log "DEBUG" "VEUILLEZ SÉLECTIONNER UNE OPTION VALIDE DANS LA LISTE SUIVANTE:"
                        log "DEBUG" "1) overseer --purge start"
                        log "DEBUG" "2) overseer --purge stop"
                        log "DEBUG" "3) overseer --server start"
                        log "DEBUG" "4) overseer --server stop"
                        log "DEBUG" "5) overseer --server restart"
                        log "DEBUG" "6) overseer --server update"
                        log "DEBUG" "7) overseer --dynamic monday"
                        log "DEBUG" "8) overseer --dynamic tuesday"
                        log "DEBUG" "9) overseer --dynamic wednesday"
                        log "DEBUG" "10) overseer --dynamic thursday"
                        log "DEBUG" "11) overseer --dynamic friday"
                        log "DEBUG" "12) overseer --dynamic saturday"
                        log "DEBUG" "13) overseer --dynamic sunday"
                        log "DEBUG" "14) Quit"
                      fi
                    done
                else
                  log "ERROR" "LA JOUR DE LA SEMAINE N'EST PAS VALIDE."
                  log "DEBUG" "VEUILLEZ FOURNIR UN JOUR DE LA SEMAINE VALIDE: (0-6) (0 POUR DIMANCHE)"
                fi
              else
                log "ERROR" "LE MOIS N'EST PAS VALIDE."
                log "DEBUG" "VEUILLEZ FOURNIR UN MOIS VALIDE: (1-12)"
              fi
            else
              log "ERROR" "LE JOUR DU MOIS N'EST PAS VALIDE."
              log "DEBUG" "VEUILLEZ FOURNIR UN JOUR DU MOIS VALIDE: (1-31)"
            fi
          else
            log "ERROR" "L'HEURE N'EST PAS VALIDE."
            log "DEBUG" "VEUILLEZ FOURNIR UNE HEURE VALIDE: (0-23)"
          fi
        else
          log "ERROR" "LA MINUTE N'EST PAS VALIDE."
          log "DEBUG" "VEUILLEZ FOURNIR UNE MINUTE VALIDE: (0-59)"
        fi
      else
        log "ERROR" "LA DESCRIPTION DE LA TÂCHE PLANIFIÉE EST REQUISE."
        log "DEBUG" "VEUILLEZ FOURNIR UNE DESCRIPTION POUR LA TÂCHE PLANIFIÉE."
      fi
    else
      log "ERROR" "LE NOM DE LA TÂCHE PLANIFIÉE EST REQUIS."
      log "DEBUG" "VEUILLEZ FOURNIR UN NOM POUR LA TÂCHE PLANIFIÉE."
    fi
  else
    log "OVERSEER" "CRÉATION DE LA TÂCHE PLANIFIÉE ANNULÉE POUR LE SERVEUR $ARK_SERVER_SERVICE SUR $HOSTNAME."
  fi
}


task(){
  local action=$1

  case "$action" in
    create)
      create_scheduled_task
      ;;
    *)
      log "ERROR" "L'ACTION $action QUE VOUS AVEZ FOURNIE N'EST PAS PRISE EN CHARGE."
      log "DEBUG" "VEUILLEZ FOURNIR UNE ACTION VALIDE: {create}"
      log "DEBUG" "EXEMPLE: task create"
  esac
}





