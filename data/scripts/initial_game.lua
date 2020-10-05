-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  game:set_starting_location("normal_version/overworld/north_beach/outdoors", "first_spawn")  -- Starting location.

  game:set_max_life(12)
  game:set_life(game:get_max_life())
  game:set_max_money(100)
end

return initial_game
