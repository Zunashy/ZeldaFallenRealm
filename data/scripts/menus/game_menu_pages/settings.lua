local settings_menu = {
    bg_surface = nil,
    origin_page = nil,
    cursor = 1
}

local first_button_pos = {
    x = 32,
    y = 24
}

settings_menu.bg_surface = sol.surface.create("menus/settings_menu.png")
settings_menu.cursor_surface = sol.surface.create("menus/settings_cursor.png")

--SUBMENU METHODS

function settings_menu:draw(dst_surface)
    settings_menu.bg_surface:draw(dst_surface)
    local x = first_button_pos.x - 12
    local y = first_button_pos.y + 2 + (self.cursor - 1) * 20

    self.cursor_surface:draw(dst_surface, x, y)
end

function settings_menu:on_page_selected()
    settings_menu.cursor = 1
end

function settings_menu:on_started(game)
    local controls_surface = self.game_menu.lang:load_image("menus/controls")
    local x, y = first_button_pos.x, first_button_pos.y
    controls_surface:draw(self.bg_surface, x, y)
end

return settings_menu