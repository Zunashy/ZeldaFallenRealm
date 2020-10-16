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
      sol.audio.play_music(name)
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
      map:enable_entity(name)
    elseif event:starts("flash") then
      vfx.flash(tonumber(event:sub(7) or 20), {255, 255, 255})
    end
end

local function parse_event_string(map, s)
    for event in s:fields(";") do
        trigger_event(map, event)
    end
end

return parse_event_string