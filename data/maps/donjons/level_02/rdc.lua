local map = ...
local game = map:get_game()

local boss

local function boss_rock_destroy()
  if boss.waiting then --if the rock was destroyed but the boss is still waiting = the player didn't send therock on the boss (stupid donkey it's fucking OBVIOUS)
    local x, y, layer = rock_respawn:get_position()
    if map:get_hero():get_position() < x + 16 then
      x, y, layer = rock_respawn_2:get_position()
    end
    local rock = map:create_destructible({
      x = x,
      y = y,
      layer = layer,
      sprite = "entities/projectile/rock",
      weight = 1
    })
    rock.on_thrown = boss_rock_destroy
  end
end

function map:on_started_()
  self:init_dungeon_features()

  boss_rock.on_thrown = boss_rock_destroy

  boss = self:get_entity("boss_2")
end

function map:on_opening_transition_finished()

end
