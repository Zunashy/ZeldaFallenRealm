-- Lua script of item ice_seed.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()
  self:set_savegame_variable("ice_seed")
  self:set_assignable(true)
end

function item:on_obtaining()
  -- Automatically assign the item to a command slot
  -- if nothing is assigned.
  if game:get_item_assigned(1) == nil then
    game:set_item_assigned(1, self)
  elseif game:get_item_assigned(2) == nil then
    game:set_item_assigned(2, self)
  end
end

-- Event called when the hero is using this item.
function item:on_using()
  -- On récupère les coordonnées du héros +16 (une tile) dans la direction où il regarde
  local hero = self:get_map():get_entity("hero")
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 16
  elseif direction == 1 then
    y = y - 16
  elseif direction == 2 then
    x = x - 16
  elseif direction == 3 then
    y = y + 16
  end

  -- On regarde toutes les entitées dans un petit rectangle autour de ces coordonnées
  for entity in self:get_map():get_entities_in_rectangle(x-2, y-2, 5, 5) do
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
    end
  end

  item:set_finished()
end

-- Event called when a pickable treasure representing this item
-- is created on the map.
function item:on_pickable_created(pickable)

  -- You can set a particular movement here if you don't like the default one.
end
