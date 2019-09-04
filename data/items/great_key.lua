local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()

  self:set_shadow("small")
  self:set_brandish_when_picked(true)
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("picked_small_key")
  self:set_savegame_variable("great_key")
end

-- Event called when the hero starts using this item.
function item:on_using()
  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)
  
end
