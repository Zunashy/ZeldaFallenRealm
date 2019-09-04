local map_menu = {
    cx = 0,
    cy = 0,
    name = "Minimap Menu"
}

map_menu.bg_surface = sol.surface.create(sol.video.get_quest_size())
map_menu.bg_surface:fill_color({0, 0, 0})
map_menu.cursor_surface = sol.surface.create("menus/map_cursor.png")
map_menu.map_surface = sol.surface.create("menus/map_menu.png")
map_menu.mask_surface = sol.surface.create("menus/map_mask.png")

local cursor_pos = {
    offset = 8,
    tl_offset = {
        x = 16, 
        y = 8
    }
}

local map_pos = {
    x = 20,
    y = 12,
}

--Map manager
local map_manager = require("scripts/managers/map_manager")

--Methods

function map_menu:cursor_right()
    self.cx = self.cx + 1
    if self.cx > 14 then self.cx = 0 end
end

function map_menu:cursor_up()
    self.cy = self.cy - 1
    if self.cy < 0 then self.cy = 14 end  
end

function map_menu:cursor_left()
    self.cx = self.cx - 1
    if self.cx < 0 then self.cx = 14 end  
end

function map_menu:cursor_down()
    self.cy = self.cy + 1
    if self.cy > 14 then self.cy = 0 end
end

function map_menu:start_cursor_timer(direction)
    local callback = map_menu["cursor_"..direction]

    self["cursor_"..direction.."_timer"] = sol.timer.start(self, 400, function()
        if not map_menu.game:is_command_pressed(direction) then return false end
        map_menu["cursor_"..direction.."_timer"] = sol.timer.start(map_menu, 50, function()
            if not map_menu.game:is_command_pressed(direction) then return false end
            callback(map_menu)
            return true
        end)
        return false
    end)
end

--MENU METHODS
function map_menu:on_started()
    self.game:set_suspended(true)

    local x, y = map_pos.x, map_pos.y
    self.map_surface:draw(self.bg_surface, 20, 12)
    for i = 1, 15 do
        x = map_pos.x
        for j = 1, 15 do
            if not (map_manager.map[i][j] == 1) then
                self.mask_surface:draw(self.bg_surface, x, y)
            end
            x = x + 8
        end
        y = y + 8
    end
    self.cx, self.cy = 0, 0
end

function map_menu:on_finished()
    if self.cursor_right_timer then self.cursor_right_timer:stop() end
    if self.cursor_top_timer then self.cursor_top_timer:stop() end
    if self.cursor_left_timer then self.cursor_left_timer:stop() end
    if self.cursor_down_timer then self.cursor_down_timer:stop() end
    self.game:set_suspended(false)
end

function map_menu:on_draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    local x = cursor_pos.tl_offset.x + cursor_pos.offset * self.cx
    local y = cursor_pos.tl_offset.y + cursor_pos.offset * self.cy
    self.cursor_surface:draw(dst_surface, x, y)
end

function map_menu:on_command_pressed(command)
    if command == "right" then
        self:cursor_right()
    elseif command == "up" then
        self:cursor_up()
    elseif command == "left" then
        self:cursor_left()
    elseif command == "down" then
        self:cursor_down()
    else
        if command == "select" then
            sol.menu.stop(self) 
        end
        return
    end

    self:start_cursor_timer(command)
end

function map_menu:on_command_released(command)
    if command == "right" and self.cursor_right_timer then
        self.cursor_right_timer:stop()
        self.cursor_right_timer = nil
    elseif command == "top" and self.cursor_top_timer then
        self.cursor_top_timer:stop()
        self.cursor_top_timer = nil
    elseif command == "left" and self.cursor_left_timer then
        self.cursor_left_timer:stop()
        self.cursor_left_timer = nil
    elseif command == "down" and self.cursor_top_timer then
        self.cursor_down_timer:stop()
        self.cursor_down_timer = nil
    end
end

--====== BINDING THE MENU TO THE GAME ======

local function start_menu(game)
    sol.menu.start(game, map_menu)
end

function map_menu:bind_to_game(game)
    game.map_menu = self
    self.game = game
end 

local function start_callback(game)
    map_menu:bind_to_game(game)     
end

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", start_callback)

return start_menu