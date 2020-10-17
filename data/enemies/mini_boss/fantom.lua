local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local camera = map:get_camera()
local hero = map:get_hero()
local sprite
local wind_sprite

local walk_speed = 32
local dash_speed = 104

local dir_from_angle = mg.dir_from_angle
local shake = eg.shake

local camera_offset = {x = 0, y = 0}

local function camera_override()
  local x, y = camera:get_position_to_track(hero)
  camera:set_position(x + camera_offset.x, y + camera_offset.y)
  return true
end

local function stop_camera_override()
  if camera.position_override then
    camera.position_override:stop()
    camera.position_override = nil
  end
end

local function start_camera_shake()
  stop_camera_override()
  camera.position_override = sol.timer.start(camera, 10, camera_override)
end


function enemy:on_created()

  sprite = enemy:create_sprite("enemies/mini_boss/fantom")
  wind_sprite = enemy:create_sprite("enemies/mini_boss/fantom_wind")
  enemy:set_life(5)
  enemy:set_damage(2)

  self.unhurt = true
end

local function target_move_pos_callback(m)
  sprite:set_direction(dir_from_angle(enemy:get_angle(hero)))
end

function enemy:target_hero()
  sprite:set_animation("walking")
  local movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(walk_speed)
  movement.on_position_changed = target_move_pos_callback
  movement:start(self)
end

local function dash_obstacle_callback(m)
  start_camera_shake()
  shake(camera_offset, 0, 2, 50, 500, stop_camera_override, camera)
  m:stop()
  sprite:set_animation("stunned")
  wind_sprite:set_animation("walking")
  enemy:set_attacks_consequence(1)
  sol.timer.start(enemy, 500, function()
    enemy:target_hero()
  end)
end 

function enemy:start_attack_movement()
  local  movement = sol.movement.create("straight")
  movement:set_speed(dash_speed)
  movement:set_angle(self:get_angle(hero))
  movement:set_smooth(false)
  movement.on_obstacle_reached = dash_obstacle_callback
  movement:start(self)

  sprite:set_animation("spin")
  wind_sprite:set_animation("spin")
end

function enemy:start_attack()
  self:set_attacks_consequence("protected")
  sprite:set_animation("windup", function()
    enemy:start_attack_movement()
  end)
end

function enemy:on_restarted()
  if self.unhurt then 
    self:target_hero()
  else
    self:start_attack()
  end
end

local function hurt_cb(self)
  self.unhurt = false
end
enemy:register_event("on_hurt", hurt_cb)