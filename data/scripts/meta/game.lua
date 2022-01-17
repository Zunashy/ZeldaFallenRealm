 local game_meta = sol.main.get_metatable("game")

local function map_callback(game, map)
  local camera = map:get_camera()
  camera:set_size(CAMERA_W,CAMERA_H)
  camera:set_position_on_screen(0, game.HUD_height)
  
  if map.obscurity then
    map:set_obscurity(map.obscurity)
  --game.obscurity_shader:set_uniform("amount", 3)
  end
  --camera:get_surface():set_shader(game.chroma_shader)
  local hero = map:get_hero()
  hero:save_solid_ground()
  hero:reset_walking_speed()

  if (hero:get_sprite():get_shader() and not hero:get_sprite():get_shader().persistent) then
    hero:get_sprite():set_shader(nil)
  end
end  

game_meta:register_event("on_map_changed", map_callback)

function game_meta:get_story_state()
  return self:get_value("story_state") or 0
end

function game_meta:set_story_state(state)
  return self:set_value("story_state", state)
end

function game_meta:get_sidequest_state(sidequest)
  return self:get_value("sidequest_"..sidequest) or 0
end

function game_meta:set_sidequest_state(sidequest, state)
  return self:set_value("sidequest_"..sidequest, state)
end

function game_meta:get_essence()
  return self:get_value("essence") or 0
end

local obs_uniform_names = {"light1", "light2", "light3", "light4"}

function game_meta:manage_obscurity_shader(camera, shader)
  local i = 1
  local cx, cy, cw, ch = camera:get_bounding_box()
  for i, light in ipairs(map.active_lights) do
    local power, x, y = (light.light_power or 30), light:get_position()
    x, y = x - cx, y - cy + 8
    if x > -power and x < cw + power * 2 and y > -power and y < ch + power * 2 then
      shader:set_uniform(obs_uniform_names[i], {x, y, power})
      i = i + 1
    end
  end
end

--NOTE : s'il s'avère qu'on n'utilise l'obscurité que sur des maps à séparateurs, retirer le test de position
function game_meta:on_draw(dst_surf)
  local map = self:get_map()
  local camera = map:get_camera()
  local shader = camera:get_surface():get_shader()

  if shader == self.shaders.obscurity and map.lights then
    --self:manage_obscurity_shader(camera, shader)
  end

  if shader and shader.on_draw then
    shader:on_draw(self)
  end

  if self.visual_effect then
    self.visual_effect(dst_surf)
  end

  if self.game_over_link_sprite then
    self.game_over_link_sprite:draw(dst_surf, self.game_over_link_position.x, self.game_over_link_position.y)
  end

end

function game_meta:on_started()
  sol.main.game = self

  if self.on_init and not self.started then
    self:on_init()
    self.started = true
  end

  self:get_hero().test = 10

  self.shaders = require("scripts/api/shader")
end

function game_meta:on_finished()
  sol.main.game = nil
end

local game_over_menu = require("scripts/menus/game_over")
function game_meta:on_game_over_started()
  local hero = self:get_hero()
  local game = self
  self.game_over_link_sprite = sol.sprite.create("hero/tunic1")
  local x, y = hero:get_position()
  local cmx, cmy = self:get_map():get_camera():get_position()
  x = x - cmx
  y = y - cmy + self.HUD_height
  self.game_over_link_position = {x = x, y = y}
  sol.audio.play_sound("hero_dying")
  sol.audio.stop_music()
  hero:remove()
  self.game_over_link_sprite:set_animation("dying", function ()
    game.game_over_link_sprite:set_animation("dead", function ()
      sol.menu.start(game, game_over_menu)
    end)
  end)
end

function game_meta:__tostring()
  return "Game"
end

--The following scripts also modify the game metatable :
-- - menus/dialog_box
-- - managers/input_manager