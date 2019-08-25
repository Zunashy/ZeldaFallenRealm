local meta = sol.main.get_metatable("game")

function meta:on_key_pressed(key, modifiers)
  local handled = false
  if key == "f5" then
   -- F5: change the video mode.
   sol.video.switch_mode()
   handled = true
  elseif key == "f6" then
    sol.video.switch_scale()
    handled = true
  elseif key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "f1" then
    sol.main.game:get_hero():teleport("Map1")
  elseif key == "f2" then
    sol.main.game:get_hero():teleport("donjon_rc")
  elseif key == "f3" then
    sol.main.game:set_life(12)  
  elseif key == "f7" then
    print(sol.main.game:get_value("small_keys"))
  end

  return handled
end

function meta:set_custom_command_effect(command, fun)
  self.command_effect[command] = fun
end

function meta:get_custom_command_effect(command)
  return self.command_effect[command]
end

local start_map_menu = require("scripts/menus/map")
function meta:on_command_pressed(command)
  if type(self.command_effect[command]) == "function" then
    return self.command_effect[command](game)
  end

  if command == "select" and not self:is_suspended() then
    start_map_menu(self)
    return true
  end
end

local function fire_command_event(game, command)
  if game.on_command_pressed then
    if game:on_command_pressed(command) then
      return true
    end 
  end
  for menu in sol.menu.menus() do
    if menu.on_command_pressed then
      if menu:on_command_pressed(command) then  
        return true
      end
    end
  end
  if game:get_map() and game:get_map().on_command_pressed then
    if game:get_map().on_command_pressed(command) then
      return true
    end
  end
end

local function custom_command_keyboard(game, key)
  if game.custom_keyboard_binding[key] then
    fire_command_event(game, game.custom_keyboard_binding[key])
  end
end
meta:register_event("on_key_pressed", custom_command_keyboard)

local function start_callback(game)
  game.command_effect = {
    --nothing at the start of the game
  }

  game.custom_keyboard_binding = {
    backspace = "select"
  }

  game.custom_joypad_bindings = {
    
  }

  game:set_command_keyboard_binding("action", "space")
  game:set_command_keyboard_binding("attack", "p")
  game:set_command_keyboard_binding("item_1", "k")
  game:set_command_keyboard_binding("item_2", "o")
  game:set_command_keyboard_binding("right", "d")
  game:set_command_keyboard_binding("up", "z")
  game:set_command_keyboard_binding("left", "q")
  game:set_command_keyboard_binding("down", "s")
  game:set_command_keyboard_binding("pause", "return")


end
meta:register_event("on_started", start_callback)

