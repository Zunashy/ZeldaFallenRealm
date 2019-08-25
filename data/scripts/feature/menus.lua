local menus = {}
local start_menu = sol.menu.start
local stop_menu = sol.menu.stop

function sol.menu.start(context, menu, on_top)
    start_menu(context, menu, on_top)
    
    local n = table.getn(menus)
    menus[n + 1] = menu
end

function sol.menu.stop(menu)
    stop_menu(menu)
    for i, v in ipairs(menus) do
        if menu == v then
            table:remove(i)
        end
    end
end

function sol.menu.get_menus()
    return menus
end

function sol.menu.menus()
    local i = 1
    return function()
        i = i + 1
        return menus[i - 1]
    end
end
