local map = ...
local game = map:get_game()

map.discover = mpg.discover
map.init_reset_separators = mpg.init_reset_separators

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


function map:on_opening_transition_finished()
  self:discover(cases)
  self:init_reset_separators(true)

  if game:get_story_state() == 0 then
    sol.timer.start(1000, function() --à remplacer par l'animation de link arrivant sur la plage
      game:get_hero():teleport("villages/nielint_village/bar", "bed", "fade")
    end)
  end

end
