local save_select = {
    name = "Save selection",
    surface = nil,   
    background_surface = nil,
    cursor_surface = nil,
    cursor = 1,
    saves = {},
    link_sprite = nil,
    hearts_img = nil,
    mode = 1, -- 1 : sélection normale (save ou bouton settings) ; 2 : options de save, boutons du bas (erase)
    selected_save = 0,
    draw_link = false
}

local cursor_pos = {
    {x = 8, y = 53},
    {x = 8, y = 77},
    {x = 8, y = 101},
    {x = 37, y = 121},
    footer = {
        {x = 34, y = 122},
        {x = 90, y = 122}
    }
}

local save_name_pos = {
    x = 24,
    y = 54,
    offset = 24
}

local link_pos = {
    x = 88,
    y = 75,
}

local hearts_pos = {
    x = 80, 
    y = 81
}

local exists, game, name, name_surface

local footer_y = 120

local game_manager = require("scripts/game_manager")
local enter_name_menu = require("scripts/menus/enter_name")
local settings_menu = require("scripts/menus/game_menu_pages/settings")
local lang = require("scripts/api/language_manager")

save_select.surface = sol.surface.create(sol.video.get_quest_size())

save_select.background_surface = lang:load_image("menus/save_select")
save_select.cursor_surface = sol.surface.create("menus/save_select_cursor.png")
save_select.cursor_bw_surface = sol.surface.create("menus/save_select_cursor_bw.png")
save_select.alt_footer_surface = lang:load_image("menus/save_select_footer")

save_select.link_sprite = sol.sprite.create("hero/tunic1")
save_select.link_sprite:set_animation("walking")
save_select.link_sprite:set_direction(3)

save_select.hearts_surface = sol.surface.create(60, 12)
save_select.hearts_img = sol.surface.create("hud/hearts.png")

function save_select:draw_hearts(life, max_life, ox, oy)

    self.hearts_surface:clear()

    for j = 1, max_life do
        if j % 4 == 0 then
            local x, y
            if j <= 20 then
                x = 2 * (j - 4)
                y = 0
            else
                x = 2 * (j - 24)
                y = 8
            end
            if life >= j then
                self.hearts_img:draw_region(0, 0, 8, 8, self.surface, ox + x, oy + y)
            else
                self.hearts_img:draw_region(32, 0, 8, 8, self.surface, ox + x, oy + y)
            end
        end
    end
    if life % 4 == 3 then
        local x, y
        if life <= 20 then
            x = 2 * (life - 3)
            y = 0
        else
            x = 2 * (life - 23)
            y = 8
        end
        self.hearts_img:draw_region(8, 0, 8, 8, self.surface, ox + x, oy + y)
    end

    if life % 4 == 2 then
        local x, y
        if life <= 20 then
            x = 2 * (life - 2)
            y = 0
        else
            x = 2 * (life - 22)
            y = 8
        end
        self.hearts_img:draw_region(16, 0, 8, 8, self.surface, ox + x, oy + y)
    end

    if life % 4 == 1 then
        local x, y
        if life <= 20 then
            x = 2 * (life - 1)
            y = 0
        else
            x = 2 * (life - 21)
            y = 8
        end
        self.hearts_img:draw_region(24, 0, 8, 8, self.surface, ox + x, oy + y)
    end
end

function save_select:rebuild_surface()
    self.background_surface:draw(self.surface)
    local game = self.mode == 1 and self.saves[self.cursor] or self.saves[self.selected_save]
    if self.mode > 1 or (self.cursor < 4 and self.saves[self.cursor].initialized) then
        self.draw_link = true
        if game and game.initialized then
            local life = game:get_life()
            local max_life = game:get_max_life()
            self:draw_hearts(life, max_life, hearts_pos.x, hearts_pos.y)
        end
    else
        self.draw_link = false
    end
    if self.mode > 1 then
        self.alt_footer_surface:draw(self.surface, 0, footer_y)
        self.cursor_bw_surface:draw(self.surface, cursor_pos[self.selected_save].x, cursor_pos[self.selected_save].y)
        if self.mode == 3 then 
            self.cursor_bw_surface:draw(self.surface, cursor_pos.footer[1].x, cursor_pos.footer[1].y)
        end
    end

    local cursor_pos_array = self.mode == 2 and cursor_pos.footer or cursor_pos
    self.cursor_surface:draw(self.surface, cursor_pos_array[self.cursor].x, cursor_pos_array[self.cursor].y)
