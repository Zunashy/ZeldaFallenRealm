--global object containing all public functions created here.
gen = {}

--coeficients linked to all 4 dirs = coordinates of an unitary vector pointing in that direction.
gen.dirCoef = {
  {x = 1, y = 0},
  {x = 0, y = -1},
  {x = -1, y = 0},
  {x = 0, y = 1}
}

--Transpose a point following a specified direction, with a specified direction.
function gen.shift_direction4(x, y, dir, dist)
  return x + dist * gen.dirCoef[dir + 1].x, y + dist * gen.dirCoef[dir + 1].y
end

--Adds properties of the src object to the dest object. Useful to import functions from feature objects (gen, eg, mg, mpg) to game objects.
function gen.import(dest, src, ...)
  if not (dest and src) then return end
  
  local args = {...}
  if not next(args) then
    args = src
  end

  for _, p in ipairs(args) do
    if src[p] then
      dest[p] = src[p]
    end
  end

end

--Crée une nouvelle classe, avec sa métatable, et une méthode new() pour créer une instance.
--Si bClass est spécifié, cette classe héritera de bClass

function gen.class(bClass)
  local newclass = {}
  newclass.mt = {
    __index = newclass,
    __tostring = function () return newclass.name end
  }

  function newclass:new(...)
    local inst
    if type(self.build) == "function" then
      inst = self:build(...) or {}
    elseif bClass then
      inst = bClass:new(...)
    else
      inst = {}
    end
    setmetatable(inst, self.mt)
    if type(newclass.constructor) == "function" then
      if inst:constructor(...) then
        return false
      end
    end 
    return inst
  end

  local meta
  if bClass then
    if type(bClass) == "table" and bClass.__index then
      meta = bClass
    else
      meta = {__index = bClass}
    end
  else 
    meta = {}
  end
  meta.__call = newclass.new
  setmetatable(newclass, meta)

  newclass.name = tostring(newclass)

  return newclass
end

function gen.new(class, ...)
  if type(class.new) == "function" then
    return class:new(...)
  end
end

function table.deepcopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      if copies[orig] then
          copy = copies[orig]
      else
          copy = {}
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
          end
          copies[orig] = copy
          setmetatable(copy, deepcopy(getmetatable(orig), copies))
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

function gen.xor(a, b) 
  return a and (not b) or (not a) and b
end

function math.sign(x)
  if x<0 then
    return -1
  elseif x>0 then
    return 1
  else
    return 0
  end
end

return gen