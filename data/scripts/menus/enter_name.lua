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

local black_char_code = 121

local name_cursor_pos = {
  x = 80, y = 24
}

name_menu.surface = sol.surface.create(sol.video.get_quest_size())
name_menu.background_surface = sol.surface.create("menus/enter_name.png")
name_menu.name_cursor_surface = sol.surface.create("menus/enter_name_cursor1.png")

function name_menu:get_keyboard_cursor_pos()
  return unpack(self.keyboard_cursor)
end

function name_menu:get_keyboatd_selection() --can be a character code but also an option like "ok"
  local x, y = self:get_keyboard_cursor_pos()
	
  if y == 5 then //on est sur la ligne des commandes
    return nil
  elseif x < 6 then // on est dans la partie des majs
    local pos = y * 6 + x 
      return 65 + pos
  else 
    local pos = y * 6 + (x - 6)
    return 97 + pos
  end
end

function name_menu:rebuild_keyboard_cursor_surface()  
  self.blue_font:draw_char(black_char_code, self.keyboard_cursor_surface)
  
  local k = self:get_keyboatd_selection()
  if k == -1 then
	--JE SAIS PAS PUTAIN
  else
	self.blue_font:draw_char(k, self.keyboard_cursor_surface)
  end
end

function name_menu:rebuild_surface()
  self.background_surface:draw(self.surface)
  self.name_cursor_surface:draw(self.surface, name_cursor_pos.x, name_cursor_pos.y)
  self.keyboard_cursor_surface:draw(self.surface, self:get_keyboard_cursor_pos())
end

function name_menu:on_draw(dst_surf)
  self.surface:draw(dst_surf)
end

function name_menu:on_started()
  self:rebuild_surface()
end
