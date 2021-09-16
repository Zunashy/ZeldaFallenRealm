local vfx = require("scripts/api/visual_effects")

local function trigger_event(map, event)
    if not type(event) == "string" then return end
    local name
      
    if event:starts("door_") then  --event type : opening a door
      map:open_door(event:sub(6))   --opening all doors having the name specified after "door_"
    elseif event:starts("close_door") then
      map:close_door(event:sub(11))
    elseif event:starts("treasure_") then  --Event type: item spawn
      name = event:sub(10)
      if map:has_entity(name) then
        map:enable_entity(name)   --Enabling the item with this name
      else 
        map:enable_entity(event)
      end
    elseif event:starts("spawn_") then
      name = event:sub(7)
      map:enable_entity(name)
    elseif event:starts("function_") then
      name = event:sub(10)
      if type(map[name]) == "function" then
        map[name](map)
      end
    elseif event:starts("music_") then
      name = event:sub(7)
      if name == "none" then
        sol.audio.stop_music()
      else
        sol.audio.play_music(name)
      end
    elseif event:starts("setrespawn_") then
      name = event:sub(12)
      local e = map:get_entity(name)
      if e and e:get_type() == "destination" then
        map:get_game():set_starting_location(map:get_id(), name)
      end
    elseif event:starts("teleport_") then
      name = event:sub(10)
      local name, style = name:xfields("$")
      local map_name, dest = name:xfields(":")
      if map_name == "here" then
        map_name = map:get_id()
      end
      map:get_hero():teleport(map_name, dest, style)
    elseif event:starts("disable_") then
      name = event:sub(9)
      map:disable_entity(name)
    elseif event:starts("flash") then
      vfx.flash(tonumber(event:sub(7) or 20), {255, 255, 255})
    end
end

local effects = {}

function effects.open(map, arg)
  map:open_door(arg)
end
effects.door = effects.open
effects.open_door = effects.open

function effects.close_door(map, arg)
  map:close_door(arg)
end

function effects.spawn(map, arg)
  map:enable_entity(arg)
end

function effects.trasure(map, arg)
  local entity = map:get_entity(arg)
  if entity then
    entity:set_enabled(true)   --Enabling the item with this name
  else 
    map:enable_entity("treasure_"..arg)
  end
end

function effects.function_(map, arg)
  local fname, args = arg:xfields("$")

  if type(map[fname]) == "function" then 
    map[fname](args:xfields(","))
  end
end

function effects.music(map, arg)
  if (not arg) or arg == "none" then
    sol.audio.stop_music()
  else
    sol.audio.play_music(arg)
  end
end

function effects.setrespawn(map, arg)
  local e = map:get_entity(arg)
  if e and e:get_type() == "destination" then
    map:get_game():set_starting_location(map:get_id(), arg)
  else
    print("Tried to set destination " .. arg .. " (which doesn't exist or isn't a destination) as the respawn point")
  end
end

function effects.teleport(map, arg)
  local dest, style = arg:xfields("$")
  local map_name, dest = dest:xfields(">")

  if style == "light" then
    map:get_hero():light_teleport(dest, map)
    return
  end

  if map_name == "here" then
    map_name = map:get_id()
  end
  map:get_hero():teleport(map_name, dest, style)
end

function effects.disable(map, arg)
  map:disable_entity(arg)
end

function effects.flash(map, arg)
  vfx.flash(tonumber(arg or 20), {255, 255, 255})
end

local function trigger_event(map, event)
  if not type(event) == "string" then return end
  local effect, arg = event:xfields(":")
  if effect then
    return effects[effect] and effects[effect](map, arg)
  end
end

local function parse_event_string(map, s)
    for event in s:fields(";") do
        trigger_event(map, event)
    end
end

return parse_event_string