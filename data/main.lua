-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

local loading_surface = sol.surface.create("menus/loading.png")
local loading_menu = {
  on_draw = function(self, dst_surface)
    loading_surface:draw(dst_surface)
  end
}
sol.menu.start(sol.main, loading_menu)
require("scripts/features")

local game_manager = require("scripts/game_manager")
local start_initial_menus = require("scripts/menus/initial_menus_manager")
local settings_manager = require ("scripts/api/settings")
local controls_manager = require("scripts/api/controls_manager")
--require("scripts/sinking_override")

local default_save_file = "save1.dat"

-- This function is called when Solarus starts.
-- It is the real entry point of the game.
function sol.main:on_started()
  settings_manager:load()
  controls_manager:load()
  sol.audio.preload_sounds()
  -- Setting a language is useful to display text and dialogs.
  sol.menu.stop(loading_menu)
  start_initial_menus()
end

-- Event called when the program stops.
function sol.main:on_finished()
  settings_manager:save()
  controls_manager:save()
end
