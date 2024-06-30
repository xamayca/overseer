#!/bin/bash
set -euo pipefail

install_command_line() {

  log "LOG" "GÉNÉRATION DE LA LIGNE DE COMMANDE POUR LE LANCEMENT DU SERVEUR SUR $HOSTNAME."

  QUERY_PARAMS=""
  FLAG_PARAMS=""

  # Tableau de paramètres avec ? + valeur
  local query_params=(
    "Map=$MAP_NAME"
    "SessionName=$SERVER_NAME"
    "ServerPassword=$SERVER_PASSWORD"
    "Port=$GAME_PORT"
    "RCONEnabled=$RCON_ENABLED"
    "RCONPort=$RCON_PORT"
    "ServerPVE=$SERVER_PVE"
    "PreventOfflinePvP=$PREVENT_OFFLINE_PVP"
    "PreventOfflinePvPInterval=$PREVENT_OFFLINE_PVP_INTERVAL"
    "ClampItemStats=$CLAMP_ITEM_STATS"
    "DayCycleSpeedScale=$DAY_CYCLE_SPEED_SCALE"
    "DayTimeSpeedScale=$DAY_TIME_SPEED_SCALE"
    "NightTimeSpeedScale=$NIGHT_TIME_SPEED_SCALE"
    "CustomRecipeEffectivenessMultiplier=$CUSTOM_RECIPE_EFFECTIVENESS_MULTIPLIER"
    "CustomRecipeSkillMultiplier=$CUSTOM_RECIPE_SKILL_MULTIPLIER"
    "DontAlwaysNotifyPlayerJoined=$DONT_ALWAYS_NOTIFY_PLAYER_JOINED"
    "AlwaysNotifyPlayerLeft=$ALWAYS_NOTIFY_PLAYER_LEFT"
    "PreventTribeAlliances=$PREVENT_TRIBE_ALLIANCES"
    "AllowHideDamageSourceFromlogs=$ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS"
    "TribeLogDestroyedEnemyStructures=$TRIBE_LOG_DESTROYED_ENEMY_STRUCTURES"
    "OverrideOfficialDifficulty=$OVERRIDE_OFFICIAL_DIFFICULTY"
    "DifficultyOffset=$DIFFICULTY_OFFSET"
    "ServerCrosshair=$SERVER_CROSSHAIR"
    "PreventSpawnAnimations=$PREVENT_SPAWN_ANIMATION"
    "RandomSupplyCratePoints=$RANDOM_SUPPLY_CRATE_POINTS"
    "ShowFloatingDamageText=$SHOW_FLOATING_DAMAGE_TEXT"
    "ShowMapPlayerLocation=$SHOW_MAP_PLAYER_LOCATION"
    "AllowHitMarkers=$ALLOW_HIT_MARKERS"
    "AllowThirdPersonPlayer=$ALLOW_THIRD_PERSON_PLAYER"
    "AllowFlyerCarryPvE=$ALLOW_FLYER_CARRY_PVE"
    "AllowRaidDinoFeeding=$ALLOW_RAID_DINO_FEEDING"
    "AlwaysAllowStructurePickup=$ALWAYS_ALLOW_STRUCTURE_PICKUP"
    "ForceAllStructureLocking=$FORCE_ALL_STRUCTURE_LOCKING"
    "StructurePreventResourceRadiusMultiplier=$STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER"
    "ResourceNoReplenishRadiusPlayers=$RESOURCE_NO_REPLENISH_RADIUS_PLAYERS"
    "ResourcesRespawnPeriodMultiplier=$RESOURCES_RESPAWN_PERIOD_MULTIPLIER"
    "OverrideStructurePlatformPrevention=$OVERRIDE_STRUCTURE_PLATFORM_PREVENTION"
    "AllowCaveBuildingPvE=$ALLOW_CAVE_BUILDING_PVE"
    "AllowCaveBuildingPvP=$ALLOW_CAVE_BUILDING_PVP"
    "EnableExtraStructurePreventionVolumes=$ENABLE_EXTRA_STRUCTURE_PREVENTION_VOLUMES"
    "TheMaxStructuresInRange=$THE_MAX_STRUCTURES_IN_RANGE"
    "PvEAllowStructuresAtSupplyDrops=$PVE_ALLOW_STRUCTURES_AT_SUPPLY_DROPS"
    "PerPlatformMaxStructuresMultiplier=$PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER"
    "PlatformSaddleBuildAreaBoundsMultiplier=$PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER"
    "TamingSpeedMultiplier=$TAMING_SPEED_MULTIPLIER"
    "HarvestAmountMultiplier=$HARVEST_AMOUNT_MULTIPLIER"
    "CropGrowthSpeedMultiplier=$CROP_GROWTH_SPEED_MULTIPLIER"
    "XPMultiplier=$XP_MULTIPLIER"
    "CraftXPMultiplier=$CRAFT_XP_MULTIPLIER"
    "GenericXPMultiplier=$GENERIC_XP_MULTIPLIER"
    "KillXPMultiplier=$KILL_XP_MULTIPLIER"
    "SpecialXPMultiplier=$SPECIAL_XP_MULTIPLIER"
    "BabyCuddleGracePeriodMultiplier=$BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER"
    "BabyCuddleIntervalMultiplier=$BABY_CUDDLE_INTERVAL_MULTIPLIER"
    "BabyImprintAmountMultiplier=$BABY_IMPRINT_AMOUNT_MULTIPLIER"
    "BabyImprintingStatScaleMultiplier=$BABY_IMPRINTING_STAT_SCALE_MULTIPLIER"
    "BabyMatureSpeedMultiplier=$BABY_MATURE_SPEED_MULTIPLIER"
    "EggHatchSpeedMultiplier=$EGG_HATCH_SPEED_MULTIPLIER"
    "MatingIntervalMultiplier=$MATING_INTERVAL_MULTIPLIER"
    "MatingSpeedMultiplier=$MATING_SPEED_MULTIPLIER"
    "AllowAnyoneBabyImprintCuddle=$ALLOW_ANYONE_BABY_IMPRINT_CUDDLE"
    "ItemStackSizeMultiplier=$ITEM_STACK_SIZE_MULTIPLIER"
    "PlayerCharacterWaterDrainMultiplier=$PLAYER_CHARACTER_WATER_DRAIN_MULTIPLIER"
    "PlayerCharacterFoodDrainMultiplier=$PLAYER_CHARACTER_FOOD_DRAIN_MULTIPLIER"
    "PlayerCharacterStaminaDrainMultiplier=$PLAYER_CHARACTER_STAMINA_DRAIN_MULTIPLIER"
    "PlayerCharacterHealthRecoveryMultiplier=$PLAYER_CHARACTER_HEALTH_RECOVERY_MULTIPLIER"
    "PlayerDamageMultiplier=$PLAYER_DAMAGE_MULTIPLIER"
    "PlayerResistanceMultiplier=$PLAYER_RESISTANCE_MULTIPLIER"
    "RaidDinoCharacterFoodDrainMultiplier=$RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER"
    "GlobalItemDecompositionTimeMultiplier=$GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER"
    "PreventDownloadSurvivors=$PREVENT_DOWNLOAD_SURVIVORS"
    "PreventDownloadItems=$PREVENT_DOWNLOAD_ITEMS"
    "PreventDownloadDinos=$PREVENT_DOWNLOAD_DINOS"
    "PreventUploadSurvivors=$PREVENT_UPLOAD_SURVIVORS"
    "PreventUploadItems=$PREVENT_UPLOAD_ITEMS"
    "PreventUploadDinos=$PREVENT_UPLOAD_DINOS"
    "NoTributeDownloads=$NO_TRIBUTE_DOWNLOADS"
    "DinoCharacterFoodDrainMultiplier=$DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER"
    "DinoCharacterStaminaDrainMultiplier=$DINO_CHARACTER_STAMINA_DRAIN_MULTIPLIER"
    "DinoCharacterHealthRecoveryMultiplier=$DINO_CHARACTER_HEALTH_RECOVERY_MULTIPLIER"
    "DinoDamageMultiplier=$DINO_DAMAGE_MULTIPLIER"
    "DinoResistanceMultiplier=$DINO_RESISTANCE_MULTIPLIER"
    "MaxTamedDinos=$MAX_TAMED_DINOS"
    "EventColorsChanceOverride=$EVENT_COLORS_CHANCE_OVERRIDE"
    "ServerAdminPassword=$SERVER_ADMIN_PASSWORD"
  )

  # Tableau de paramètres avec - + valeur
  local flag_params=(
    "WinLiveMaxPlayers=$WIN_LIVE_MAX_PLAYERS"
    "passivemods=$PASSIVE_MODS"
    "mods=$MODS"
  )

  # Tableau de paramètres - (Yes) ou vide (No)
  local simple_flag_params=(
    "NoTransferFromFiltering=$NO_TRANSFER_FROM_FILTERING"
    "NoWildBabies=$NO_WILD_BABIES"
    "ForceRespawnDinos=$FORCE_RESPAWN_DINOS"
    "ForceAllowCaveFlyers=$FORCE_ALLOW_CAVE_FLYERS"
    "NoDinos=$NO_DINOS"
    "EasterColors=$EASTER_COLORS"
    "NoBattlEye=$NO_BATTLE_EYE"
    "UseServerNetSpeedCheck=$USE_SERVER_NET_SPEED_CHECK"
    "nosound=$NO_SOUND"
    "onethread=$ONE_THREAD"
    "noperfthreads=$NO_PERF_THREADS"
    "forceuseperfthreads=$FORCE_USE_PERF_THREADS"
    "NoAI=$NO_AI"
    "ForceDupeLog=$FORCE_DUPE_LOG"
    "ignoredupeditems=$IGNORE_DUPED_ITEMS"
    "disableCharacterTracker=$DISABLE_CHARACTER_TRACKER"
    "UnstasisDinoObstructionCheck=$UNSTASIS_DINO_OBSTRUCTION_CHECK"
  )

  # Ajout des paramètres avec ? + valeur
  for param in "${query_params[@]}"; do
    query_param="${param%%=*}"
    query_value="${param#*=}"
    if [ -n "$query_value" ]; then
      if [ "$query_param" == "Map" ]; then
        QUERY_PARAMS+="$query_value"
      else
        QUERY_PARAMS+="?$query_param=$query_value"
      fi
    fi
  done

  # Ajout des paramètres avec - + valeur
  for param in "${flag_params[@]}"; do
    flag_param="${param%%=*}"
    flag_value="${param#*=}"
    if [ -n "$flag_value" ]; then
      FLAG_PARAMS+=" -${flag_param}=${flag_value}"
    fi
  done

  # Ajout des paramètres - (Yes) ou vide (No)
  for param in "${simple_flag_params[@]}"; do
    simple_flag_param="${param%%=*}"
    simple_flag_value="${param#*=}"
    if [ "$simple_flag_value" == "Yes" ]; then
      FLAG_PARAMS+=" -${simple_flag_param}"
    fi
  done

  log "SUCCESS" "LIGNE DE COMMANDE GÉNÉRÉE POUR LE LANCEMENT DU SERVEUR SUR $HOSTNAME."
  log "INFO" "LIGNE DE COMMANDE DU SERVEUR:${JUMP_LINE}${JUMP_LINE}$QUERY_PARAMS$FLAG_PARAMS"

}
