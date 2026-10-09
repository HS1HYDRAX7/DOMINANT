-- Forsaken helpers: folders, generators, items, structures, traps and support units.
-- Results are cached for 1.5 seconds.
local M = {}

local cache = {}

local function cached(name, build)
    local entry = cache[name]
    local now = os.clock()
    if entry and now - entry.at < 1.5 then
        return entry.value
    end
    local value = build()
    cache[name] = { at = now, value = value }
    return value
end

M.cached = cached

M.TrapWords = { "trap", "spike", "mine", "tripwire", "graffiti", "sentry", "dispenser", "bulb", "vine", "golem", "respawnlocation", "subspace" }

function M.killers()
    local folder = workspace:FindFirstChild("Players")
    return folder and folder:FindFirstChild("Killers") or nil
end

function M.survivors()
    local folder = workspace:FindFirstChild("Players")
    return folder and folder:FindFirstChild("Survivors") or nil
end

function M.ingame()
    local map = workspace:FindFirstChild("Map")
    return map and map:FindFirstChild("Ingame") or nil
end

function M.mapModel()
    local ingame = M.ingame()
    return ingame and ingame:FindFirstChild("Map") or nil
end

function M.generators()
    return cached("generators", function()
        local list = {}
        local map = M.mapModel()
        if map then
            for _, object in ipairs(map:GetDescendants()) do
                if (object.Name == "Generator" or object.Name == "FakeGenerator") and object:IsA("Model") then
                    table.insert(list, object)
                end
            end
        end
        return list
    end)
end

function M.progress(generator)
    local value = generator:FindFirstChild("Progress")
    if value and value:IsA("ValueBase") then
        return value.Value
    end
    local attribute = generator:GetAttribute("Progress")
    if type(attribute) == "number" then
        return attribute
    end
    return 0
end

-- world position of a model or part, or nil
function M.position(object)
    local ok, pivot = pcall(function()
        return object:GetPivot().Position
    end)
    if ok then
        return pivot
    end
    if object:IsA("BasePart") then
        return object.Position
    end
    return nil
end

function M.items()
    return cached("items", function()
        local list = {}
        local ingame = M.ingame()
        if ingame then
            for _, object in ipairs(ingame:GetDescendants()) do
                if object:IsA("Tool") and object:FindFirstChildWhichIsA("BasePart") then
                    table.insert(list, object)
                end
            end
        end
        return list
    end)
end

-- Returns { object = ..., kind = "pallet" | "window" | "chest" }
function M.structures()
    return cached("structures", function()
        local list = {}
        local map = M.mapModel()
        if map then
            for _, object in ipairs(map:GetDescendants()) do
                if object:IsA("Model") or object:IsA("BasePart") then
                    local lowered = object.Name:lower()
                    local kind = nil
                    if lowered:find("pallet", 1, true) then
                        kind = "pallet"
                    elseif lowered:find("window", 1, true) then
                        kind = "window"
                    elseif lowered:find("chest", 1, true) or lowered:find("supply", 1, true) then
                        kind = "chest"
                    end
                    if kind then
                        table.insert(list, { object = object, kind = kind })
                    end
                end
            end
        end
        return list
    end)
end

function M.isTrap(object)
    local name = object.Name:lower()
    for _, word in ipairs(M.TrapWords) do
        if name:find(word, 1, true) then
            return true
        end
    end
    return object:FindFirstChild("Wire") ~= nil
end

function M.supports()
    return cached("supports", function()
        local list = {}
        local ingame = M.ingame()
        if not ingame then
            return list
        end
        for _, object in ipairs(ingame:GetChildren()) do
            if object:IsA("Model") and not game:GetService("Players"):GetPlayerFromCharacter(object) then
                local humanoid = object:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.WalkSpeed ~= 16 and humanoid.WalkSpeed ~= 26 and object:FindFirstChild("HumanoidRootPart") then
                    table.insert(list, object)
                end
            end
        end
        return list
    end)
end

function M.traps()
    return cached("traps", function()
        local list = {}
        local ingame = M.ingame()
        local map = M.mapModel()
        if ingame then
            for _, object in ipairs(ingame:GetChildren()) do
                if object ~= map and (object:IsA("Model") or object:IsA("BasePart")) and M.isTrap(object) then
                    table.insert(list, object)
                end
            end
        end
        if map then
            for _, object in ipairs(map:GetDescendants()) do
                if (object:IsA("Model") or object:IsA("BasePart")) and object.Name ~= "Generator" and object.Name ~= "FakeGenerator" then
                    local lowered = object.Name:lower()
                    if lowered:find("graffiti", 1, true) or lowered:find("respawnlocation", 1, true) then
                        table.insert(list, object)
                    end
                end
            end
        end
        return list
    end)
end

return M
