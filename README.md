# GUIDE D'INSTALLATION D'UN SERVEUR ARK: SURVIVAL ASCENDED LINUX

## ⚠️ __ATTENTION__ ⚠️
- VOUS NE POUVEZ MODIFIER QUE LE FICHIER `CONFIG.CFG` POUR CONFIGURER VOTRE SERVEUR
- TOUTES AUTRES MODIFICATIONS EST A VOS RISQUES & PERILS
- EN PLUS DE RENDRE L'ENSEMBLE DE CET OUTILS NON FONCTIONNEL

## ETAPE I - SE CONNECTER AU FTP DE VOTRE SYSTEME LINUX :

### 1 - CONFIGURATION DE LA CONNEXION SSH AVEC PUTTY :
> - `Générer une clé SSH` pour se connecter au conteneur avec [PuTTYgen](https://www.putty.org/).
> - Sauvegarder la `clé privée` et la `clé publique` dans un dossier ou vous pourrez les `retrouver`.
> - Lancer [PuTTY](https://www.putty.org/).
> - Rentrer l'adresse `IP` de votre `conteneur`.
> - Connection type: `SSH`.
> - Ensuite dans le panneau de gauche cliquer sur `Auth` puis `Credentials`.
> - Cliquer sur `Browse` pour `ajouter la clé privée` générée avec [PuTTYgen](https://www.putty.org/).
> - Maintenant cliquer sur **Open** pour vous connecter à votre conteneur.
> - Entrer le `nom d'utilisateur (root)` et la `passphrase` que vous avez `défini lors de la création de la clé SSH` avec [PuTTYgen](https://www.putty.org/).
> - Félicitation vous êtes `connecté` à votre conteneur `LXC Debian 12`.

### 2 - CONFIGURATION DE LA CONNEXION SFTP AVEC FILEZILLA :
> - Ouvrez [FileZilla](https://filezilla-project.org/).
> - Rentrer `l'adresse IP` de votre conteneur.
> - Connection type: `SFTP SSH File Transfer Protocol`.
> - Type d'authentification: `Clé privée`.

## ETAPE II - INSTALLATION DU SERVEUR ARK: SURVIVAL ASCENDED :
> > **Ouvez le fichier `FRANCESURVIVAL.sh` avec votre éditeur et `modifier les variables` en fonction de `votre configuration`📝.**
> - `Se connecter en SSH` à votre conteneur `LXC Debian 12`.
> - **Copier** le contenu du fichier `FRANCESURVIVAL.sh` dans votre conteneur.
> - Rendre le script exécutable avec la commande `chmod +x FRANCESURVIVAL.sh`.
> - Exécuter le script avec la commande `./FRANCESURVIVAL.sh`.
> - Suivre les instructions du script pour `installer le serveur ARK: Survival Ascended`.
> - Félicitation votre serveur ARK: Survival Ascended est `installé et configuré` sur votre conteneur `LXC Debian 12`.

## ETAPE III - MAINTENAANCE DU SERVEUR ARK: SURVIVAL ASCENDED :
> - Rendez vous dans le répertoire maintenance creé par le script d'installation.
> - `cd /home/YOURUSERACCOUNT/maintenance`.
> - Ouvrez un terminal a ce niveau pour pouvoir executez les commandes suivantes:
> > - `./management.sh auto_update` (Recherche de mise à jour & redémarrage du serveur si nécessaire).
> > - `./management.sh daily_restart` (Redémarrage quotidien du serveur).
> > - `./management.sh purge_start` (Démarrage de la purge PVP).
> > - `./management.sh purge_stop` (Arrêt de la purge PVP).
> > - `./management.sh dynamic_monday` (Activation de la configuration dynamique du lundi).
> > - `./management.sh dynamic_tuesday` (Activation de la configuration dynamique du mardi).
> > - `./management.sh dynamic_wednesday` (Activation de la configuration dynamique du mercredi).
> > - `./management.sh dynamic_thursday` (Activation de la configuration dynamique du jeudi).
> > - `./management.sh dynamic_friday` (Activation de la configuration dynamique du vendredi).
> > - `./management.sh dynamic_saturday` (Activation de la configuration dynamique du samedi).
> > - `./management.sh dynamic_sunday` (Activation de la configuration dynamique du dimanche).
