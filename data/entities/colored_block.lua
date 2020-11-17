local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local dirCoef = gen.dirCoef

local parse_event_string = require("scripts/feature/event_string")

function entity:set_colors_state(state)
    self:get_sprite():set_animation(state.top)
    self.colorState = state
end

local function movement_obstacle(self)
    self:stop()
end

local function collision_movement_callback(self)
    if self.entity.restart then
        self.entity:restart()
    end
end

local function collision_callback(entity, other)
    local m = entity:get_movement()
    if m and not (other:get_movement() and other:get_movement().is_color_block_knockback) then
        new_m = sol.movement.create("straight")
        local ox, oy = other:get_position()
        other:set_position(ox + 4 * gen.dirCoef[m.direction + 1].x, oy + 4 * gen.dirCoef[m.direction + 1].y)
        local x, y = entity:get_position()
        new_m:set_max_distance(16 - sol.main.get_distance(x, y, m.start_x, m.start_y))
        new_m:set_angle(m:get_angle())
        new_m:set_speed(64)
        new_m.entity = other
        new_m.is_color_block_knockback = true
        new_m:start(other)
    end
end

function entity:on_created()
    if not self:get_sprite() then 
        self:create_sprite("entities/dungeon_elements/color_cube")
    end
    self:set_modified_ground("low_wall")
    self:set_can_traverse_ground("hole", false)


    self.is_colored_block = true
    self:set_colors_state({top = "red", right = "yellow", up = "blue"})
    self:add_collision_test("overlapping", collision_callback)
end

local function color_trigger_callback(block_destination)
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

    self.separator_reset = true
end

function entity:check_destination()
    for e in map:get_entities_by_type("custom_entity") do
        if e.is_CBD and e:overlaps(self) then
            self.block_destination = e
            e.block = self
            color_trigger_callback(e)
            e:set_torchs_color(self.colorState.top)
            return
        end
    end
end

local function block_movement_finished(self)
    local block = self.block

    block:set_colors_state(block.nextState)
    block.frame_timer:stop()
    block:check_destination()
end

local function hero_movement_finished(self)
    local hero = self.hero

    hero:get_state_object():stop()
end

local function create_movement(dir)
    local m = sol.movement.create("straight")
    m:set_speed(40)
    m:set_angle((math.pi / 2) * dir)
    m:set_max_distance(16)
    return m
end

local visu = require("scripts/debug/visualizer")
function entity:move(dir, hero)
    local movtype = (dir % 2)

    if self:test_obstacles( 8 * dirCoef[dir + 1].x, 8 * dirCoef[dir + 1].y) then return end
    local cx, cy, w, h = self:get_bounding_box()
    for e in map:get_entities_in_rectangle(w * dirCoef[dir + 1].x + cx, h * dirCoef[dir + 1].y + cy, w, h) do
        if (e:get_type() == "enemy") then
            return
        end
    end

    local m
    m = create_movement(dir)
    m.on_finished = block_movement_finished
    m.on_obstacle_reached = movement_obstacle
    m.start_x, m.start_y = self:get_position()
    m.block = self
    m.direction = dir
    m:start(self)

    m = create_movement(dir)
    m.on_finished = hero_movement_finished
    m.hero = hero
    m:start(hero)

    hero:start_push_block()

    if self.block_destination then
        local map = self:get_map()
        for k, _ in pairs(self.block_destination.linked_torchs) do
            map:get_entity(k):set_enabled(false)
        end
        self.block_destination.block = nil
        self.block_destination = nil
    end 

    self.nextState = {}
    if movtype == 0 then
        self.nextState.top = self.colorState.right
        self.nextState.right = self.colorState.top
        self.nextState.up = self.colorState.up
    else
        self.nextState.top = self.colorState.up
        self.nextState.up = self.colorState.top
        self.nextState.right = self.colorState.right
    end

    self:get_sprite():set_animation(self.colorState.top .. self.nextState.top)
    self:get_sprite():set_direction(dir)
    local frame_delay = ((0.4) / ((movtype == 1) and 3 or 2)) * 1000
    self.frameID = 0
    self.frame_timer = sol.timer.start(self, frame_delay, function()
        self.frameID = self.frameID + 1
        self:get_sprite():set_frame(self.frameID)
    end)
end 

function entity:on_hero_state_pushing(hero)
    if self:overlaps(hero, "facing") then
        if hero:get_state() == "pushing" then
            local dir = hero:get_direction()
            local revDir = (dir + 2) % 4
            local x, y = self:get_position()
            hero:set_position(16 * gen.dirCoef[revDir + 1].x + x, 16 * gen.dirCoef[revDir + 1].y + y)

            self:move(dir, hero)
        end
    end
end