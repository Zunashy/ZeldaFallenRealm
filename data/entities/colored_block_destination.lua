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
    local i = 1
    for t in torchs:fields(";") do
      entity.linked_torchs[i] = map:get_entity(t)
      i = i + 1
    end
  end

  self.is_CBD = true
  self.notify_on_separator = true
end

function entity:set_torchs_color(color)
  for _, torch in ipairs(self.linked_torchs) do
    torch:set_enabled(true)
    torch:get_sprite():set_animation(color)
  end
end

function entity:disable_torchs()
  for _, torch in ipairs(self.linked_torchs) do
    torch:set_enabled(false)
  end
end

function entity:on_separator_activated()
  self:disable_torchs()
end 
