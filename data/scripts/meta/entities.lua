local sensor_meta = sol.main.get_metatable("sensor")

function sensor_meta:on_created()
  if self:get_property("persistent") then
    self.persistent = true 
  end
end

function sensor_meta:on_activated()
  self.activated = true
end

function sensor_meta:on_left()
  if not self.persistent then 
    self.activated = false
  end
end

function sensor_meta:is_activated()
  return self.activated
end

local sep_meta = sol.main.get_metatable("separator")

function sep_meta:on_created()
  if self:get_property("no_save") then
    self.no_save = true
  end
end

function sep_meta:on_activated()
  hero = self:get_map():get_hero()
  local ground = hero:get_ground_below();
  if (ground ~= "deep_water"
    and ground ~= "hole"
    and ground ~= "lava"
    and ground ~= "prickles"
    and ground ~= "empty"
    and hero.is_on_nonsolid_ground == false
    and not self.no_save)
  then hero:save_solid_ground()
  end
end

local npc_meta = sol.main.get_metatable("npc")
local function npc_interaction(npc)
  local dialog = npc:get_property("dialog")
  if dialog then
    npc:get_game():start_dialog(dialog)
  end
end
npc_meta:register_event("on_interaction", npc_interaction)