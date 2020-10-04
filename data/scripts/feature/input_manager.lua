local controls = require("scripts/api/controls_manager") --API des commandes

--== INPUT MANAGEMENT CALLBACKS ==--

--Starts a "command pressed" event for when solarus doesn't do it (custom commands / game not started)
local function fire_command_event(game, command)
  if game and game.on_command_pressed then
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
  if game and game:get_map() and game:get_map().on_command_pressed then
    if game:get_map().on_command_pressed(command) then
      return true
    end
  end
end

function sol.main:on_key_pressed(key) --manages commands if no game is started (solarus only manages them if a game is started)
  if not sol.main.get_game() then
    local commands = controls:get_keyboard_bindings()
    for k, v in pairs(commands) do
      if v == key then
        fire_command_event(nil, k)
      end
    end
  end
end

function sol.main:on_joypad_button_pressed(button)
  print(type(button), button)
end

local meta = sol.main.get_metatable("game") --what comes after this line is about the input management during a game

--DEBUG COMMANDS FUNCTION
local vfx = require("scripts/api/visual_effects")
function meta:on_key_pressed(key, modifiers) --manages inputs upstream of the commands management
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
    sol.main.game:get_hero():teleport("tests/blue_slime")
  elseif key == "f3" then
    sol.main.game:set_life(12)  
  elseif key == "f7" then
    print(sol.main.game:get_value("small_keys"))
  elseif key == "f8" then
    sol.main.game:get_hero():teleport("donjons/level_01/RDC")
  elseif key == "f9" then
    vfx.shockwave(sol.main.game:get_map():get_camera():get_surface(), 64, 64, 1, 10, 30, 0.4)
  end

  return handled
end

--Command effects management : why did i even do this lol
function meta:set_custom_command_effect(command, fun)
  self.command_effect[command] = fun
end

function meta:get_custom_command_effect(command)
  return self.command_effect[command]
end

--When a key is pressed, tests if it is bound with a custom command
local function custom_command_keyboard(game, key) --manages custom commands
  for k, v in pairs(game.custom_keyboard_binding) do
    if v == key then
      fire_command_event(game, k)
    end
  end
end
meta:register_event("on_key_pressed", custom_command_keyboard)

--MAIN COMMAND MANAGER
local start_map_menu = require("scripts/menus/map")
function meta:on_command_pressed(command) --manages commands that aren't directly managed by solarus
  if type(self.command_effect[command]) == "function" then
    return self.command_effect[command](game)
  end

  if command == "select" and not self:is_suspended() then
    start_map_menu(self)
    return true
  end
end

--== OTHER CALLBACKS AND FUNCTIONS ==--

local commands = {
  action = true,
  attack = true,
  item_1 = true,
  item_2 = true,
  right = true,
  up = true,
  left = true,
  down = true,
  pause = true,
}

local custom_commands = {
  select = true
}
for k, v in pairs(custom_commands) do commands[k] = v end

local function start_callback(game) --initializes the command bindings lists and apply controls loaded by the controls manager
  game.command_effect = {
    --nothing at the start of the game
  }

  game.custom_keyboard_binding = {

  }

  game.custom_joypad_bindings = {
    
  }
  controls:apply(game, commands)
end
meta:register_event("on_started", start_callback)


local set_command_keyboard_binding_old = meta.set_command_keyboard_binding
-- overriding the command binding function of game objects
function meta:set_command_keyboard_binding(command, key) --uses the built-in binding function for the built-in commands and adds the command to the custom commands list used by the custom commands manager for custom commands
  assert(commands[command], "Bad argument #1 to game:set_command_keyboard_binding : "..tostring(command).." is not a game command.")
  assert(self.custom_keyboard_binding, "Custom commands haven't been initalized yet")
  if custom_commands[command] then
    self.custom_keyboard_binding[command] = key
  else --at this point we are sure command is a built-in a command
    set_command_keyboard_binding_old(self, command, key)
  end
end

