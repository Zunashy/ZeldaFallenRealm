local print_nul = print
function print(...)
  print_nul(...)
  io.stdout:flush()
end

function tprint (tbl, indent, max_recursion, recursion_level)
  recursion_level = recursion_level or 1
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      if recursion_level == max_recursion then
        print(v)
      else
        tprint(v, indent+1, max_recursion, recursion_level + 1)
      end
    else
      print(formatting .. tostring(v))
    end
  end
end

function typeof(var)
  local _type = type(var);
  if(_type ~= "table" and _type ~= "userdata") then
      return _type;
  end
  local _meta = getmetatable(var);
  if(_meta ~= nil and _meta._NAME ~= nil) then
      return _meta._NAME;
  else
      return _type;
  end
end
  