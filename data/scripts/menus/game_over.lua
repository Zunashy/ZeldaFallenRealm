local game_over = {
    name = "Game Over",
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

local game

game_over.cursor_surface = sol.surface.create("menus/save_cursor.png")

local button_effects = {
    "continue",
    "save",
    "save_quit"
}

function game_over:blink_cursor_cycle(callback)
    self.blink_timer = sol.timer.start(self, 100, function()
        game_over.view_cursor = false
        game_over.blink_timer = sol.timer.start(game_over, 100, function()
            game_over.blink_count = self.blink_count + 1
            if game_over.blink_count > 3 then
                self.cursor_blinking = false
                callback()
            else
                game_over.view_cursor = true
                game_over:blink_cursor_cycle(callback)
            end
        end)
    end)
end

local function restart_game(game)
    game:set_life(game:get_max_life())
    game:start()
end

function game_over:blink_cursor(callback)
    self.cursor_blinking = true
    self.blink_count = 0 
    self:blink_cursor_cycle(callback)
end

--button effects
function game_over:button_continue()
    restart_game(game)
    sol.menu.stop(self)
end

function game_over:button_save()
    game:save()
    restart_game(game)
    sol.menu.stop(self)
end

function game_over:button_save_quit()
    game:save()
    sol.main.exit()
    sol.menu.stop(self)
end

--SUBMENU METHODS

function game_over:on_started()
    self.view_cursor = true
    sol.audio.play_music("game_over")
end

function game_over:on_draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    if self.view_cursor then
        local x, y = cursor_pos.x, cursor_pos.y + cursor_pos.offset * (self.cursor - 1)
        self.cursor_surface:draw(dst_surface, x, y)
    end
end

function game_over:on_command_pressed(command)
    if self.cursor_blinking then return true end 
    if command == "up" then
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

function game_over:on_closed()
    if self.blink_timer then self.blink_timer:stop() end
end


local function bind_to_game(game_)
    game = game_
    game_over.bg_surface = require("scripts/api/language_manager"):load_image("menus/game_over_menu")
end

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", bind_to_game)

return game_over
