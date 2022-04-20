local walking_speed = 88
local swimming_speed = 66
local climbing_speed = 44

local sv = {}

sv.pObject = gen.class()

sv.gravity = 0.10

function sv.pObject:constructor(entity)
  self.entity = entity
  self.speed = 0
  self.acc = 0
end

function sv.pObject:get_pos()
  return self.entity:get_position()
end

function sv.pObject:set_pos(x, y)
  self.entity:set_position(x, y)
end

function sv.pObject:freeze()
  self.frozen = true
end  

function sv.pObject:unfreeze()
  self.frozen = false
end  

--CODE DE PHOENIXII54


local function is_on_ground(entity, dy)
  dy = dy or 0
  local x,y = entity:get_position()
  local map = entity:get_map()
  return entity:test_obstacles(0, 1) or not (entity:get_ground_below() == "ladder") and map:is_ladder(x, y+3)
end

----

function sv.pObject:apply_physics()
  if (is_on_ground(self.entity) and self.on_ground or 
    (self.entity:get_ground_below() == "ladder")) and 
    not (self.speed < 0) or
    self.frozen
  then return end

  local x, y, layer = self:get_pos()

  self.speed = self.speed + self.acc

  local dy = self.speed
  local map = self.entity:get_map()

  if self.entity:test_obstacles(0, dy) or (map:is_ladder(x, y + dy+2, layer)) then
    local sign = math.sign(self.speed)
    dy = sign
    while not (self.entity:test_obstacles(0, self.speed) or map:is_ladder(x, y + dy+2, layer)) do
      dy = dy + sign
    end
    dy = dy - sign
    self.speed = 0   
  end
  y = y + dy  


  self.on_ground = is_on_ground(self.entity)

  self:set_pos(x, y)
end

function sv.init_physics(entity)
  entity.pObject = gen.new(sv.pObject, entity)
  entity.pObject.acc = sv.gravity
end

local function update_animation(hero, direction)
  local state, cstate = hero:get_state()
  local map = hero:get_map()
  local movement = hero:get_movement()
  local x,y,layer = hero:get_position()
  local sprite = hero:get_sprite("tunic")
  direction = direction or sprite:get_direction()
  local new_animation
 
  if state == "swimming" or (state=="custom" and cstate:get_description()=="sideview_swim") then
    if movement and movement:get_speed() ~= 0 then
      --new_animation = "swimming_scroll"
    else
     -- new_animation = "stopped_swimming_scroll"
    end
  end
  if state == "sword loading" then
    if hero:get_ground_below() == "deep_water" then
      --new_animation = "swimming_scroll_loading"
      hero:get_sprite("sword"):set_animation("sword_loading_swimming_scroll")  
    end
  end
 
  if (state=="free" or cstate == hero.ladder_state) and not (hero.frozen) then
    if (movement and movement:get_speed() ~= 0) then
      if hero.on_ladder and hero:test_ladder() then
        new_animation = "walking"
      elseif not is_on_ground(hero) and not hero:test_ladder() then
        if map:get_ground(x,y+4,layer)=="deep_water" then
          --new_animation ="swimming_scroll"
        else
          new_animation = "jumping"
        end
      else
        new_animation = "walking"
      end
    else
      if hero.on_ladder and hero:test_ladder() then
        new_animation = "stopped"
      elseif not is_on_ground(hero) and not hero:test_ladder() then
        if map:get_ground(x,y+4,layer)=="deep_water" then
          --new_animation ="stopped_swimming_scroll"
        else
          new_animation = "jumping"
        end
      else
        new_animation = "stopped"
      end
    end
  end
 
  if new_animation and new_animation ~= sprite:get_animation() then
    sprite:set_animation(new_animation)
  end
 
end

function sv.update_hero(hero)
  local movement = hero:get_movement()
  local game = hero:get_game()
 
  local function command(id)
    return game:is_command_pressed(id)
  end
 
  local x, y, layer = hero:get_position()
  local map = game:get_map()
  local speed, hangle, vangle
  local can_move_vertically = true
  local _left, _right, _up, _down
 
  hero.ladder_below = map:is_ladder(x, y+3, layer)

  --TODO enhance the movement angle calculation.
  if command("up") and not command("down") then
    _up=true
    if map:get_ground(x,y,layer)=="deep_water" then
      speed = swimming_speed
    elseif hero.on_ladder then
      speed = climbing_speed
    else
      can_move_vertically=false
      --    game:simulate_command_released("up")
    end
  elseif command("down") and not command("up") then
    ---print "LEFT"
    _down=true
    if map:get_ground(x,y, layer) =="deep_water" then
      speed = swimming_speed
    elseif map:is_ladder(x, y+3, layer) then
      hero.on_ladder = true
      speed = climbing_speed
    else
      can_move_vertically = false
      --  game:simulate_command_released("down")
    end
  end

 
  if command("right") and not command("left") then
    _right=true
    hangle = 0
    speed=walking_speed
    if map:get_ground(x,y,layer)=="deep_water" then
      speed = swimming_speed
    end
 
  elseif command("left") and not command("right") then
    _left=true
    speed=walking_speed
    hangle = math.pi
    if map:get_ground(x,y,layer)=="deep_water" then
      speed = swimming_speed
    end
  end
 
  if hero:test_obstacles(0,1) and hero:test_ladder() and map:is_ladder(x,y+3) then
    hero.on_ladder=true
  end
 
  if can_move_vertically==false then
    --print "Trying to override the vertical movement"
    local m=hero:get_movement()
    if m then
      local a=m:get_angle()
      --print (a)
      if _up==true then
        --print "UP"
        --print(m:get_speed(), hero:get_walking_speed())
        if _left==true or _right==true then
          --print "UP-DIAGONAL"
          if hangle ~=a then
            m:set_angle(hangle)
          end
        else
          speed = 0
        end
      elseif _down==true then
        --print "DOWN"
        --print (m:get_speed(), hero:get_walking_speed())
        if _left==true or _right==true then
          --print "DOWN-DIAGONAL"
          m:set_angle(hangle)
          if hangle ~=a then
            m:set_angle(hangle)
          end
        else
          speed = 0
        end
      end
    end
  end
 
  if speed and speed~=hero:get_walking_speed() then
    hero:set_walking_speed(speed)
  end

  update_animation(hero)
end

local function leave_map_callback(map)
  local hero = map:get_hero()
  hero.pObject = nil
  hero.ladder_below = false
end

function sv:init(map)
  local hero = map:get_hero()
  self.init_physics(hero)

  map.physics_timer = sol.timer.start(map, 10, function() 
    if hero:get_state() == "back to solid ground" then return true end
    hero.pObject:apply_physics()
    self.update_hero(hero)
    return true
  end)

  map.is_side_view = true
  map:register_event("on_finished", leave_map_callback)

  hero:update_ladder()

  hero:register_event("on_state_changing", function(self, ps)
    if (ps == "back to solid ground") then
      self:set_direction(1)
    end
  end)

end

return sv