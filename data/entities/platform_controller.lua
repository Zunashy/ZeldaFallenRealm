local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:read_properties()
  local p = self:get_property("direction")
  if p then p = tonumber(p) end
  if 0 < p and p < 4 then
    self.direction = p 
  end  

end

function collision_callback(e)
  
end

-- Event called when the custom entity is initialized.
function entity:on_created()
  self:read_properties()
end
