-- ESP for monsters, players, items, currency, keycards, exit doors, lockers, fake doors and generators.
local Players = game:GetService("Players")

local M = {}

function M.Register(ctx, data)
    local scan = ctx.modules:require("games/pressure/scan")
    local objects = {}
    local step, clear

    ctx.addSetting("esp", false, function(value)
        if value then
            ctx.startLoop("esp", 0.15, step)
        else
            ctx.stopLoop("esp")
            clear()
        end
    end)
    for _, key in ipairs({ "esp_monsters", "esp_players", "esp_items", "esp_currency", "esp_keycards", "esp_text", "esp_distance" }) do
        ctx.addSetting(key, true)
    end
    for _, key in ipairs({ "esp_doors", "esp_lockers", "esp_fake_doors", "esp_generators" }) do
        ctx.addSetting(key, false)
    end
    ctx.addSetting("esp_max_distance", 1000)
    ctx.addSetting("esp_fill", 0.6)
    ctx.addSetting("color_monster", Color3.fromRGB(200, 0, 0))
    ctx.addSetting("color_player", Color3.fromRGB(60, 255, 120))

    local function adorneePart(target)
        if target:IsA("BasePart") then
            return target
        end
        if target:IsA("Model") then
            return target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function create(target, label, color)
        local part = adorneePart(target)
        if not part then
            return nil
        end
        local highlight = Instance.new("Highlight")
        highlight.Name = "DominantHighlight"
        highlight.Adornee = target
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.OutlineColor = color
        highlight.Parent = target

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DominantLabel"
        billboard.Adornee = part
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(180, 32)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = part

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 13
        text.TextStrokeTransparency = 0.4
        text.TextColor3 = color
        text.Text = label
        text.Parent = billboard

        local entry = { highlight = highlight, billboard = billboard, label = text }
        objects[target] = entry
        return entry
    end

    local function destroy(target)
        local entry = objects[target]
        if not entry then
            return
        end
        pcall(function()
            entry.highlight:Destroy()
        end)
        pcall(function()
            entry.billboard:Destroy()
        end)
        objects[target] = nil
    end

    clear = function()
        for target in pairs(objects) do
            destroy(target)
        end
    end

    local function collect()
        local cfg = ctx.cfg
        local list = {}

        if cfg.esp_monsters then
            for _, child in ipairs(workspace:GetChildren()) do
                if data.Monsters[child.Name] and (child:IsA("Model") or child:IsA("BasePart")) then
                    table.insert(list, { target = child, label = child.Name, color = cfg.color_monster })
                end
            end
        end

        if cfg.esp_players then
            for _, player in ipairs(Players:GetPlayers()) do
                local character = player.Character
                if player ~= Players.LocalPlayer and character then
                    table.insert(list, { target = character, label = player.DisplayName, color = cfg.color_player })
                end
            end
        end

        for _, entry in ipairs(scan.items(data)) do
            local wanted = (entry.kind == "item" and cfg.esp_items)
                or (entry.kind == "currency" and cfg.esp_currency)
                or (entry.kind == "keycard" and cfg.esp_keycards)
            if wanted then
                table.insert(list, { target = entry.object, label = entry.label, color = entry.color })
            end
        end

        for _, entry in ipairs(scan.roomObjects(data)) do
            local object = entry.object
            if object.Parent then
                if entry.kind == "door" and cfg.esp_doors then
                    table.insert(list, { target = object, label = ctx.L("esp_exit_door"), color = data.Colors.ExitDoor })
                elseif entry.kind == "locker" and cfg.esp_lockers then
                    table.insert(list, { target = object, label = ctx.L("esp_locker"), color = data.Colors.Locker })
                elseif entry.kind == "fakedoor" and cfg.esp_fake_doors then
                    table.insert(list, { target = object, label = ctx.L("esp_fake_door"), color = data.Colors.FakeDoor })
                elseif entry.kind == "generator" and cfg.esp_generators then
                    local fixed = object:FindFirstChild("Fixed")
                    local value = fixed and fixed.Value
                    local pct = 0
                    if type(value) == "boolean" then
                        pct = value and 100 or 0
                    elseif type(value) == "number" then
                        pct = value
                    end
                    if pct < 100 then
                        local r = math.floor(255 * (1 - pct / 100))
                        local g = math.floor(255 * (pct / 100))
                        local target = object:FindFirstChild("ProxyPart") or object
                        table.insert(list, {
                            target = target,
                            label = ctx.L("esp_generator", tostring(math.floor(pct))),
                            color = Color3.fromRGB(r, g, 0),
                        })
                    end
                end
            end
        end

        return list
    end

    step = function()
        local cfg = ctx.cfg
        local root = ctx.state.root
        if not cfg.esp or not root then
            return
        end
        local seen = {}
        for _, item in ipairs(collect()) do
            local part = adorneePart(item.target)
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if distance <= cfg.esp_max_distance then
                    local entry = objects[item.target] or create(item.target, item.label, item.color)
                    if entry then
                        seen[item.target] = true
                        entry.highlight.FillColor = item.color
                        entry.highlight.FillTransparency = 1 - cfg.esp_fill
                        entry.label.TextColor3 = item.color
                        entry.billboard.Enabled = cfg.esp_text
                        local text = item.label
                        if cfg.esp_distance then
                            text = text .. " [" .. tostring(math.floor(distance)) .. "m]"
                        end
                        entry.label.Text = text
                    end
                end
            end
        end
        for target in pairs(objects) do
            if not seen[target] or not target.Parent then
                destroy(target)
            end
        end
    end

    ctx.onUnload(clear)
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    ui.section(tab, "sec_esp", "Lucide:eye")
    ui.toggle(tab, "esp", "Lucide:eye")
    ui.toggle(tab, "esp_monsters", "Lucide:skull")
    ui.toggle(tab, "esp_players", "Lucide:users")
    ui.toggle(tab, "esp_items", "Lucide:package")
    ui.toggle(tab, "esp_currency", "Lucide:coins")
    ui.toggle(tab, "esp_keycards", "Lucide:key-round")
    ui.toggle(tab, "esp_doors", "Lucide:door-open")
    ui.toggle(tab, "esp_lockers", "Lucide:lock")
    ui.toggle(tab, "esp_fake_doors", "Lucide:door-closed")
    ui.toggle(tab, "esp_generators", "Lucide:cog")
    ui.toggle(tab, "esp_text", "Lucide:type")
    ui.toggle(tab, "esp_distance", "Lucide:ruler")
    ui.slider(tab, "esp_max_distance", 100, 5000, 50, "Lucide:radar", " studs")
    ui.slider(tab, "esp_fill", 0, 1, 0.05, "Lucide:droplet")
    ui.section(tab, "sec_esp_colors", "Lucide:palette")
    ui.color(tab, "color_monster", "Lucide:skull")
    ui.color(tab, "color_player", "Lucide:users")
end

return M
