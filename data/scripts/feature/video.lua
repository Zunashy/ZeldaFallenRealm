sol.video.default_scale = 2

local scale = sol.video.default_scale

function sol.video.set_scale(sc)
  scale = sc
  sol.video.set_window_size(160 * sc, 144 * sc)
end

function sol.video.get_scale()
  return scale
end

function sol.video.switch_scale()
  scale = 6 - scale
  sol.video.set_scale(scale)
end