-- An icon that shows the inventory item assigned to a slot.

local item_icon_builder = {}

local background_img = sol.surface.create("hud/item_icon.png")

function item_icon_builder:new(game, config)

  local item_icon = {name = "HUD Item Icon"}

  item_icon.slot = config.slot or 1
  item_icon.surface = sol.surface.create(22, 22)
  item_icon.item_sprite = sol.sprite.create("entities/items")
  item_icon.item_displayed = nil
  item_icon.item_variant_displayed = 0
  item_icon.current_amount = 0

  local display_amount = false

  local dst_x, dst_y = config.x, config.y

  local digits_text = sol.text_surface.create({
    font = "8_bit OOS",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  })
  digits_text:set_horizontal_alignment("right")

  function item_icon:rebuild_surface()

    item_icon.surface:clear()

    -- Background image.
    background_img:draw(item_icon.surface)

    if item_icon.item_displayed ~= nil then
      -- Item.
      item_icon.item_sprite:draw(item_icon.surface, 8, 13)
    end

    if display_amount then
      digits_text:draw(item_icon.surface, 21, 8)
    end

  end

  function item_icon:on_draw(dst_surface)

    local x, y = dst_x, dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    item_icon.surface:draw(dst_surface, x, y)
  end

  local function set_amount(amount)
    digits_text:set_text(tostring(amount))
  end

  local function check_item(item)
    local need_rebuild
    if item_icon.item_displayed ~= item then
      need_rebuild = true
      item_icon.item_displayed = item
      item_icon.item_variant_displayed = nil
      if item ~= nil then
        item_icon.item_sprite:set_animation(item:get_name())
        display_amount = item:has_amount()
        set_amount(item:get_amount())
      end
    end

    if item ~= nil then
      -- Variant of the item.
      local item_variant = item:get_variant()
      if item_icon.item_variant_displayed ~= item_variant then
        need_rebuild = true
        item_icon.item_variant_displayed = item_variant
        item_icon.item_sprite:set_direction(item_variant - 1)
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
        item_icon:rebuild_surface()
        return true
    end
    
  end

  local function check()
    -- Item assigned.
    local item = game:get_item_assigned(item_icon.slot)
    check_item(item)

    return true  -- Repeat the timer.
  end

  local old = game.set_item_assigned
  function game:set_item_assigned(slot, item)
    if (slot == item_icon.slot) then
      check_item(item)
    end
    old(game, slot, item)
  end

  local meta = sol.main.get_metatable("item")
  meta:register_event("on_amount_changed", function(item, amount)
    if (item == item_icon.item_displayed) and (display_amount) then
      set_amount(amount)
      item_icon:rebuild_surface()
    end
  end)

  -- Periodically check.
  --check()
  --sol.timer.start(game, 50, check)
  
    if not check_item(game:get_item_assigned(item_icon.slot)) then
        item_icon:rebuild_surface()
    end
    
  return item_icon
end

return item_icon_builder