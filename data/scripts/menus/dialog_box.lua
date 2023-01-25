--====== INIT DIALOG_BOX =======
local dialog_box = {

  -- Dialog box properties.
  dialog = nil,                -- Dialog being displayed or nil.
  first = true,                -- Whether this is the first dialog of a sequence.
  style = nil,                 -- "box" or "empty".
  vertical_position = "auto",  -- "auto", "top" or "bottom".
  skip_mode = nil,             -- "none", "current", "all" or "unchanged".
  icon_index = nil,            -- Index of the 16x16 icon in hud/dialog_icons.png or nil.
  info = nil,                  -- Parameter passed to start_dialog().
  skipping = false,            -- Whether the player skipped the dialog.
  selected_answer = nil,       -- Selected answer (1 or 2) or nil if there is no question.
  next = nil,
  name = "Dialog Box",

  -- Displaying text gradually.
  current_line = nil,             -- Next line to display or nil.
  next_line = nil,
  new_lines = 0,
  line_movement = nil,
  char_timer = nil,
  line_it = nil,               -- Iterator over of all lines of the dialog.
  line_surfaces = {},          -- Array of the 3 text surfaces.
  line_index = nil,            -- Line currently being shown.
  char_index = nil,            -- Next character to show in the current line.
  char_delay = nil,            -- Delay between two characters in milliseconds.
  full = false,                -- Whether the 3 visible lines have shown all content.
  need_letter_sound = false,   -- Whether a sound should be played with the next character.
  gradual = true,              -- Whether text is displayed gradually.
  text_speed = 3, 

  -- Graphics.
  surface = nil,
  box_surface = nil,
  cursor_surface = nil,
  illutration_surface = nil,
  icons_img = nil,
  end_arrow = nil,
  arrow_timer = nil,
  draw_arrow = false,
  box_position = nil,      -- Destination coordinates of the dialog box.
  question_dst_position = nil, -- Destination coordinates of the question icon.
  icon_dst_position = nil,     -- Destination coordinates of the icon.
  df_font = "oracle",
  current_font = "", 
  font_size = 9,
  choice_cursor_positions = {24, 100, y = 24}
}


-- Constants.
local nb_visible_lines = 2     -- Maximum number of lines in the dialog box.
local char_delays = {          -- Delay before displaying the next character.
  45,
  30,
  15
}
local letter_sound_delay = 50
local box_size = {w = 144, h = 40}
local arrow_pos = {x = 136, y = 33}
local line_spacing = 16
local text_pos = {} -- Text position relative to the box
local line_transition_speed = 64
local text_max_width = box_size.w - 15

function text_pos:reset()
  self.x = 8
  self.y = 6
end

local function on_game_started()
  -- Initialize dialog box data.
  --dialog_box.font, dialog_box.font_size = language_manager:get_dialog_font()
  for i = 1, nb_visible_lines do
    dialog_box.line_surfaces[i] = gen.char_surface.create(text_max_width, 11, "")
  end

  dialog_box.surface = sol.surface.create(sol.video.get_quest_size())
  dialog_box.box_surface = sol.surface.create(box_size.w, box_size.h)
  dialog_box.end_arrow = sol.surface.create("menus/dialog.png")
  dialog_box.cursor_surface = sol.surface.create("menus/dialog_cursor.png")

  dialog_box.box_position = gen.vector_class()
  dialog_box.illustration_position = gen.vector_class()
  dialog_box.illutration_surface = sol.surface.create(32, 32)

end

--dialog_box.box_img = sol.surface.create("hud/dialog_box.png")
--dialog_box.icons_img = sol.surface.create("hud/dialog_icons.png")
--dialog_box.end_lines_sprite = sol.sprite.create("hud/dialog_box_message_end")

--====== DIALOG MENU CALLBACKS ======

function dialog_box:on_started()
  self.char_delay = char_delays[self.text_speed] -- à remplacer par une vraie sélection de la vitesse (settings ?)
  self.box_position:set(8, 96)
  self.illustration_position:set(64, 48)

  local map = self.game:get_map()
  local hero = self.game:get_hero()
  local _, hero_y = map:get_camera():get_position_on_camera(hero:get_position())
  local _, cam_h = map:get_camera():get_size()
  if hero:is_enabled() and hero:is_visible() then
    print(hero_y > cam_h - 56)
    if hero_y > cam_h - 56 and not (self.dialog.position == "bottom") or (self.dialog.position == "top")  then
      self.box_position:set(8, 24)
      self.illustration_position:set(64, 80)
    end
  end

  self:show_dialog()
end

function dialog_box:on_finished()
end

