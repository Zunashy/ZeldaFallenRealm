local map = ...
local game = map:get_game()

local c = 0

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started_()

end

function map:on_horn_used(horn)
  if c == 0 then
    c = c + 1
    return false
  else
    horn:start_animation(function()
      print("oui")
    end)
  end
end