-- Lua script of custom entity breakable_pillar.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local top_entity

-- Event called when the custom entity is initialized.
function entity:on_created()
  sprite = self:get_sprite() or self:create_sprite("entities/destructible/pillar_base")

  local x, y, layer = self:get_position()
  top_entity = map:create_custom_entity({
    direction = 0,
    x = x,
    y = y,
    layer = layer + 1,
    width = 16,
    height = 32,
    sprite = "entities/destructible/pillar_top"
  })

  self:set_traversable_by(false)

end

function entity:on_explosion(bomb)
  print("exploded")
  local angle = bomb:get_angle(self)
  local direction = 0

  top_entity:remove()
  self:set_traversable_by(true)

  sprite:set_animation("falling", function()
    sprite:set_animation("fallen")
    local x, y, layer = self:get_position()
    x, y = gen.shift_direction4(x, y, direction, 32)

    map:create_destructible({
      x = x,
      y = y,
      layer = layer,
      sprite = "entities/destructible/pillar_fragment",
      weight = 1,
      ground = "wall"
    })
  end)
  sprite:set_direction(direction)


end