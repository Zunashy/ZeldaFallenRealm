local map_menu = {
    name = "Minimap Menu",
    map_view_tw = 15, --in tiles
    map_view_th = 15,
    cw = 30, 
    ch = 30,
    arrows_offset = 8,

    cx = 0,
    cy = 0,
    camera_cx = 0,
    camera_cy = 0,
    display_cx = 0,
    display_cy = 0
}

map_menu.map_view_w = map_menu.map_view_tw * 8
map_menu.map_view_h = map_menu.map_view_th * 8
map_menu.max_camera_cx = map_menu.cw - map_menu.map_view_tw
map_menu.max_camera_cy = map_menu.ch - map_menu.map_view_th

map_menu.map_image = sol.surface.create("menus/map_menu_old.png")
map_menu.bg_image = sol.surface.create("menus/map_menu_bg.png")
map_menu.cursor_surface = sol.surface.create("menus/map_cursor.png")
map_menu.mask_surface = sol.surface.create("menus/map_mask.png")
map_menu.masked_map_surface = sol.surface.create(map_menu.map_image:get_size())
map_menu.render_surface = sol.surface.create(sol.video.get_quest_size())

map_menu.arrow_sprites = {}
for i = 1, 4 do
    local sprite = sol.sprite.create("menus/map_arrow")
    sprite:set_direction(i - 1)
    sprite:stop_animation()
    map_menu.arrow_sprites[i] = sprite
end


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

map_menu.arrow_sprites[1].x = map_pos.x + map_menu.map_view_w - map_menu.arrows_offset; 
map_menu.arrow_sprites[1].y = map_pos.y + (map_menu.map_view_h / 2)
map_menu.arrow_sprites[2].x = map_pos.x + (map_menu.map_view_w / 2)
map_menu.arrow_sprites[2].y = map_pos.y + map_menu.arrows_offset
map_menu.arrow_sprites[3].x = map_pos.x + map_menu.arrows_offset
map_menu.arrow_sprites[3].y = map_pos.y + (map_menu.map_view_h / 2)
map_menu.arrow_sprites[4].x = map_pos.x + (map_menu.map_view_w / 2)
map_menu.arrow_sprites[4].y =  map_pos.y + map_menu.map_view_h - map_menu.arrows_offset

local current

--Map manager
local map_manager = require("scripts/api/map_manager")

--Methods

function map_menu:start_arrow_sprite(i)
    map_menu.arrow_sprites[i]:set_animation("default")
end

function map_menu:update_arrow_sprites()
    self.arrow_sprites[1].enabled = self.camera_cx < self.max_camera_cx
    self.arrow_sprites[2].enabled = self.camera_cy > 0
    self.arrow_sprites[3].enabled = self.camera_cx > 0
    self.arrow_sprites[4].enabled = self.camera_cy < self.max_camera_cy
end


function map_menu:update_cursor_h()
    local dx = self.cx - self.camera_cx

    if (dx > 11 and self.camera_cx < self.max_camera_cx) then
        self.camera_cx = self.camera_cx + 1 
        self.arrow_sprites[3].enabled = true
        self.arrow_sprites[1].enabled = self.camera_cx < self.max_camera_cx
        self:render_map()
    elseif (dx < 2 and self.camera_cx > 0) then
        self.camera_cx = self.camera_cx - 1 
        self.arrow_sprites[1].enabled = true
        self.arrow_sprites[3].enabled = self.camera_cx > 0
        self:render_map()
    end

    self.display_cx = self.cx - self.camera_cx
end

function map_menu:update_cursor_v()
    local dy = self.cy - self.camera_cy

    if (dy > 11 and self.camera_cy < self.max_camera_cy) then
        self.camera_cy = self.camera_cy + 1 
        self.arrow_sprites[2].enabled = true
        self.arrow_sprites[4].enabled = self.camera_cy < self.max_camera_cy
        self:render_map()
    elseif (dy < 2 and self.camera_cy > 0) then
        self.camera_cy = self.camera_cy - 1
        self.arrow_sprites[4].enabled = true 
        self.arrow_sprites[2].enabled = self.camera_cy > 0
        self:render_map()
    end

    self.display_cy = self.cy - self.camera_cy
