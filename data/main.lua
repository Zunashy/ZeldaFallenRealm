-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")

local game_manager = require("scripts/game_manager")
local start_initial_menus = require("scripts/menus/initial_menus_manager")
local settings_manager = require ("scripts/managers/settings")
--require("scripts/sinking_override")

local default_save_file = "save1.dat"

-- Starts a game.
function sol.main:start_game(file)
  local game = game_manager:create(file)

  sol.main.game = game
  game:start()
end

-- This function is called when Solarus starts.
-- It is the real entry point of the game.
function sol.main:on_started()
  sol.language.set_language("en")
  --settings_manager:load()
  sol.audio.preload_sounds()
  -- Setting a language is useful to display text and dialogs.
  
  start_initial_menus(function() sol.main:start_game(default_save_file) end)
end

-- Event called when the program stops.
function sol.main:on_finished()
  --settings_manager:save()
end
