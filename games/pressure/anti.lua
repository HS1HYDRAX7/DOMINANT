-- Anti removals: destroys monsters and objects matched by name as they appear.
local Players = game:GetService("Players")

local M = {}

local function nameSet(...)
    local set = {}
    for _, name in ipairs({ ... }) do
        set[name] = true
    end
    return set
end

local function byName(names)
    return function(object)
        if names[object.Name] then
            return object
        end
        return nil
    end
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- group: "monsters", "spawns" or "encounters" (decides the section it is shown in)
local LIST = {
    { key = "eyefestation", group = "monsters", match = byName(nameSet("EyefestHurt", "EyefestationCameraEffect")) },
    { key = "pandemonium", group = "monsters", match = function(data) return byName(data.Pandemonium) end },
    { key = "pipsqueak", group = "monsters", match = function(object)
        if string.find(object.Name, "Pipsqueak", 1, true) or string.find(object.Name, "Pipsqeuak", 1, true) then
            return object
        end
        return nil
    end },
    { key = "a200", group = "monsters", match = function(object)
        if string.find(object.Name, "A200", 1, true) or string.find(object.Name, "A-200", 1, true) then
            return object
        end
        return nil
    end },
    { key = "walldweller", group = "monsters", match = byName(nameSet("WallDweller", "MeatWallDweller", "RottenWallDweller", "DwellerModel")) },
    { key = "bouncer", group = "monsters", match = byName(nameSet("Bouncer", "Bouncers")) },
    { key = "skeletonhead", group = "monsters", match = byName(nameSet("SkeletonHead")) },
    { key = "statue", group = "monsters", match = byName(nameSet("StatueRoot", "StatueHead")) },
    { key = "nogood", group = "monsters", match = byName(nameSet("NoGood")) },
    { key = "skinless", group = "monsters", match = byName(nameSet("SkinlessCorpse")) },
    { key = "witchinghour", group = "monsters", match = function(object)
        if object.Name:lower() == "witchinghour" then
            return object
        end
        return nil
    end },
    { key = "divine", group = "monsters", match = byName(nameSet("DiVine", "DiVineRoot", "Divineroot")) },
    { key = "searchlights", group = "monsters", match = byName(nameSet("Searchlights")) },
    { key = "monsterlocker", group = "monsters", match = byName(nameSet("MonsterLocker")) },
    { key = "squiddles", group = "monsters", match = function(object)
        if object.Name == "SquiddleBuildup" and object.Parent and object.Parent.Name == "Face" and object.Parent.Parent then
            return object.Parent.Parent
        end
        if object.Name == "Squiddle" or object.Name == "SquiddleBase" then
            return object
        end
        return nil
    end },
    { key = "coagulate", group = "monsters", match = function(object)
        local current = object
        while current and current ~= workspace and current ~= game do
            local lower = current.Name:lower()
            if string.find(lower, "coagulate", 1, true) or string.find(lower, "coagulant", 1, true) then
                return current
            end
            current = current.Parent
        end
        return nil
    end },
    { key = "edentrees", group = "monsters", match = function(object)
        if object:IsA("Model") and not isPlayerCharacter(object) and string.match(object.Name, "^%l%l%l%l$") and object:FindFirstChild("RootPart") then
            return object
        end
        local parent = object.Parent
        if parent and parent:IsA("Model") and not isPlayerCharacter(parent) and string.match(parent.Name, "^%l%l%l%l$") and parent:FindFirstChild("RootPart") then
            return parent
        end
        return nil
    end },
    { key = "cement", group = "spawns", match = function(object)
        if string.find(object.Name:lower(), "cement", 1, true) then
            return object
        end
        return nil
    end },
    { key = "turrets", group = "spawns", match = function(object)
        if object.Name == "Turret" or string.match(object.Name, "^TurretSpawn") then
            return object
        end
        return nil
    end },
    { key = "tripwires", group = "spawns", match = byName(nameSet("Tripwire", "TripwireSpawn")) },
    { key = "landmines", group = "spawns", match = byName(nameSet("Landmine", "LandmineSpawn", "DrawerLandmine")) },
    { key = "damageparts", group = "encounters", match = function(object)
        local lower = object.Name:lower()
        if lower == "damagepart" or lower == "electricity" or lower == "damageparts" then
            return object
        end
        return nil
    end },
    { key = "firewall", group = "encounters", match = byName(nameSet("Firewall")) },
}

function M.Register(ctx, data)
    local connections = {}

    local function disconnect(key)
        local list = connections[key]
        if list then
            for _, connection in ipairs(list) do
                connection:Disconnect()
            end
        end
        connections[key] = nil
    end

    local function run(object, matcher)
        if not object.Parent then
            return
        end
        local ok, target = pcall(matcher, object)
        if ok and target and target.Parent then
            pcall(function()
                target:Destroy()
            end)
        end
    end

    local function enable(key, matcher)
        disconnect(key)
        local list = {}
        connections[key] = list
        for _, object in ipairs(workspace:GetDescendants()) do
            run(object, matcher)
        end
        table.insert(list, workspace.DescendantAdded:Connect(function(object)
            task.defer(run, object, matcher)
        end))
    end

    for _, entry in ipairs(LIST) do
        local key = "anti_" .. entry.key
        local matcher = entry.match
        -- matchers that need game data are built once data is available
        if type(matcher) == "function" and entry.key == "pandemonium" then
            matcher = matcher(data)
        end
        ctx.addSetting(key, false, function(value)
            if value then
                enable(key, matcher)
            else
                disconnect(key)
            end
        end)
    end

    ctx.onUnload(function()
        for key in pairs(connections) do
            disconnect(key)
        end
    end)
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    local sections = {
        monsters = "sec_anti_monsters",
        spawns = "sec_anti_spawns",
        encounters = "sec_anti_encounters",
    }
    local shown = {}
    for _, entry in ipairs(LIST) do
        if not shown[entry.group] then
            shown[entry.group] = true
            ui.section(tab, sections[entry.group], "Lucide:shield")
        end
        ui.labelToggle(tab, "anti_" .. entry.key, ctx.L("anti_" .. entry.key), nil, "Lucide:shield")
    end
end

return M
