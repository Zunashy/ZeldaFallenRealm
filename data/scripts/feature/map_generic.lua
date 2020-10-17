--/!\ the generic map features are no longer stored in a global module/object, they are now in the map meta
local map = sol.main.get_metatable("map")
mpg = map


--Opens or closes all doors that have the name format 'door_<name>*'
function map:open_door(name)
  if type(name) == "number" then name = tostring(name) end
  if not self then return end
  self:open_doors(name)
  self:open_doors("door_"..name)
end

function map:close_door(name)
  if type(name) == "number" then name = tostring(name) end
  if not self then return end
  self:close_doors(name)
  self:close_doors("door_"..name)
end

local parse_event_string = require("scripts/feature/event_string")

--Enable an entity with a specified name on the specified map (or disables it, depending on state)
function map:enable_entity(name)
  self = self or sol.main.game:get_map()
  local prop, force
  
  for e in self:get_entities(name) do
  
    force = e:get_property("force_spawn")
    
    if force or not (
    (e:get_type() == "door" and not e:is_closed()) or 
    (e:get_type() == "enemy" and not  e:exists())) then
        
      
      
      e:set_enabled(true)
      prop = e:get_property("spawn_savegame_variable")
      if prop then
        self:get_game():set_value(prop, true)
      end
      
      prop = e:get_property("spawn_trigger")
      if prop and not (e:get_type() == "door" and not e:is_closed()) then 
        parse_event_string(self, prop) 
      end
    end
  end

  if self.separator_manager_enabled then
    for _, enemy in ipairs(self:get_stored_enemies()) do
      if enemy.name and enemy.name:starts(name) then
        enemy.is_enabled = true
      end
    end 
  end
end

function map:disable_entity(name)
  self = self or sol.main.game:get_map()
  local prop, force
  
  for e in self:get_entities(name) do    
    e:set_enabled(false)
    prop = e:get_property("spawn_savegame_variable")
    if prop then
      self:get_game():set_value(prop, false)
    end
  end
end

--Callback for the trigger 'death' : added tothe on_dead event callback of enemies linked to a death_trigger. (checks if other enemies linked with this trigger are still alive, if not launches the linked event)
local function death_trigger_callback(enemy)
  local map = enemy:get_map()
  local event = enemy:get_property("death_trigger")  --the event is the value of the 'death_trigger' custom prop
  local last_to_die = true   --considering that this enemy is the last alive

  if not event then return end

  for e in map:get_entities_by_type("enemy") do
    local o_event = e:get_property("death_trigger")
    if o_event and o_event == event and not (e == enemy) then  --testing if there is any other enemy, alive, with this trigger
      last_to_die = false  
    end
  end
  if last_to_die then  --if no such enemy was found, launches the event
    parse_event_string(map, event)
  end
end

local function activate_trigger_callback(entity)
  local map = entity:get_map()
  local event = entity:get_property("activate_trigger")
  local all_activated = true

  if not event then return end

  local var = entity:get_property("savegame_variable")
  if var and map:get_game():get_value(var) then
    return
  end

  for e in map:get_entities() do
    local o_event = e:get_property("activate_trigger")
    if o_event and o_event == event and e.is_activated and not e:is_activated() then
      all_activated = false
    end
  end
  if all_activated then
    parse_event_string(map, event)
  end
end

local function spawn_loot(enemy, item, variant, save_var)
	if enemy:get_game():get_value(save_var) then return end
  local x, y, layer = enemy:get_position()
  
  local ground = enemy:get_map():get_ground(x, y, layer)
  if ground == "deep_water" or ground == "lava" or ground == "hole" then
    x = enemy.hurt_x
    y = enemy.hurt_y
  end
	
	enemy:get_map():create_pickable({
		layer = layer,
		x = x,
		y = y,
		treasure_name = item,
		treasure_variant = variant,
		treasure_savegame_variable = save_var,
	})
end

local function group_loot_callback(enemy)
	enemy.dead = true
  local map = enemy:get_map()
  local loot = enemy:get_property("group_loot")  --the item looted (and additional informations) are the value of the property "group loot"
  local last_to_die = true   --considering by default that this enemy is the last alive

  local item, variant, save_var

  item, save_var = loot:xfields("$") -- the name of the save var is after the "$", if any
  item, variant = item:xfields("#") -- the variant of the item is after the "#", if any
  variant = variant and tonumber(variant) or 1

  if not loot then return end
  for e in map:get_entities_by_type("enemy") do
    local o_loot = e:get_property("group_loot")
    if o_loot and o_loot == loot and not (e == enemy) and not e.dead then  --testing if there is any other enemy, alive, with this group loot
      last_to_die = false  
    end
  end
  
  if last_to_die then  --if no such enemy was found, launches the event
    --enemy:register_event("on_dead", function(e)  spawn_loot(e, item, variant, save_var)end)
	  spawn_loot(enemy, item, variant, save_var)
  end
end

function map:init_enemies_event_triggers()
  for e in self:get_entities_by_type("enemy") do
    if e:get_property("death_trigger") then
      e:register_event("on_dead", death_trigger_callback)
    end
    if e:get_property("group_loot") then
      e:register_event("on_dead", group_loot_callback)
    end
  end
end

function map:init_activate_triggers()
  for e in self:get_entities() do
    if e:get_property("activate_trigger") then
      e:register_event("on_activated", activate_trigger_callback)
    end
  end
end

local function block_move_callback(block)
    block.activated = true
    if block.on_activated then
      block:on_activated()
    end
end

function map:init_activatables()
  for e in self:get_entities_by_type("block") do
    if e:get_property("activate_when_moved") then
      function e:is_activated()
        return self.activated
      end

      e.old_reset = sol.main.get_metatable("block").reset 
      function e:reset()
        self.activated = false
        self:old_reset()
      end
      e:register_event("on_moved", block_move_callback) 
    end
  end
end

local function detect_open_callback(door)
  local map = door:get_map()
  local name = door:get_name()
  if not name then return end
  name = name:field("_", 2)
  map.open_door(map, name)
end

function map:init_detect_open()
    
  for e in self:get_entities_by_type("door") do
    if e:get_property("detect_open") then
      e:register_event("on_opened", detect_open_callback)
    end
  end
end

local side_view = require("scripts/api/map_side_view")

function map:init_side_view()
  side_view:init(self)
end

local separator_manager = require("scripts/api/separator_manager")

function map:init_reset_separators(default)
  separator_manager:manage_map(self, default)
end

function map:init_dungeon_features()

  self:init_enemies_event_triggers()
  self:init_activate_triggers()
  self:init_activatables()
  self:init_detect_open()  
  self:init_reset_separators()
end

local colored_block_manager = require("entities/colored_block")
function map:enable_colored_blocks()
  self.colored_block_manager = colored_block_manager
  for block in self:get_entities("colored_block") do
    colored_block_manager.init(block)
  end
end

--Map Manager
local map_manager = require("scripts/api/map_manager")

function map:discover(cases)
  local x, y
  for i, v in ipairs(cases) do
    x, y = v[1], v[2]
    map_manager.map[y][x] = 1
  end
  map_manager:save_discovered(self:get_game())
end

return map