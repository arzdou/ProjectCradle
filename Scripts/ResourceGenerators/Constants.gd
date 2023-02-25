# Resource to manage and keep all ingame constants
extends Resource
class_name CONSTANTS

enum MOUNT_SIZES {MAIN, HEAVY, AUX, MAIN_AUX, FLEX, SUPERHEAVY, INTEGRATED}
enum WEAPON_SIZE {AUX, MAIN, HEAVY, SUPERHEAVY}
enum WEAPON_TYPES {RIFLE, MELEE, CANNON, LAUNCHER, NEXUS, CQB}
enum WEAPON_RANGE_TYPES {RANGE, LINE, CONE, BLAST, BURST, THREAT}
enum DAMAGE_TYPES {KINETIC, EXPLOSIVE, ENERGY, BURN, HEAT}

enum ACTION_TYPES {WEAPON, TECH, MOVEMENT, MISC}

enum UOVERLAY_CELLS {MOVEMENT, MARKED, DAMAGE}

enum STATUS {DANGER_ZONE, ENGAGED, EXPOSED, HIDDEN, INVISIBLE, PRONE, SHUT_DOWN}
enum CONDITIONS {IMMOBILIZED, IMPAIRED, JAMMED, LOCKED_ON, SHREDDED, SLOWED, STUNNED}

enum BOARD_STATE {FREE, MOVEMENT, SELECTING, ACTING}

enum ACTIVATION_TYPE {FREE, PROTOCOL, QUICK, FULL, INVADE, FULL_TECH, QUICK_TECH, REACTION, OTHER}
