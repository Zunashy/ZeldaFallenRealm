--global object containing all public functions created here.
eg = {} 

-- detects if a specified entity is in a cone starting from another entity. Can be seen as this second entity's "sight field", in a certain direction (median of the cone), with acertain angle, and to a certain distance (cone side length)
function eg.cone_detect(detector,detected,distance,direction,angle,same_region) 
  distance = distance or math.inf --default distance is infinite, which means detection at any distance
  angle = angle or 90 --default angle is square
  direction = direction or 0  --default direction is east
  if detector:get_distance(detected) > distance then
   return false  --if the detected entity is too far from the detecting entity, test fails.
  else 
    local angleR = detector:get_angle(detected)  --trigonometric angle between the two entities (angle with the x+ vector)
    angleR = angleR - ((math.pi/2) * direction)
    if angleR > math.pi * 2 then
      angleR = angleR % math.pi * 2
    end
    if angleR > angle/2 or angleR < -angle/2 then --after some calculations, we can decide if the detected entity is in the cone
      return false
    else 
      return (not same_region) or detector:is_in_same_region(detected)
    end
  end
end

function eg.zone_detect(detector, detected, distance, same_region)
  return detector:get_distance(detected) < distance and (not same_region or detector:is_in_same_region(detected))
end

function eg.line_detect(detector, detected, direction, distance, same_region)
  local x1, y1 = detector:get_center_position()
  local x2, y2, w, h = detected:get_bounding_box() 
  if direction % 2 == 1 then --don't read this code please i beg you
    h = w
    x1, y1 = y1, x1
    x2, y2 = y2, x2
  end
   return (y1 > y2 and y1 < y2 + h) and (mg.dir_from_angle(detector:get_angle(detected)) == direction) and not (distance and detector:get_distance(detected) > distance) and (not same_region or detector:is_in_same_region(detected))
end

function eg.lines_detect(detector, detected, distance, same_region)
  local x1, y1 = detector:get_position()
  local x2, y2, w, h = detected:get_bounding_box()
  if (y1 > y2 and y1 < y2 + h) and x1 < x2 and not (distance and detector:get_distance(detected) > distance) and (not same_region or detector:is_in_same_region(detected)) then
    return 0
  elseif (x1 > x2 and x1 < x2 + w) and y1 > y2 and not (distance and detector:get_distance(detected) > distance) and (not same_region or detector:is_in_same_region(detected)) then
    return 1
  elseif (y1 > y2 and y1 < y2 + h) and x1 > x2 and not (distance and detector:get_distance(detected) > distance) and (not same_region or detector:is_in_same_region(detected)) then
    return 2
  elseif (x1 > x2 and x1 < x2 + w) and y1 < y2 and not (distance and detector:get_distance(detected) > distance) and (not same_region or detector:is_in_same_region(detected)) then
    return 3
  else
    return nil
  end
end

    --list of grounds considered as dangerous (e.g. will usually deal damages do living entities, and make the hero reappear elsewhere)
local dangerous_grounds = {
  hole = true,
  lava = true
}

--tests if the ground below an entity or at a specified point is dangerous
function eg.is_ground_dangerous(entity, x, y, l)
  local map
  if sol.main.get_type(entity) == "map" then
    map = entity --if the "entity" is actually a map, will test grounds on this map
  elseif not entity then
    map = sol.main.game:get_map()  -- if no entity is specified, will test on the current map
  else
    map = entity:get_map()  --else, simply tests no the map the map the entity is on 
    local ex, ey, el = entity:get_position() --in that case, take the entity's position if not specified
    x, y, l = x or ex, y or ey, l or el
  end
  if not map then return end

  local ground = map:get_ground(x, y, l)  --gets the ground at the position and map choosen.
  return dangerous_grounds[ground] --returns wether it is a dangrous ground or not. 
  
end

--returns the position of the left top corner of the bounding box of an entity
function eg.get_corner_position(entity)
  local x, y = entity:get_position()
  ox, oy = entity:get_origin()
  return x - ox, y - oy
end



local function get_pos(object)
  if object.get_xy then
    return object:get_xy()
  elseif object.get_position then
    return object:get_position()
  else
    return object.x, object.y
  end
end

local function set_pos(object, x, y)
  if object.set_xy then
    return object:set_xy(x, y)
  elseif object.gset_position then
    return object:set_position(x, y)
  else
    object.x = x
    object.y = y
  end
end

function eg.shake(entity, dir, amplitude, delay, duration, callback, context)
  amplitude = amplitude or 1
  local m = sol.movement.create("pixel")
  local vertical = dir % 2 == 1
  local traj = (vertical and {{0, -amplitude},{0, amplitude}}) or {{-amplitude, 0},{amplitude, 0}}
  m:set_trajectory(traj)
  m:set_delay(delay)
  m:set_loop(true)  
  m:set_ignore_obstacles()
  local x, y = get_pos(entity)
  set_pos(entity, (vertical and x) or x + amplitude / 2, (vertical and y + amplitude / 2) or y)
  m:start(entity)

  if duration then
    sol.timer.start(context or entity, duration, function()
      m:stop()
      set_pos(entity, x, y)
      if callback then
        callback(entity)
      end
    end)
  end
end

local function blink_cycle(entity, hperiod)
  entity:set_visible(false)
  entity.blink_timer = sol.timer.start(entity, hperiod, function()
    entity:set_visible(true)
    entity.blink_timer = sol.timer.start(entity, hperiod, function()
      blink_cycle(entity, hperiod)
    end)
  end)
end

function eg.stop_blinking(entity)
  if entity.blink_timer then
    entity.blink_timer:stop()
    entity.blink_timer = nil
  end
end

function eg.blink(entity, hperiod, duration, callback)
  blink_cycle(entity, hperiod)
  sol.timer.start(entity, duration, function()
    eg.stop_blinking(entity)
    entity:set_visible(true)
    if callback then callback() end
  end)
end

function eg.add_light_entity(entity, power)
  local lights = entity:get_map().lights
  lights[#lights + 1] = entity
  entity.light_power = power
  entity:get_map():add_active_light(entity)
end