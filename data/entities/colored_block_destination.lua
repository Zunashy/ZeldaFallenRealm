-- Lua script of custom entity colored_block_destination.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

entity.linked_torchs = {}

function entity:on_created()
  local torchs = self:get_property("torchs")
  if torchs then
    for t in torchs:fields(";") do
      entity.linked_torchs[t] = true
    end
  end
end
