-- Lua script of item ice_seed.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

local floor = math.floor

local range = 8
 
local stc = {
  {-4, -8},
  {4, -8},
  {-4, 0},
  {4, 0}
}

-- Event called when the game is initialized.
function item:on_started()
  self:set_savegame_variable("ice_seed_possession")
  self:set_amount_savegame_variable("ice_seed_amount")
  self:set_assignable(true)
end

local function check_ground(map, x, y, layer)
  return map:get_ground(x, y, layer) == "deep_water" or map:get_ground(x, y, layer) == "shallow_water"
end

local function create_big_tile(map, x, y, layer)
  local e = map:create_custom_entity({
    model = "ice_floor",
    direction = 0,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16
  })
end

local function create_small_tile(map, x, y, layer, position)
  local e = map:create_custom_entity({
    model = "ice_floor",
    direction = 0,
    layer = layer,
    x = x,
    y = y,
    width = 8,
    height = 8,
  })
  e:get_sprite():set_animation("ice_floor_" .. position)
  e:set_origin(4, 5)
end

local bit = require("scripts/api/bit")
local function create_small_tiles(map, x, y, layer, control)
  local n = 1
  for i in bit.get_bits(control, 4) do
    if i==1 then
      create_small_tile(map, x + stc[n][1], y + stc[n][2], layer, n)
    end
    n = n + 1
  end
end

-- Event called when the hero is using this item.
function item:on_using()
  -- On récupère les coordonnées du héros +16 (une tile) dans la direction où il regarde
  local hero = game:get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  -- On regarde toutes les entitées dans un petit rectangle autour de ces coordonnées
  --[[for entity in self:get_map():get_entities_in_rectangle(x-2, y-2, 5, 5) do
    -- S'il s'agit d'une entité custom d'eau profonde
    if entity:get_type() == "custom_entity" and entity.is_deep_water and not entity.is_frozen then
      -- On met en premier plan le sprite de glace, on met un terran traversable et on indique que ce n'est plus de l'eau
      entity:bring_sprite_to_front(entity:get_sprite("ice_floor"))
      entity:set_modified_ground("traversable")
      entity.is_frozen = true
      -- Après 5 secondes, on annule nos changements pour ravoir la case d'eau
      -- On pourrait imaginer avoir un 3ème sprite de glace fissurée qu'on affiche au bout de 4 secondes 
      sol.timer.start(entity, 5000, function()
        entity:bring_sprite_to_front(entity:get_sprite("deep_water"))
        entity:set_modified_ground("deep_water")
        entity.is_frozen = false
      end)
    end]]
	
	x, y = gen.shift_direction4(x, y, direction, range)
	x = floor(x / 16) * 16 + 8; y = floor(y / 16) * 16 + 13	
	
	local map = game:get_map()
  
  local control = 0
  for i = 1, 4 do
    if check_ground(map, x + stc[i][1], y + stc[i][2], layer) then
      control = control + 2^(i-1)
    end
  end

  if control == 15 then
    create_big_tile(map, x, y, layer)
  else
    create_small_tiles(map, x, y, layer, control)
  end

  item:set_finished()
end
