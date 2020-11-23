local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local shield_sprite
local arm_sprites = {}

local arm_diameter = 12
local shield_radius = 12
local hand_radius = 6
local arms_nb = 2
local movement_range = shield_radius + hand_radius + (arm_diameter * arms_nb) 

local movement_speed = 80
local rock_speed = 140
local protect_movement_speed = 96

local protect_y_offset = 30

local rock_destroy_chance = 0.7

local arms_pos = {}
for i = 1, arms_nb do
  arms_pos[i] = (movement_range - hand_radius - (arm_diameter * (i - 0.5))) / movement_range
end

--arms_pos[1] = movement_range - hand_radius - arm_diameter * 0.5
--arms_pos[2] = movement_range - hand_radius - arm_diameter * 1.5
--arms_pos[3] = movement_range - hand_radius - arm_diameter * 2.5 = shield_radius + (arm_diameter * 0.5)
--movement_range = shield_radius + hand_radius + arm_diameter * 3


function enemy:on_created()

  for i = 1, arms_nb do
    arm_sprites[i] = self:create_sprite("enemies/boss/rock_mosquito_arm", "arm_"..i)
  end

  shield_sprite = self:create_sprite("enemies/boss/rock_mosquito_hand_shield", "shield")
  sprite = self:create_sprite("enemies/boss/rock_mosquito_hand", "hand")

  self:set_life(1)
  self:set_damage(1)
  self:set_attacks_consequence("protected")

  self:update_arm()

  self:set_drawn_in_y_order(false)
end

function enemy:update_arm()
  local x, y = sprite:get_xy()
  local current_pos
  for i = 1, arms_nb do
    arm_sprites[i]:set_xy(arms_pos[i] * x, arms_pos[i] * y)
  end
end

local function movement_position_callback()
  enemy:update_arm()
end

function enemy:start_movement()
  self.movement_count = self.movement_count - 1

  if self.movement_count < 1 and not self.other_hand.throwing then
    self:start_attack()
    return
  end

  local x, y
  local angle = gen.random() * math.pi * 1.5 + (math.pi / 2)
  local norm = gen.random(movement_range * 0.25, movement_range * 0.75)
  x = norm * math.cos(angle)
  y = norm * math.sin(angle)

  local m = sol.movement.create("target")
  m:set_speed(movement_speed)
  m:set_target(x,  y)
  m.on_position_changed = movement_position_callback
  m:start(sprite, function() 
    enemy:start_movement()
  end)
end

function enemy:start_attack()
  self.throwing = true
  local angle = self:get_angle(hero)
  angle = angle + math.pi
  local cx, cy = sprite:get_xy()
  local x, y
  x = movement_range * math.cos(angle)
  y = movement_range * -math.sin(angle)
  local dist = sol.main.get_distance(x, y, cx, cy)
  local m = sol.movement.create("target")
  m:set_speed(48 + (48 * (dist / movement_range)))
  m:set_target(x, y)
  m.on_position_changed = movement_position_callback
  m:start(sprite, function()
    enemy:throw()
  end)
end

local function destroy_rock(rock)
  rock:get_sprite():set_animation("destroy", function()
    rock:set_modified_ground("traversable")
    rock:remove()
  end)
end

local function rock_position_callback(rock)
  if rock:overlaps(hero, "overlapping") and not hero:is_blinking() then
    hero:start_hurt(rock, 2)
    rock:destroy()
  end
end

local function init_rock(rock, movement_angle, distance)
  rock.is_rock = true
  rock:bring_to_front()

  rock.on_position_changed = rock_position_callback
  rock.destroy = destroy_rock

  local m = sol.movement.create("straight")
  m:set_speed(rock_speed)
  m:set_angle(movement_angle)
  m:set_max_distance(distance)

  function m:on_obstacle_reached()
    rock:destroy()
  end

  m:start(rock, function()
    if math.random() < rock_destroy_chance or rock:overlaps(hero, "overlapping") then
      rock:destroy()
    else
      local x, y, layer = rock:get_position()
      local dest = map:create_destructible({
        x = x,
        y = y,
        layer = layer,
        weight = 1,
        ground = "wall",
        sprite = "entities/projectile/rock",
      })
      dest.is_rock = true
      rock:remove()
    end
  end)
end

function enemy:throw()
  local x, y, layer = self:get_position()
  local hx, hy = sprite:get_xy()
  local rock = self:get_map():create_custom_entity({
    x = x + hx,
    y = y + hy + 4,
    layer = layer,
    sprite = "entities/projectile/rock",
    width = 16,
    height = 16,
    direction = 0
  })

  local angle = sol.main.get_angle(hx, hy, 0, 0)
  local distance = hero:get_distance(x + hx, y + hy)

  init_rock(rock, angle, distance)

  local m = sol.movement.create("straight")
  m:set_speed(rock_speed)
  m:set_angle(angle)
  m:set_max_distance(movement_range * 2)
  m.on_position_changed = movement_position_callback
  m:start(sprite, function()
    self.movement_count = 4
    self.throwing = false
    sprite:set_animation("walking")
    enemy:start_movement()
  end)

  sprite:set_animation("open")
end

function enemy:protect(x_offset)
  self.rm.protected = self
  self.throwing = false
  if sprite:get_movement() then
    sprite:get_movement():stop()
  end

  local x, y = self.rm_position.x, self.rm_position.y
  x = x + x_offset
  y = y + protect_y_offset

  local m = sol.movement.create("target")
  m:set_speed(protect_movement_speed)
  m:set_target(x, y)
  m.on_position_changed = movement_position_callback
  m:start(sprite)

end

function enemy:start()
  self.throwing = false
  self.movement_count = 4
  self:start_movement()
end

function enemy:on_restarted()

end
