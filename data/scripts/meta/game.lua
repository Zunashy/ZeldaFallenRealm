 local game_meta = sol.main.get_metatable("game")

local function map_callback(game, map)
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, game.HUD_height)
  
  if map.obscurity then
    map:set_obscurity(map.obscurity)
  end
  camera:get_surface():set_shader(game.chroma_shader)
  game.obscurity_shader:set_uniform("amount", 3)
  local hero = map:get_hero()
  hero:save_solid_ground()
  hero:reset_walking_speed()

end  

game_meta:register_event("on_map_changed", map_callback)

function game_meta:get_story_state()
  return self:get_value("story_state") or 0
end

function game_meta:set_story_state(state)
  return self:set_value("story_state", state)
end

local obs_uniform_names = {"light1", "light2", "light3", "light4"}

--NOTE : s'il s'avène qu'on n'utilise l'obscurité que sur des maps à séparateurs, retirer le test de position
function game_meta:on_draw(dst_surf)
  local map = self:get_map()
  local camera = map:get_camera()
  local i = 1
  if camera:get_surface():get_shader() == self.obscurity_shader and map.lights then
    local cx, cy, cw, ch = camera:get_bounding_box()
    for i, light in ipairs(map.active_lights) do
      local power, x, y = (light.light_power or 30), light:get_position()
      x, y = x - cx, y - cy + 8
      if x > -power and x < cw + power * 2 and y > -power and y < ch + power * 2 then
        self.obscurity_shader:set_uniform(obs_uniform_names[i], {x, y, power})
        i = i + 1
      end
    end
    --print(map.active_lights)
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

  self.obscurity_shader = sol.shader.create("obscurity")
  self.chroma_shader = sol.shader.create("shader")
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