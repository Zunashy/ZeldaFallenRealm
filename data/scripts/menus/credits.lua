local fonts = require("scripts/api/image_fonts")

local line_h = 12

local credits_menu = {
    text = {
        "Director :",
        "    Zunashy",
        "Graphic design : ",
        "    Zunashy",
        "Programming :",
        "    TwilCynder",
        "Mapping :",
        "    Zunashy",
        "    Nillan",
        "Writing :",
        "    Zunashy",
        "    Phoenix",
        "    Nillan",
        "    TwilCynder",
        "Dialogs",
        "    Phoenix",
        "    Nillan",
        "Special Thanks",
        "    Anarith",
        "    Pure Zelda-",
        "    Classic",
        "Realise avec le ",
        "moteur Solarus"
    }, 
    x = 0,
    y = 0
}

credits_menu.surface = sol.surface.create(160, #credits_menu.text * line_h)

function credits_menu:write_line(line, y)
    local x = 0
    for c in line:chars() do
        self.font:draw_char(c:byte(), self.surface, x, y)
        x = x + 8
    end
end


function credits_menu:on_started()
    self.surface:fill_color({0, 0, 0})
    self.font = fonts:new("oracle")
    local y = 0
    for _, line in pairs(self.text) do 
        self:write_line(line, y)
        y = y + line_h
    end

    sol.main.get_game().disable_pause_menu = true
    sol.main.get_game():set_paused()

    sol.timer.start(self, 2000, function()
        local m = sol.movement.create("straight")
        m:set_speed(32)
        m:set_angle(math.pi * 0.5)
        m:start(credits_menu)
        m:set_max_distance(#credits_menu.text * line_h - 144)
        function m:on_finished()
            sol.timer.start(2000, function()
                sol.main.exit()
            end)
        end
    end)
    self.surface:fade_in(20)

end

function credits_menu:on_draw(dst_surf)
    self.surface:draw(dst_surf, self.x, self.y)
end

return credits_menu
