local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local direction_shift = {
  function(x, y, corner_x, corner_y, w, h, sensor_w, sensor_h)
    return corner_x + w - sensor_w / 2, y
  end,
  function(x, y, corner_x, corner_y, w, h, sensor_w, sensor_h)
    return x, corner_y + sensor_h - 3
  end,
  function(x, y, corner_x, corner_y, w, h, sensor_w, sensor_h)
    return corner_x + sensor_w / 2, y
  end,
  function(x, y, corner_x, corner_y, w, h, sensor_w, sensor_h)
    return x, y
  end,
}

function entity:on_created()
  local _, _, layer = self:get_position()
  local cx, cy, w, h = self:get_bounding_box()
  local direction = self:get_direction()

  --Calculating the position of a standard origin relative to the bounding box, since the actual origin is probably misplaced if the entity was placed using the editor
  local x, y = cx + w / 2, cy + h - 3

  print(cx, cy, w, h, x, y, direction)

  local invisible_platform = map:create_custom_entity{
    x = x, y = y, layer = layer + 1,
    width = w, height = h,
    direction = direction,
  }
  invisible_platform:set_modified_ground("traversable")
  invisible_platform:set_origin(w / 2, h - 2)
  invisible_platform:set_position(x, y)

  local hero = game:get_hero()
  --bottom sensor is "after" top sensor, according to the direction of the entity

  local hero_w, hero_h = hero:get_size()
  local sensor_w, sensor_h
  if direction % 2 == 0 then
    sensor_w = hero_w
    sensor_h = h
  else
    sensor_w = w
    sensor_h = hero_h
  end

  local bottom_sensor_x, bottom_sensor_y = direction_shift[direction + 1](x, y, cx, cy, w, h, sensor_w, sensor_h)
  local top_sensor_x, top_sensor_y = direction_shift[((direction + 2) % 4) + 1](x, y, cx, cy, w, h, sensor_w, sensor_h)

  local name = self:get_name()
  local bottom_sensor = map:create_sensor{
    x = bottom_sensor_x, y = bottom_sensor_y, layer = layer,
    width = sensor_w, height = sensor_h,
    name = name and name .. "_bottom_sensor" or nil
  }
  local top_sensor = map:create_sensor{
    x = top_sensor_x, y = top_sensor_y, layer = layer + 1,
    width = sensor_w, height = sensor_h,
    name = name and name .. "_top_sensor" or nil
  }

  function bottom_sensor:on_activated()
    print("BOTTOM")
    hero:set_layer(layer + 1)
  end
  function top_sensor:on_activated()
    print("TOP")
    hero:set_layer(layer)
  end

  print(sensor_w, sensor_h, top_sensor_x, top_sensor_y, bottom_sensor_x, bottom_sensor_y)


end