end

function save_select:true_rebuild_surface()
    local y = save_name_pos.y
    for i = 1, 3 do
        game = self.saves[i]

        if game.initialized then
            name = game:get_value("name")
            name_surface = gen.char_surface.create(49, 11, "oracle")
            name_surface:write(name)
            name_surface:draw(self.background_surface, save_name_pos.x, y)
        end
        y = y + save_name_pos.offset
    end

    self:rebuild_surface()
end


function save_select:on_draw(dst_surface)
    self.surface:draw(dst_surface)
    if self.draw_link then
        self.link_sprite:draw(dst_surface, link_pos.x, link_pos.y)
    end
end

function save_select:on_command_pressed(command)
    if command == "up" then
        if self.mode == 1 then
            if self.cursor == 1 then
                self.cursor = 4
            else
                self.cursor = self.cursor - 1
            end
        elseif self.mode == 3 then
            self.cursor = 6 - self.cursor - self.selected_save
        end
        self:rebuild_surface()
    elseif command == "down" then
        if self.mode == 1 then
            if self.cursor == 4 then
                self.cursor = 1
            else
                self.cursor = self.cursor + 1
            end
        elseif self.mode == 3 then
            self.cursor = 6 - self.cursor - self.selected_save
        end
        self:rebuild_surface()
    elseif (command == "left" or command == "right") and self.mode == 2 then
        self.cursor = 3 - self.cursor
        self:rebuild_surface()
    elseif command == "action" or command == "pause" then
        if self.mode == 1 then
            if self.cursor < 4 then
                local game = self.saves[self.cursor]
                sol.menu.stop(self)

                if game.initialized then
                    game_manager:start_game(game)
                else 
                    sol.menu.start(sol.main, enter_name_menu, nil, {
                        game = game,
                        game_manager = game_manager,
                        prev_menu = self
                    })
                end
            else 
                sol.menu.stop(self)
                sol.menu.start(sol.main, settings_menu)
                settings_menu.origin_page = self
            end
        elseif self.mode == 2 then
            if self.cursor == 2 then
                sol.file.remove("save"..self.selected_save..".dat")
                self.saves[self.selected_save] = game_manager:load("save"..self.selected_save..".dat")
                self.background_surface:fill_color({0, 0, 0}, 
                    save_name_pos.x, save_name_pos.y + (save_name_pos.offset * (self.selected_save - 1)), 49, 11)
                self.mode = 1
                self.cursor = self.selected_save
                self:rebuild_surface()
            else 
                self.mode = 3
                self.cursor = (self.selected_save + 1) % 3
                self:rebuild_surface() 
            end
        else
            --self.saves[self.cursor] = self.saves[self.selected_save]
            self.mode = 1
            --print("save"..self.selected_save..".dat")
            --gen.copyFile("save"..self.selected_save..".dat", "save"..self.cursor..".dat")
            --self.saves[self.cursor] = game_manager:load("save"..self.cursor..".dat")
            self:true_rebuild_surface()
        end
    elseif command == "select" then
        if self.mode == 1 and self.saves[self.cursor] and self.saves[self.cursor].initialized then
            self.selected_save = self.cursor
            self.cursor = 1
            self.mode = 2
            self:rebuild_surface()
        elseif self.mode == 3 then
            self.mode = 1
            self.cursor = self.selected_save
            self:rebuild_surface()
        end
    end
end

function save_select:load_saves()
    for i = 1, 3 do
        self.saves[i] = game_manager:load("save"..i..".dat")
    end
    self.saves_loaded = true
end

function save_select:on_started()

    if not self.saves_loaded then self:load_saves() end

    self:true_rebuild_surface()
    sol.audio.play_music("save_select")
end

return save_select