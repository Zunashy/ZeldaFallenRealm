-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

sol.features = {}

require("scripts/multi_events")

require("scripts/hud/hud")

require("scripts/feature/generic")
require("scripts/feature/movement_generic")
require("scripts/feature/entity_generic")
require("scripts/feature/map_generic")
require("scripts/feature/video")
require("scripts/feature/menus")

require("scripts/meta/char_surface")
require("scripts/meta/string")
require("scripts/meta/hero")
require("scripts/meta/entities")
require("scripts/meta/game")
require("scripts/meta/map")

require("scripts/menus/dialog_box")
require("scripts/menus/game_menu")

require("scripts/debug/utilities")

return true
