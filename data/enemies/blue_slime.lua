-- Lua script of enemy blue_slime.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local dash_values = {
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{8, 24, 8, 17}, {24, 8, 12, 5}, {8, 24, 0, 17}, {24, 8, 12, 5}},
  {{8, 24, 8, 17}, {24, 8, 12, 5}, {8, 24, 0, 17}, {24, 8, 12, 5}},
  {{8, 32, 8, 21}, {32, 8, 16, 5}, {8, 32, 0, 21}, {32, 8, 16, 5}},
}

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.cone_detect = eg.cone_detect

local detect_angle = math.pi/2
local detect_distance = 64
local dash = sol.movement.create("straight")
local back_movement = sol.movement.create("target")
local dash_speed = 96

-- Dash and back movement methods

local function kick_hero()
  local m = sol.movement.create("straight")
  m:set_angle(sprite:get_direction() * math.pi / 2)
  m:set_speed(240)
  m:set_max_distance(400)
  function m:on_obstacle_reached()
    m:stop()
    if m.freeze_cancel_timer:get_remaining_time() > 0 then
      m.freeze_cancel_timer:stop()
    end
    hero:unfreeze()
    hero:start_hurt(enemy:get_damage())
  end

  m.freeze_cancel_timer = sol.timer.start(hero, 600, function()
    hero:unfreeze()
    m:start(hero)
  end)

  hero:freeze()
  m:start(hero)
end

local function dash_hit_callback()
  kick_hero()
  dash:dEnd()
end

local function back_movement_hit_callback()
  return true
end

local function check_distance(movement)
  local x, y = enemy:get_position()
  local d = math.sqrt(math.pow(x - dash.xs, 2) + math.pow(y - dash.ys, 2))     
  local i = 6
  local l = enemy.step_len
  for j = 1,6 do
    if d < j * l then
      i = j
      break
    end
  end
  if not (enemy.dash_state == i) then 
    enemy:set_dash_state(i)
  end 
end

dash.on_position_changed = check_distance
back_movement.on_position_changed = check_distance

function dash:on_obstacle_reached() 
  dash:dEnd()
end

function dash:dEnd()
  dash:stop()

  sol.timer.start(enemy, 1000, function()
    enemy:shake(sprite:get_direction())
    sol.timer.start(enemy, 500, function()
      
      enemy:set_attacks_state("ignored")
      enemy.on_attacking_hero = back_movement_hit_callback

      back_movement:set_target(dash.xs, dash.ys)
      back_movement:set_speed(120)
      back_movement:is_smooth(false)
      back_movement:set_ignore_obstacles(true)
      back_movement:start(enemy) 
    end)
  end)
end

function back_movement:on_finished()
  enemy:set_size(16, 16)
  enemy:set_origin(8,13)
  enemy:set_position(dash.xs, dash.ys)
  enemy:restart()
end

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(3)
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("swimming")

  enemy.step_len = enemy:get_property("step_length") or 16

end

local function basic_hit_callback(enemy)
  if enemy:cone_detect(hero, detect_distance, enemy:get_sprite():get_direction(), detect_angle) then
    kick_hero()
  else
    hero:start_hurt(enemy, 2)
  end
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  enemy:set_attacks_state(1) 
  enemy.on_attacking_hero = basic_hit_callback
  sol.timer.start(enemy, 100, function()
    local back = (enemy:get_sprite():get_direction() + 2) % 4
    for i = 0,3 do
      if enemy:cone_detect(hero, detect_distance, i, detect_angle) and not (i == back) then
        enemy:dash(i)
        return false
      end   
    end
    return true
  end)
end

function enemy:shake(dir)
  local m = sol.movement.create("pixel")
  local vertical = dir % 2 == 1
  local traj = (vertical and {{2, 0},{-2, 0}}) or {{0, 2},{0, -2}}
  m:set_trajectory(traj)
  m:set_delay(30)
  m:set_loop(true)  
  local x, y = enemy:get_position()
  enemy:set_position((vertical and x + 1) or x, (vertical and y) or y + 1)
  m:start(enemy)
end

local function get_dash_values(i, d)
  return 
    dash_values[i + 1][d + 1][1],
    dash_values[i + 1][d + 1][2],
    dash_values[i + 1][d + 1][3],
    dash_values[i + 1][d + 1][4]
end

function enemy:set_dash_state(i)
  sprite:set_animation('dash'..i)
  local w, h, x, y = get_dash_values(i, sprite:get_direction())
  enemy:set_size(w, h)
  enemy:set_origin(x, y)
  enemy.dash_state = i
end

function enemy:set_attacks_state(state)
  enemy:set_attack_consequence("sword", state)
  enemy:set_attack_consequence("arrow", state)
  enemy:set_attack_consequence("hookshot", state)
  enemy:set_attack_consequence("boomerang", state)
end

function enemy:dash(d)
  self:stop_movement()
  enemy:set_dash_state(0)
  sprite:set_direction(d)
  enemy.dash_state = 0
  sol.timer.start(self, 400, 
    function()    
      enemy:set_attacks_state("protected")
      dash.xs, dash.ys = enemy:get_position()
      dash.enemy = enemy      
      dash:set_speed(dash_speed)
      dash:set_angle(d * (math.pi / 2))

      enemy.on_attacking_hero = dash_hit_callback

      dash:start(enemy)
    end
  )
end

function enemy:on_attack()
end 
