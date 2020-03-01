-- Lua script of custom entity merman_wave.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = game:get_hero()

local damage = 1

local function hit_hero()
  game:remove_life(damage)
  local m = sol.movement.create("straight")
  m:set_angle(3 * math.pi / 2)
  m:set_speed(240)
  m:set_max_distance(400)
  function m:on_obstacle_reached()
    m:stop()
    if m.freeze_cancel_timer:get_remaining_time() > 0 then
      m.freeze_cancel_timer:stop()
    end
    hero:unfreeze()
  end

  m.freeze_cancel_timer = sol.timer.start(entity, 600, function()
    hero:unfreeze()
    m:start(hero)
  end)

  hero:freeze()
  m:start(hero)
end



-- Event called when the custom entity is initialized.
function entity:on_created()
  self:set_can_traverse_ground("shallow_water", true)
  self:set_can_traverse_ground("deep_water", true)

  self:create_sprite("enemies/boss/merman_wave")
  local m = sol.movement.create("straight")
  m:set_angle(3 * math.pi / 2)
  m:set_speed(96)
  function m:on_obstacle_reached()
    m:stop()
    entity:remove()
  end
  m:start(self)
end

function entity:on_position_changed(x, y, layer)  
  if entity:overlaps(hero) then
    hit_hero()
    entity:remove()
  end    
end