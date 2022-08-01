--initializing the submenu object
local inventory_menu = {
    bg_sprite = "menus/inventory.png",
    bg_image = nil,
    bg_surface = nil,
    items = {
        "rock_feather",
        "ice_seed",
        "fire_seed",
        "hammer",
        "bomb",
        "griffe",
        [13] = "horn",
    },
    items_sprites = {},
    enable_info_text = true
}

local horizontal_offset = 32
local vertical_offset = 24
local first_slot_offset = {
    x = 22, 
    y = 9
}

local cursor_pos = {
    h_offset = 32,
    v_offset = 24,
    tl_offset = {
        x = 22, 
        y = 9
    }
}

local items_pos = {
    h_offset = 32,
    v_offset = 24,
    tl_offset = {
        x = 34, 
        y = 21
    }
}

--local functions and generic methods
function inventory_menu:get_selected_item()
    return self.items[self.cursor]
end

local function slot_coords_to_index(cx, cy)
    return (cx + cy * 4) + 1
end

local function slot_index_to_coords(i)
    return (i - 1) % 4, math.floor((i - 1) / 4)
end

function inventory_menu:on_selection_changed(game_menu)
    local item = self:get_selected_item()
    if not (item and item:get_variant() ~= 0) then
        self.game_menu:init_info_surface(nil, nil)
    else
        local item_name = item:get_name()
        self.game_menu:init_info_surface("items."..item_name..".name", "items."..item_name..".description")
    end
    self.game_menu:play_move_sound()
end

--SUBMENU METHODS : will be called by the game_menu methods
function inventory_menu:on_started(game_menu)
    self.bg_surface:clear()
    self.bg_image:draw(self.bg_surface)
    for i, item in pairs(self.items) do 
        if item:get_variant() ~= 0  then 
            if not (self.items_sprites[item] and self.items_sprites[item]:get_direction() == item:get_variant() - 1) then
                self.items_sprites[item] = sol.sprite.create("entities/items")
                self.items_sprites[item]:set_animation(item:get_name())
                self.items_sprites[item]:set_direction(item:get_variant() - 1)
            end
            cx, cy = slot_index_to_coords(i)
            x, y = items_pos.tl_offset.x + (cx * items_pos.h_offset), items_pos.tl_offset.y + (cy * items_pos.v_offset)
            self.items_sprites[item]:draw(self.bg_surface, x, y)
        end 
    end    
end

function inventory_menu:on_page_selected()  --appelée quand cette page est sélectionnée
    self.cursor = 1
    self:on_selection_changed()
end

function inventory_menu:on_draw(dst_surface, game_menu)
    self.bg_surface:draw(dst_surface)
    local cx, cy = slot_index_to_coords(self.cursor)
    local x, y = cursor_pos.tl_offset.x + (cx * cursor_pos.h_offset), cursor_pos.tl_offset.y + (cy * cursor_pos.v_offset)
    self.game_menu.cursor_surface:draw(dst_surface, x, y)
end

local function use_item_callback(item, unpause)
    if unpause then
        inventory_menu.game_menu.game:set_paused(false)
    end
    item:on_using()
end

function inventory_menu:use_item(item)
    if item.use_from_inventory and true then
        if item.on_using_from_inventory then
            item:on_using_from_inventory(use_item_callback)
        else
            item:on_using()
        end
    end
end

function inventory_menu:assign_item(item, slot)
    if item:is_assignable() then
        item:get_game():set_item_assigned(slot, item)
    else
        self:use_item(item)
    end
end

function inventory_menu:on_command_pressed(command)
    local cx, cy
    local ret = true
    if command == "item_1" then
        local item = self:get_selected_item()
        if item and item:get_variant() ~= 0 then
            self:assign_item(item, 1)
        end
	elseif command == "item_2" then
		local item = self:get_selected_item()
		if item and item:get_variant() ~= 0 then
			self:assign_item(item, 2)
        end
    elseif command == "action" then
        local item = self:get_selected_item()
        if item and item:get_variant() ~= 0 then
            self:use_item(item)
        end
    elseif command == "right" then
        cx, cy = slot_index_to_coords(self.cursor)
        cx = cx + 1
        if cx > 3 then cx = 0 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "up" then
        cx, cy = slot_index_to_coords(self.cursor)
        cy = cy - 1
        if cy < 0 then cy = 3 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "left" then
        cx, cy = slot_index_to_coords(self.cursor)
        cx = cx - 1
        if cx < 0 then cy = 3 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "down" then
        cx, cy = slot_index_to_coords(self.cursor)
        cy = cy + 1
        if cy > 3 then cy = 0 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    else
        ret = false
    end
    return ret
end

--Replacing the items names by the items objects when the game starts
function inventory_menu:preload(game)
    for k, v in pairs(inventory_menu.items) do
        self.items[k] = game:get_item(v)
    end
    self.bg_image = sol.surface.create("menus/inventory.png")
    self.bg_surface = sol.surface.create(self.bg_image:get_size())
	self.initalized = true
end

return inventory_menu
