local item = ...
local game = item:get_game()

function item:on_started()
  self:set_savegame_variable("possession_horn")
end

function item:find_npc()
  local hero = game:get_hero()
  local closest_dist = math.huge
  local chosen, dist


  for npc in self:get_map():get_entities_by_type("npc") do
    if npc:get_property("horn_map") and npc:is_in_same_region(hero) then
      dist = npc:get_distance(hero)
      if dist < closest_dist then
        chosen = npc
      end
    end
  end
  return chosen
end

function item:on_using_from_inventory(callback)
  game:start_dialog("item.horn", function(res)
    if res.answer == 1 then
      callback(self, true)
    end
  end)
end

local vfx = require("scripts/api/visual_effects")
function item:on_using()
  local hero = game:get_hero()
  local npc = self:find_npc()
  if npc then
    hero:freeze()
    hero:get_sprite():set_animation("horn")

    local camera = game:get_map():get_camera()
    local x, y = camera:get_position_on_camera(hero:get_position())
    vfx.shockwave(camera:get_surface(), x, y, 1, 5, 30, 0.4)

    sol.timer.start(hero, 1000, function()
      hero:teleport(npc:get_property("horn_map"), npc:get_property("horn_destination"), "fade")
      item:set_finished()
    end)
  else
    game:start_dialog("item.horn.no_npc", function() item:set_finished() end)
  end
end

function item:on_obtained()
  self:set_variant(1)
end

item.use_from_inventory = true