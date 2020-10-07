sol.audio.default_music_volume = 0

function sol.audio.disable_music()
    sol.audio.current_music_volume = sol.audio.get_music_volume()
    sol.audio.set_music_volume(0)
end

function sol.audio.restore_music()
    sol.audio.set_music_volume(sol.audio.current_music_volume)
end