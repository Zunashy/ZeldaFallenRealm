local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local head_sprite
local shield_sprite

local move_range = 8
local movement_speed = 16

local hand_offset = {
  x = 40,
  y = 32
}

local function rock_lift_callback(self)
  if not (self.waiting or self.protected) then
    if gen.random() > 0.5 then
      self.left_hand:protect(-8)
    else
      self.right_hand:protect(8)
    end
  end 
end

local function rock_release_callback(self)
  if self.protected then
    sol.timer.start(self.protected, 200, function()
      self.protected:start_movement()
      self.protected = false
    end)
  end
end

function enemy:on_created()
  head_sprite = enemy:create_sprite("enemies/boss/rock_mosquito")
  shield_sprite = enemy:create_sprite("enemies/boss/rock_mosquito_shields")
  self:bring_sprite_to_back(shield_sprite)
  head_sprite:set_direction(0)
  shield_sprite:set_direction(0)

  head_sprite:set_xy(0, 0)

  self:set_invincible_sprite(shield_sprite)
  self:set_attacks_consequence_sprite(head_sprite, "protected")
  self:set_attack_consequence_sprite(head_sprite, "thrown_item", 1)

  self:set_life(4)
  self:set_damage(0)
  self:set_pushed_back_when_hurt(false)

  self.left_hand = self:create_enemy({
    x = -hand_offset.x,
    y = hand_offset.y,
    breed = "boss/rock_mosquito_hand",
    direction = 0,
    name = "left_hand",
    properties = {
      no_reset = "1"
    }
  })
  self.left_hand.no_reset = true
  self.right_hand = self:create_enemy({
    x = hand_offset.x,
    y = hand_offset.y,
    name = "right_hand",
    breed = "boss/rock_mosquito_hand",
    direction = 0
  })
  self.right_hand.no_reset = true

  self.left_hand.rm = self
  self.right_hand.rm = self

  self.left_hand.other_hand = self.right_hand
  self.right_hand.other_hand = self.left_hand

  self.left_hand.rm_position = {
    x = hand_offset.x,
    y = -hand_offset.y,
  }
  self.right_hand.rm_position = {
    x = -hand_offset.x,
    y = -hand_offset.y,
  }

  self.waiting = true

  map:add_hero_state_callback(rock_lift_callback, "carrying", false, self) 
  map:add_hero_state_callback(rock_release_callback, "carrying", true, self) 
end

function enemy:start_movement() 
  local x, y
  local angle = gen.random() * math.pi * 2
  local norm = gen.random(move_range)
  x = norm * math.cos(angle)
  y = norm * math.sin(angle)

  local m = sol.movement.create("target")
  m:set_speed(movement_speed)
  m:set_target(x,  y)
  m:start(head_sprite, function() enemy:start_movement() end)
end

function enemy:on_restarted() 
  if not self.waiting then
    self:start_movement()
  end
end

local function hurt_cb(self)
  if self.waiting then
    self.waiting = false
    sol.audio.play_music("boss", true)
    self.left_hand:start()
    self.right_hand:start()
    self:start_movement()
  end

  for entity in map:get_entities_by_type("destructible") do  
    local destroy_entity
    if entity.is_rock then
      local x, y, layer = entity:get_position()
      local destroy_entity = self:get_map():create_custom_entity({
        direction = 0,
        layer = layer,
        x = x,
        y = y,
        sprite = "entities/projectile/rock",
        width = 16,
        height = 16,
      })
      destroy_entity:get_sprite():set_animation("destroy", function()
        destroy_entity:remove()
      end)
      entity:remove()
    end
  end

end

function enemy:on_dying()
  self.left_hand:remove_life(999)
  self.right_hand:remove_life(999)
end

enemy:register_event("on_hurt", hurt_cb)
