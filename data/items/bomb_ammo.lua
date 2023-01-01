local item = ...

local amounts = {
    1, 5, 10
}

function item:on_created()
    self.bomb_item = self:get_game():get_item("bomb")
    self:set_brandish_when_picked(false)
end

function item:on_obtained(variant)
    self.bomb_item:add_amount(amounts[variant])
end