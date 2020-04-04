

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:build_surface(price_string)
  self.surface = sol.surface.create(32, 32)
  local item_sprite = sol.sprite.create("entities/items")
  item_sprite:set_animation(self.item_name)
  item_sprite:set_direction(self.variant)
  item_sprite:draw(self.surface, 16, 13)
  
  local price_surf = gen.char_surface.create(32, 11, "8_bit OOS", true)
  price_surf:write(price_string)
  price_surf:draw(self.surface, 16 - ((price_string:len() * (price_surf:get_font():get_char_size())) / 2) , 21)
end

function entity:on_created()
  self.item_name = self:get_property("item")
  if not self.item_name then
    self:remove()
    return
  end

  self.variant = tonumber(self:get_property("variant")) or 0

  local price_string = self:get_property("price") or "20"
  self.price = tonumber(price_string)

  local save_var = self:get_property("savegame_variable")
  if save_var then
    if game:get_value(save_var) then
      self.disrupted = true
      price_string = "--"
    else
      self.save_var = save_var
    end
  end
  self:build_surface(price_string)
end

function entity:on_post_draw()
  local x, y = self:get_position()
  map:draw_visual(self.surface, x - 8, y - 13)
end

function entity:on_interaction()
  if game:get_money() < self.price or self.disrupted then return end
  game:get_hero():start_treasure(self.item_name, self.variant)
  game:remove_money(self.price)
  if self.save_var then
    game:set_value(self.save_var, true)
    self.disrupted = true
    self:build_surface("--")
  end
end


  
  
