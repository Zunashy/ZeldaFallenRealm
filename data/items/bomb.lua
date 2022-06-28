-- Bombs item.
local item = ...
local game = item:get_game()

local game = item:get_game()

local max_values = {
  20, 50, 100
}
local throw_speed = 200

item.explosion_delay = 3000
item.explosion_soon = 1500

item.state = sol.state.create()

function item:on_created()

  self:set_savegame_variable("bomb_bag")
  self:set_amount_savegame_variable("bomb_amount")
  self:set_assignable(true)

  self.state:set_can_control_direction(true)
  self.state:set_can_control_movement(true)
  self.state:set_can_use_sword(false)
  self.state:set_can_use_item(false)
  self.state:set_can_interact(false)
  self.state:set_can_grab(false)
  self.state:set_can_push(false)
  self.state.item = self
end

local function state_movement_callback(self)
  if self:get_speed() > 0 then
    self.hero:set_animation("carrying_walking")
  else
    self.hero:set_animation("carrying_stopped")
  end    
end

function item.state:on_started()
  local hero = self:get_entity()
  hero:set_animation("carrying_stopped")
  hero:get_movement().on_changed = state_movement_callback
  hero:get_movement().hero = hero
  self.bomb_sprite = hero:create_sprite("entities/projectile/bomb")
  self.bomb_sprite:set_xy(0, -15) -- 1.7 : remplacer la valeur par hero:get_carry_height()
  self.start_time = sol.main.get_elapsed_time()

  sol.timer.start(self, item.explosion_soon, function()
    item.state.bomb_sprite:set_animation("explosion_soon")
  end)

  sol.timer.start(self, item.explosion_delay, function()
    item.state:explode()
  end)
end

function item.state:on_finished(s) --todo
  local hero = self:get_entity()
  hero:remove_sprite(self.bomb_sprite)

  if s ~= "free" then
    self:drop_bomb(hero)
  end
end

function item.state:on_command_pressed(command)
  if command == "action" then
    self:throw_bomb()
  end
end

function item.state:create_bomb(hero, direction)
  local x, y, layer = hero:get_position()
  local bomb = hero:get_map():create_custom_entity({
    direction = direction,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
    model = "bomb"
  })
  bomb:init(sol.main.get_elapsed_time() - self.start_time, 15)

  return bomb
end

function item.state:explode()
  local bomb = self:drop_bomb()
  local x, y = bomb:get_position()
  bomb:set_position(x, y - 1)
  bomb:BOOM()
end

--Goes from "the hero is holding the bomb" to "the bomb and the hero exist independently"
function item.state:drop_bomb(hero)
  local hero = self:get_entity()
  return self:create_bomb(hero, hero:get_direction())
end

function item.state:throw_bomb()
  local hero = self:get_entity()
  local direction = hero:get_direction()

  local bomb = self:drop_bomb(hero, direction)

  local movement = sol.movement.create("straight")
  movement:set_speed(throw_speed)
  movement:set_angle((math.pi / 2) * direction)
  movement:start(bomb)
end

function item:on_obtained(variant)
  if variant ~= self:get_variant() then
    self:set_variant(variant)
    self:set_max_amount(max_values[variant])
    self:set_amount(self:get_max_amount())
    print(self:get_amount(), self:get_max_amount())
  end
end

-- Called when the player uses the bombs of his inventory by pressing
-- the corresponding item key.
function item:on_using()
  local hero = game:get_hero()

  if hero:get_state_object() == self.state then
    self.state:throw_bomb()
  else
    if self:get_amount() > 0 then
      self:remove_amount(1)
      hero:start_state(self.state)
    end
  end
  item:set_finished()
end

