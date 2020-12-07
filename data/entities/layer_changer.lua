local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:create_top_entity()
  local x, y, layer = self:get_position()
  local w, h = self:get_size()
  local e = map:create_custom_entity({
    layer = layer + 1,
    x = x,
    y = y,
    width = w,
    height = h,
    direction = 0
  })

  e:set_modified_ground(self:get_ground_below())

end

function entity:on_created()
  self:create_top_entity()
  self:add_collision_test("origin", function(entity, other)
    if other:get_type() == "hero" then
      local x, y, layer = other:get_position()
      other:set_position(x, y, layer + 1)
    end
  end)
end
