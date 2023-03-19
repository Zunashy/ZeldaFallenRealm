
local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  self:init_dungeon_features()
end

function map:on_opening_transition_finished()

end
