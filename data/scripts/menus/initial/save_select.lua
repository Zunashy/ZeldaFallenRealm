local save_select = {
    name = "Save selection",
    surface = nil,   
    background_surface = nil,
    cursor_surface = nil,
    cursor = 1,
    saves = {},
    link_sprite = nil,
    hearts_surface = nil,
    hearts_img = nil,
}

local cursor_pos = {
    {x = 8, y = 53},
    {x = 8, y = 77},
    {x = 8, y = 101},
    {x = 37, y = 121}
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

local game_manager = require("scripts/game_manager")
local enter_name_menu = require("scripts/menus/enter_name")
local settings_menu = require("scripts/menus/game_menu_pages/settings")

local lang = require("scripts/api/language_manager")
save_select.background_surface = lang:load_image("menus/save_select")
save_select.cursor_surface = sol.surface.create("menus/save_select_cursor.png")

save_select.link_sprite = sol.sprite.create("hero/tunic1")
save_select.link_sprite:set_animation("walking")
save_select.link_sprite:set_direction(3)

save_select.hearts_surface = sol.surface.create(60, 12)
save_select.hearts_img = sol.surface.create("hud/hearts.png")

function save_select:draw_hearts(life, max_life)

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
                self.hearts_img:draw_region(0, 0, 8, 8, self.hearts_surface, x, y)
            else
                self.hearts_img:draw_region(32, 0, 8, 8, self.hearts_surface, x, y)
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
        self.hearts_img:draw_region(8, 0, 8, 8, self.hearts_surface, x, y)
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
        self.hearts_img:draw_region(16, 0, 8, 8, self.hearts_surface, x, y)
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
        self.hearts_img:draw_region(24, 0, 8, 8, self.hearts_surface, x, y)
    end
end

function save_select:on_draw(dst_surface)
    self.background_surface:draw(dst_surface)
    self.cursor_surface:draw(dst_surface, cursor_pos[self.cursor].x, cursor_pos[self.cursor].y)

    if self.cursor < 4 and self.saves[self.cursor].initialized then
        self.link_sprite:draw(dst_surface, link_pos.x, link_pos.y)
        self.hearts_surface:draw(dst_surface, hearts_pos.x, hearts_pos.y)
    end
end

function save_select:on_command_pressed(command)
    if command == "up" then
        if self.cursor == 1 then
            self.cursor = 4
        else
            self.cursor = self.cursor - 1
        end
        local game = self.saves[self.cursor]
        if game and game.initialized then
            local life = game:get_life()
            local max_life = game:get_max_life()
            self:draw_hearts(life, max_life)
        end
    elseif command == "down" then
        if self.cursor == 4 then
            self.cursor = 1
        else
            self.cursor = self.cursor + 1
        end
        local game = self.saves[self.cursor]
        if game and game.initialized then
            local life = game:get_life()
            local max_life = game:get_max_life()
            self:draw_hearts(life, max_life)
        end
    elseif command == "action" or command == "pause" then

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
    end
end

function save_select:load_saves()
    for i = 1, 3 do
        self.saves[i] = game_manager:load("save"..i..".dat")
    end
    self.saves_loaded = true
end

function save_select:on_started()
    local exists, game, name, name_surface, y
    y = save_name_pos.y

    if not self.saves_loaded then self:load_saves() end

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

    game = self.saves[self.cursor]
    if game and game.initialized then
        local life = game:get_life()
        local max_life = game:get_max_life()
        self:draw_hearts(life, max_life)
    end

end

return save_select