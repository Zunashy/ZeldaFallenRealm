local item = ...
local game = item:get_game()

function item:on_started()
  self:set_savegame_variable("possession_horn")
end

function item:find_entities()
  local hero = game:get_hero()
  local entities = {}
  local i = 0

  for entity in self:get_map():get_entities("horn_") do
    if entity:is_in_same_region(hero) and not entity:is_enabled() then
      i = i + 1
      entities[i] = entity
    end
  end
  return i > 0 and entities
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
  local found_entities = self:find_entities()
  if found_entities then
    hero:freeze()
    hero:get_sprite():set_animation("horn")

    local camera = game:get_map():get_camera()
    local x, y = camera:get_position_on_camera(hero:get_position())
    vfx.shockwave(camera:get_surface(), x, y, 1, 5, 30, 0.4)
    sol.audio.stop_music()
    sol.audio.play_sound("horn")
    sol.timer.start(hero, 1300, function()
      vfx.flash(20, {255, 255, 255})
      sol.timer.start(hero, 300, function()
        for _, v in ipairs(found_entities) do
          v:set_enabled(true)
        end
        item:set_finished()
        hero:unfreeze()
      end)  
    end)
  else
    game:start_dialog("item.horn.no_npc", function() item:set_finished() end)
  end




end

item.use_from_inventory = true