local separator_manager = {}

local enemy_places
local destructible_places
local entity_places
local block_places
local destroy_on_activate

local function get_stored_enemies()
    return enemy_places
end

local function get_sprite_name(entity)
    local sprite = entity:get_sprite()
    return sprite and sprite:get_animation_set() or ""
end

local function enemy_death_calback(self)
    self.dead = true
end

local function separator_on_activated(separator)
    local map = separator:get_map()
    local hero = map:get_hero()

    --Managing every enemy that was saved

    local entity, old_entity
    --Enemies.
    for _, place in ipairs(enemy_places) do
        entity = place.enemy

        --If the enemy is enabled, disable it
        if entity:is_enabled() then
            entity:set_enabled(false)
            entity.disabled_by_separator_manager = true
        end

        --Enemies in the current region are enabled and reset
        if entity.disabled_by_separator_manager and entity:is_in_same_region(hero) and not entity.dead then
            entity:set_enabled(true)
            entity:set_position(place.x, place.y, place.layer)
            local sprite = entity:get_sprite()
            sprite:set_animation("walking")
            sprite:set_direction(place.direction)

            entity.disabled_by_separator_manager = false
            if entity.on_reset then
                entity:on_reset()
            end
            if entity.on_restarted then
                entity:on_restarted()
            end
        end
    end

    --Entities
    for _, place in ipairs(entity_places) do
        entity = place.entity
        if entity:exists() then
            entity:remove()
        end

        if entity:is_in_same_region(hero) then
            place.entity = map:create_custom_entity(place) 
        end
    end

    --Blocks
    for block in map:get_entities_by_type("block") do
        if not block:get_property("no_reset") then
        -- Reset blocks in regions no longer visible.
            if not block:is_in_same_region(hero) then
                block:reset()
            end
        end
    end

    for _, place in ipairs(block_places) do
        if not place.block:exists() then
            entity = map:create_block(place)
            entity:set_pushable(place.pushable)
            entity:set_pullable(place.pullable)
        end
    end

    for _, place in ipairs(destructible_places) do
        entity = place.destructible 
        
        if not entity:exists() then
            entity = map:create_destructible(place)
            entity:set_treasure(unpack(place.treasure))
        end
    end
    for _, e in ipairs(destroy_on_activate) do
        e:remove()
    end
end

function separator_manager:manage_map(map)
    local game = map:get_game()
    local hero = map:get_hero()

    enemy_places = {}
    destructible_places = {}
    entity_places = {}
    block_places = {}
    destroy_on_activate = {}

    map.get_stored_enemies = get_stored_enemies


    for separator in map:get_entities_by_type("separator") do
        if not separator:get_property("no_reset") then
            separator:register_event("on_activated", separator_on_activated)     
        end
    end
    --===  Storing entities ===--
    --Enemies.

    for enemy in map:get_entities_by_type("enemy") do
        if not (enemy:get_property("no_reset") or enemy.no_reset) then
            local x, y, layer = enemy:get_position()
            local sprite = enemy:get_sprite()
            table.insert(enemy_places, {
                x = x,
                y = y,
                layer = layer,
                direction = sprite and sprite:get_direction() or 0,
                name = enemy:get_name(),
                enabled_at_start = enemy:is_enabled(),
                enemy = enemy,
            })

            enemy:register_event("on_dead", enemy_death_calback)

            --Enemies that are in other regions are disabled
            if not enemy:is_in_same_region(hero) and enemy:is_enabled() then
                enemy:set_enabled(false)
                enemy.disabled_by_separator_manager = true
            end
            
        end
    end

    --Destructibles.
    for destructible in map:get_entities_by_type("destructible") do
        if not (destructible:get_property("no_reset") or destructible.no_reset) then
            local x, y, layer = destructible:get_position()
            table.insert(destructible_places, {
                x = x,
                y = y,
                layer = layer,
                name = destructible:get_name(),
                treasure = { destructible:get_treasure() },
                sprite = get_sprite_name(destructible),
                destruction_sound = destructible:get_destruction_sound(),
                weight = destructible:get_weight(),
                can_be_cut = destructible:get_can_be_cut(),
                can_explode = destructible:get_can_explode(),
                can_regenerate = destructible:get_can_regenerate(),
                damage_on_enemies = destructible:get_damage_on_enemies(),
                ground = destructible:get_modified_ground(),
                properties = destructible:get_properties(),
                destructible = destructible
            })
        end
    end

    --Entities.
    for entity in map:get_entities_by_type("custom_entity") do
        if entity:get_property("separator_reset") or entity.separator_reset then
            local x, y, layer = entity:get_position()
            local w, h = entity:get_size()
            local sprite = entity:get_sprite()
            table.insert(entity_places, {
                x = x,
                y = y,
                layer = layer,
                width = w,
                height = h,
                model = entity:get_model(),
                direction = sprite and sprite:get_direction() or 0,
                name = entity:get_name(),
                sprite = sprite and sprite:get_animation_set() or "",
                enabled_at_start = entity:is_enabled(),
                properties = entity:get_properties(),
                entity = entity,
            })
        end
    end 

    --Blocks.
    for block in map:get_entities_by_type("block") do
        local x, y, layer = block:get_position()
        table.insert(block_places, {
            x = x,
            y = y,
            layer = layer,
            name = block:get_name(),
            block = block,
            pushable = block:is_pushable(),
            pullable = block:is_pullable(),
            max_moves = block:get_max_moves(),
            sprite = block:get_sprite():get_animation_set(),
            enabled_at_start = block:is_enabled(),
            properties = block:get_properties(),
            colored = block.is_colored_block
        })
    end

    map.separator_manager_enabled = true
end

function separator_manager:destroy_on_separator(e)
    destroy_on_activate[#destroy_on_activate + 1] = e
    table.insert(destroy_on_activate, e)
end

return separator_manager