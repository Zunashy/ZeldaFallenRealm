local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()
  self:set_assignable(true)
end

-- Event called when the hero starts using this item.
function item:on_using()
  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)
  self:set_assignable(true)
end
