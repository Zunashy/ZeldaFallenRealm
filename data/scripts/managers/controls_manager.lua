local controls = {}

default_controls = {
    action = "space",
    attack = "p",
    item_1 = "k",
    item_2 = "o",
    right = "d",
    up = "z",
    left = "q",
    down = "s",
    pause = "return",
    select = "backspace"
}

current_controls = {}

for k, v in pairs(default_controls) do current_controls[k] = v end

function controls:load()
    local file, error = sol.file.open("controls.dat", "r")
    local key, val
    if file then
        for line in file:lines() do
            key, val = line:xfields("=")
            key = key:rtrim()
            key = key:ltrim()
            val = val:rtrim()
            val = val:ltrim()

            current_controls[key] = val
        end
    else
        print(error)
        return
    end
end

function controls:apply(game, commands)
    assert(type(commands) == "table", "Bad argument #1 to controls:apply() : commands must be a table.")
    for k, _ in pairs(commands) do
        game:set_command_keyboard_binding(k, current_controls[k])
    end
end

function controls:save()
    local file, error = sol.file.open("controls.dat", "w")
    if not file then
        print(error)
        return false
    end
    for k, v in pairs(current_controls) do
        file:write(k .. " = "..v..'\n')
    end
end

function controls:get_keyboard_bindings()
    return current_controls
end

return controls