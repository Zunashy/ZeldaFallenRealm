local block_meta = sol.main.get_metatable("block")
function block_meta:on_removed()
  local ground = self:get_ground_below()
  if ground == "hole" then
    local map = self:get_map()
    local x, y, layer = self:get_position()
    local entity = self:get_map():create_custom_entity({
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      sprite = self:get_sprite():get_animation_set(),
      width = 16,
      height = 16,
    })
    local sprite = entity:get_sprite()
    sprite:set_animation("falling", function()
      local x, y, layer = entity:get_position()
      local direction = sprite:get_direction()
      if direction == 0 then
        x = x + 8
      elseif direction == 1 then
        y = y - 4
      elseif direction == 2 then
        x = x - 8
      elseif direction == 3 then
        y = y + 12
      end
      entity:set_position(x, y, layer)
      entity:set_modified_ground("empty")
      sprite:set_animation("falling_vertical", function()
        entity:remove()
      end)
    end)
    sprite:set_direction((2 + self:get_direction4_to(self:get_map():get_hero())) % 4)
    entity:set_modified_ground("wall")
  end
end

local sensor_meta = sol.main.get_metatable("sensor")

function sensor_meta:on_created()
  if self:get_property("persistent") then
    self.persistent = true 
  end
end

function sensor_meta:on_activated()
  if self.persistent and self.activated then
    return true
  end
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
  if self.no_save then return end
  hero = self:get_map():get_hero()
  local ground = hero:get_ground_below();
  if (ground ~= "deep_water"
   and ground ~= "hole"
   and ground ~= "lava"
   and ground ~= "prickles"
   and ground ~= "empty"
   and not hero.is_on_nonsolid_ground)
  then 
    print("save_solid")
    hero:save_solid_ground()
  else
    hero.need_solid_ground = true
  end
end

local npc_meta = sol.main.get_metatable("npc")

local function npc_interaction(npc)
  local dialog = npc:get_property("dialog")
  if dialog then
    npc:get_game():start_dialog(dialog)
    return true
  end
end

npc_meta:register_event("on_interaction", npc_interaction)

local function exclam_anim_cb(self)
  self.entity:remove_sprite(self)
  if self.callback then
    self.callback(self, self.entity)
  end
end

function npc_meta:exclamation(callback)
  local sprite = self:create_sprite("things/exclamation")
  sprite:set_xy(0, -16)
  sol.audio.play_sound("exclamation")
  sprite.callback = callback
  sprite.entity = self

  sol.timer.start(self,300,function()
    exclam_anim_cb(sprite)
    end)
end

function npc_meta:set_dialog(dialog)
  self:set_property("dialog", dialog)
end

sol.main.get_metatable("hero").exclamation = npc_meta.exclamation

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

function enemy_meta:set_attacks_consequence_sprite(sprite, consequence)
  self:set_attack_consequence_sprite(sprite, "sword", consequence)
  self:set_attack_consequence_sprite(sprite, "thrown_item", consequence)
  self:set_attack_consequence_sprite(sprite, "explosion", consequence)
  self:set_attack_consequence_sprite(sprite, "arrow", consequence)
  self:set_attack_consequence_sprite(sprite, "hookshot", consequence)
  self:set_attack_consequence_sprite(sprite, "boomerang", consequence)
  self:set_attack_consequence_sprite(sprite, "fire", consequence)
end

function enemy_meta:on_hurt()
  local x, y = self:get_position()
  self.hurt_x = x
  self.hurt_y = y
end

function enemy_meta:on_dead()
  self.dead = true
  local prop = self:get_property("savegame_variable") 
  if prop then
    self:get_game():set_value(prop, true)
  end
end

