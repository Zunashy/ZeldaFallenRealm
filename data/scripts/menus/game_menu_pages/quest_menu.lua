quest_menu = {
    enable_info_text = true,
    bg_surface = nil,
    bg_image = nil,
    cursor_36x14_surface = nil,
    current_cursor = nil
}

quest_menu.cursor_36x14_surface = sol.surface.create("menus/cursor_36_14.png")
quest_menu.heart_surface = sol.surface.create("menus/heart_quarters.png")
quest_menu.bg_image = sol.surface.create("menus/quest_menu.png")
quest_menu.bg_surface = sol.surface.create(sol.video.get_quest_size())

local slot_cursors = {
    {110, 33 , "cursor_36x14_surface"},
    {110, 61, "cursor_36x14_surface"},
    {110, 81, "cursor_36x14_surface"}
}
local slot_effects = {
    nil,
    "settings",
    "save",
}
local slot_help = {
    "qheart",
    "settings",
    "save"
}
local heart_position = {
    x = 116,
    y = 13
}
local save_position = {
    x = 112,
    y = 82
}
local settings_position = {
    x = 112,
    y = 62
}

local settings_menu = require("scripts/menus/game_menu_pages/settings")
local save_menu = require("scripts/menus/game_menu_pages/save_menu")

--UTILITY METHODS AND FUNCTIONS
function quest_menu:get_cursor_info(slot)
    return slot_cursors[slot]
end

function quest_menu:set_current_cursor(slot)
    self.current_cursor = {}
    local cursor_info = self:get_cursor_info(slot)
    if not cursor_info then return end
    local x, y, cursor = unpack(cursor_info)
    self.current_cursor.x = x
    self.current_cursor.y = y
    self.current_cursor.cursor = self[cursor] or self.game_menu.cursor_surface
end

function quest_menu:on_selection_changed(game_menu)
    local help = slot_help[self.cursor]
    if not (help) then
        self.game_menu:init_info_surface(nil, nil)
    else
        self.game_menu:init_info_surface("menus.quest."..help..".name", "menus.quest."..help..".description")
    end

    quest_menu:set_current_cursor(self.cursor)
end

--slot effects
function quest_menu:save()
    self.game_menu.current_page = save_menu
    save_menu.origin_page = self
end

function quest_menu:settings()
    self.game_menu.current_page = settings_menu
    settings_menu.origin_page = self
end

--SUBMENU METHODS : will be called by the game_menu methods--

function quest_menu:on_started()
    self.bg_image:draw(self.bg_surface)
    local qhearts = self.game_menu:get_game():get_item("heart_quarter"):get_amount()
    if qhearts > 0 then
        local x, y = heart_position.x, heart_position.y
        self.heart_surface:draw_region((qhearts - 1) * 24, 0, 24, 18, self.bg_surface, x, y)
    end
end

function quest_menu:on_page_selected()
    self.cursor = 3
    self:set_current_cursor(self.cursor)
    self.game_menu:init_info_surface("menus.quest.save.name", "menus.quest.save.description")
end

function quest_menu:draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    if self.current_cursor then
        local x, y = self.current_cursor.x, self.current_cursor.y
        self.current_cursor.cursor:draw(dst_surface, x, y)
    end
end

function quest_menu:on_command_pressed(command)
    if command == "action" then
        if slot_effects[self.cursor] then
            self[slot_effects[self.cursor]](self)
        end
    elseif command == "up" then
        self.cursor = self.cursor - 1
        if self.cursor < 1 then self.cursor = 3 end
        self:on_selection_changed()
    elseif command == "down" then
        self.cursor = self.cursor + 1
        if self.cursor > 3 then self.cursor = 1 end
        self:on_selection_changed()
    end
end

--Loading the correct button images, depending on the language

function quest_menu:preload()
    local save_surface = self.game_menu.lang:load_image("menus/save")
    local x, y = save_position.x, save_position.y
    save_surface:draw(self.bg_image, x, y)

    local settings_surface = self.game_menu.lang:load_image("menus/settings")
    x, y = settings_position.x, settings_position.y
    settings_surface:draw(self.bg_image, x, y)

end

return quest_menu
