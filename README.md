# GUIDE D'INSTALLATION D'UN SERVEUR ARK: SURVIVAL ASCENDED LINUX

## ⚠️ __ATTENTION__ ⚠️
- VOUS NE POUVEZ MODIFIER QUE LE FICHIER `CONFIG.CFG` POUR CONFIGURER VOTRE SERVEUR
- TOUTES AUTRES MODIFICATIONS EST A VOS RISQUES & PERILS
- EN PLUS DE RENDRE L'ENSEMBLE DE CET OUTILS NON FONCTIONNEL

## ETAPE I - INSTALLATION DES DEPENDANCES, DE L'UTILISATEUR & DU SERVEUR ARK: SURVIVAL ASCENDED :
> - #### Rendez vous dans le répertoire de l'outil overseer.
> - #### `cd /home/root/<NOM_DU_REPERTOIRE>`.
> - #### Ouvrez un terminal a ce niveau pour pouvoir executez les commandes suivantes:
> - #### `chmod +x overseer.sh` pour rendre le script exécutable.
> - #### `./overseer.sh` pour lancer le script d'installation.

## ⚠️ __ATTENTION__ ⚠️
> - #### Suivez les instructions du script d'installation, vous serez invité à:
> - #### Copier la clé SSH générée pour l'utilisateur administrateur du serveur ARK: Survival Ascended.
> - #### Confirmé la sauvegarde de la clé SSH et laissez le script d'installation continuer.

## ETAPE II - MAINTENAANCE DU SERVEUR ARK: SURVIVAL ASCENDED :
> - Rendez vous dans le répertoire maintenance creé par le script d'installation.
> - `cd /home/overseer/OverseerManager`.
> - Ouvrez un terminal a ce niveau pour pouvoir executez les commandes suivantes:
> > - #### `overseer --version` pour voir la version de l'outil.
> > - #### `overseer --help` pour voir les commandes disponibles.
> > - #### `overseer --server start` pour démarrer le serveur.
> > - #### `overseer --server stop` pour arrêter le serveur.
> > - #### `overseer --server restart` pour redémarrer le serveur.
> > - #### `overseer --server update` pour mettre à jour le serveur.
> > - #### `overseer --server edit` pour éditer le fichier de configuration.
> > - #### `overseer --server backup` pour sauvegarder le serveur.
> > - #### `overseer --purge start` pour démarrer la purge PVP.
> > - #### `overseer --purge stop` pour arrêter la purge PVP.
> > - #### `overseer --dynamic monday` pour activer la configuration dnyamique du lundi.
> > - #### `overseer --dynamic tuesday` pour activer la configuration dnyamique du mardi.
> > - #### `overseer --dynamic wednesday` pour activer la configuration dnyamique du mercredi.
> > - #### `overseer --dynamic thursday` pour activer la configuration dnyamique du jeudi.
> > - #### `overseer --dynamic friday` pour activer la configuration dnyamique du vendredi.
> > - #### `overseer --dynamic saturday` pour activer la configuration dnyamique du samedi.
> > - #### `overseer --dynamic sunday` pour activer la configuration dnyamique du dimanche.
> > - #### `overseer --configure web-server` pour configurer le serveur web.
> > - #### `overseer --configure cluster` pour configurer le cluster.
> > - #### `overseer --configure dynamic` pour configurer la configuration dynamique.
> > - #### `overseer --configure admin-list` pour configurer la liste des administrateurs.
> > - #### `overseer --task create` pour créer une tâche planifiée.
