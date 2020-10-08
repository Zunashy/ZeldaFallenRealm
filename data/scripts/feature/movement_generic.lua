mg = {}

local direction_name = {"droite", "haut", "gauche", "bas"}

function mg.dir_from_angle(angle)
  return math.floor(angle / (math.pi / 2) + 0.5) % 4
end

-- Fonction utilitaire
-- On construit un tableau de 4 éléments qui contient les 4 directions dans l'ordre
-- de celle qui est la plus proche de l'angle donné à celle qui est la plus éloignée
function mg.directions_from_angle(angle)
  local directions = {}
  -- On vérifie que l'angle est dans [0, 2π[
  angle = math.fmod(angle, 2*math.pi)
  -- On divise l'angle par π/2, on a quelque chose dans [0, 4[
  -- Entre 0.5 et 1.5, c'est la direction haut (1), entre 1.5 et 2.5 c'est gauche (2)...
  -- Cas particulier pour droite (0) qui est > 3.5 ou < 0.5
  -- Du coup on rajoute 0.5, on a donc : 
  --  < 1 -> droite : 0
  --  > 1 et < 2 ->haut : 1 ...
  -- On prend donc l'arrondi au dessous (floor) modulo 4 pour revenir à 0 quand on est à 4
  directions[0] = math.floor(angle / (math.pi / 2) + 0.5) % 4
  -- Selon de quel côté (> ou <) l'angle se trouve par rapport à la direction principale,
  -- la direcion secondaire n'est pas la même. Cas particulier où la direction principale est la droite
  if directions[0] == 0 then
    if angle > math.pi then
      -- Angle plus vers le bas
      directions[1] = 3
    else
      -- Angle plus vers le haut
      directions[1] = 1
    end
  else
    if angle - math.pi/2 * directions[0] > 0 then
      -- L'angle est plus grand que la direction ramenée à un angle
      directions[1] = (directions[0] + 1) % 4
      -- On est plus proche de direction suivante
    else
      -- Sinon, on est plus proche de la direction précédente
      directions[1] = (directions[0] - 1) % 4
    end
  end
  -- La troisième direction est l'opposée de la deuxième
  directions[2] = (directions[1] + 2) % 4
  -- La quatrième est l'opposée de la première
  directions[3] = (directions[0] + 2) % 4

  return directions
end

-- Fonction utilitaire qui teste la présence d'un obstacle à côté d'une entitée dans la direction donnée
function mg.test_obstacles_dir(entity, dir, distance)
  local distance = distance or 1
  return entity:test_obstacles(gen.dirCoef[dir + 1].x * distance, gen.dirCoef[dir + 1].y * distance)
end


