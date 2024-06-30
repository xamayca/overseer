#!/bin/bash
set -euo pipefail

help() {
  echo "Usage: overseer [OPTION] [ACTION]"
  echo "Options:"
  echo "  -h, --help                 Affiche l'aide de l'Overseer."
  echo "  -s, --stop                 Arrête le serveur pour une maintenance."
  echo "  -r, --restart [ACTION]     Redémarre le serveur pour une maintenance ou quotidien."
  echo "  -p, --purge [ACTION]       Active ou désactive la purge PVP."
  echo "  -u, --update               Recherche et installe les mises à jour du serveur."
  echo "  -d, --dynamic [DAY]        Active la configuration dynamique pour un jour spécifique"
  echo "  -c, --configure [ACTION]   Configure le serveur pour une action spécifique."
  echo ""
  echo "Actions:"
  echo "  restart maintenance        Redémarre le serveur pour une maintenance (prévention en jeu)."
  echo "  restart daily              Redémarre le serveur pour une maintenance quotidienne (prévention en jeu)."
  echo "  purge start                Active la purge PVP (prévention en jeu)."
  echo "  purge stop                 Désactive la purge PVP (prévention en jeu)."
  echo "  update                     Recherche et installe les mises à jour du serveur (prévention en jeu)."
  echo "  dynamic [DAY]              Active la configuration dynamique pour un jour spécifique (prévention en jeu)."
  echo "  configure web_server       Configure le serveur web nécessaire pour ( Dynamic Config, Cluster, etc.)"
  echo "  configure cluster          Configure le serveur pour le mode cluster."
  echo "  configure dynamic          Configure le serveur pour le mode dynamique."
  echo "  configure task             Configure une tâche automatique pour le serveur."
  echo
  echo "Exemples:"
  echo "  overseer --restart maintenance"
  echo "  overseer --restart daily"
  echo "  overseer --purge start"
  echo "  overseer --purge stop"
  echo "  overseer --update"
  echo "  overseer --dynamic monday"
  echo "  overseer --configure web_server"
  echo "  overseer --configure cluster"
  echo "  overseer --configure dynamic"
  echo "  overseer --configure task"
  echo
}