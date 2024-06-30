#!/bin/bash
set -euo pipefail

# [ ARK: Server Configuration ]
MAP_NAME="TheIsland_WP"
SERVER_NAME="PROTONARK1"
GAME_PORT="7777"
SERVER_PASSWORD=""
SERVER_ADMIN_PASSWORD="YOURADMINPASSWORDHERE"
RCON_ENABLED="True"
RCON_PORT="11640"
WIN_LIVE_MAX_PLAYERS="30"
SERVER_PLATFORM="ALL"
CULTURE="en"
NO_BATTLE_EYE=""
USE_SERVER_NET_SPEED_CHECK="Yes"

# MODS="984026 JERBOA ELEMENT FRANCE SURVIVAL"

# [ ARK: Server Mods Configuration ]
MODS="984026"
PASSIVE_MODS=""

# [ ARK: Server World Configuration ]
OVERRIDE_OFFICIAL_DIFFICULTY="5"
DIFFICULTY_OFFSET="1"
DINO_COUNT_MULTIPLIER="1"
SERVER_CROSSHAIR="True"
PREVENT_SPAWN_ANIMATION="True"
RANDOM_SUPPLY_CRATE_POINTS="True"
SHOW_FLOATING_DAMAGE_TEXT="True"
SHOW_MAP_PLAYER_LOCATION="True"
ALLOW_HIT_MARKERS="True"
ALLOW_THIRD_PERSON_PLAYER="True"
ALLOW_FLYER_CARRY_PVE="True"
ALLOW_RAID_DINO_FEEDING="True"
RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER="1"
GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER="2"
GLOBAL_SPOILING_TIME_MULTIPLIER="1"

# [ ARK: Cluster Configuration ]
NFS_IP_ADDRESS="192.168.1.5"
NFS_FOLDER_DIR="/volume1/CLUSTER-PVE"
CLUSTER_DIR_OVERRIDE="/home/overseer/cluster"
MULTIHOME="192.168.1.105"
CLUSTER_ID="FRANCESURVIVALSERVERSPVECLUSTER"

# [ ARK: Cluster Transfer Configuration ]
PREVENT_DOWNLOAD_SURVIVORS="False"
PREVENT_DOWNLOAD_ITEMS="False"
PREVENT_DOWNLOAD_DINOS="False"
PREVENT_UPLOAD_DINOS="False"
PREVENT_UPLOAD_ITEMS="False"
PREVENT_UPLOAD_SURVIVORS="False"
NO_TRIBUTE_DOWNLOADS="False"
NO_TRANSFER_FROM_FILTERING="Yes"

# [ ARK: Rates Configuration ]
TAMING_SPEED_MULTIPLIER="3"
HARVEST_AMOUNT_MULTIPLIER="3"
CROP_GROWTH_SPEED_MULTIPLIER="3"
XP_MULTIPLIER="3"
CRAFT_XP_MULTIPLIER="3"
GENERIC_XP_MULTIPLIER="3"
KILL_XP_MULTIPLIER="3"
SPECIAL_XP_MULTIPLIER="3"

# [ ARK: Baby Configuration ]
BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER="1"
BABY_CUDDLE_INTERVAL_MULTIPLIER="0.07"
BABY_IMPRINT_AMOUNT_MULTIPLIER="3"
BABY_IMPRINTING_STAT_SCALE_MULTIPLIER="1"
BABY_MATURE_SPEED_MULTIPLIER="20"
EGG_HATCH_SPEED_MULTIPLIER="3"
MATING_INTERVAL_MULTIPLIER="0.125"
MATING_SPEED_MULTIPLIER="1"
ALLOW_ANYONE_BABY_IMPRINT_CUDDLE="True"
NO_WILD_BABIES=""

# [ ARK: Player Configuration ]
SERVER_PVE="True"
PREVENT_OFFLINE_PVP="True"
PREVENT_OFFLINE_PVP_INTERVAL="60"
CLAMP_ITEM_STATS="False"
DAY_CYCLE_SPEED_SCALE="0.5"
DAY_TIME_SPEED_SCALE="1"
NIGHT_TIME_SPEED_SCALE="1"

# [ ARK: Recipe Configuration ]
CUSTOM_RECIPE_EFFECTIVENESS_MULTIPLIER="1"
CUSTOM_RECIPE_SKILL_MULTIPLIER="1"

# [ ARK: Notifications Configuration ]
DONT_ALWAYS_NOTIFY_PLAYER_JOINED="False"
ALWAYS_NOTIFY_PLAYER_LEFT="True"

# [ ARK: Tribe Configuration ]
PREVENT_TRIBE_ALLIANCES="False"
ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS="False"
TRIBE_LOG_DESTROYED_ENEMY_STRUCTURES="True"

# [ ARK: Structure Configuration ]
ALWAYS_ALLOW_STRUCTURE_PICKUP="True"
FORCE_ALL_STRUCTURE_LOCKING="True"
STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER="1"
RESOURCE_NO_REPLENISH_RADIUS_PLAYERS="1"
RESOURCES_RESPAWN_PERIOD_MULTIPLIER="1"
OVERRIDE_STRUCTURE_PLATFORM_PREVENTION="True"
ALLOW_CAVE_BUILDING_PVE="False"
ALLOW_CAVE_BUILDING_PVP="True"
ENABLE_EXTRA_STRUCTURE_PREVENTION_VOLUMES="True"
THE_MAX_STRUCTURES_IN_RANGE="10000"
PVE_ALLOW_STRUCTURES_AT_SUPPLY_DROPS="True"
PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER="1"
PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER="10000"

# [ ARK: Configuration ]
ITEM_STACK_SIZE_MULTIPLIER="2"
PLAYER_CHARACTER_WATER_DRAIN_MULTIPLIER="0.5"
PLAYER_CHARACTER_FOOD_DRAIN_MULTIPLIER="0.5"
PLAYER_CHARACTER_STAMINA_DRAIN_MULTIPLIER="1"
PLAYER_CHARACTER_HEALTH_RECOVERY_MULTIPLIER="1"
PLAYER_DAMAGE_MULTIPLIER="1"
PLAYER_RESISTANCE_MULTIPLIER="1"

# [ ARK: Configuration ]
DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER="1"
DINO_CHARACTER_STAMINA_DRAIN_MULTIPLIER="1"
DINO_CHARACTER_HEALTH_RECOVERY_MULTIPLIER="1"
DINO_DAMAGE_MULTIPLIER="1"
DINO_RESISTANCE_MULTIPLIER="1"
MAX_PERSONAL_TAMED_DINOS="100"
MAX_TAMED_DINOS="5000"
FORCE_RESPAWN_DINOS="Yes"
FORCE_ALLOW_CAVE_FLYERS=""
NO_DINOS=""
EASTER_COLORS=""
EVENT_COLORS_CHANCE_OVERRIDE="1"

# [ ARK: TEST Environment Configuration ]
NO_SOUND=""
ONE_THREAD=""
NO_PERF_THREADS=""
FORCE_USE_PERF_THREADS=""
NO_AI=""
FORCE_DUPE_LOG=""
IGNORE_DUPED_ITEMS=""
DISABLE_CHARACTER_TRACKER=""
UNSTASIS_DINO_OBSTRUCTION_CHECK="Yes"