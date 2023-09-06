--global object containing all public functions created here.
gen = {}

--coeficients linked to all 4 dirs = coordinates of an unitary vector pointing in that direction.

local dirCoef = {
  {x = 1, y = 0},
  {x = 0, y = -1},
  {x = -1, y = 0},
  {x = 0, y = 1}
}
gen.dirCoef = dirCoef


--Transpose a point following a specified direction, with a specified direction.
function gen.shift_direction4(x, y, dir, dist)
  return x + dist * dirCoef[dir + 1].x, 
         y + dist * dirCoef[dir + 1].y
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

-- Récupère une des propriétés custom données (la première qui a une valeur)
function gen.get_any_property(entity, ...)
  for _, key in ipairs({...}) do
    local property = entity:get_property(key)
    if property then
      return property
    end
  end
  return nil
end

--Crée une nouvelle classe, avec sa métatable, et une méthode new() pour créer une instance.
--Si bClass est spécifié, cette classe héritera de bClass

local function new_instance(self, ...)
  local inst
  if type(self.build) == "function" then
    inst = self:build(...) or {}
    assert(type(inst) == "table", "Error while creating instance of class " .. tostring(self) .. " : build method did not return a table or nil/false") 
  else
    inst = {}
  end
  inst.class = self
  setmetatable(inst, self.mt)
  if type(self.constructor) == "function" then
    if inst:constructor(...) then
      return false
    end
  end 
  return inst
end

function gen.class(bClass)
  if bClass then
    return gen.inherit_class(bClass)
  end

  local newclass = {}
  newclass.mt = {
    __index = newclass,
    __tostring = function () return "Instance of class :" .. newclass.name end
  }

  newclass.new = new_instance

  setmetatable(newclass, {
    __call = new_instance,
    __tostring = function () return "Class : " .. newclass.name end
  })

  return newclass
end

function gen.inherit_class(bClass)
  local newclass = {}
  newclass.mt = {
    __index = newclass,
    __tostring = function () return "class : " .. newclass.name end
  }

  newclass.new = new_instance

  local meta
  if type(bClass) == "table" and bClass.__index then --the bclass is a metatable
    meta = bClass
  else
    meta = {__index = bClass}
    newclass.super = bClass
  end

  meta.__call = newclass.new
  setmetatable(newclass, meta)

  newclass.name = tostring(newclass)

  return newclass
end

function gen.new(class, ...)
  return class:new(...)
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
  return x > 0 and 1 or (x == 0 and 0 or -1)
end

local directions = {
  [-1] = {
    [-1] = 5,
    [0]  = 4,
    [1]  = 3
  },
  [1] = {
    [-1] = 7,
    [0]  = 0,
    [1]  = 1
  },
  [0] = {
    [-1] = 6,
    [0]  = nil,
    [1]  = 2
  }
}

function gen.vector8_direction(x, y)
  return directions[x][y]
end

function gen.splitColor(code)
  local r, g, b
  b = code % 256
  code = (code - b) / 256
  g = code % 256
  r = (code - g) / 256
  return r, g, b
end

function gen.copyFile(src, dest)
  if not sol.file.exists(src) then return false end
  print("cp "..src.." "..dest)
  os.execute("cp "..src.." "..dest)
end

local seed = 1
local mod = require("scripts/api/bit").pow2(32)

function gen.randomseed(seed_)
  seed = seed_ % mod
end

function gen.random(bound, upper)
  seed = ((seed * 214013) + 2531011) % mod
  local res = seed / mod
  if bound then
    if upper then
      upper = upper - bound
      return math.floor(res * upper + bound)
    end
    return math.floor(res * bound)
  end
  return res 
end

gen.vector_class = gen.class()

function gen.vector_class:set(x, y)
  self.x = x
  self.y = y
end

function gen.vector_class:get()
  return self.x, self.y
end

gen.vector_class.name = "Vector"

gen.rect_class = gen.class(gen.vector_class)


function gen.rect_class:set(x, y, w, h)
  self.super.set(self, x, y)
  self.w = w
  self.h = h
end

function gen.rect_class:get()
  local x, y = self.super.get(self)
  return x, y, self.w, self.h
end

gen.rect_class.name = "Rectangle"

return gen