end

function map_menu:cursor_right()
    self.cx = self.cx + 1
    if self.cx > self.cw - 1 then 
        self.cx = 0 
        self.camera_cx = 0
        self.display_cx = 0
        self:render_map()
        self.arrow_sprites[3].enabled = false
        self.arrow_sprites[1].enabled = true 
    else
        self:update_cursor_h() 
    end

end

function map_menu:cursor_up()
    self.cy = self.cy - 1
    if self.cy < 0 then 
        self.cy = self.ch - 1
        self.camera_cy = self.max_camera_cy
        self.display_cy = self.cy - self.camera_cy
        self:render_map()
        self.arrow_sprites[4].enabled = false
        self.arrow_sprites[2].enabled = true 
    else 
        self:update_cursor_v()
    end  

end

function map_menu:cursor_left()
    self.cx = self.cx - 1
    if self.cx < 0 then 
        self.cx = self.cw - 1 
        self.camera_cx = self.max_camera_cx
        self.display_cx = self.cx - self.camera_cx 
        self:render_map()
        self.arrow_sprites[1].enabled = false
        self.arrow_sprites[3].enabled = true 
    else 
        self:update_cursor_h()
    end 
end

function map_menu:cursor_down()
    self.cy = self.cy + 1
    if self.cy > self.ch - 1  then  
        self.cy = 0  
        self.camera_cy = 0
        self.display_cy = 0
        self:render_map()
        self.arrow_sprites[2].enabled = false
        self.arrow_sprites[4].enabled = true 
    else 
        self:update_cursor_v()
    end  

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

function map_menu:mask_map()
    local x, y = 0, 0
    self.map_image:draw(self.masked_map_surface, map_pos.x + 1, map_pos.y + 1)
    for i = 1, 15 do
        x = map_pos.x
        for j = 1, 15 do
            if not (map_manager.map[i][j] == 1) then
                --self.mask_surface:draw(self.masked_map_surface, x, y)
            end
            x = x + 8
        end
        y = y + 8
    end
end

function map_menu:render_map()
    map_menu.bg_image:draw(map_menu.render_surface)
    local rx, ry = self.camera_cx * 8, self.camera_cy * 8
    map_menu.map_image:draw_region(rx, ry, map_menu.map_view_w, map_menu.map_view_h, map_menu.render_surface, map_pos.x, map_pos.y)
end

--MENU METHODS
function map_menu:on_started()
    self.game:set_suspended(true)
    self:mask_map()
    self:render_map()
    self.cx, self.cy = 0, 0

    for i = 1, 4 do
        map_menu.arrow_sprites[i]:set_animation("default")
    end
    self:update_arrow_sprites()
end

function map_menu:on_finished()
    if self.cursor_right_timer then self.cursor_right_timer:stop() end
    if self.cursor_top_timer then self.cursor_top_timer:stop() end
    if self.cursor_left_timer then self.cursor_left_timer:stop() end
    if self.cursor_down_timer then self.cursor_down_timer:stop() end
    self.game:set_suspended(false)

    for i = 1, 4 do
        map_menu.arrow_sprites[i]:stop_animation()
    end
end

function map_menu:on_draw(dst_surface)
    self.render_surface:draw(dst_surface)
    local x = cursor_pos.tl_offset.x + cursor_pos.offset * self.display_cx
    local y = cursor_pos.tl_offset.y + cursor_pos.offset * self.display_cy
    self.cursor_surface:draw(dst_surface, x, y)
    for i = 1, 4 do
        local sprite = self.arrow_sprites[i]
        if sprite.enabled then
            sprite:draw(dst_surface, sprite.x, sprite.y)
        end
    end
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
game_meta:register_event("on_init", start_callback)

return start_menu