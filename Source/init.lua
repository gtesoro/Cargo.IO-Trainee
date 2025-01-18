import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animator"
import "CoreLibs/animation"
import "CoreLibs/math"
import "CoreLibs/crank"
import "CoreLibs/ui"

import "LDtk"

import "data/Constants"
import "data/Static"

import "tools/List"
import "tools/Map"

import "obj/managers/EventManager"
import "obj/managers/SceneManager"
import "obj/managers/NotificationManager"
import "obj/managers/SystemManager"
import "obj/managers/SoundManager"

import "obj/Stateful"
import "obj/items/Items"

import "obj/AnimatedSprite"
import "obj/Masker"
import "obj/TextBox"

import "obj/contracts/contracts"

import "ui/fuel"

import "obj/Planet"
import "obj/Ship"
import "obj/Enemy"
import "obj/Particle"

import "obj/UI/Widget"
import "scenes/Scene"

import "obj/UI/ItemPanel"
import "obj/UI/ItemPanelShop"
import "obj/UI/ListBox"
import "obj/UI/GridBox"
import "obj/UI/Codex"


import "scenes/tools/Snapshot"
import "scenes/MiningLaser"
import "scenes/systems/System"
import "scenes/systems/EmptySystem"
import "scenes/systems/AsteroidSystem"
import "scenes/systems/PlanetSystem"
import "scenes/systems/StageSystem"

import "scenes/menus/GenericMenu"
import "scenes/menus/GenericInventory"
import "scenes/menus/PlayerMenu"
import "scenes/menus/Map"
import "scenes/menus/LocationMenu"
import "scenes/menus/Popup"
import "scenes/menus/TextViewer"
import "scenes/menus/ImageViewer"
import "scenes/menus/Intro"
import "scenes/menus/GameOver"
import "scenes/menus/LoadoutMenu"
import "scenes/menus/InventoryPopup"

import "scenes/facilities/Facilities"

import "transitions/HorizontalWipe"
import "transitions/Unstack"
import "transitions/Stack"
import "transitions/ToMenu"
import "transitions/OutMenu"
import "transitions/BetweenMenus"

import "tools/tools"

lorem_ipsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."