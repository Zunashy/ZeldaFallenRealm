sol.audio.default_music_volume = 0

function sol.audio.disable_music()
    print("disable")
    sol.audio.set_music_volume(0)
end