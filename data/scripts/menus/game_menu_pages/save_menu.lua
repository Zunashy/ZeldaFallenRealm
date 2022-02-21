local save_menu = {
    bg_surface = nil,
    cursor = 1,
    origin_menu = nil,
    view_cursor = true,

    full_screen = true
}

local cursor_pos = {
    x = 33,
    y = 57,
    offset = 24,
}

save_menu.cursor_surface = sol.surface.create("menus/save_cursor.png")

local button_effects = {
    "continue",
    "save",
    "save_quit"
}

function save_menu:blink_cursor_cycle(callback)
    self.blink_timer = sol.timer.start(self.game_menu, 100, function()
        save_menu.view_cursor = false
        save_menu.blink_timer = sol.timer.start(self.game_menu, 100, function()
            save_menu.blink_count = self.blink_count + 1
            if save_menu.blink_count > 3 then
                self.cursor_blinking = false
                callback()
            else
                save_menu.view_cursor = true
                save_menu:blink_cursor_cycle(callback)
            end
        end)
    end)
end

function save_menu:blink_cursor(callback)
    self.cursor_blinking = true
    self.blink_count = 0 
    self:blink_cursor_cycle(callback)
end

--button effects
function save_menu:button_continue()
    self.game_menu.game:set_paused(false)
end

function save_menu:button_save()
    self.game_menu.game:oow_save()
    self.game_menu.game:set_paused(false)
end

function save_menu:button_save_quit()
    self.game_menu.game:oow_save()
    sol.main.exit()
end

--SUBMENU METHODS
function save_menu:on_started()
    self.view_cursor = true
end

function save_menu:on_draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    if self.view_cursor then
        local x, y = cursor_pos.x, cursor_pos.y + cursor_pos.offset * (self.cursor - 1)
        self.cursor_surface:draw(dst_surface, x, y)
    end
end

function save_menu:on_command_pressed(command)
    if self.cursor_blinking then return true end 
    if command == "sword" or command == "select" then
        self.game_menu.current_page = self.origin_page
    elseif command == "up" then
        self.cursor = self.cursor - 1
        if self.cursor < 1 then self.cursor = 3 end
    elseif command == "down" then
        self.cursor = self.cursor + 1
        if self.cursor > 3 then self.cursor = 1 end
    elseif command == "action" then
        local effect = self["button_"..button_effects[self.cursor]]
        self:blink_cursor(function() effect(self) end)
    end
end

function save_menu:on_closed()
    if self.blink_timer then self.blink_timer:stop() end
end

function save_menu:preload()
    self.bg_surface = self.game_menu.lang:load_image("menus/save_menu")
end

return save_menu
