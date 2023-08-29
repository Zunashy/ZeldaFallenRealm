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

  entity:set_drawn_in_y_order(true)

  self:set_traversable_by(false)

end

local function calc_knockback_angle_h(e, y)
  local _, ey = e:get_position()
  return ey < y and math.pi / 2 or math.pi * 1.5
end

local function calc_knockback_angle_v(e, x)
  local ex = e:get_position()
  return ex > x and 0 or math.pi
end

function entity:on_explosion(bomb)
  if self.fallen then return end
  print("exploded")
  self.fallen = true

  local angle = bomb:get_angle(self)
  local direction = 0

  top_entity:remove()
  self:set_traversable_by(true)

  sprite:set_animation("falling", function()
    sprite:set_animation("fallen")
    entity:set_drawn_in_y_order(false)
    entity:bring_to_back()

    local x, y, layer = self:get_position()

    local ox, oy = sprite:get_origin()

    local rx = x - ox - (direction == 2 and 32 or 0)
    local ry = y - oy - (direction == 1 and 32 or 0)
    local rw = direction % 2 == 0 and 48 or 16
    local rh = direction % 2 == 1 and 48 or 16
    for e in map:get_entities_in_rectangle(rx, ry, rw, rh) do
      if (e:get_type() == "hero") then
        local kb_angle = direction % 2 == 0 and calc_knockback_angle_h(e, y) or calc_knockback_angle_v(e, x)
        e:start_hurt(entity, 1)

        local movement = e:get_movement()
        if movement and movement.set_angle then
            movement:set_angle(kb_angle)
            movement:set_ignore_obstacles(true)
        end

      elseif (e:get_type() == "enemy") then
        local kb_angle = direction % 2 == 0 and calc_knockback_angle_h(e, y) or calc_knockback_angle_v(e, x)

        e:hurt(1)
        local kb = sol.movement.create("straight")
        kb:set_speed(160)
        kb:set_max_distance(16)
        kb:set_angle(kb_angle)
        kb:start(e)
      end
    end


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