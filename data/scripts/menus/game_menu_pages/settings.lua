local settings = require("scripts/api/settings")

local settings_menu = {
    bg_surface = nil,
    surface = nil,
    origin_page = nil,
    view_cursor = true,
    cursor = 1,
    scrolling = 0,
    button_effects = {},
    button_surface_builders = {}
}

local title_pos = {
    x = 16,
    y = 8
}

local cursor_pos = {
    x = 33,
    y = 57,
    offset = 24,
}

local button_pos = {
    x = 33, 
    y = 61,
    offset = 24
}

settings_menu.buttons = {
    {
        name = "controls",
        effect = function() end,
    },
    {
        name = "text_speed",
        effect = function(command, button) 
            local speed = settings:get("text_speed")
            if command == "left" and speed > 1 then
                speed = speed - 1
            elseif command == "right" and speed < 3 then
                speed = speed + 1
            end
            settings:set("text_speed", speed)
            button.menu:rebuild_surface()
        end,
        languages_pos = {
            fr = 80,
            en = 83
        },
        surface_builder = function(button) 
            local speed = settings:get("text_speed")
            local pos = button.languages_pos[settings:get("language")] or 0
            button.menu.assets:draw_region(10 * (speed - 1), 0, 10, 13, button.surface, pos, 0)
        end,
    },
    {
        name = "view",
        effect = function(command, button)
            local view = settings:get("view")
            if command == "left" then
                if view == true then
                    view = 4
                elseif view > 1 then
                    view = view / 2
                end
            elseif command == "right" then
                if view ~= true then
                    if view < 4 then
                        view = view * 2
                    else
                        view = true
                    end
                end
            end
            settings:set("view", view)
            button.menu:rebuild_surface()
        end,
        languages_pos = {
            fr = 79,
            en = 62
        },
        surface_builder = function(button)
            local view = settings:get("view")

            local pos = (button.languages_pos[settings:get("language")] or 0)
            if view == true then
                button.menu.assets:draw_region(50, 0, 20, 13, button.surface, pos, 0)
            else
                button.menu.assets:draw_region(70, 0, 10, 13, button.surface, pos, 0)
                button.menu.assets:draw_region((view - 1) * 10, 0, 10, 13, button.surface, pos + 7, 0)
            end
        end
    }
}

settings_menu.bg_surface = sol.surface.create("menus/settings_menu.png")
settings_menu.cursor_surface = sol.surface.create("menus/save_cursor.png")
settings_menu.surface = sol.surface.create(sol.video.get_quest_size())
settings_menu.assets = sol.surface.create("menus/settings_assets.png")

--methods
function settings_menu:rebuild_surface()
    self.bg_surface:draw(self.surface)

    local x, y
    for i = 1, 3 do 
        x = button_pos.x
        y = button_pos.y + button_pos.offset * (i - 1)
        if self.buttons[i + self.scrolling].surface_builder then
            self:rebuild_button_surface(self.buttons[i + self.scrolling])
        end
        self.buttons[i + self.scrolling].surface:draw(self.surface, x, y)
    end

    if self.view_cursor then 
        x = cursor_pos.x
        y = cursor_pos.y + cursor_pos.offset * (self.cursor - self.scrolling - 1)
        self.cursor_surface:draw(self.surface, x, y)
    end
end

function settings_menu:rebuild_button_surface(button)
    button.bg_surface:draw(button.surface)
    button:surface_builder()
end

--SUBMENU METHODS

function settings_menu:on_draw(dst_surface)
    self.surface:draw(dst_surface)
end

function settings_menu:on_page_selected()
    settings_menu.cursor = 1
end

function settings_menu:on_command_pressed(command)
    if command == "action" or command == "left" or command == "right" then
        self.buttons[self.cursor].effect(command, self.buttons[self.cursor])
    elseif command == "sword" or command == "select" then
        if sol.menu.is_started(self) then
            sol.menu.stop(self)
	end
	
	if self.origin_page then
	    if self.origin_page.game_menu and sol.menu.is_started(self.origin_page.game_menu) then
	        self.game_menu.current_page = self.origin_page
	    else 
	        sol.menu.start(self.context or self.origin_page.context, self.origin_page)
	    end
	end	     
    elseif command == "up" then
        local cursor_relative = self.cursor - self.scrolling
        if cursor_relative == 1 then
            if self.scrolling == 0 then
                self.scrolling = self.nButtons - 3
                self.cursor = self.nButtons
            else
                self.scrolling = self.scrolling - 1
                self.cursor = self.cursor - 1
            end
        else
            self.cursor = self.cursor - 1
        end
        self:rebuild_surface()
    elseif command == "down" then
        local cursor_relative = self.cursor - self.scrolling
        if cursor_relative == 3 then
            if self.scrolling == self.nButtons - 3 then
                self.scrolling = 0
                self.cursor = 1
            else
                self.scrolling = self.scrolling + 1
                self.cursor = self.cursor + 1
            end
        else
            self.cursor = self.cursor + 1
        end
        self:rebuild_surface()
    end

end

function settings_menu:on_started()
    self:preload()
    self:rebuild_surface()
    self.origin_page = nil 
    if self.arguments then
        self.origin_page = self.arguments.origin_page
    end
end

function settings_menu:preload()
    if self.initialized then return end
    local title_surface = self.game_menu.lang:load_image("menus/settings_title")
    local x, y = title_pos.x, title_pos.y
    title_surface:draw(self.bg_surface, x, y)

    for i, v in ipairs(settings_menu.buttons) do
        v.surface = settings_menu.game_menu.lang:load_image("menus/settings_"..v.name)
        v.menu = self
        if v.surface_builder then 
            v.bg_surface = sol.surface.create(96, 13)
            v.surface:draw(self.buttons[i].bg_surface)
        end
    end
    self.nButtons = table.getn(self.buttons)

    self.initialized = true
end


return settings_menu
