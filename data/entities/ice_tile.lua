-- Lua script of custom entity ice_tile.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local separator_manager = require("scripts/api/separator_manager")

-- Event called when the custom entity is initialized.

function entity:on_created()
 self:create_sprite("entities/ice_tile")
 separator_manager:destroy_on_separator()
 self:set_modified_ground("traversable")
 self:set_can_traverse_ground("deep_water", true)
 self:set_can_traverse_ground("shallow_water", true)
end
