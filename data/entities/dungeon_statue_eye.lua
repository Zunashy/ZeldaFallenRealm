-- Lua script of custom entity dungeon_statue_eye.
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
local x, y = 0, 0
--local sprite = sol.sprite.create("entities/dungeon_statue_eye")

local coords = {
  {x = 1, y = 0},
  {x = 0, y = 0},
  {x = 0, y = 1},
  {x = 1, y = 1}
}

local s = sol.surface.create(1, 1)
s:fill_color({0, 0, 0})

local function get_draw_pos()
  oX, oY = entity:get_position()
  return x + oX, y + oY
end

function entity:get_hero_angle()
  return self:get_angle(hero)
end

local function update_eye_pos()
  local angle = entity:get_hero_angle()
  for i = 1, 4 do
    if angle < (math.pi / 2) * i then
      x, y = coords[i].x, coords[i].y      
      break
    end
  end
  return true
end

-- Event called when the custom entity is initialized.
function entity:on_created()
  update_eye_pos()
  sol.timer.start(entity, 50, update_eye_pos)
end

function entity:on_post_draw()
  map:draw_visual(s,get_draw_pos())
end