local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()
local movement
local sprite

local distance = 16
local speed = 20
local delay = 400
local jump_speed = 72


function enemy:on_created()

  sprite = enemy:create_sprite("enemies/ice_slime")
  enemy:set_life(1)
  enemy:set_damage(2)
  
  self.movement_count = -1
end

function enemy:movement_cycle()
  if self:get_distance(hero) < 40 then
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

function enemy:on_reset()
  self.movement_count = -1
end



-- Code additionnel pour geler link
local function freeze_hero()
end

-- Code additionnel pour bruler le mob
function enemy:on_burn()
end
