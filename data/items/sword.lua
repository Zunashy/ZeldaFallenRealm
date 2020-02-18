local item = ...
local game = item:get_game()

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
end

function item:on_obtaining()
  game:get_dialog_box().info = require("scripts/api/controls_manager"):get_keyboard_bindings().attack
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end
