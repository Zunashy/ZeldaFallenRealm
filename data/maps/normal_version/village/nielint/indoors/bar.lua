local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  local zuna = map:get_entity("zuna")
  map:get_entity("separator_1").on_activated = function()
    if game:get_story_state() < 2 then
      zuna:get_sprite():set_direction(2)
      game:start_dialog("pnj.village.nielint.barman.awake1", function() game:set_story_state(2) end)  
    end
  end

  local story_state = game:get_story_state() or 0
  if story_state > 9 then
    zuna:set_enabled(false)
  elseif story_state > 7 then
    local x, y = zuna:get_position()
    zuna:set_position(x, y + 8)
    zuna:remove_sprite(zuna:get_sprite())
    zuna:create_sprite("pnj/nielint/barman_sleeping")
    function zuna:on_interaction()
      game:start_dialog("pnj.village.nielint.barman.sleep")
    end
  elseif game:has_item("sword") then
    function zuna:on_interaction()
      game:start_dialog("pnj.village.nielint.barman.sword")
    end
  else
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
