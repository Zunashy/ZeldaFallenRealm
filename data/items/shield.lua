local item = ...

function item:on_created()

  self:set_savegame_variable("possession_shield")
  self:set_sound_when_picked(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the shield determines the built-in ability "shield".
  self:get_game():set_ability("shield", variant)
end

