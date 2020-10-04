local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local damage_ticks = 8

function entity:on_created()
  local count = 0
  local hero = map:get_hero()

  sol.timer.start(self, 50, function()
    if entity:overlaps(hero, "origin") then
      hero:get_sprite():set_shader(game.shaders.poison)
      count = count + 1
      if count == damage_ticks then
        count = 0
        game:remove_life(1)
      end
    else
      hero:get_sprite():set_shader(nil)
      count = 0
    end
    return true
  end)
end
