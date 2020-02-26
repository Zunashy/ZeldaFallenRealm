local name_menu  = {
  name = "Save name prompt", 

  surface = nil,
  background_surface = nil,
  name_cursor_surface = nil,
  name_surface = nil,
  keyboard_cursor_surface = nil,

  blue_font = nil,

  name_cursor = 1, --starts at 1 to match lua convention (since it will be used as a table index)
  current_text = {}, --array of char codes
  keyboard_cursor = {0, 0},
}

local fonts = require("scripts/api/image_fonts")
name_menu.blue_font = fonts:new("oracle_blue")
name_menu.black_font = fonts:new("oracle_black")

local black_char_code = 161

local name_cursor_pos = {
  x = 80, 
  y = 13,
  w = 8,
  h = 11
}

local keyboard_cursor_pos = {
  x = 24,
  y = 45,
  w = 8,
  h = 16,
  midoffset = 16
}

local ok_pos = {
  x = 120,
  y = 136
}

local max_name_len = 6
local name_surface_color = {gen.splitColor(0xDECB18)}

name_menu.surface = sol.surface.create(sol.video.get_quest_size())
name_menu.background_surface = sol.surface.create("menus/enter_name.png")
name_menu.name_cursor_surface = sol.surface.create("menus/enter_name_cursor1.png")
name_menu.ok_cursor_surface = sol.surface.create("menus/enter_name_cursor2.png")
name_menu.name_surface = sol.surface.create(name_cursor_pos.w * max_name_len, name_cursor_pos.h)

local char_w, char_h = name_menu.blue_font:get_char_size()
name_menu.keyboard_cursor_surface = sol.surface.create(16, char_h + 2)

function name_menu:get_keyboard_cursor_key()
  return unpack(self.keyboard_cursor)
end

function name_menu:set_keyboard_cursor_key(x, y)
  self.keyboard_cursor[1] = x or self.keyboard_cursor[1]
  self.keyboard_cursor[2] = y or self.keyboard_cursor[2]
end

function name_menu:get_keyboard_cursor_pos()

  if self.keyboard_cursor[2] == 5 then
    return ok_pos.x, ok_pos.y
  end

  local cx, cy = self:get_keyboard_cursor_key()
  local offset = cx > 5 and keyboard_cursor_pos.midoffset or 0  

  return  
    keyboard_cursor_pos.x + cx * keyboard_cursor_pos.w + offset, 
    keyboard_cursor_pos.y + cy * keyboard_cursor_pos.h

end

function name_menu:get_keyboard_selection() --can be a character code but also an option like "ok"
  local x, y = self:get_keyboard_cursor_key()
	
  if y == 5 then --on est sur la ligne des commandes
    return -1
  elseif x < 6 then -- on est dans la partie des majs
    local pos = y * 6 + x 
    return 65 + pos
  else 
    local pos = y * 6 + (x - 6)
    return 97 + pos
  end
end

function name_menu:rebuild_keyboard_cursor_surface()  
  self.blue_font:draw_char(black_char_code, self.keyboard_cursor_surface)
  local k = self:get_keyboard_selection()

  self.keyboard_cursor_surface:clear()
  if k == -1 then
    self.ok_cursor_surface:draw(self.keyboard_cursor_surface)
  else
    self.name_cursor_surface:draw(self.keyboard_cursor_surface, 0, char_h)
	  self.blue_font:draw_char(k, self.keyboard_cursor_surface)
  end
end

function name_menu:erase_char(pos)
  self.name_surface:fill_color(name_surface_color, name_cursor_pos.w * (pos - 1), 
    0, name_cursor_pos.w, name_cursor_pos.h)
end

function name_menu:rebuild_surface()
  self.background_surface:draw(self.surface)
  self.name_cursor_surface:draw(self.surface, 
    name_cursor_pos.x + name_cursor_pos.w * (self.name_cursor - 1), 
    name_cursor_pos.y + name_cursor_pos.h)
  self.name_surface:draw(self.surface, name_cursor_pos.x, name_cursor_pos.y)
  self:rebuild_keyboard_cursor_surface()
  self.keyboard_cursor_surface:draw(self.surface, self:get_keyboard_cursor_pos())
end

function name_menu:make_name_string()
  return string.char(unpack(self.current_text))
end

function name_menu:on_draw(dst_surf)
  self.surface:draw(dst_surf)
end

function name_menu:on_started()
  self:rebuild_surface()
end

function name_menu:on_command_pressed(command)
  local x, y = self:get_keyboard_cursor_key()
  if command == "right" then
    x = x + 1
    if x > 11 then
      x = 0
    end
    self:set_keyboard_cursor_key(x, nil)
  elseif command == "left" then
    x = x - 1
    if x < 0 then
      x = 11
    end
    self:set_keyboard_cursor_key(x, nil)
  elseif command == "up" then
    y = y - 1
    if y < 0 then
      y = 5
    end
    self:set_keyboard_cursor_key(nil, y)
  elseif command == "down" then
    y = y + 1
    if y > 5 then
      y = 0
    end
    self:set_keyboard_cursor_key(nil, y)
  elseif command == "action" then
    local char_code = self:get_keyboard_selection()
    if char_code == -1 then
      if self.current_text[1] == nil then return end
      self.arguments.game:set_value("name", self:make_name_string())
      sol.menu.stop(self)
      self.arguments.game_manager:start_game(self.arguments.game)
    end
    if self.current_text[self.name_cursor] then
      self:erase_char(max_name_len)
    end
      self.black_font:draw_char(char_code, self.name_surface, name_cursor_pos.w * (self.name_cursor - 1), 0)
    self.current_text[self.name_cursor] = char_code
    if self.name_cursor < max_name_len then
      self.name_cursor = self.name_cursor + 1
    end
  elseif command == "attack" then
    self.current_text[self.name_cursor] = nil
    self:erase_char(self.name_cursor)
    if self.name_cursor > 1 then 
      self.name_cursor = self.name_cursor - 1
    end
  else 
    return
  end

  self:rebuild_surface()
  
end

return name_menu