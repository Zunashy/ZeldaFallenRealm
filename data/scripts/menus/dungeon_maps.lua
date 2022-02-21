local room_types = require("scripts/feature/dungeon_room_types")

local cw = 6
local position = require("scripts/feature/positionConverter").pos_to_id(cw)

return {
    {
        id = "1",
        name = "menus.dungeon_names.1",
        floors = {
            [0] = {
                cw = cw,
                ch = 8,
                rooms = {
                    [position(0, 0)] = {type = room_types.normal_s},
                    [position(0, 1)] = {type = room_types.normal_sn},
                    [position(0, 2)] = {type = room_types.normal_sn},
                    [position(0, 3)] = {type = room_types.normal_ne},
                    [position(1, 3)] = {type = room_types.normal_we},
                    [position(2, 0)] = {type = room_types.normal_s},
                    [position(2, 1)] = {type = room_types.normal_sn},
                    [position(2, 2)] = {type = room_types.normal_sn},
                    [position(2, 3)] = {type = room_types.normal_wne},
                    [position(3, 0)] = {type = room_types.normal_s},
                    [position(3, 1)] = {type = room_types.normal_sn},
                    [position(3, 2)] = {type = room_types.normal_sn},
                    [position(3, 3)] = {type = room_types.normal_wne},
                    [position(4, 3)] = {type = room_types.normal_we},
                    [position(5, 0)] = {type = room_types.normal_s},
                    [position(5, 1)] = {type = room_types.normal_sn},
                    [position(5, 2)] = {type = room_types.normal_sn},
                    [position(5, 3)] = {type = room_types.normal_wn},
                    [position(2, 4)] = {type = room_types.normal_se},
                    [position(3, 4)] = {type = room_types.normal_wn},
                    [position(2, 5)] = {type = room_types.normal_sn},
                    [position(3, 5)] = {type = room_types.normal_s},
                    [position(2, 6)] = {type = room_types.normal_sne},
                    [position(3, 6)] = {type = room_types.normal_swn},
                    [position(2, 7)] = {type = room_types.normal_n},
                    [position(3, 7)] = {type = room_types.normal_n},
                }
            }
        }
    },
    {
        id = "2",
        name = "menus.dungeon_names.2",
        floors = {
            [0] = {
                cw = 8,
                ch = 6,
                rooms = {

                }
            },
            [1] = {
                cw = 8,
                ch = 6,
                rooms = {
                    
                }
            }
        }
    }
}