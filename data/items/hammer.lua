-- Lua script of item hammer.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()
local hero = game:get_hero()

function item:on_created()
  self:set_savegame_variable("possession_hammer")
  self:set_assignable(true)
end 

-- Event called when all items have been created.
function item:on_started()
  local hero = item:get_map():get_entity("hero")

  -- Initialize the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
end

-- Event called when the hero starts using this item.
function item:on_using()

  -- Define here what happens when using this item
  -- and call item:set_finished() to release the hero when you have finished.
  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end

function item:on_obtained()
  self:set_variant(1)
end
