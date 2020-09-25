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
  hero.need_solid_ground = false
  local ground = hero:get_ground_below();
  if (ground ~= "deep_water"
    and ground ~= "hole"
    and ground ~= "lava"
    and ground ~= "prickles"
    and ground ~= "empty"
    and hero.is_on_nonsolid_ground == false
    and not self.no_save)
  then 
    hero:save_solid_ground()
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

local enemy_meta = sol.main.get_metatable("enemy")
function enemy_meta:set_attacks_consequence(consequence)
  self:set_attack_consequence("sword", consequence)
  self:set_attack_consequence("thrown_item", consequence)
  self:set_attack_consequence("explosion", consequence)
  self:set_attack_consequence("arrow", consequence)
  self:set_attack_consequence("hookshot", consequence)
  self:set_attack_consequence("boomerang", consequence)
  self:set_attack_consequence("fire", consequence)
end

local dest_meta = sol.main.get_metatable("destructible")
function dest_meta:is_flammable()
  local sprite_name = self:get_sprite():get_animation_set()
  return name == "tree" or name == "grass"
end

function dest_meta:on_cut()
  if self:get_sprite():has_animation("cut") then
    local x, y, layer = self:get_position()
    local entity = self:get_map():create_custom_entity({
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      sprite = self:get_sprite():get_animation_set(),
      width = 32,
      height = 32,
    })
    entity:get_sprite():set_animation("cut")
  end
end

local carried_meta = sol.main.get_metatable("carried_object")
local visu = require("scripts/debug/visualizer")

function carried_meta:on_thrown()
  visu:start_visualization(self:get_map(), 0, 0, 0, 0)
  local co = self
  sol.timer.start(self, 10, function()
    local x, y = co:get_position()
    visu:set_position(x, y, 10, 10)
    return true
  end)

  local _, y = self:get_position()
  self.throw_y = y
end

function carried_meta:on_breaking()
  local x = self:get_position()
  self:set_position(x, self.throw_y)
end  

local switch_meta = sol.main.get_metatable("switch")

function switch_meta:on_interaction()
  self:set_activated(true)
end