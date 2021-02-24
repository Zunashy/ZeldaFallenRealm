local qmg = gen.class()
qmg.name = "Quick Menu"

local max_h = 128
local inter_element = 6

local max_elements = math.floor((max_h - inter_element) / (16 + inter_element))

local obscure_surf = sol.surface.create(sol.video.get_quest_size())
local frame_surf = sol.surface.create("menus/frame.png")
obscure_surf:fill_color({0, 0, 0}, 0, 16, sol.video.get_quest_size())
obscure_surf:set_opacity(127)

function qmg:constructor(x)
    self.elements = {}
    self.enabled_elements = {}
    self.x = x or 0
    self.y = 16
    self.current_element = 1 --haha 1-starting arrays go brr
    self.state = 0 --0 = normal ; 1 = moving
    self.surface = sol.surface.create(sol.video.get_quest_size())
    self.movInfo = {x = 0, y = 0}
    self.movDir = 0
    self.need_rebuild = true
    self.buffered = nil
    self.cycling_element_surface = sol.surface.create(16, 16)
end

function qmg:add_element(enabled)
    local elt = {
        enabled = enabled,
        surface = sol.surface.create(16, 16)
    }
    frame_surf:draw(elt.surface)
    self.elements[#self.elements + 1] = elt
    return elt
end

function qmg:on_draw(dest)
    obscure_surf:draw(dest)
    local y = inter_element + self.movInfo.y
    local i = self.first_element_displayed

    if self.state == 1 then
        self.need_rebuild = true
    end
    if self.need_rebuild then
        self.surface:clear()
        for j = 1, self.nb_displayed_elements do
            element = self.enabled_elements[i]
            element.surface:draw(self.surface, self.x, y)
            y = y + inter_element + 16
            i = i + 1
            if i > self.nb_elements then
                i = 1
            end
        end

        if self.state == 1 and self.cyclic then
            self.cycling_element_surface:draw(self.surface, self.x, y)
        end

        if self.state == 0 then
            self.need_rebuild = false
        end
    end

    self.surface:draw(dest, 0, 16)
end

function qmg:end_movement()
    self.state = 0
    self.movInfo.y = 0

    self.elements[self.first_element_displayed].surface:set_opacity(255)
    
    local last_element_surface
    if self.cyclic then
        last_element_surface = self.cycling_element_surface
    else
        last_element_surface = self.elements[((self.first_element_displayed + max_elements - 2) % self.nb_elements) + 1].surface
    end
    last_element_surface:set_opacity(255)

    self.first_element_displayed = self.current_element
    self.nb_displayed_elements = (self.nb_elements <= max_elements) and self.nb_elements or max_elements

    if self.buffered then
        self:move(self.buffered)
        self.buffered = nil
    end
    if self.game:is_command_pressed("up") then
        self:move(-1)
    elseif self.game:is_command_pressed("down") then
        self:move(1)
    end
end

local function movement_end_callback(self)
    self.entity:end_movement()
end

function qmg:move(direction) -- 1 = down ; -1 = up
    --si direction = -1, on veut MONTER dans la liste, donc visuellement elle DESCEND
    --si direction = 1, on veut DESCENDRE dans la liste, donc visuellement elle MONTE

    if self.state == 1 then
        self.buffered = direction
        return
    end

    self.state = 1
    self.current_element = ((self.current_element + direction - 1) % self.nb_elements ) + 1

    if direction == -1 then
        self.first_element_displayed = self.current_element
    end

    if self.cyclic then
        self.elements[self.first_element_displayed].surface:draw(self.cycling_element_surface)
    else
        self.nb_displayed_elements = self.nb_displayed_elements + 1
    end

    local last_element_surface
    if self.cyclic then
        last_element_surface = self.cycling_element_surface
    else
        last_element_surface = self.elements[((self.first_element_displayed + max_elements - 2) % self.nb_elements) + 1].surface
    end

    if direction == -1 then
        self.elements[self.first_element_displayed].surface:fade_in(5)
        last_element_surface:fade_out(5)
    else
        self.elements[self.first_element_displayed].surface:fade_out(5)
        last_element_surface:fade_in(5)
    end

    local m = sol.movement.create("straight")
    m:set_angle((math.pi / 2) * 2 - direction)
    m:set_speed(160)
    m:set_max_distance(16 + inter_element + 4)
    m.on_finished = movement_end_callback
    m.entity = self
    if direction == 1 then
        self.movInfo.y = 0
    else
        self.movInfo.y = -(16 + inter_element)
    end
    m:start(self.movInfo)
    self.movInfo.movement = m

    self.movDir = direction
end

function qmg:on_command_pressed(command)
    if command == "up" then
        self:move(-1)
    elseif command == "down" then
        self:move(1)
    end
end

function qmg:on_started()
    self.game:set_suspended(true)
    self.enabled_elements = {}
    for _, e in ipairs(self.elements) do
        if e.enabled then
            self.enabled_elements[#self.enabled_elements + 1] = e
        end
    end
    self.nb_elements = #self.enabled_elements

    if self.nb_elements < 1 then
        sol.menu.stop(self)
    end

    self.first_element_displayed = self.current_element
    if self.nb_elements <= max_elements then
        self.nb_displayed_elements = self.nb_elements
        self.cyclic = true
    else
        self.nb_displayed_elements = max_elements
        self.cyclic = false
    end
end

local function game_start(game)
    qmg.game = game
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return qmg