local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  map:get_entity("separator_1").on_activated = function()
    if game:get_story_state() < 2 then
      game:start_dialog("pnj.village.nielint.barman.awake1", function() game:set_story_state(2) end)  
    end
  end

  local story_state = game:get_story_state() or 0
  local zuna = map:get_entity("zuna")
  if story_state < 666 and game:has_item("sword") then
    function zuna:on_interaction()
      game:start_dialog("pnj.village.nielint.barman.sword")
    end
  elseif story_state < 3 then
    function zuna:on_interaction()
      game:start_dialog("pnj.village.nielint.barman.awake2")
    end
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()
  if game:get_story_state() < 2 then
    game:set_story_state(1)
  end
end