function enemy_meta:on_removed()
  local ground = self:get_ground_below()
  if ground == "deep_water" then
    local map = self:get_map()
    local x, y, layer = self:get_position()
    local entity = self:get_map():create_custom_entity({
      direction = 0,
      layer = layer,
      x = x,
      y = y,
      sprite = "enemies/plunging_water",
      width = 16,
      height = 16,
    })
    entity:get_sprite():set_animation("plunging", function()
      entity:remove()
    end)
  end
end


local function is_dug_ground(entity)
  local prop = entity:get_property("dig_variable")
  return prop and entity:get_game():get_value(prop)
end


--called only when removing a dig tp because variable set
local function check_dig_tp(entity)
  prop = entity:get_property("dig_map")
  if prop then
    local destination = entity:get_property("dig_destination")
    local x, y, layer = entity:get_position()
    local w, h = entity:get_size()
    entity:get_map():create_teletransporter({
      x = x - 8,
      y = y - 13,
      layer = layer,
      width = w,
      height = h,
      sprite = "entities/ground/dug_stairs",
      transition = "fade",
      destination_map = prop,
      destination = destination
    })
  end
end

local dynatile_meta = sol.main.get_metatable("dynamic_tile")
function dynatile_meta:on_created()
  if is_dug_ground(self) then --this dynatile had saved dig info
    check_dig_tp(self)  --we check if it was a TP and act accordingly
  end
end

local dest_meta = sol.main.get_metatable("destructible")

function dest_meta:on_created()
  local prop = self:get_property("savegame_variable")
  if prop and self:get_game():get_value(prop) or is_dug_ground(self) then
    check_dig_tp(self)
    self:remove()
  end

  local t, v, variable = self:get_treasure()
  if variable and self:get_game():get_value(variable) then
    self:get_map():create_hole(self)
    self:remove()
  end
end

function dest_meta:is_flammable()
  local sprite = self:get_sprite():get_animation_set()
  return (sprite:starts("entities/vegetation/grass/grass")) or (sprite == "entities/vegetation/arbuste") or (sprite == "entities/vegetation/grass_door")
end

function dest_meta:on_destroyed()
  local prop = self:get_property("savegame_variable")
  if prop then
    self:get_game():set_value(prop, true)
  end
end

function dest_meta:cut()
  self:on_cut()
  self:remove()
end

function dest_meta:attempt_cut()
  if self:get_can_be_cut() then
    self:cut()
  end
end

function dest_meta:hit_with_explosion()
  self:on_exploded()
  self:remove()
end

function dest_meta:on_exploded()
  if self:get_sprite():has_animation("exploded") then
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
    entity:get_sprite():set_animation("exploded", function()
      entity:remove()
    end)
  end
  self:on_destroyed()
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
    entity:get_sprite():set_animation("cut", function()
      entity:remove()
    end)
  end
  self:on_destroyed()
end

function dest_meta:on_lifting(hero, carried_object)
  local prop = self:get_property("savegame_variable")
  if prop then
    carried_object.destructible_savegame_var = prop
  end

  carried_object.destructible_on_thrown = self.on_thrown
end

local carried_meta = sol.main.get_metatable("carried_object")

function carried_meta:on_thrown()
  local co = self

  local _, y = self:get_position()
  self.throw_y = y

end

function carried_meta:on_breaking()
  local x, y = self:get_position()
  local direction = self:get_movement():get_direction4()
  if direction % 2 == 1 then
    local _, sprite_y = self:get_sprite():get_xy()
    self:set_position(x, y - sprite_y)
  elseif direction % 2 == 0 then
    self:set_position(x, self.throw_y)
  end

  if self.destructible_on_thrown then
    self:destructible_on_thrown()
  end

  if self.destructible_savegame_var then
    self:get_game():set_value(self.destructible_savegame_var, true)
  end
end  

local switch_meta = sol.main.get_metatable("switch")

function switch_meta:on_interaction()
  self:set_activated(true)
end

local camera_meta = sol.main.get_metatable("camera")

function camera_meta:get_position_on_camera(x, y)
  local cx, cy = self:get_position()
  return x - cx, y - cy
end