--WIP

local name_menu  = {
  name = "Save name prompt", 

  surface = nil,
  background_surface = nil,
  name_cursor_surface = nil,
  keyboard_cursor_surface = nil,

  blue_font = nil,

  name_cursor = 0,
  keyboard_cursor = 0,
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

function name_menu:rebuild_surface(dst_surf)
  self.background_surface:draw(self.surface)
  self.name_cursor_surface:draw(self.surface, name_cursor_pos.x, name_cursor_pos.y)
  self.keyboard_cursor_surface:draw(self.surface, self:get_keyboard_cursor_pos())
end

function name_menu:get_selected_char()
  return 65
end

function name_menu:get_keyboard_cursor_pos()
  return 0, 0
end

function name_menu:rebuild_keyboard_cursor_surface()  
  self.blue_font:draw_char(black_char_code, self.keyboard_cursor_surface)
  self.blue_font:draw_char(self:get_selected_char(), self.keyboard_cursor_surface)
end

function name_menu:on_draw(dst_surf)
  self.surface:draw(dst_surf)
end