-- Fonction qui dit dans quelle direction doit aller un enemi
function mg.choose_direction(enemy)
  local map = enemy:get_map()
  -- On récupère les directions 
  local dirs = mg.directions_from_angle(enemy:get_angle(map:get_hero()))
  local continue = true
  local i = 0

  while continue and i < 4 do
  --  print(i)
    -- On teste s'il y a un obstacle à côté de l'ennemi dans la direction dirs[i]
    -- Ou s'il s'agit de la direction "interdite" pour éviter l'effet "yoyo"
    -- Ou si c'est d'où vient (on accepte le demi-tour si c'est la seule solution)
    if (not mg.test_obstacles_dir(enemy, dirs[i]))
      and (i == 2 or i == 3 or dirs[i] ~= enemy.forbidden_direction) 
      and (dirs[i] ~= enemy.back_direction or (mg.test_obstacles_dir(enemy, dirs[(i+1)%4])
      and mg.test_obstacles_dir(enemy, dirs[(i+2)%4]) and mg.test_obstacles_dir(enemy, dirs[(i+3)%4]))) then
      continue = false
    else
      i = i+1
    end
  end

  -- Si la direction principale est la direction but, c'est qu'on a contourné l'obstacle
  -- on reset donc les données relatives au contournement d'obstacle
  if i == 0 and dirs[0] == enemy.goal_direction then
    enemy.goal_direction = -1
    enemy.forbidden_direction = -1
  end
  -- Si on est obligé de prendre la deuxième direction, c'est parce qu'il y a un obstacle,
  -- on enclenche la séquence de contournement
  if i == 1 then
    enemy.goal_direction = dirs[0]
    enemy.forbidden_direction = dirs[2]
    enemy.counter = 2
  end
  if i == 2 and dirs[2] == (enemy.goal_direction + 2) % 4 then
    i = 3
  end

  -- On sauvegarde la direction qu'on vient de calculer
  enemy.back_direction = (dirs[i%4] + 2) % 4

  return dirs[i % 4]
end

function mg.choose_random_direction(entity, callback)
  local dirs = {}
  local i = 0
  callback = callback or (function(dir, entity) return dir end)
  for dir = 0,3 do
    if callback(dir, entity) then
      i = i + 1
      dirs[i] = dir
    end
  end

  math.randomseed(os.time())
  local dir = math.random(1,i)
  return dirs[dir]
end

-- Fonction qui lance le mouvement vers le héros
function mg.target_hero(enemy, speed)
  if sol.main.get_type(enemy) ~= "enemy" then
    print("Erreur, le paramètre n'est pas de type enemy")
    return
  end

  enemy.is_moving = true

  -- Vitesse par défaut
  if speed == nil then
    if enemy.t_speed == nil then
      enemy.t_speed = 40
    end
  else
    enemy.t_speed = speed
  end

  if enemy.goal_direction == nil then
    enemy.goal_direction = -1
  end 
  if enemy.forbidden_direction == nil then
    enemy.forbidden_direction = -1
  end

  if enemy.back_direction == nil then
    enemy.back_direction = -1
  end

  enemy.distance = 0

  if enemy.t_movement == nil or sol.main.get_type(enemy.t_movement) ~= "path_movement" then
    enemy.t_movement = sol.movement.create("path")
    enemy.t_movement:set_speed(enemy.t_speed)
    enemy.t_movement:set_path{2 * mg.choose_direction(enemy)}
    enemy.t_movement:start(enemy)
  else
    enemy.t_movement:set_path{2 * mg.choose_direction(enemy)}
  end
end


-- Fonction qui permet d'arrêter le mouvement (celui utilisé par les fonctions de ce script)
function mg.stop_movement(enemy)
  if enemy.is_moving then
    if sol.main.get_type(enemy.t_movement) == "path_movement" then
      enemy.t_movement:stop()
    end
    enemy.is_moving = false
  end
  mg.reset_movement(enemy)
end


-- Fonction liée à l'évènement on_position_changed pour recalculer la nouvelle trajectoire si nécéssaire
function mg.update_targetting(enemy, x, y, layer)
  enemy.distance = enemy.distance + 1
  if enemy.t_movement and ((enemy.t_movement:get_direction4() % 2 == 0 and x % 8 == 0)
      or (enemy.t_movement:get_direction4() % 2 == 1 and y % 8 == 0)
      or enemy.distance >= 7) then
    if enemy.is_moving then      
      mg.target_hero(enemy)
    end
  end
end


function mg.restart_movement(enemy, movement)
  mg.target_hero(enemy)
end


function mg.reset_movement(enemy, attack)
  enemy.back_direction = -1
  enemy.goal_direction = -1
  enemy.forbidden_direction = -1
  enemy.t_movement = nil
  enemy.is_moving = false
end


function mg.initialize_state(enemy, speed)
  if speed ~= nil then
    enemy.t_speed = speed
  end
  enemy.distance = 0

  enemy:register_event("on_position_changed", mg.update_targetting)
  enemy:register_event("on_obstacle_reached", mg.restart_movement)
  enemy:register_event("on_hurt", mg.reset_movement)
end

function mg.start_jumping(entity, direction, distance, speed, callback)
  local m = sol.movement.create("jump")
  m:set_speed(speed or 16)
  m:set_direction8(direction or 0)
  m:set_distance(distance or 16)
  m:start(entity, callback)
  return m
end

function mg.move_straight(entity, direction, distance, speed, callback, config)
  local m = sol.movement.create("straight")
  m:set_speed(speed or 16)
  m:set_angle((direction or 0) * (math.pi / 2))
  m:set_max_distance(distance or 16)
  if config then
    if config.change_direction then
      entity:get_sprite():set_direction(direction)
    end
    if config.ignore_obstacles then
      m:set_ignore_obstacles(true)
    end
  end
  m:start(entity, callback)
  return m
end

return mg