function dialog_box:on_draw(dst_surface)
  local x, y = self.box_position:get()
  self.box_surface:fill_color({0, 0, 0})

  if self:is_full() then
    if self:is_choice_active() then
      self.cursor_surface:draw(self.box_surface, self.choice_cursor_positions[self.selected_answer], self.choice_cursor_positions.y)
    elseif self.draw_arrow then
      self.end_arrow:draw(self.box_surface, arrow_pos.x, arrow_pos.y)
    end
  end
  
  local text_y = text_pos.y
  local text_x = text_pos.x
  for i = 1, nb_visible_lines do
    self.line_surfaces[i]:draw(self.box_surface, text_x, text_y)
    text_y = text_y + line_spacing
  end
  
  if self.illustrate then
    self.illutration_surface:draw(self.surface, self.illustration_position:get())
  end
  self.box_surface:draw(self.surface, x, y)
  self.surface:draw(dst_surface)
end

function dialog_box:on_command_pressed(command)
  if command == "action" and dialog_box:is_full() then
    dialog_box:advance()
  elseif command == "attack" then 
    if dialog_box:is_full() then
      dialog_box:advance()
    else
      dialog_box:skip()
    end
  elseif command == "left" and self:is_choice_active() then
    self.selected_answer = 1
  elseif command == "right" and self:is_choice_active() then
    self.selected_answer = 2
  end
  return true
end

--====== DIALOG MENU FUNCTIONS ======

function dialog_box:quit()
  if sol.menu.is_started(self) then
    sol.menu.stop(self)
  end
  
  self.illustrate = false
  self.arrow_timer = nil
  self.game:set_custom_command_effect("action", nil)
  if self.game:is_dialog_enabled() then 
    local answer
    if self.dialog.choice then answer = self.selected_answer end
    self.game:stop_dialog({dialog = self.dialog.dialog_id, answer = answer})
  end
  
end

function dialog_box:is_choice_active()
  return self.dialog.choice and not self:has_more_lines()
end

function dialog_box:is_line_full()
  return self.char_index > #self.current_line
end

-- Updates the result of is_full().
function dialog_box:check_full()
  if self.new_lines > 1 or not self:has_more_lines() then
    self.full = true
  else
    self.full = false
  end
end

function dialog_box:is_full()
  return self.full
end

function dialog_box:start_arrow_blinking()
  if self.arrow_timer then
    return
  end
  self.draw_arrow = true
  self.arrow_timer = sol.timer.start(self, 500, function()
    dialog_box.draw_arrow = not dialog_box.draw_arrow
    return true
  end)
end

function dialog_box:stop_arrow_blinking()
  self.draw_arrow = false
  self.arrow_timer:stop()
  self.arrow_timer = nil
end

local function combine_byte_char(c1, c2)
  return (c1 - 192) * 64 + (c2 - 128)
end

function dialog_box:parse_text()
  local chars_on_line = 0
  local word_start = 0
  local whitespace = false 
  local max_line = math.floor(text_max_width / 8)
  local special = false
  local c
  local i = 1
  local text = self.dialog.text
  local strlen = text:len()

  while i <= strlen do
    c = text:sub(i, i)
    code = c:byte()

    if c == "$" then
      special = true
    elseif special then
      special = false
    elseif c == "\n" then
      whitespace = true
      chars_on_line = 0
    elseif code and code > 31 then
      chars_on_line = chars_on_line + 1

      if c == " " then
        whitespace = true
      elseif whitespace then
        word_start = i    
        whitespace = false
      end

      if chars_on_line > max_line then
        text = text:insert("\n", word_start)
        chars_on_line = i - word_start
        word_start = i
        strlen = strlen + 1
        i = i + 1
      end
    end
    if (code >= 192 and code < 224) then
      i = i + 1
    end
    i = i + 1
  end
  self.dialog.text = text
end

function dialog_box:init_illustration(sprite)
  self.illutration_surface:fill_color({0, 0, 0})
  sprite:draw(self.illutration_surface, 16, 21)
  self.illustrate = true
end

function dialog_box:illustrate_item(name)
  if not name then return end
  local item_name, variant = name:xfields("#")
  local item = self.game:get_item(item_name)
  if item then
    local sprite = sol.sprite.create("entities/items")
    sprite:set_animation(item_name)
    sprite:set_direction((variant or 1) - 1)
    self:init_illustration(sprite)
  end
end

function dialog_box:show_dialog()
-- Initialize this dialog.
  local dialog = self.dialog
  self:parse_text()
  local text = dialog.text

  if dialog_box.info ~= nil then
    -- There is a "$v" sequence to substitute.
    text = text:gsub("%$v", dialog_box.info)
  end
  text = text:gsub("%$n", self.game:get_value("name"))
  -- Split the text in lines.
  text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
  self.line_it = text:gmatch("([^\n]*)\n")  -- Each line including empty ones.
  self.next_line = self.line_it()

  if self.dialog.choice then
    self.dialog.choice = 1
  end
  self.selected_answer = 1

  if self.illustrate_item then
    self:illustrate_item(self.dialog.illustrate_item)
  else
    self.illustrate = false
  end

  self.line_index = 0
  
  self.current_font = self.df_font
  for i = 1, nb_visible_lines do
    self.line_surfaces[i]:clear()
  end
  
  self.surface:clear()
  
  self.need_letter_sound = true

  self:advance()
