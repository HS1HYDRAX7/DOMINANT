local M = {}

local cache = { items = {}, itemsAt = 0, rooms = {}, roomsAt = 0 }

local function matchList(list, name)
    for _, entry in ipairs(list) do
        if string.match(name, entry[1]) then
            return entry[2], entry[3]
        end
    end
    return nil
end

local function gameplay()
    return workspace:FindFirstChild("GameplayFolder")
end

function M.rooms()
    local folder = gameplay()
    return folder and folder:FindFirstChild("Rooms") or nil
end

local function containers()
    local list = {}
    local rooms = M.rooms()
    if rooms then
        table.insert(list, rooms)
    end
    local folder = gameplay()
    local dropped = folder and folder:FindFirstChild("DroppedItems")
    if dropped then
        table.insert(list, dropped)
    end
    local droppedWorkspace = workspace:FindFirstChild("DroppedItems")
    if droppedWorkspace then
        table.insert(list, droppedWorkspace)
    end
    return list
end

function M.classify(data, name)
    local card = data.KeyCards[name]
    if card then
        return "keycard", card.label, card.color
    end
    local label, color = matchList(data.CurrencyPatterns, name)
    if label then
        return "currency", label, color
    end
    label, color = matchList(data.ItemPatterns, name)
    if label then
        return "item", label, color
    end
    return nil
end

function M.items(data)
    local now = os.clock()
    if now - cache.itemsAt < 2 then
        return cache.items
    end
    cache.itemsAt = now
    local list = {}
    for _, container in ipairs(containers()) do
        for _, object in ipairs(container:GetDescendants()) do
            if object:IsA("Model") or object:IsA("BasePart") then
                local parent = object.Parent

                local duplicate = object:IsA("BasePart") and parent ~= nil and parent:IsA("Model") and M.classify(data, parent.Name) ~= nil
                if not duplicate then
                    local kind, label, color = M.classify(data, object.Name)
                    if kind then
                        table.insert(list, { object = object, kind = kind, label = label, color = color })
                    end
                end
            end
        end
    end
    cache.items = list
    return list
end

function M.roomObjects(data)
    local now = os.clock()
    if now - cache.roomsAt < 2 then
        return cache.rooms
    end
    cache.roomsAt = now
    local list = {}
    local rooms = M.rooms()
    if rooms then
        for _, object in ipairs(rooms:GetDescendants()) do
            local name = object.Name
            if data.DoorNames[name] and object:IsA("BasePart") then
                table.insert(list, { object = object, kind = "door" })
            elseif name == "MonsterLocker" then
                table.insert(list, { object = object, kind = "locker" })
            elseif name == "Door" and object:IsA("BasePart") and object.Parent and object.Parent.Name == "TricksterDoor" then
                table.insert(list, { object = object, kind = "fakedoor" })
            elseif (name == "PresetGenerator" or name == "Generator") and object:IsA("Model") then
                table.insert(list, { object = object, kind = "generator" })
            end
        end
    end
    cache.rooms = list
    return list
end

return M
