local title_screen_menu = {}

local surface = sol.surface.create("menus/title.png")

function title_screen_menu:on_draw(screen)
  surface:draw(screen)
end

function title_screen_menu:on_started()
  surface:fade_in()
  sol.timer.start(3000,function()
    surface:fade_out(function() sol.menu.stop(title_screen_menu) end)
  end)
  --surface:fade_in(function()sol.menu.stop(title_screen_menu)end)
end

return title_screen_menu