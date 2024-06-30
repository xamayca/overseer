#!/bin/bash
set -euo pipefail

log(){
  local type="$1"
  local message="$2"
  local color
  local emoji

  case $type in
    "DEBUG") color="${BGREY}"; emoji="💾" ;;  # Bold grey
    "LOG") color="${BCYAN}"; emoji="📝" ;;  # Bold white
    "SUCCESS"|"OK") color="${BGREEN}"; emoji="✅" ;;  # Bold green
    "WARNING") color="${BYELLOW}"; emoji="${BLINK_START}❗${BLINK_END}" ;;  # Bold yellow
    "ERROR") color="${BRED}"; emoji="❌" ;;  # Bold red
    "ATTENTION") color="${BRED}"; emoji="⚠️" ;;  # Bold red
    "INFO") color="${BBLUE}"; emoji="📌" ;;  # Bold blue
    "QUESTION") color="${BMAGENTA}"; emoji="❓" ;;  # Bold magenta
    "OVERSEER") color="${BMAGENTA}"; emoji="🤖" ;;  # Bold magenta
    *) color="${BCYAN}"; emoji="" ;;  # Bold cyan
  esac

  send_log "[${emoji}${type}] ${message}" "${color}"
}

send_log() {
    local message="$1"
    local color="$2"

    local terminal_width
    terminal_width=$(tput cols)

    local separator_line="${BGREY}"
    # Pour chaque colonne de la console, ajoute un tiret gris
    for ((i = 0; i < terminal_width; i++)); do
        separator_line="${separator_line}-"
    done

    separator_line="${separator_line}${RESET}"

    # Affiche le message dans la console
    echo -e "${separator_line}"
    echo -e "${color} ${message}${RESET}"
    echo -e "${separator_line}"
}