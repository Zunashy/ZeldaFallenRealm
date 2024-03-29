-- Lua script of map normal_version/village/nielint/outdoors.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local story = game:get_story_state()

-- Event called at initialization time, as soon as this map is loaded.
local function free_octo_entrance()
  local npc = map:get_entity("octo_guard")
  local x, y = npc:get_position()
  npc:set_position(x + 16, y)
  npc:set_dialog("pnj.village.nielint.SE_girl_green_dress_2")
end

function map:on_started()
  if story > 9 then
    free_octo_entrance()
  end

  local zuna = self:get_entity("zuna")
  if game:get_story_state() == 9 then
    map:get_entity("sensor_1").on_activated = function()
      if game:get_item("fire_seed"):get_variant() == 0 then
        map:get_hero():freeze()
        game:set_story_state(10)
        mg.move_straight(zuna, 3, nil, 64, function()
          game:start_dialog("pnj.village.nielint.barman.east", function()
            map:get_hero():start_treasure("fire_seed")
            free_octo_entrance()
          end)
        end, {stop_on_obstacle = true})
      end
    end
  elseif story < 9 or story > 10 then
    zuna:set_enabled(false)
  end
end

function map:on_opening_transition_finished(destination)
end