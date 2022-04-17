-- Initialize hero behavior specific to this quest.

local hero_speed = 128

local hero_meta = sol.main.get_metatable("hero")

local hero_sprite, sword_sprite

local pull_lever_state
local push_block_state

local function initialize_hero_features(game)

  local hero = game:get_hero()
  hero.get_corner_position = eg.get_corner_position
  
  function hero:on_created()
    hero_sprite = hero:get_sprite("tunic")
    sword_sprite = hero:get_sprite("sword")
  end

  function hero:reset_walking_speed()
    hero:set_walking_speed(hero_speed)
  end
  
  --Méthodes / Callbacks
  function hero:start_hurt_oow(damage, knockback_angle, knockback_distance)
    
    if hero.on_taking_damage then
     handled = hero:on_taking_damage(damage)
    end  
    if (not handled) and damage then hero:remove_life(damage) end
 
    sol.audio.play_sound("hero_hurt")
    hero:set_invincible(true, 2000)
    sprite:set_animation("hurt")
    hero:set_blinking(true, 2000)
    
    local m = sol.movement.create("straight")
    m:set_angle(knockback_angle)
    m:set_speed(120)
    m:set_max_distance(knockback_distance)
    function m:on_obstacle_reached()
      m.finished = true
      if m.timer_end then
        hero:unfreeze()
      end
    end

    hero:freeze()
    sol.timer.start(hero, 200, function()
      m.timer_end = true
      
    end)

    m:start(hero)
  end
  
  function hero:test_ladder()
    local map = self:get_map()
    local x, y, layer = self:get_position()
    return self:get_ground_below() == "ladder"
  end

  hero.is_on_nonsolid_ground = false
  
  function hero:update_ladder()
    if self:test_ladder(self) or self.ladder_below then
      if not self:get_state_object() then
        self.on_ladder = true
        self:start_state(self.ladder_state)
        self:get_sprite():set_direction(1)
      end
    elseif self.on_ladder then
      self.on_ladder = false
      self:unfreeze()
    end
  end

  function hero:on_position_changed() 
    if self.need_solid_ground then
      local ground = self:get_ground_below();
      if (ground ~= "deep_water"
        and ground ~= "hole"
        and ground ~= "lava"
        and ground ~= "prickles"
        and ground ~= "empty"
        and self.is_on_nonsolid_ground == false)
      then 
        self:save_solid_ground()
        self.need_solid_ground = false
      end
    end

    self:update_ladder()

    self.is_on_nonsolid_ground = false
  end

  function hero:start_jumping_oow(dir, dist)
    dir = (dir or 0) % 8
    if not hero:get_map().is_side_view then
      hero:start_jumping(dir, dist)
      return true
    end

    if dir == 2 or dir == 6 then
     -- return false
    end

    if not self.pObject or not (self.pObject.on_ground) then return false end

    self.pObject.speed = -2.5
  end

  function hero:on_state_changing(current, next)
    if current == "treasure" then
      sol.audio.restore_music()
    end
    self:get_map():call_hero_state_callback(current, next)
  end

  function hero:on_state_changed(s)
    local map = game:get_map()
    if not map then return false end
    
    s = s:gsub(" ", "_")
    for e in map:get_entities() do
      if e["on_hero_state_" .. s] then
        e["on_hero_state_" .. s](e, self)
      end
    end
    if s == "plunging" then
      if self.pObject then self.pObject:freeze() end
      hero_sprite:set_animation("plunging_water", function()
        hero:set_position(hero:get_solid_ground_position())
        hero:start_hurt(1)
        if hero.pObject then hero.pObject:unfreeze() end
      end)
    elseif s == "sword_tapping" then
     local m = sol.movement.create("straight")
     m:set_speed(100)
     m:set_angle(hero_sprite:get_direction() * (math.pi / 2) + math.pi)
     m:set_max_distance(3)
     m:start(self)
     --sol.audio.play_sound("sword_tapping")
    elseif s == "treasure" then
      sol.audio.disable_music()
    end
  end

  pull_lever_state = sol.state.create()
  pull_lever_state:set_can_control_movement(false)
  pull_lever_state:set_can_control_direction(false)

  function pull_lever_state:stop()
    self:get_entity():unfreeze()
  end

  function pull_lever_state:on_command_released(command)
    if command == "action" then
      self:stop()
      if self.lever and self.lever.state == 1 then 
        self.lever:release()
      end
    end
  end

  function hero_meta:start_pull_lever()
    self:start_state(pull_lever_state)
    return pull_lever_state
  end

  push_block_state = sol.state.create()
  push_block_state:set_can_control_movement(false)
  push_block_state:set_can_control_direction(false)

  function push_block_state:stop()
    self:get_entity():unfreeze()
  end

  function hero_meta:start_push_block()
    self:start_state(push_block_state)
    return push_block_state
  end

  function hero:on_taking_damage(dmg)
    game:remove_life(dmg)
  end

  hero.ladder_state = sol.state.create()
  hero.ladder_state:set_can_control_direction(false)
  hero.ladder_state:set_can_control_movement(true)

  function hero.ladder_state:on_movement_started()
    self:get_entity():get_sprite():set_animation("walking")
  end

  function hero.ladder_state:on_movement_changed(m)
    if m:get_speed() == 0 then
      self:get_entity():get_sprite():set_animation("stopped")
    else
      self:get_entity():get_sprite():set_animation("walking")
    end
  end
end

function hero_meta:light_teleport(destination, map)
  map = map or hero:get_map()
  local dest = map:get_entity(destination)
  hero:set_position(dest:get_position())
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_hero_features)
return true
