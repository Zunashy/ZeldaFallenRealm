-- Lua script of custom entity grass.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created() 

  _,__,w,h = entity:get_bounding_box()
  xBase,yBase,layer = entity:get_position() 

  for x = xBase,xBase + w - 8,16 do
  for y = yBase,yBase + h - 8,16 do
    
  map:create_destructible({
 
  sprite = "entities/grass_dark",
  can_be_cut = true,
  ground = "grass",
 x = x, y = y, layer = layer --Étrangement, mettre le get_position ici ne marchait pas
})

  self:remove()

end
end

  
end
