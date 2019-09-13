-- Lua script of custom entity deep_water.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()

  -- Initialize the properties of your custom entity here,
  -- like the sprite, the size, and whether it can traverse other
  -- entities and be traversed by them.
  entity:set_size(16, 16)
  entity:set_origin(8, 13)
  entity:set_traversable_by(true)
  -- On charge le sprite normal et celui affiché en cas de gel
  entity:create_sprite("entities/deep_water", "deep_water")
  entity:create_sprite("entities/ice_floor", "ice_floor")
  -- On met en avant plan le sprite normal
  entity:bring_sprite_to_front(entity:get_sprite("deep_water"))
  entity:set_modified_ground("deep_water")
  -- On indique que cette entitée est de l'eau profonde qu'on peut geler
  entity.is_deep_water = true
  entity.is_frozen = false
end
