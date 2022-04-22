local item = ...
local game = item:get_game()

local animation_started = false

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

function item:start_animation(effect)
  local hero = game:get_hero()
  hero:freeze()
  hero:get_sprite():set_animation("horn")

  if not animation_started then
    local camera = game:get_map():get_camera()
    local x, y = camera:get_position_on_camera(hero:get_position())
    vfx.shockwave(camera:get_surface(), x, y, 1, 15, 90, 0.7) --speed, width, amplitude, refraction
    sol.audio.stop_music()
    sol.audio.play_sound("horn")
  end
  sol.timer.start(hero, 1300, function()
    vfx.flash(20, {255, 255, 255})
    sol.timer.start(hero, 300, function()
      effect(item)
      hero:unfreeze()
    end)  
  end)
  animation_started = true
end

function item:enable_entities()
  local found_entities = self:find_entities()
  if not found_entities then return false end
  for _, v in ipairs(found_entities) do
    v:set_enabled(true)
  end
  self:set_finished()
end

function item:on_using()
  animation_started = false
  local map = game:get_map()
  local res
  --false = il s'est rien passé mais on fait quand même pas spawn les entités
  --nil = il s'est rien passé
  --true = il s'est passé un truc

  if map.on_horn_used then
    res = map:on_horn_used(item)
  end

  if res == nil then
    self:start_animation(self.enable_entities)
    res = true
  end

  if not res and not animation_started then
    game:start_dialog("item.horn.no_npc", function() item:set_finished() end)
  end

  --do nothing and return nothing : entities spawn
  --do something and return nothing : entities spawn
  --do nothing and return true : nothing happens
  --do something and return true : nothing happens
  --do nothing and return false : no entity message
  --do something and return false : nothing happens

end

item.use_from_inventory = true