 local game_meta = sol.main.get_metatable("game")

local function map_callback(game, map)
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, game.HUD_height)
  
  if map.obscurity then
    map:set_obscurity(map.obscurity)
  end

  local hero = map:get_hero()
  hero:save_solid_ground()
end  
game_meta:register_event("on_map_changed", map_callback)

function game_meta:get_story_state()
  return self:get_value("story_state") or 0
end

function game_meta:set_story_state(state)
  return self:set_value("story_state", state)
end

function game_meta:on_draw()
  local map = self:get_map()
  local camera = map:get_camera()
  if camera:get_surface():get_shader() == self.obscurity_shader and map.lights then
    local lights_pos = {}
    local cx, cy, cw, ch = camera:get_bounding_box()
    for i, light in ipairs(map.lights) do
      local x, y = light:get_position()
      x, y = x - cx, y - cy
      
      if x > 0 and x < cw and y > 0 and y < ch then
        lights_pos[#lights_pos + 1] = {x, y, light.power or 50}
      end
    end
    self.obscurity_shader:set_uniform("lights", lights_pos[1])
    self.obscurity_shader:set_uniform("lights_n", 1)
  end
end

function game_meta:on_started()
  sol.main.game = self

  self.obscurity_shader = sol.shader.create("obscurity")
end

function game_meta:on_finished()
  sol.main.game = nil
end

--The following scripts also modify the game metatable :
-- - menus/dialog_box
-- - managers/input_manager