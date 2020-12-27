-- Lua script of map donjons/level_05/ss4.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local camera = map:get_camera()
local flash = require("scripts/api/visual_effects").flash



-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  self:init_dungeon_features()


  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()


  --camera:get_surface():set_shader(game.shaders.obscurity)
  --game.shaders.obscurity:set_uniform("obs_level", 1.5)
  --game.shaders.obscurity:set_uniform("n_lights", 1)
  --game.shaders.obscurity:set_uniform("light1", {80, 80, 60, 20})
end
