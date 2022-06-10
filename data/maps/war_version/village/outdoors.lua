-- Lua script of map war_version/village/outdoors.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

if game:get_story_state() < 7 then
  sol.audio.stop_music()
end

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()
  zuna:create_sprite("pnj/main/zuna_sword", "sword")
  local story = game:get_story_state()
  local hero = self:get_hero()
  if story < 7 then 

    self:get_entity("sep_1").on_activated = function()
      if game:get_story_state() < 7 then
        local zuna_sprite = zuna:get_sprite()
        local zuna_sword = zuna:get_sprite("sword")
        local hero_sprite = hero:get_sprite()
        local hero_sword = hero:get_sprite("sword")

        mg.move_straight(hero, 1, 8, 64, function()
          hero:freeze()
          hero:set_direction(1)
          game:start_dialog("pnj.main.zuna.first_encounter.1", function()
            zuna_sprite:set_direction(3)
            sol.timer.start(zuna, 1500, function()
              hero:exclamation()
              zuna_sprite:set_animation("sword")
              zuna_sword:set_animation("sword")
              local vfx = require("scripts/api/visual_effects")
              sol.audio.play_sound("sword1")
              mg.move_straight(zuna, 3, 32, 213, function()
                hero_sprite:set_animation("sword_looping")
                hero_sword:set_animation("sword_looping")
                hero_sword:set_direction(1)
                sol.audio.play_sound("sword1")
                sol.timer.start(hero, 1000, function()
                  game:start_dialog("pnj.main.zuna.first_encounter.2", function()
                    hero_sprite:set_animation("stopped")
                    hero_sword:stop_animation()
                    zuna_sprite:set_animation("stopped")
                    zuna_sword:stop_animation()
                    zuna_sprite:set_direction(3)
                    game:start_dialog("pnj.main.zuna.first_encounter.3", function()
                      game:set_story_state(7)
                      hero:unfreeze()
                      zuna.dialog = "pnj.main.zuna.first_encounter.4"
                    end)
                  end)
                end)
              end, {ignore_obstacles = true})
            end)
          end)
        end)
      end
    end
  elseif story < 666 then
    zuna:get_sprite():set_direction(1)
    zuna:set_property("dialog", "pnj.main.zuna.first_encounter.5")
  elseif game:get_story_state() > 666 then
    zuna:set_enabled(false)
  end
end

function map:on_horn_used(horn)
  if zuna and zuna:is_in_same_region(hero) then
    horn:start_animation(function(horn) 
      local hero = map:get_hero()
      game:set_story_state(8)
      hero:teleport("normal_version/village/nielint/indoors/bar", "horn")
    end)
  end
  return false
end