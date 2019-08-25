-- Lua script of custom entity arrow.
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
  entity:set_size(8,16)
  entity:set_origin(4,8)
  local sprite = entity:create_sprite("entities/bone")
  
  init_traversable()

    -- Création du mouvement
  movement = sol.movement.create("straight")
  movement:set_speed(200)
  movement:set_smooth(false)
  -- Angle en radian à partir de la direction (0-3)
  movement:set_angle(math.pi / 2 * entity:get_direction())
  movement:start(entity)
end

function init_traversable()
  -- Comme le caillou vole, il passe au dessus des murets et sols spéciaux
  entity:set_can_traverse_ground("low_wall", true)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("shallow_water", true)
  entity:set_can_traverse_ground("grass", true)
  entity:set_can_traverse_ground("hole", true)
  entity:set_can_traverse_ground("prickles", true)
  entity:set_can_traverse_ground("lava", true)
end

function entity:on_obstacle_reached(movement)
  --animation de la flèche qui tourne avant de depop
  entity:remove()
end

function entity:set_hurts_hero()
  function entity:on_position_changed(x, y, layer)  
    local hero = map:get_hero()  
    if entity:overlaps(hero) then
      -- TODO : ajouter la gestion du bouclier quand il y en aura un
      hero:start_hurt(entity, 2)
      -- TODO : Jouer un son, rajouter une animation de pierre qui se casse
      entity:remove()
    end    
  end
end

function entity:set_hurts_ennemies()
  entity:add_collision_test("overlapping", function(arrow,other)
    if (other:get_type() == "enemy") then other:hurt(1) ; entity:remove() end
  end)
end