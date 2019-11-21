--WIP

local name_menu  = {
  name = "Save name prompt", 

  surface = nil,
  background_surface = nil,
  name_cursor_surface = nil,
  keyboard_cursor_surface = nil,

  blue_font = nil,

  name_cursor = 0,
  keyboard_cursor = {0, 0}
}

local fonts = require("scripts/api/image_fonts")
name_menu.blue_font = fonts:new("oracle_blue")

local black_char_code = 161

local name_cursor_pos = {
  x = 80, y = 24
}

local keyboard_cursor_pos = {
  x = 24,
  y = 45,
  w = 8,
  h = 16,
  midoffset = 16
}

name_menu.surface = sol.surface.create(sol.video.get_quest_size())
name_menu.background_surface = sol.surface.create("menus/enter_name.png")
name_menu.name_cursor_surface = sol.surface.create("menus/enter_name_cursor1.png")

local char_w, char_h = name_menu.blue_font:get_char_size()
name_menu.keyboard_cursor_surface = sol.surface.create(char_w, char_h + 2)

function name_menu:get_keyboard_cursor_key()
  return unpack(self.keyboard_cursor)
end

function name_menu:set_keyboard_cursor_key(x, y)
  self.keyboard_cursor[1] = x or self.keyboard_cursor[1]
  self.keyboard_cursor[2] = y or self.keyboard_cursor[2]
  tprint(self.keyboard_cursor)
end

function name_menu:get_keyboard_cursor_pos()

  local cx, cy = self:get_keyboard_cursor_key()
  local offset = cx > 5 and keyboard_cursor_pos.midoffset or 0  

  return  
    keyboard_cursor_pos.x + cx * keyboard_cursor_pos.w + offset, 
    keyboard_cursor_pos.y + cy * keyboard_cursor_pos.h

end

function name_menu:get_keyboard_selection() --can be a character code but also an option like "ok"
  local x, y = self:get_keyboard_cursor_key()
	
  if y == 5 then --on est sur la ligne des commandes
    return nil
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

  if k == -1 then
	--JE SAIS PAS PUTAIN
  else
    self.name_cursor_surface:draw(self.keyboard_cursor_surface, 0, char_h)
	  self.blue_font:draw_char(k, self.keyboard_cursor_surface)
  end
end

function name_menu:rebuild_surface()
  self.background_surface:draw(self.surface)
  self.name_cursor_surface:draw(self.surface, name_cursor_pos.x, name_cursor_pos.y)
  self:rebuild_keyboard_cursor_surface()
  self.keyboard_cursor_surface:draw(self.surface, self:get_keyboard_cursor_pos())
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
      y = 4
    end
    self:set_keyboard_cursor_key(nil, y)
  elseif command == "down" then
    y = y + 1
    if y > 4 then
      y = 0
    end
    self:set_keyboard_cursor_key(nil, y)
  else 
    return
  end

  self:rebuild_surface()
  
end

return name_menu