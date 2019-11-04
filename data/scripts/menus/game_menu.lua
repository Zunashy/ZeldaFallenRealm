local game_menu = {
    surface = nil,      --main surface (will be be draw directly into the screen)
    transition_surface, --will be used to keep the last frame of the closing menu page during the transition 
    main_pages = {           --submenus
        "inventory",
        "quest_menu"
    },
    side_pages = {
        "settings",
        "save_menu"
    },
    pages = {},
    cursor_sprite = "menus/cursor.png",     --image used as the default cursor
    cursor_surface = nil,                   --surface for the cursor
    current_page_index = 1,
    current_page = nil,
    info_surface = nil,
    info_pre_surface = nil,
    info_surface_pos = {
        x = 0,
        y = 0,
    },
    info_surface_movement = nil,
    transition_movement = nil,
    transition_movement_pos = {x = 0, y = 0},
    name = "Game Menu"
}

game_menu.surface = sol.surface.create(sol.video.get_quest_size())
game_menu.transition_surface = sol.surface.create(sol.video.get_quest_size())
game_menu.cursor_surface = sol.surface.create(game_menu.cursor_sprite)

local info_name_text_surface = sol.text_surface.create({
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "oracle_black"
})
local info_desc_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "oracle_black"
})
game_menu.info_surface = sol.surface.create(144, 19)

local page
for k, v in ipairs(game_menu.main_pages) do
    page = require("scripts/menus/game_menu_pages/"..v)
    game_menu.main_pages[k] = page
    game_menu.pages[v] = page
    page.game_menu = game_menu
    page.is_main_page = true
end

for k, v in ipairs(game_menu.side_pages) do
    page = require("scripts/menus/game_menu_pages/"..v)
    game_menu.pages[v] = page
    page.game_menu = game_menu
end

--LOADING EXTERNAL MODULES
game_menu.lang = require("scripts/api/language_manager")

--MENU METHODS AND UTILITY FUNCTIONS
function game_menu:init_info_surface(name, desc)
    self.info_pre_surface = nil

    sol.timer.stop_all(self)
    if not (name and desc) then return false end
    info_name_text_surface:set_text_key(name)
    info_desc_text_surface:set_text_key(desc)

    local desc_size, _ = info_desc_text_surface:get_size()
    self.info_pre_surface = sol.surface.create(152 + desc_size, 19)

    local surf = self.info_pre_surface
    info_name_text_surface:draw(surf, 72, 9)
    info_desc_text_surface:draw(surf, 152, 9)
    self:start_info_cycle()
end

function game_menu:start_info_cycle()
    if self.info_surface_movement then 
        self.info_surface_movement:stop()
        self.info_surface_movement = nil
    end

    self.info_surface_pos.x = 0
    sol.timer.start(self, 1000, function()
        game_menu:start_info_movement_1()
    end)
end

function game_menu:start_info_movement_1()
    self.info_surface_movement = sol.movement.create("straight")
    local m = self.info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    local surf_w, _ = self.info_pre_surface:get_size()
    m:set_max_distance(surf_w)
    function m:on_finished()
        game_menu:start_info_movement_2()
    end     
    m:start(self.info_surface_pos)
end

function game_menu:start_info_movement_2()
    self.info_surface_pos.x = 144
    self.info_surface_movement = sol.movement.create("straight")
    local m = self.info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    function m:on_finished()
        game_menu:start_info_cycle()
    end
    m:set_max_distance(144)
    m:start(self.info_surface_pos)
end

function game_menu:get_game()
    return self.game
end

function game_menu:page_transition(new_page)
    self.current_page:draw(self.transition_surface)
    if self.current_page.on_closes then
        self.current_page:on_closed()
    end
    
    self.current_page = new_page

    self.transition_movement = sol.movement.create("straight")
    local m = self.transition_movement
    m:set_speed(196)
    m:set_angle(math.pi)
    function m:on_finished()
        game_menu:end_transition()
    end
    m:set_max_distance(160)
    self.transition_movement_pos = {x = 160, y = 0}
    m:start(self.transition_movement_pos)
end

function game_menu:end_transition()
    self.transition_movement = nil
    self.current_page:on_page_selected()
end

function game_menu:open_page(new_page, transition, remember_origin)
    remember_origin = (remember_origin == nil) and (not transition) or remember_origin

    if remember_origin then new_page.origin_page() end
    if transition then
        self:page_transition(new_page)
    else
        self.current_page = new_page
        if self.current_page.on_page_selected then
            self.current_page:on_page_selected()
        end
    end
end

--====== MENU CALLBACKS ======
function game_menu:on_started()
    self.current_page = self.main_pages[self.current_page_index]

    for k, v in pairs(self.pages) do
        if v.init then v:init(self) end
    end
    self.current_page:on_page_selected(self)
end

function game_menu:draw(dst_surface, x, y)
    local surf = self.surface
    surf:clear()
    self.current_page:draw(surf, self)

    local info_x, info_y = self.info_surface_pos.x, self.info_surface_pos.y
    if self.current_page.enable_info_text and self.info_pre_surface then
        self.info_surface:clear()
        self.info_pre_surface:draw(self.info_surface, info_x, info_y)
        self.info_surface:draw(surf, 8, 104)
    end

    surf:draw(dst_surface, x, y)
end

function game_menu:on_draw(dst_surface)  
    local offset = self.current_page.full_screen and 0 or 16
    if self.transition_movement then
        local x, y = self.transition_movement_pos.x, self.transition_movement_pos.y
        self.transition_surface:draw(dst_surface, x - 160, y + offset)
        
        self:draw(dst_surface, x, offset)
    else
        self:draw(dst_surface, 0, offset)
    end
end

function game_menu:on_finished()
    if self.current_page.on_closed then
        self.current_page:on_closed()
    end
    if self.transition_movement then
        self.transition_movement:stop()
    end
    if self.info_surface_movement then
        self.info_surface_movement:stop()
    end
end

function game_menu:on_command_pressed(command)
    if self.transition_movement then
        return true 
    end

    if command == "select" and self.current_page.is_main_page then
        self.current_page_index = self.current_page_index + 1
        if self.current_page_index > table.getn(self.main_pages) then
            self.current_page_index = 1
        end
        self:open_page(self.main_pages[self.current_page_index], true)
    end

    if self.current_page.on_command_pressed then
        self.current_page:on_command_pressed(command)
    end
end

--====== BINDING THE MENU TO THE GAME ======

local function get_game_menu(game)
    return game_menu
end

function game_menu:bind_to_game(game)
    game.game_menu = self
    self.game = game
end

local function pause_callback(game)
    sol.menu.start(game, game_menu)
end

local function unpause_callback()
    sol.menu.stop(game_menu)
end    

local function start_callback(game)
    game_menu:bind_to_game(game)

    for k, v in pairs(game_menu.pages) do
        if v.on_started and not v.initalized then 
			v:on_started(game) 
		end
    end            
end

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", start_callback)
game_meta:register_event("on_paused", pause_callback)
game_meta:register_event("on_unpaused", unpause_callback)