end

function dialog_box:advance()
  self.new_lines = 0
  self.skipping = false
  if self:has_more_lines() then
    self:pre_next_line()
  else
    self:show_next_dialog()
  end
end

function dialog_box:pre_next_line()
  self:check_full()
  if self:is_full() then
    self:start_arrow_blinking()
    return --on ne fait rien : on laisse la suite à :advance(), call par le callback on_command_pressed
  end

  if self.line_index > 1 then
    self:start_next_line_animation()
    return
  end  

  self.line_index = self.line_index + 1   
  self:start_next_line()

end

function dialog_box:start_next_line()
    print("SLN")
  text_pos:reset()

  self.current_line = self.next_line
  self.next_line = self.line_it()

  if self.next_line == nil and self.dialog.choice == 1 then
    self.next_line = "    oui      non"
    self.dialog.choice = 2
  end

  self.new_lines = self.new_lines + 1

  self.line_surfaces[self.line_index]:set_font(self.current_font, true)

  self.char_index = 0
  self:show_next_char()
end

function dialog_box:shift_text_surfaces()
  self.line_surfaces[1], self.line_surfaces[2] = self.line_surfaces[2], self.line_surfaces[1]
  self.line_surfaces[2]:clear()

end

function dialog_box:start_next_line_animation()
  local line_movement = sol.movement.create("straight")
  line_movement:set_speed(line_transition_speed)
  line_movement:set_angle(math.pi / 2)
  line_movement.dbox = dialog_box
  line_movement:set_max_distance(16)
  self.line_movement = line_movement
  function line_movement:on_finished()
    self.dbox.moving = false
    self.dbox:shift_text_surfaces()
    self.dbox:start_next_line()
  end

  if self.skipping then
    line_movement:on_finished()
    return
  end

  self.moving = true
  line_movement:start(text_pos)
end

function dialog_box:show_next_char()
  local delay = self.char_delay
  local special

  if self.skipping then delay = 0 end

  self.char_index = self.char_index + 1

  if self:is_line_full() then
    self:pre_next_line()
    return
  end 

  local current_char = self.current_line:sub(self.char_index, self.char_index)
  local csurface = self.line_surfaces[self.line_index]
  local code = current_char:byte()


  if current_char == "$" then
    special = true
    self.char_index = self.char_index + 1
    current_char = self.current_line:sub(self.char_index, self.char_index)
    if current_char == "r" then
      self.current_font = "oracle_red" 
      csurface:set_font(self.current_font, true)
    elseif current_char == "b" then
      self.current_font = "oracle_blue" 
      csurface:set_font(self.current_font, true)
    elseif current_char == "o" then
      self.current_font = "oracle" 
      csurface:set_font(self.current_font, true)
    else
      special = false
    end
  end

  if special then
    delay = 0
  else 
  
    if code >= 192 and code < 224 then
      self.char_index = self.char_index + 1
      local current_char2 = self.current_line:sub(self.char_index, self.char_index)
      local code2 = current_char2:byte()

      code = combine_byte_char(code, code2)
    end

    csurface:add_char(code)

    if self.need_letter_sound then
      sol.audio.play_sound("text")
      self.need_letter_sound = false
      sol.timer.start(self, letter_sound_delay, function()
        self.need_letter_sound = true
      end)
    end

  end

  self.char_timer = sol.timer.start(self, delay, function() self:show_next_char(skip) end)
end

function dialog_box:show_next_dialog()
  local next 
  if self.selected_answer == 2 then 
    next = self.dialog.next_dialog_2 
  else
    next = self.dialog.next_dialog
  end

  if next then
    local dialog = sol.language.get_dialog(next)
    if dialog then
      self.dialog = dialog
      self.dialog.dialog_id = next
      self:show_dialog()
    else
      self:quit()
    end
  else
    self:quit()
  end
end

function dialog_box:has_more_lines()
  return self.next_line ~= nil
end

function dialog_box:skip()

  if self.moving then
    self.line_movement:stop()
  end

  self.skipping = true
  self.char_timer:stop()
  self:show_next_char()
end

function dialog_box:get_text_speed()
  return self.text_speed
end

function dialog_box:set_text_speed(speed)
  self.text_speed = speed
end

--====== BINDING THE DIALOG TO THE GAME ======

local function dialog_start_callback(game, dialog, info)
  dialog_box.dialog = dialog
  dialog_box.info = (dialog.use_preset_info) and dialog_box.info or info

  if sol.menu.is_started(dialog_box) then 
    print("/!\\ Tried starting a dialog but the dialog menu is already started")
    sol.menu.stop(dialog_box) 
  end
  sol.menu.start(game, dialog_box)
end

local function get_dialog_box(game)
  return dialog_box
end

local function bind_to_game(game_)
  on_game_started()
  dialog_box.game = game_
  game_:register_event("on_dialog_started", dialog_start_callback)
  game_.get_dialog_box = get_dialog_box
end

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_init", bind_to_game)

return dialog_box