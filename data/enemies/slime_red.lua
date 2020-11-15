

local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()
local movement
local sprite

local distance = 16
local speed = 48
local delay = 400
local jump_speed = 72


function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(2)
  self.movement_count = 0
end

function enemy:movement_cycle()
  if self:get_distance(hero) < 48 then
    self.movement_count = self.movement_count + 1
  end


  if self.movement_count < 2 then
    sol.timer.start(enemy, delay, function()
      movement = sol.movement.create("straight")
      movement:set_max_distance(distance)
      movement:set_speed(speed)
      movement:set_angle(self:get_angle(hero))
      movement:start(enemy, function()
        enemy:movement_cycle() 
      end)
    end)
  else
    self.movement_count = -1
    self:prepare_jump()
  end
end

function enemy:jump()
  local m = sol.movement.create("jump")
  m:set_direction8(self:get_direction8_to(hero))
  m:set_distance(self:get_distance(hero))
  m:set_speed(jump_speed)
  m:start(enemy, function()
    enemy:movement_cycle()
  end)
  movement = m
end

function enemy:prepare_jump()
  eg.shake(self, 1, 1, 50, 600, function(e)
    e:jump()
  end)
end

function enemy:on_restarted()
  enemy:movement_cycle()
end

function enemy:on_dead()
  local map = self:get_map()
  local x, y, layer = self:get_position()
  map:create_enemy({
    x = x - 6, 
    y = y,
    layer = layer,
    breed = self:get_breed().."_small",
    treasure_name = "random",
    direction = 0,
  })
  map:create_enemy({
    x = x + 6, 
    y = y - 12,
    layer = layer,
    breed = self:get_breed().."_small",
    treasure_name = "random",
    direction = 0,
  })
end

function enemy:on_reset()
  self.movement_count = -1
end