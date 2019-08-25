-- Fonction appelée à l'évènement on_position_changed du héros
function detect_safe_spot(hero, x, y, layer)
  -- On est en contact d'eau profonde ?
  local touch_deep_water = false
  for entity in hero:get_map():get_entities_in_rectangle(x-32, y-32, 64, 64) do
    -- S'il s'agit d'une entité custom d'eau profonde
    if entity:get_type() == "custom_entity" and entity.is_deep_water then
      -- Si on touche au moins une entité d'eau profonde
      if hero:overlaps(entity) then
        touch_deep_water = true
      end
    end
  end
  if hero:get_ground_below() == "deep_water" then
    touch_deep_water = true
  end

  -- Si on est en contact avec aucune case d'eau profonde, c'est safe
  if not touch_deep_water then
    hero.safe_x = x
    hero.safe_y = y
  end
end


-- Fonction appelée lors du changement d'état du héros
function detect_sinking(hero, state)
  -- On se base sur le nouvel état et sur l'ancien pour savoir si on coule
  -- Si le moteur essaie de nous remettre sur le sol après avoir couler
  if hero.last_state == "plunging" and state == "back to solid ground" then
    hero.is_sinking = true 
  end
  -- enregistrement de l'état qui sera l'état précédent lors du prochain changement
  hero.last_state = state
end


-- Fonction appelée lorsqu'un mouvement commence sur le héros
function place_in_safe_spot(hero, movement)
  -- Si le héros commence alors qu'on coule et qu'il s'agit d'un mouvement ciblé
  -- On part du principe qu'il s'agit du mouvement que le moteur enclenche pour nous sortir de l'eau
  if hero.is_sinking and sol.main.get_type(movement) == "target_movement" then
    -- On change la cible de ce mouvement pour mener aux positions qu'on a calculés
    movement:set_target(hero.safe_x, hero.safe_y)
    -- On est plus en train de couler
    hero.is_sinking = false
  end
end

-- On relie nos fonctions aux évènements correpondants
local hero_meta = sol.main.get_metatable("hero")
hero_meta:register_event("on_position_changed", detect_safe_spot)
hero_meta:register_event("on_state_changed", detect_sinking)
hero_meta:register_event("on_movement_started", place_in_safe_spot)
return true
