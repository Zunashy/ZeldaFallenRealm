local menus = {}
local start_menu = sol.menu.start
local stop_menu = sol.menu.stop

function sol.menu.start(context, menu, on_top, ...)
	if not menu.name then menu.name = "unnamed" end
	--print("Start : ".. menu.name)
    
    context = context or menu.context

	if menus[menu] then return end
	
	start_menu(context, menu, on_top)
    
    local n = table.getn(menus)
    menus[n + 1] = menu
    menu.context = context

    menu.arguments = {...}
    if type(menu.arguments[1]) == "table" then
        menu.arguments = menu.arguments[1]
    end
end

function sol.menu.stop(menu, i)
	--print("Stop : ".. menu.name)
    stop_menu(menu)
    if i then 
        table.remove(menus, i)
        return
    end
    for i, v in ipairs(menus) do
        if menu == v then
            table.remove(menus, i)
        end
    end
end

function sol.menu.stop_all(context)
    local i = 1
    while menus[i] do
        if menus[i].context == context then
            sol.menu.stop(menus[i], i)
        else
            i = i + 1
        end
    end
end

function sol.menu.is_started(menu)
    for m in sol.menu.menus() do
        if menu == m then
            return true
        end
    end
    return false
end

function sol.menu.get_menus()
    return menus
end

function sol.menu.menus(debug)
    local i = 0
    return function()
        i = i + 1
        return menus[i]
    end
end

function sol.menu.debuglist()
    for m in sol.menu.menus(debug) do
        print(m.name, m.context)
    end
end