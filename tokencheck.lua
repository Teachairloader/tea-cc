-- tokencheck.lua - proves a minified file carries the same token stream as its
-- source. Comments and whitespace are dropped; every other token must match
-- byte for byte, in order.
--
--   lua tokencheck.lua original.lua minified.lua

local function long_bracket_level(src, i)
    local j = i + 1
    local level = 0
    while src:sub(j, j) == "=" do
        level = level + 1
        j = j + 1
    end
    if src:sub(j, j) ~= "[" then return nil end
    return level, j + 1
end

local function read_short(src, i)
    local quote = src:sub(i, i)
    local j = i + 1
    while j <= #src do
        local c = src:sub(j, j)
        if c == "\\" then j = j + 2
        elseif c == quote then return src:sub(i, j), j + 1
        else j = j + 1 end
    end
    return src:sub(i), #src + 1
end

local function tokens(path)
    local src = assert(io.open(path, "rb")):read("a")
    local out = {}
    local i, n = 1, #src
    while i <= n do
        local c = src:sub(i, i)
        if c == "-" and src:sub(i + 1, i + 1) == "-" then
            local level, body = long_bracket_level(src, i + 2)
            if level then
                local close = "]" .. string.rep("=", level) .. "]"
                local e = src:find(close, body, true)
                i = e and (e + #close) or (n + 1)
            else
                i = src:find("\n", i, true) or (n + 1)
            end
        elseif c == " " or c == "\t" or c == "\r" or c == "\n" then
            i = i + 1
        elseif c == "[" and long_bracket_level(src, i) then
            local level, body = long_bracket_level(src, i)
            local close = "]" .. string.rep("=", level) .. "]"
            local e = src:find(close, body, true)
            local stop = e and (e + #close - 1) or n
            out[#out + 1] = "str:" .. src:sub(i, stop)
            i = stop + 1
        elseif c == '"' or c == "'" then
            local s, nexti = read_short(src, i)
            out[#out + 1] = "str:" .. s
            i = nexti
        elseif c:match("[%a_]") then
            local word = src:match("^[%a_][%w_]*", i)
            out[#out + 1] = "id:" .. word
            i = i + #word
        elseif c:match("%d") then
            local num = src:match("^0[xX][%x%.pP%+%-]+", i) or src:match("^[%d%.eE%+%-]+", i)
            out[#out + 1] = "num:" .. num
            i = i + #num
        else
            local op = src:match("^%.%.%.?", i) or src:match("^[=~<>]=?", i)
                or src:match("^//=?") or src:match("^<<=?") or src:match("^>>=?")
                or src:match("^::") or c
            out[#out + 1] = "op:" .. op
            i = i + #op
        end
    end
    return out
end

local a, b = tokens(arg[1]), tokens(arg[2])
local limit = math.min(#a, #b)
for k = 1, limit do
    if a[k] ~= b[k] then
        print(string.format("MISMATCH at token %d\n  original: %s\n  minified: %s", k, a[k], b[k]))
        os.exit(1)
    end
end
if #a ~= #b then
    print(string.format("TOKEN COUNT DIFFERS original=%d minified=%d", #a, #b))
    os.exit(1)
end
print(string.format("TOKEN STREAM IDENTICAL (%d tokens)", #a))
