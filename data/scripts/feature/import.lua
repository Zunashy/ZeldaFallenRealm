function import(module, ...)
    functions = {...}
    for i, v in ipairs(functions) do
        functions[i] = module[v]
    end
    return unpack(functions)
end