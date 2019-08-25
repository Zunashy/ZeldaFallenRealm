-- Lua script of enemy octorok.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Quelques paramètres
local walking_time = 700 --ms
local idle_time = 700 --ms
local firing_time = 50 --ms
local chance_to_throw = 30 --%
local speed = 40



-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(2)
  enemy:set_damage(2)
  mg.initialize_state(enemy, speed)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  -- Création du mouvement ciblé sur le héro
  mg.target_hero(enemy)
  -- On le laisse marcher un certain temps
  sol.timer.start(enemy, walking_time, idle)
end

function idle()
  -- Puis on l'arrête
  mg.stop_movement(enemy)
  sprite:set_animation("stopped")
  -- Soit on lance un caillou
  if math.random(100) < chance_to_throw then
    sol.timer.start(enemy, idle_time/2, function()
      sprite:set_animation("firing")
      sol.timer.start(enemy,firing_time,throw_rock)
    end)
  else -- Soit on recommence la séquence
    sol.timer.start(enemy, idle_time, function()
      enemy:restart()
    end)
  end
end

function throw_rock()
  -- Pour lancer un caillou, on prépare toutes les propriétés de l'entitée custom
  local properties = {}
  properties.model = "octorok_rock"
  properties.x, properties.y, properties.layer = enemy:get_position()
  properties.y = properties.y - 5
  properties.width = 16
  properties.height = 16
  properties.direction = sprite:get_direction()
  -- Puis on la crée
  map:create_custom_entity(properties)
  sprite:set_animation("stopped")
  -- On recommence la séquence
  sol.timer.start(enemy, idle_time/2 - firing_time, function()
    enemy:restart()
  end)
end

function enemy:on_movement_changed(movement)
  -- Mise à jour de la direction du sprite en fonction de la direction du mouvement
  local direction4 = movement:get_direction4()
  sprite:set_direction(direction4)
end
