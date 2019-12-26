local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local spawned_inside = {}

function entity:read_properties()
  local p = self:get_property("direction")
  if p then p = tonumber(p) end
  if 0 < p and p < 4 then
    self.direction = p 
  end  

  p = self:get_property("speed")
  if p then p = tonumber(p) end
  self.speed = p

end

local function collision_callback(controler, other)
  if other.is_moving_platform and not (other.initial_movement and spawned_inside[other]) then
    local m = other:get_movement()
    if m then m:stop() end

    local speed, dir = controler.speed or other.speed, controler.direction or other.direction

    if speed == other.speed and dir == other.direction then return false end

    m = sol.movement.create("straight")
    m:set_speed(other.speed)
    m:set_angle((math.pi / 2) * controler.direction)
    m:start(other)
    other.initial_movement = false
  end
end

-- Event called when the custom entity is initialized.
function entity:on_created()
  self:read_properties()

  local x, y, w, h = self:get_bounding_box()
  local ox, oy, oh, ow
  for e in map:get_entities_by_type("custom_entity") do 
    if e.is_moving_platform then
      ox, oy, oh, ow = e:get_bounding_box()
      if ox >= x and oy >= y and ox + ow <= x + w and oy + oh <= y + h then
        spawned_inside[e] = true
      end
    end
  end
    
  self:add_collision_test("containing", collision_callback)

end
