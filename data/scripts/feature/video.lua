local scale = 2

function sol.video.set_scale(sc)
  sol.video.set_window_size(160 * sc, 144 * sc)
end

function sol.video.switch_scale()
  scale = 6 - scale
  sol.video.set_scale(scale)
end