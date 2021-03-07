-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

require("scripts/multi_events")

require("scripts/feature/generic")
require("scripts/feature/movement_generic")
require("scripts/feature/entity_generic")
require("scripts/feature/map_generic")
require("scripts/feature/video")
require("scripts/feature/menus")
require("scripts/feature/audio")
--require("scripts/feature/item_mixer")

require("scripts/meta/game")
require("scripts/meta/char_surface")
require("scripts/meta/string")
require("scripts/meta/hero")
require("scripts/meta/entities")
require("scripts/meta/map")

require("scripts/feature/input_manager")

require("scripts/hud/hud")

require("scripts/menus/dialog_box")
require("scripts/menus/game_menu")
require("scripts/menus/quick_menus/test")

if DEBUG then
    require("scripts/debug/utilities")
    require("scripts/debug/visualizer")
end

return true
