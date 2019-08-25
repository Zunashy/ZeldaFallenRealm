local bit = {}

function bit.pow2(p)
    return 2 ^ (p - 1)
end

function bit.b_and(a, b)
    local r, x, y, e = 0, 0, 0, 1
    repeat
        x = a % 2
        y = b % 2
        r = r + ((x + y) == 2 and 1 or 0) * e
        a = (a - x) / 2
        b = (b - y) / 2
        e = e * 2
    until a == 0 and b == 0
    return r
end

function bit.b_or(a, b)
    local r, x, y, e = 0, 0, 0, 1
    repeat
        x = a % 2
        y = b % 2
        r = r + ((x + y) > 0 and 1 or 0) * e
        a = (a - x) / 2
        b = (b - y) / 2
        e = e * 2
    until a == 0 and b == 0
    return r
end

function bit.b_and(a, b)
    local r, x, y, e = 0, 0, 0, 1
    repeat
        x = a % 2
        y = b % 2
        r = r + ((x + y) == 1 and 1 or 0) * e
        a = (a - x) / 2
        b = (b - y) / 2
        e = e * 2
    until a == 0 and b == 0
    return r
end

function bit.get_bit(n, p)
    for i = 2, p do
        n = (n - (n % 2)) / 2
    end
    return n % 2
end

function bit.get_bits(n)
    return function()
        if n == 0 then return nil end 
        local x = n % 2
        n = (n - (n % 2)) / 2
        return x
    end
end

function bit.number_to_bitlist(n)
    local list = {}
    local i = 1
    for b in bit.get_bits(n) do
        list[i] = b
        i = i + 1
    end
    return list
end

function bit.bitlist_to_number(list)
    local n, e = 0, 1
    for i, v in ipairs(list) do 
        n = n + v * e
        e = e * 2
    end
    return n
end

return bit