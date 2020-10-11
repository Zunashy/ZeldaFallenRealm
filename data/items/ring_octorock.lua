local item = ...
local game = item:get_game()

-- Event called when all items have been created.
function item:on_started()
  self:set_assignable(false)
  self:set_savegame_variable("ring_octorok")
  self:set_brandish_when_picked(true)
end