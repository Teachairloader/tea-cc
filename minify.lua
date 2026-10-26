-- minify.lua - Lua-aware source shrinker.
-- Strips comments and collapses whitespace runs, but leaves every byte inside
-- short strings and long brackets untouched - so embedded UI text, ASCII art and
-- Lua source held in strings survive exactly as written.
--
--   lua minify.lua <in.lua> <out.lua>
--
-- Output stays syntactically identical: a whitespace run containing a newline
-- becomes one "\n", any other run becomes one space.

local function long_bracket_level(src, i)
    -- src:sub(i,i) == "[", returns level and index one past the opening bracket
    local j = i + 1
    local level = 0
    while src:sub(j, j) == "=" do
        level = level + 1
        j = j + 1
    end
    if src:sub(j, j) ~= "[" then return nil end
    return level, j + 1
end

local function read_long(src, i, level)
    local _, body = long_bracket_level(src, i)
    local close = "]" .. string.rep("=", level) .. "]"
    local endpos = src:find(close, body, true)
    if not endpos then
        return src:sub(i)
    end
    return src:sub(i, endpos + #close - 1)
end

local function read_short(src, i)
    local quote = src:sub(i, i)
    local j = i + 1
    while j <= #src do
        local c = src:sub(j, j)
        if c == "\\" then
            j = j + 2
        elseif c == quote then
            return src:sub(i, j), j + 1
        else
            j = j + 1
        end
    end
    return src:sub(i), #src + 1
end

local src = assert(io.open(arg[1], "rb")):read("a")
local out = {}
local i = 1
local n = #src

while i <= n do
    local c = src:sub(i, i)

    -- comment
    if c == "-" and src:sub(i + 1, i + 1) == "-" then
        local level = long_bracket_level(src, i + 2)
        if level then
            read_long(src, i + 2, level)
            local _, body = long_bracket_level(src, i + 2)
            local close = "]" .. string.rep("=", level) .. "]"
            local endpos = src:find(close, body, true)
            i = endpos and (endpos + #close) or (n + 1)
        else
            local nl = src:find("\n", i, true)
            i = nl or (n + 1)
        end

    -- long bracket string
    elseif c == "[" then
        local level, body = long_bracket_level(src, i)
        if level then
            local close = "]" .. string.rep("=", level) .. "]"
            local endpos = src:find(close, body, true)
            if endpos then
                out[#out + 1] = src:sub(i, endpos + #close - 1)
                i = endpos + #close
            else
                out[#out + 1] = src:sub(i)
                i = n + 1
            end
        else
            out[#out + 1] = c
            i = i + 1
        end

    -- short string
    elseif c == '"' or c == "'" then
        local s, nexti = read_short(src, i)
        out[#out + 1] = s
        i = nexti

    -- whitespace run
    elseif c == " " or c == "\t" or c == "\r" or c == "\n" then
        local j = i
        local newline = false
        while j <= n do
            local d = src:sub(j, j)
            if d == "\n" then
                newline = true
                j = j + 1
            elseif d == " " or d == "\t" or d == "\r" then
                j = j + 1
            else
                break
            end
        end
        -- drop whitespace that only pads the start/end of the file
        if #out > 0 and j <= n then
            out[#out + 1] = newline and "\n" or " "
        end
        -- collapse consecutive newlines emitted by comment removal
        if newline and #out > 1 and out[#out - 1] == "\n" then
            out[#out] = ""
        end
        i = j

    else
        out[#out + 1] = c
        i = i + 1
    end
end

local result = table.concat(out)
-- squeeze repeated newlines that survived comment stripping
result = result:gsub("\n\n+", "\n")
if result:sub(-1) ~= "\n" then result = result .. "\n" end

local f = assert(io.open(arg[2], "wb"))
f:write(result)
f:close()

io.stderr:write(string.format("%s: %d -> %d bytes (%.1f%%)\n", arg[1], n, #result, #result / n * 100))
