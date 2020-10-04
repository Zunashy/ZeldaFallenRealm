local shaders = {
    shockwave = sol.shader.create("shockwave"),
    obscurity = sol.shader.create("obscurity"),
    chroma = sol.shader.create("chroma"),
    poison = sol.shader.create("poisoned_effect")
}

function shaders.shockwave:on_draw(game)
    local time = sol.main.get_elapsed_time() - self.start_date
    self:set_uniform("rad", (time * 64 * self.speed) / 1000)
end


return shaders