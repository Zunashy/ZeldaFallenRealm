local map = ...
local game = map:get_game()
local hero = game:get_hero()

local vfx = require("scripts/api/visual_effects")

local cases = {
  {3, 4},
  {3, 5},
  {3, 6},
  {3, 7},
  {4, 4},
  {4, 5},
  {4, 6},
  {4, 7},
  {5, 4},
  {5, 5},
  {5, 6},
  {5, 7}
}

--map.obscurity = 0.8

function map:on_started_()
  self:init_reset_separators(true)
  self:init_enemies_event_triggers()
  if game:get_story_state() == 0 then sol.audio.disable_music() end
end



function map:on_opening_transition_finished()
  if game:get_story_state() == 0 then

    hero:freeze()
    hero:get_sprite():set_animation("down")

    local function init_movement()
      local m = sol.movement.create("straight")
      m:set_speed(64)
      m:set_angle(0)
      m:set_max_distance(88)
      m:set_ignore_obstacles()
      return m
    end

    local mHero = init_movement()
    local mRadeau = init_movement()
    
    function mHero:on_finished()
      eg.shake(map:get_camera(), 0, 2, 50)
      sol.timer.start(800, function()
        hero:teleport("normal_version/village/nielint/indoors/bar", "bed", "fade")
      end)
    end

    mHero:start(hero)
    mRadeau:start(map:get_entity("radeau"))
    vfx.fade_in(40)
  elseif game:get_story_state() > 2 and game:get_essence() > 0 then
    local sorcier = map:get_entity("sorcier")
    sorcier:set_enabled(true)
    map:get_entity("sensor_1").on_activated = function()

      hero:freeze()

      local function start_horn_dialog()
        game:start_dialog("item.horn", function(res)
          if res.answer == 2 then
            game:start_dialog("item.horn.svp", start_horn_dialog)
          else
            local sprite = hero:get_sprite()
            sprite:set_animation("horn")
            sprite:set_paused(true)
            sol.timer.start(hero, 2000, function()
              sprite:set_frame(1)
              local vfx = require("scripts/api/visual_effects")
              local camera = map:get_camera()
              local x, y = camera:get_position_on_camera(hero:get_position())
              vfx.shockwave(camera:get_surface(), x, y, 1, 5, 30, 0.4)
              sol.timer.start(hero, 1500, function()
                hero:teleport("war_version/overworld/forest/sword_cave", "horn", "fade")
              end)
            end)
          end
        end)
      end

      sorcier:exclamation(function()
        game:start_dialog("pnj.main.sorcier.first_encounter.1", function()
          mg.move_straight(sorcier, 3, 16, 64, function()
            game:start_dialog("pnj.main.sorcier.first_encounter.2", function()
              hero:start_treasure("horn", 1, "", start_horn_dialog)
            end)
          end)
        end)
      end)
    end
  end

  self:discover(cases)
end
