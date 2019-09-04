local map = ...
local game = map:get_game()
local hero = game:get_hero()

map.discover = mpg.discover
map.init_reset_separators = mpg.init_reset_separators
map.init_enemies_event_triggers = mpg.init_enemies_event_triggers

local vfx = require("scripts/feature/visual_effects")

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

local function on_started(map)
  map:init_reset_separators(true)
  map:init_enemies_event_triggers()
end
map:register_event("on_started", on_started)

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
        hero:teleport("villages/nielint_village/bar", "bed", "fade")
      end)
    end

    mHero:start(hero)
    mRadeau:start(map:get_entity("radeau"))
    vfx.fade_in(game)

  end

  self:discover(cases)
end
