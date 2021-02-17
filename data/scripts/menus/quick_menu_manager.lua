local qmg = gen.class()
qmg.name = "Quick Menu"

local max_h = 128

local obscure_surf = sol.surface.create(sol.video.get_quest_size())
obscure_surf:fill_color({0, 0, 0}, 0, 16, sol.video.get_quest_size())
obscure_surf:set_opacity(127)

function qmg:constructor(x)
    self.elements = {}
    self.enabled_elements = {}
    self.x = x or 0
    self.y = 16
    self.inter_element = 6
    self.current_element = 1 --haha 1-starting arrays go brr
end

function qmg:add_element(enabled)
    local elt = {
        enabled = enabled,
        surface = sol.surface.create("menus/frame.png")
    }
    self.elements[#self.elements + 1] = elt
    return elt
end

function qmg:on_draw(dest)
    obscure_surf:draw(dest)
    local y = self.y + self.inter_element
    local i = self.current_element
    for j = 1, self.nb_elements do
        element = self.enabled_elements[i]
        element.surface:draw(dest, self.x, y)
        y = y + self.inter_element + 16
        if y + self.inter_element + 16 >= max_h then 
            break 
        end
        i = i + 1
        if i > self.nb_elements then
            i = 1
        end
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
end

local function game_start(game)
    qmg.game = game
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", game_start)

return qmg