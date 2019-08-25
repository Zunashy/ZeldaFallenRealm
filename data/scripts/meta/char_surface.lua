local char_surface = {}  --the object contaning everything related to char surfaces (like sol.surface)
local meta = {}          --the metatable of char surface objects

--===== CHAR SURFACES METATABLE (METHODS and METAMETHODS) ======
function meta:set_font(font, load)
  assert(type(font) == "string", "Bad argumennt #1 to set_font : font must be a font name (string)")
  self.font = font

  self.font_surf = nil
  self.loaded_font = ""
  
  if load and not self.loaded_font == font then
    self.font_surf = sol.surface.create("fonts/"..font..".png")
    assert(self.font_surf, "set_font : Can't find the specified font")
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
 
  local font_surf
  if self.font_surf and font == self.loaded_font then
    font_surf = self.font_surf 
  else 
    font_surf = sol.surface.create("fonts/"..font..".png")
  end
  assert(font_surf, "Can't find the specified font")

  local font_w, font_h = font_surf:get_size()
  local char_w, char_h = font_w / 128, font_h / 16

  local origin_x, origin_y = char_w * (code % 128), char_h * math.floor(code / 128)
  local dst_x = self.x

  font_surf:draw_region(origin_x, origin_y, char_w, char_h, self.surface, dst_x, 0)
  self.x = dst_x + char_w
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
function char_surface.create(w, h, font)
  local surf = {}
  surf.surface = sol.surface.create(w, h) --Initializes the actual surface as a property of the char surface objects
  surf.font = font
  surf.x = 0
  surf.w = w
  surf.h = h
  surf.font_surf = nil
  surf.loaded_font = ""
  surf.is_char_surface = true
  setmetatable(surf, meta)  --Sets meta (aka char_surface.mt) as the metatable for the new object

  return surf
end

gen.char_surface = char_surface