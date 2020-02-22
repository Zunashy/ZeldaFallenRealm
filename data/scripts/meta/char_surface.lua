local char_surface = {}  --the object contaning everything related to char surfaces (like sol.surface)
local meta = {}          --the metatable of char surface objects

local fonts = require("scripts/api/image_fonts")

--===== CHAR SURFACES METATABLE (METHODS and METAMETHODS) ======
function meta:set_font(font, load)
  assert(type(font) == "string", "Bad argument #1 to set_font : font must be a font name (string)")
  self.font = font

  self.font_obj = nil
  self.loaded_font = ""

  if load ~= false and self.loaded_font ~= font then
    self.font_obj = fonts:new(font, load ~= true)
    assert(self.font_obj, "set_font : Can't find the specified font")
    self.loaded_font = font
  end
end

function meta:get_font()
  return self.font
end

function meta:get_surface()
  return self.surface
end

function meta:add_char(char, font)
  local code = char
  if type(char) == "string" then
    code = char:byte()
  end 
  assert(type(code) == "number", "Bad argument #1 to add_char: char must be a string or a number (code point)")

  font = font or self.font
  assert(type(font) == "string", "Bad argument #2 to add char : font must be a font name (string)")
 
  local font_obj
  if self.font_obj and font == self.loaded_font then
    font_obj = self.font_obj 
  else 
    font_obj = fonts:new(font)
  end
  assert(font_obj, "Can't find the specified font")

  local char_w = font_obj:get_char_size()
  font_obj:draw_char(code, self.surface, self.x, 0)
  self.x = self.x + char_w
end

function meta:write(text, font)
  for c in text:gmatch"." do
    self:add_char(c, font)
  end  
end

function meta:clear()
  self.surface:clear()
  self.x = 0
end

function meta:draw(...)
  return self.surface:draw(...)
end

function meta.__index(t, k) --The only actual metamethod here
--When we try to index a char surface object, lua will search for properties in the meta object itself and then in the surface object
  return meta[k] or t.surface[k]
end

--==========

--Binding making the metatable acessible as a property of char_surface
char_surface.mt = meta

--The creation function
function char_surface.create(w, h, font, load_font)
  local surf = {}
  surf.surface = sol.surface.create(w, h) --Initializes the actual surface as a property of the char surface objects
  surf.x = 0
  surf.w = w
  surf.h = h
  surf.is_char_surface = true

  setmetatable(surf, meta)  --Sets meta (aka char_surface.mt) as the metatable for the new object
  surf:set_font(font, load_font)
  return surf
end


gen.char_surface = char_surface