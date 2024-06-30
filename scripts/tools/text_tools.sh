#!/bin/bash
set -euo pipefail

center() {

    if [[ $# -ne 1 ]]; then
        log "ERROR" "LA FONCTION center REQUIERT UN ARGUMENT UNIQUE."
        log "DEBUG" "EXEMPLE: center <texte>"
        return 1
    fi

    COLUMNS=$(tput cols)

    declare input="${1}" filler out no_ansi_out
    no_ansi_out="$(echo -e "${input}" | sed 's/\x1b\[[0-9;]*m//g')"
    declare -i str_len=${#no_ansi_out}
    declare -i filler_len="$(((COLUMNS - str_len) / 2))"

    [[ $filler_len -lt 0 ]] && printf "%s${JUMP_LINE}" "${input}" && return 0

    filler="$(printf "%${filler_len}s")"
    out="${filler}${input}${filler}"
    printf "%s${JUMP_LINE}" "$(echo -e "${out}")"

    return 0
}