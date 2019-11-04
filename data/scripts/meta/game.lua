 local game_meta = sol.main.get_metatable("game")

local function map_callback(game, map)
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, game.HUD_height)

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

function game_meta:on_started()
  sol.main.game = self
end

function game_meta:on_finished()
  sol.main.game = nil
end

--The following scripts also modify the game metatable :
-- - menus/dialog_box
-- - managers/input_manager