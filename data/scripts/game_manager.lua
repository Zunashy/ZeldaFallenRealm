-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local initial_game = require("scripts/initial_game")

local game_manager = {}

function game_manager:init_game(game) --initializes the runtime-specific properties of a game
  game:set_transition_style("immediate")
  game.HUD_height = 16
  return game
end

function game_manager:load(file) --create a game object and initalizes it
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  self:init_game(game)
  game.initialized = exists
  return game
end

game_manager.initialize_new_savegame = initial_game.initialize_new_savegame

function game_manager:start_game(game)
  if not game.initialized then
    game_manager:initialize_new_savegame(game)
  end
  game:start()
end

return game_manager