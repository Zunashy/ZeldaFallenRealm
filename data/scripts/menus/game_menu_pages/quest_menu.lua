local quest_menu = {
    enable_info_text = true,
    bg_surface = nil,
    bg_image = nil,
    cursor_36x14_surface = nil,
    current_cursor = nil,
    items = {
        "bracelet",
        "ring_octorock"
    },
    items_sprites = {},
    cursor_area = 1, -- 0 : items | 1 : right side
    cursor = 3,
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
local essences_position = {
    h_offset = 28,
    v_offset = 24,
    tl_offset = {
        x = 22, 
        y = 21
    }
}

local items_pos = {
    h_offset = 28,
    tl_offset = {
        x = 22, 
        y = 93
    },
    cursor_offset = {
        x = 12,
        y = 12
    }
}


local settings_menu = require("scripts/menus/game_menu_pages/settings")
local save_menu = require("scripts/menus/game_menu_pages/save_menu")

--UTILITY METHODS AND FUNCTIONS
function quest_menu:get_cursor_info(slot)
    return slot_cursors[slot]
end

function quest_menu:set_current_cursor(slot)
    print(self.cursor_area)
    if self.cursor_area == 1 then
        local cursor_info = self:get_cursor_info(slot)
        if not cursor_info then return end
        local x, y, cursor = unpack(cursor_info)
        self.current_cursor.x = x
        self.current_cursor.y = y
        self.current_cursor.cursor = self[cursor] or self.game_menu.cursor_surface
    else

        self.current_cursor.x = items_pos.tl_offset.x + ((self.cursor - 1) * items_pos.h_offset) - items_pos.cursor_offset.x
        self.current_cursor.y = items_pos.tl_offset.y - items_pos.cursor_offset.y
        self.current_cursor.cursor = self.game_menu.cursor_surface
    end

end

function quest_menu:on_selection_changed(game_menu)
    if self.cursor_area == 1 then
        local help = slot_help[self.cursor]
        if not (help) then
            self.game_menu:init_info_surface(nil, nil)
        else
            self.game_menu:init_info_surface("menus.quest."..help..".name", "menus.quest."..help..".description")
        end
    else
        local item = self.items[self.cursor]
        if not (item and item:get_variant() ~= 0) then
            self.game_menu:init_info_surface(nil, nil)
        else
            local item_name = item:get_name()
            self.game_menu:init_info_surface("items."..item_name..".name", "items."..item_name..".description")
        end
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

local function slot_index_to_coords(i)
    return (i - 1) % 4, math.floor((i - 1) / 4)
end

--SUBMENU METHODS : will be called by the game_menu methods--

function quest_menu:on_started()
    local x, y
    self.bg_image:draw(self.bg_surface)
    local qhearts = self.game_menu:get_game():get_item("heart_quarter"):get_amount()
    if qhearts > 0 then
        local x, y = heart_position.x, heart_position.y
        self.heart_surface:draw_region((qhearts - 1) * 24, 0, 24, 18, self.bg_surface, x, y)
    end

    for i, item in ipairs(self.items) do 
        if item:get_variant() ~= 0  then 
            if not (self.items_sprites[item] and self.items_sprites[item]:get_direction() == item:get_variant() - 1) then
                self.items_sprites[item] = sol.sprite.create("entities/items")
                self.items_sprites[item]:set_animation(item:get_name())
                self.items_sprites[item]:set_direction(item:get_variant() - 1)
            end
            cx = i - 1
            x, y = items_pos.tl_offset.x + (cx * items_pos.h_offset), items_pos.tl_offset.y
            self.items_sprites[item]:draw(self.bg_surface, x, y)

            self.max_item = i
        end 
    end  
    
    if not self.items_sprites.essence then
        self.items_sprites.essence = sol.sprite.create("entities/items")
        self.items_sprites.essence:set_animation("essence")
    end

    local cx, cy
    for i = 1, self.items.essence:get_variant() do
        self.items_sprites.essence:set_direction(i - 1)
        cx, cy = slot_index_to_coords(i)
        x, y = essences_position.tl_offset.x + (cx * essences_position.h_offset), essences_position.tl_offset.y + (cy * essences_position.v_offset)
        self.items_sprites.essence:draw(self.bg_surface, x, y)
    end

end

function quest_menu:on_page_selected()
    self.current_cursor = {}
    self:set_current_cursor(self.cursor)
    self.game_menu:init_info_surface("menus.quest.save.name", "menus.quest.save.description")
end

function quest_menu:on_draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    if self.current_cursor then
        local x, y = self.current_cursor.x, self.current_cursor.y
        self.current_cursor.cursor:draw(dst_surface, x, y)
    end
end

function quest_menu:on_command_pressed(command)
    if command == "action" and self.cursor_area == 1 then
        if slot_effects[self.cursor] then
            self[slot_effects[self.cursor]](self)
        end
    elseif command == "up" then
        if self.cursor_area == 1 then 
            self.cursor = self.cursor - 1
            if self.cursor < 1 then self.cursor = 3 end
            self:on_selection_changed()
        end
    elseif command == "down" then
        if self.cursor_area == 1 then
            self.cursor = self.cursor + 1
            if self.cursor > 3 then self.cursor = 1 end
            self:on_selection_changed()
        end
    elseif command == "right" then
        if self.cursor_area == 0 then    
            self.cursor = self.cursor + 1
            if self.cursor > 3 then
                self.cursor = 3
                self.cursor_area = 1
            end
        else
            self.cursor_area = 0
            self.cursor = 1
        end     
        self:on_selection_changed()
    elseif command == "left" then
        if self.cursor_area == 0 then    
            self.cursor = self.cursor - 1
            if self.cursor < 1 then
                self.cursor = 3
                self.cursor_area = 1
            end
        else
            self.cursor_area = 0
            self.cursor = 3
        end 
        self:on_selection_changed()
    end
end

--Loading the correct button images, depending on the language

function quest_menu:preload(game)
    local save_surface = self.game_menu.lang:load_image("menus/save")
    local x, y = save_position.x, save_position.y
    save_surface:draw(self.bg_image, x, y)

    local settings_surface = self.game_menu.lang:load_image("menus/settings")
    x, y = settings_position.x, settings_position.y
    settings_surface:draw(self.bg_image, x, y)

    for i, v in ipairs(self.items) do
        self.items[i] = game:get_item(v)
    end
    self.items.essence = game:get_item("essence")
end

return quest_menu
