-- Initialize hero behavior specific to this quest.

local hero_speed = 64

local hero_meta = sol.main.get_metatable("hero")

local hero_sprite, sword_sprite

local pull_lever_state

local function initialize_hero_features(game)
  print("init_hero")

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

  hero.is_on_nonsolid_ground = false
  
  function hero:on_position_changed() 
    if hero.need_solid_ground then
      local ground = hero:get_ground_below();
      if (ground ~= "deep_water"
        and ground ~= "hole"
        and ground ~= "lava"
        and ground ~= "prickles"
        and ground ~= "empty"
        and hero.is_on_nonsolid_ground == false)
      then 
        hero:save_solid_ground()
        hero.need_solid_ground = false
      end
    end
    hero.is_on_nonsolid_ground = false
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

    if not self.pObject or not self.pObject.on_ground then return false end

    self.pObject.speed = -3.2
  end

  function hero:on_state_changing(current, next)
    if current == "treasure" then
      sol.audio.restore_music()
    end
  end

  function hero:on_state_changed(s)
    local map = game:get_map()
    if not map then return false end
    
    s = s:gsub(" ", "_")
    for e in map:get_entities() do
      if e["on_hero_state_" .. s] then
        e["on_hero_state_" .. s](e, hero)
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

  function hero:on_taking_damage(dmg)
    game:remove_life(dmg)
  end

end

function hero_meta:start_pull_lever()
  self:start_state(pull_lever_state)
  return pull_lever_state
end

function hero_meta:light_teleport(destination, map)
  map = map or hero:get_map()
  local dest = map:get_entity(destination)
  hero:set_position(dest:get_position())
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_hero_features)
return true
