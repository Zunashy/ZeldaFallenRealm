local function pos_to_id_(x, y, cw)
    return y * cw + x
end

local function pos_to_id(cw)
    return function(x, y)
        return pos_to_id_(x, y, cw)
    end
end

local function id_to_x(id, cw)
    return id % cw
end

local function id_to_y(id, cw)
    return math.floor(id / cw)
end

local function id_to_pos(id, cw)
    return id_to_x(id, cw), id_to_y(id, cw)
end

return {
    pos_to_id_ = pos_to_id_,
    pos_to_id = pos_to_id,
    id_to_x = id_to_x,
    id_to_y = id_to_y,
    id_to_pos = id_to_pos
}