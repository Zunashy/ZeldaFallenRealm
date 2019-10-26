local initial_menus = {
  "scripts/menus/initial/solarus_logo",
  "scripts/menus/title_screen"
--  "scripts/menus/initial/zunashy",
}

local function start_initial_menus(callback)
  if #initial_menus == 0 then
    return
  end
  
  for i, menu_script in ipairs(initial_menus) do
    initial_menus[i] = require(menu_script)
  end
  if type(callback) == "function" then  
    initial_menus[#initial_menus + 1] = {
      on_started = function(menu) 
        sol.menu.stop(menu)
        callback() 
      end}
  end

  local on_top = false  -- To keep the debug menu on top.
  for i, menu in ipairs(initial_menus) do
    function menu:on_finished()
      if sol.main.get_game() ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = initial_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end


  sol.menu.start(sol.main, initial_menus[1], on_top)

end

return start_initial_menus