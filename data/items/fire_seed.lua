-- Lua script of item fire_seed.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()
  self:set_savegame_variable("fire_seed_possession")
  --self:set_amount_savegame_variable("fire_seed_amount")
  self:set_assignable(true)
end

-- Event called when the hero starts using this item.
function item:on_using()
  local hero = game:get_hero()
  local x, y, layer = hero:get_position()
  x, y = gen.shift_direction4(x, y, hero:get_direction(), 16)
  local e = game:get_map():create_custom_entity({
    model = "flame",
    direction = 0,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
  })
  item:set_finished()
end

function item:on_pickable_created(pickable)
  
end
