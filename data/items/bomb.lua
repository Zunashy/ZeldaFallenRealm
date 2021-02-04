-- Bombs item.
local item = ...
local game = item:get_game()

local game = item:get_game()

local max_values = {
  20, 50, 100
}

item.state = sol.state.create()

function item:on_created()

  self:set_savegame_variable("bomb_bag")
  self:set_amount_savegame_variable("bomb_amount")
  self:set_assignable(true)

  self.state:set_can_control_direction(true)
  self.state:set_can_control_movement(true)
  self.state:set_can_use_sword(false)
  self.state:set_can_use_item(false)
  self.state:set_can_interact(false)
  self.state:set_can_grab(false)
  self.state:set_can_push(false)
end

function item.state:on_started()
  local hero = self:get_entity()
  hero:set_animation("carrying_stopped")
end

function item:on_obtained(variant)
  if variant ~= self:get_variant() then
    self:set_variant(variant)
    self:set_max_amount(max_values[variant])
  end
end



-- Called when the player uses the bombs of his inventory by pressing
-- the corresponding item key.
function item:on_using()
  if self:get_amount() > 0 then
    local hero = game:get_hero()
    self:remove_amount(1)
    hero:start_state(self.state)
  end
end

