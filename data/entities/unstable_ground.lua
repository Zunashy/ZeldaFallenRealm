-- Lua script of custom entity unstable_ground.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()

local crumble_delay = 1000
local fall_delay = 1000

local shake = eg.shake

local function start_shaking()
  shake(entity, 1, 1, 100, nil)
end

local function destroy()
  entity:remove()
end

local function check_hero()
  return entity:overlaps(hero, "origin")
end

-- Event called when the custom entity is initialized.
function entity:on_created()
  local is_hero_here = false
  local get_time =  sol.main.get_elapsed_time
  local start_time = 0

  sol.timer.start(self, 40, function()
    if check_hero() then
      if not is_hero_here then
        is_hero_here = true
        start_time = get_time()
      else
        if get_time() > start_time + crumble_delay then
          start_shaking()
          sol.timer.start(self, fall_delay, function()
            destroy()
          end)
          return false
        end
      end
    else
      is_hero_here = false
    end
    return true
  end)

  self:set_modified_ground("traversable")
end
