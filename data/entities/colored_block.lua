local manager = {}

local parse_event_string = require("scripts/feature/event_string")

local function color_trigger_callback(block_destination)
    local map = block_destination:get_map()
    local event
    local color = block_destination.block.colorState.top
    local all_activated = true
    event = block_destination:get_property(color.."_trigger")
    if not event then return end 
    for e in map:get_entities_by_type("custom_entity") do
        if e:get_model() == "colored_block_destination" then
            
            local o_event = e:get_property(color.."_trigger")
            if o_event and o_event == event and e.block and not e.block.colorState.top == color then
                all_activated = false
            end
        end
    end
    if all_activated then
        parse_event_string(map, event)
    end
end

function on_moving(block)
    local dir = block:get_game():get_hero():get_direction()
    local movtype = (dir % 2)

    if block:test_obstacles( 8 * gen.dirCoef[dir + 1].x, 8 * gen.dirCoef[dir + 1].y) then return end

    if block.block_destination then
        local map = block:get_map()
        for k, _ in pairs(block.block_destination.linked_torchs) do
            map:get_entity(k):set_enabled(false)
        end
        block.block_destination.block = nil
        block.block_destination = nil
    end 

    block.nextState = {}
    if movtype == 0 then
        block.nextState.top = block.colorState.right
        block.nextState.right = block.colorState.top
        block.nextState.up = block.colorState.up
    else
        block.nextState.top = block.colorState.up
        block.nextState.up = block.colorState.top
        block.nextState.right = block.colorState.right
    end

    block:get_sprite():set_animation(block.colorState.top .. block.nextState.top)
    block:get_sprite():set_direction(dir)
    local frame_delay = ((0.4) / ((movtype == 1) and 3 or 2)) * 1000
    block.frameID = 0
    block.frame_timer = sol.timer.start(block, frame_delay, function()
        block.frameID = block.frameID + 1
        block:get_sprite():set_frame(block.frameID)
    end)
end

function on_moved(block)
    block:set_colors_state(block.nextState)
    block.frame_timer:stop()
    local map = block:get_map()
    for e in map:get_entities_by_type("custom_entity") do
        if e:get_model() == "colored_block_destination" and e:overlaps(block) then
            block.block_destination = e
            e.block = block
            color_trigger_callback(e)
            for k, _ in pairs(e.linked_torchs) do
                map:get_entity(k):set_enabled(true)
                map:get_entity(k):get_sprite():set_animation(block.colorState.top)
            end
            return
        end
    end
end

function set_colors_state(block, state)
    block:get_sprite():set_animation(state.top)
    block.colorState = state
end

function manager.init(block)
    block.is_colored_block = true
    block.on_moving = on_moving
    block.on_moved = on_moved
    block.set_colors_state = set_colors_state
    block:set_colors_state({top = "red", right = "yellow", up = "blue"})
end

return manager