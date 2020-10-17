local map = ...
local game = map:get_game()
local hero = map:get_hero()
local camera = map:get_camera()
-- Event called at initialization time, as soon as this map is loaded.

local villagers = {count = 0}

local flash = require("scripts/api/visual_effects").flash

local function villagers_dialog_callback(villager)
  if not villagers[villager] then
    villagers[villager] = true
    print(villager, villagers[villager])
    villagers.count = villagers.count + 1
    if villagers.count > 3 then
      hero:freeze()
      sol.timer.start(hero, 500, function()
        game:start_dialog("pnj.overworld.plain.camp.talked_all", function()
          flash(50)
          sol.audio.stop_music()
          sol.timer.start(hero, 750, function()
            map:get_hero():light_teleport("campfire", map)
            hero:set_direction(0)
            sol.audio.play_music("campfire")
            hero:freeze()
            camera:get_surface():set_shader(game.shaders.obscurity)
            game.shaders.obscurity:set_uniform("obs_level", 1.2)
            game.shaders.obscurity:set_uniform("n_lights", 1)
            game.shaders.obscurity:set_uniform("light1", {72, 80, 40, 15})
          end)
          sol.timer.start(hero, 3000, function()
            game:start_dialog("pnj.overworld.plain.camp.cinematic", function()              
              flash(50)
              sol.timer.start(hero, 750, function()
                camera:get_surface():set_shader(nil)
                sol.audio.play_music("plain")
              end)
              sol.timer.start(hero,2000,function() 
                game:start_dialog("pnj.overworld.plain.camp.morning", function()
                  hero:unfreeze()
                  game:set_story_state(12)
                  map:get_entity("guard_east"):set_enabled(false) 
                end )    
              end )
            end)
          end)
        end)
      end)
    end
  end
end

local function villager_interaction(villager)
  if game:get_story_state() < 12 then
    game:start_dialog("pnj.overworld.plain.camp." .. villager:get_name() .. ".1", function() villagers_dialog_callback(villager) end)
  else
    game:start_dialog("pnj.overworld.plain.camp." .. villager:get_name() .. ".2")
  end
end

function map:on_started_()
  self:init_reset_separators(true)

  local guard_moblin = self:get_entity("moblin_cave_guard")
  local sidequest = game:get_sidequest_state("moblin_cave")
  
  function guard_moblin:on_interaction()
    local sidequest = game:get_sidequest_state("moblin_cave")
    if sidequest == 0 then
      game:start_dialog("pnj.overworld.plain.guard_moblin_cave", function(res)
        if res.answer == 1 then
          game:start_dialog("pnj.overworld.plain.guard_moblin_cave.goodluck", function()
            mg.move_straight(guard_moblin, 1, 16, 64, function()
              mg.move_straight(guard_moblin, 2, 16, 64, function()
                guard_moblin:get_sprite():set_direction(0)
                game:set_sidequest_state("moblin_cave", 1)
              end)
            end)
          end)
        end
      end)
    elseif sidequest == 1 then
      game:start_dialog("pnj.overworld.plain.guard_moblin_cave.alt")
    else 
      game:start_dialog("pnj.overworld.plain.guard_moblin_cave.success")
    end
  end
  if sidequest > 0 then
    local x, y = guard_moblin:get_position()
    guard_moblin:set_position(x - 16, y - 32)
    guard_moblin:get_sprite():set_direction(0)
  end

  local guard_camp = self:get_entity("guard_camp")
  local story = game:get_story_state()

  if story < 11 then
    function guard_camp:on_interaction()
      if game:get_story_state() < 11 then
        game:start_dialog("pnj.overworld.plain.guard_camp", function()
          mg.move_straight(guard_camp, 1, 16, 64, function()
            mg.move_straight(guard_camp, 2, 16, 64, function()
              guard_camp:get_sprite():set_direction(0)
              game:set_story_state(11)
            end)
          end)
        end)
      else
        game:start_dialog("pnj.overworld.plain.guard_camp.alt")
      end
    end
  elseif story == 11 then
    guard_camp:set_dialog("pnj.overworld.plain.guard_camp.alt")
    local x, y = guard_camp:get_position()
    guard_camp:set_position(x - 16, y - 32)
    guard_camp:get_sprite():set_direction(0)
  else
    guard_camp:set_enabled(false)
  end

  for e in self:get_entities("villager") do
    villagers[e] = false
    e.on_interaction = villager_interaction
  end
end
