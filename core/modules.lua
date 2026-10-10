local Modules = {}
Modules.__index = Modules

function Modules.new(baseUrl)
    return setmetatable({ base = baseUrl, cache = {} }, Modules)
end

function Modules:fetch(path)
    local url = self.base .. path .. ".lua"
    local ok, body = pcall(game.HttpGet, game, url)
    if not ok or type(body) ~= "string" or #body < 10 then
        error("could not download " .. url)
    end
    local chunk, compileError = loadstring(body)
    if not chunk then
        error("could not compile " .. path .. ": " .. tostring(compileError))
    end
    return chunk
end

function Modules:require(path)
    local cached = self.cache[path]
    if cached ~= nil then
        return cached
    end
    local result = self:fetch(path)()
    if result == nil then
        error("module " .. path .. " returned nothing")
    end
    self.cache[path] = result
    return result
end

return Modules
