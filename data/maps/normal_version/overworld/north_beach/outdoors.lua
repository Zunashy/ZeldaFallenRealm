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

local function separator_callback_1(self)
  if game:get_story_state() == 3 then
    local moblin = map:get_entity("moblin_cinematic")
    local key = map:get_entity("great_key")
 
    game:start_dialog("pnj.overworld.north_beach.moblin_run")
    moblin:get_sprite():set_direction(2)
    mg.move_straight(moblin, 2, 40, 64, function()
      key:set_enabled(false)
      moblin:get_sprite():set_direction(3)
      game:set_story_state(4)
      mg.move_straight(moblin, 3, 48, 96, function()
        game:set_story_state(4)
        moblin:set_enabled(false)
      end, {ignore_obstacles = true})
    end)
  end
end

local function separator_callback_2(self)
  if game:get_story_state() == 4 then
    local moblin = map:get_entity("moblin_cinematic_2")
    mg.move_straight(moblin, 3, 32, 96, function()
      game:set_story_state(5)
      moblin:set_enabled(false)
    end, {ignore_obstacles = true})
  end
end

local function separator_callback_3(self)
  if game:get_story_state() == 5  then
    hero:freeze()
    local moblin = map:get_entity("moblin_cinematic_3")
    mg.move_straight(moblin, 1, 16, 64, function()
      local sword = moblin:create_sprite("enemies/moblin_sword_sword", "sword")
      sword:set_animation("swing")

      local vine = map:get_entity("vine_door_cinematic")
      sol.timer.start(vine, 200, function()
        vine:get_sprite():set_animation("cut", function()
          hero:unfreeze()
          game:set_story_state(6)
          mg.move_straight(moblin, 1, 64, 64, nil, {ignore_obstacles = true})
        end)
      end)
    end)
  end
end

function map:on_started_()
  self:init_reset_separators(true)
  self:init_enemies_event_triggers()
  local story = game:get_story_state()
  if story == 0 then 
    sol.audio.disable_music() 
  elseif story < 6 then
    self:get_entity("sep_cinematic1"):register_event("on_activated",separator_callback_1)
    for sep in self:get_entities("sep_cinematic2") do
      sep:register_event("on_activated",separator_callback_2)
    end
    self:get_entity("sep_cinematic3"):register_event("on_activated", separator_callback_3)
  elseif story == 6 and game:get_essence() > 0 then
    local sorcier = map:get_entity("sorcier")
    sorcier:set_enabled(true)
    map:get_entity("sensor_1").on_activated = function()

      hero:freeze()

      local function start_horn_dialog()
        hero:freeze()
        game:start_dialog("item.horn", function(res)
          if res.answer == 2 then
            game:start_dialog("item.horn.svp", start_horn_dialog)
          else
            local sprite = hero:get_sprite()
            sprite:set_animation("horn")
            sprite:set_paused(true)
            sol.audio.stop_music()
            sol.timer.start(hero, 2000, function()
              sprite:set_frame(1)
              game:get_item("horn"):start_shockwave(hero)
              sol.audio.play_sound("horn")
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
  end

  self:discover(cases)
end


