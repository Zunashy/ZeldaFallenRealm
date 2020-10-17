-- Lua script of enemy crab.
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
local m = sol.movement.create("straight")
local tested_dirs

enemy.jump = mg.start_jumping
enemy.get_corner_position = eg.get_corner_position

local sword_hitbox = {
  {x = 8, y = -16, w = 24, h = 32},
  {x = 0, y = -16, w = 32, h = 24},
  {x = -16, y = -16, w = 24, h = 32},
  {x = -16, y = 8, w = 32, h = 24},
}

local function reset_tested_dirs()
  tested_dirs = {false, false, false, false}
end
-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/skeleton_3")
  enemy:set_life(5)
  enemy:set_damage(2)
 
  m.on_finished = m.refresh
end

function enemy:on_started() --Après le spawn
  m:refresh()
end

function enemy:on_restarted() --L'ennemi restart après avoir été immobilisé (quand il prend un coup par exemple)
  m:refresh()
  enemy:reset_jump_state()
end

function m:refresh() --Démarre le mouvement de base de l'ennemi : 16 pixels tout droit dans une direction random.
  math.randomseed(os.time())  
  local dir = mg.choose_random_direction(enemy, dir_callback)
  enemy.direction = dir

  m:set_angle(dir * math.pi / 2)
  m:set_speed(48)
  m:set_max_distance(16)
  m:start(enemy)
end 

function m:on_obstacle_reached() --Callback d'event appelé quand l'ennemi atteint un obstacle
  m:refresh()
end

function enemy:on_position_changed() --Callback d'event appelé quand l'ennemi se déplace
  reset_tested_dirs()
end


function enemy:on_hero_state_sword_swinging(hero) --Callback appelé quand le héros utilise l'épée.
  if enemy.is_jumping then return end
  local x, y = hero:get_corner_position()
  dir = hero:get_sprite():get_direction()
  local coefs = sword_hitbox[dir + 1]

  if enemy:overlaps(x + coefs.x, y + coefs.y, coefs.w, coefs.h) then
    enemy:start_jump()
  end
end

local function jump_callback() --Fonction qui servira de callback de fin au jump
  enemy:throw_bone(enemy.direction)
  print(enemy.direction)
  enemy:restart()  
end

local function dir_callback(dir) --Fonction qui sera fournie comme callback de choose_random_direction
  return not mg.test_obstacles_dir(enemy, dir)
end

function enemy:start_jump() --Déclenche le saut, et change les propriétés de l'enemi en conséquence
  local dir = mg.dir_from_angle(enemy:get_angle(hero) + math.pi)
  enemy:jump(dir * 2, 16, 36, jump_callback)
  enemy:set_obstacle_behavior("flying")
  enemy:set_attack_consequence("sword", "ignored")
  enemy.is_jumping = true
  sprite:set_animation("jumping")

  enemy.direction = (dir + 2) % 4 
end

function enemy:reset_jump_state() --Annule les changements de propriétés causés par le saut
  enemy:set_obstacle_behavior("normal")
  enemy:set_attack_consequence("sword", 1)
  enemy.is_jumping = false
  sprite:set_animation("walking")
end

function enemy:throw_bone(direction)
  local properties = {}
    properties.model = "bone"
    properties.x, properties.y, properties.layer = enemy:get_position()
    properties.width = 16
    properties.height = 16
    properties.direction = direction
  local arrow = map:create_custom_entity(properties)
    arrow:set_hurts_hero()
end