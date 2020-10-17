local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local parse_event_string = require("scripts/feature/event_string.lua")

local function obtained_callback()
  if entity.on_obtained then
    parse_event_string(map, entity.on_obtained)
  end
end

local function collision_test(entity, other)
  if other:get_type() == "hero" then
    entity:remove()
    print(obtained_callback)
    other:start_treasure(entity.item, entity.variant, entity.savegame_variable, obtained_callback)
  end
end


function entity:on_created()
  self.item = self:get_property("item")
  if not self.item then
    self:remove()
    return
  end

  self.variant = tonumber(self:get_property("variant"))
  self.savegame_variable = self:get_property("savegame_variable")
  self.on_obtained = self:get_property("on_obtained")

  if self.savegame_variable and game:get_value(self.savegame_variable) then
    self:remove()
  end

  local sprite = self:create_sprite("entities/items")
  sprite:set_animation(self.item)
  sprite:set_direction(self.variant - 1)

  local item_object = game:get_item(self.item)
  if item_object.on_pickable_created then
    item_object:on_pickable_created(self)
  end

  self:add_collision_test("overlapping", collision_test)

end
