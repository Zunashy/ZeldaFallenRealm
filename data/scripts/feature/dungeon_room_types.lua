local room_types = {
    normal_swne = true,
    normal_swn = true,
    normal_swe = true,
    normal_sw = true,
    normal_sne = true,
    normal_sn = true,
    normal_se = true,
    normal_s = true,
    normal_wne = true,
    normal_wn = true,
    normal_we = true,
    normal_w = true,
    normal_ne = true,
    normal_n = true,
    normal_e = true,
    normal_nodoors = true,
}

for name, _ in pairs(room_types) do
    room_types[name] = sol.surface.create("menus/dungeon_map_rooms/"..name..".png")
    --print("menus/dungeon_map_room_types/"..name..".png")
    --print(room_types[name])
end

return room_types