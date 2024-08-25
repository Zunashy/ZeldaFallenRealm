function import(module, ...)
    local functions = {...}
    for i, v in ipairs(functions) do
        functions[i] = module[v]
    end
    return unpack(functions)
end