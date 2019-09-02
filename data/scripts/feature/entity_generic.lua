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

function eg.shake(entity, dir, amplitude, delay, duration)
  amplitude = amplitude or 1
  local m = sol.movement.create("pixel")
  local vertical = dir % 2 == 1
  local traj = (vertical and {{0, -amplitude * 2},{0, amplitude * 2}}) or {{-amplitude * 2, 0},{amplitude * 2, 0}}
  m:set_trajectory(traj)
  m:set_delay(delay)
  m:set_loop(true)  
  m:set_ignore_obstacles()
  local x, y = entity:get_position()
  entity:set_position((vertical and x) or x + amplitude, (vertical and y + amplitude) or y)
  m:start(entity)

  if duration and type(entity) == "userdata" then
    sol.timer.start(entity, duration, function()
      m:stop()
      entity:set_position(x, y)
    end)
  end
end