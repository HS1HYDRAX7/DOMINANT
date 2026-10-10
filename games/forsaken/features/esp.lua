local Players = game:GetService("Players")

local M = {}

local ENABLE = {
    killer = "esp_killers", survivor = "esp_survivors", generator = "esp_generators", fake = "esp_fake",
    item = "esp_items", trap = "esp_traps", pallet = "esp_pallets", window = "esp_windows",
    chest = "esp_chests", support = "esp_support",
}

function M.Register(ctx)
    local G = ctx.modules:require("games/forsaken/game")
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
    for _, key in ipairs({ "esp_killers", "esp_survivors", "esp_generators", "esp_items", "esp_pallets",
        "esp_windows", "esp_chests", "esp_support", "esp_text", "esp_distance" }) do
        ctx.addSetting(key, true)
    end
    for _, key in ipairs({ "esp_traps", "esp_fake", "esp_health", "esp_hide_done" }) do
        ctx.addSetting(key, false)
    end
    ctx.addSetting("esp_max_distance", 2500)
    ctx.addSetting("esp_text_size", 14)
    ctx.addSetting("esp_fill", 0.6)
    ctx.addSetting("color_killer", Color3.fromRGB(255, 50, 50))
    ctx.addSetting("color_survivor", Color3.fromRGB(60, 255, 120))
    ctx.addSetting("color_generator", Color3.fromRGB(255, 230, 60))
    ctx.addSetting("color_item", Color3.fromRGB(70, 170, 255))
    ctx.addSetting("color_trap", Color3.fromRGB(255, 120, 40))
    ctx.addSetting("color_fake", Color3.fromRGB(255, 165, 0))
    ctx.addSetting("color_support", Color3.fromRGB(180, 0, 0))
    ctx.addSetting("color_pallet", Color3.fromRGB(200, 150, 255))
    ctx.addSetting("color_window", Color3.fromRGB(150, 220, 255))
    ctx.addSetting("color_chest", Color3.fromRGB(255, 180, 0))

    local function adorneePart(target)
        if target:IsA("BasePart") then
            return target
        end
        if target:IsA("Model") then
            return target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function create(target, color)
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
        billboard.Size = UDim2.fromOffset(200, 32)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = part

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = ctx.cfg.esp_text_size
        text.TextStrokeTransparency = 0.4
        text.TextColor3 = color
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
        local list = {}
        local character = ctx.state.character
        local function addModels(folder, kind)
            if folder then
                for _, model in ipairs(folder:GetChildren()) do
                    if model ~= character then
                        table.insert(list, { target = model, kind = kind })
                    end
                end
            end
        end
        addModels(G.killers(), "killer")
        addModels(G.survivors(), "survivor")

        for _, generator in ipairs(G.generators()) do
            if generator.Parent then
                local done = G.progress(generator) >= 100
                if not (ctx.cfg.esp_hide_done and done) then
                    table.insert(list, { target = generator, kind = generator.Name == "FakeGenerator" and "fake" or "generator" })
                end
            end
        end
        for _, tool in ipairs(G.items()) do
            if tool.Parent then
                table.insert(list, { target = tool, kind = "item" })
            end
        end
        for _, trap in ipairs(G.traps()) do
            if trap.Parent then
                table.insert(list, { target = trap, kind = "trap" })
            end
        end
        for _, entry in ipairs(G.structures()) do
            if entry.object.Parent then
                table.insert(list, { target = entry.object, kind = entry.kind })
            end
        end
        for _, unit in ipairs(G.supports()) do
            if unit.Parent then
                table.insert(list, { target = unit, kind = "support" })
            end
        end
        return list
    end

    local function label(item, distance)
        local cfg = ctx.cfg
        local target = item.target
        local parts = {}
        if item.kind == "killer" or item.kind == "survivor" then
            local player = Players:GetPlayerFromCharacter(target)
            table.insert(parts, player and player.DisplayName or target.Name)
            if cfg.esp_health then
                local humanoid = target:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    table.insert(parts, string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
                end
            end
        elseif item.kind == "generator" then
            table.insert(parts, ctx.L("esp_generator_label", math.floor(G.progress(target))))
        elseif item.kind == "fake" then
            table.insert(parts, ctx.L("esp_fake_label"))
        else
            table.insert(parts, target.Name)
        end
        if cfg.esp_distance then
            table.insert(parts, string.format("[%dm]", math.floor(distance)))
        end
        return table.concat(parts, " ")
    end

    step = function()
        local cfg = ctx.cfg
        local root = ctx.state.root
        if not cfg.esp or not root then
            return
        end
        local seen = {}
        for _, item in ipairs(collect()) do
            local enabled = cfg[ENABLE[item.kind]]
            local part = adorneePart(item.target)
            if enabled and part then
                local distance = (part.Position - root.Position).Magnitude
                if distance <= cfg.esp_max_distance then
                    local color = cfg["color_" .. item.kind]
                    local entry = objects[item.target] or create(item.target, color)
                    if entry then
                        seen[item.target] = true
                        entry.highlight.FillColor = color
                        entry.highlight.FillTransparency = 1 - cfg.esp_fill
                        entry.label.TextColor3 = color
                        entry.label.Text = label(item, distance)
                        entry.billboard.Enabled = cfg.esp_text
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

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_esp", "Lucide:eye")
    ui.toggle(tab, "esp", "Lucide:eye")
    ui.toggle(tab, "esp_killers", "Lucide:skull")
    ui.toggle(tab, "esp_survivors", "Lucide:users")
    ui.toggle(tab, "esp_generators", "Lucide:cog")
    ui.toggle(tab, "esp_items", "Lucide:package")
    ui.toggle(tab, "esp_pallets", "Lucide:layers")
    ui.toggle(tab, "esp_windows", "Lucide:app-window")
    ui.toggle(tab, "esp_chests", "Lucide:box")
    ui.toggle(tab, "esp_traps", "Lucide:triangle-alert")
    ui.toggle(tab, "esp_support", "Lucide:user-round")
    ui.toggle(tab, "esp_fake", "Lucide:cog")
    ui.toggle(tab, "esp_text", "Lucide:type")
    ui.toggle(tab, "esp_distance", "Lucide:ruler")
    ui.toggle(tab, "esp_health", "Lucide:heart")
    ui.toggle(tab, "esp_hide_done", "Lucide:check")
    ui.slider(tab, "esp_max_distance", 100, 5000, 50, "Lucide:radar", " studs")
    ui.slider(tab, "esp_text_size", 8, 30, 1, "Lucide:type")
    ui.slider(tab, "esp_fill", 0, 1, 0.05, "Lucide:droplet")
    ui.section(tab, "sec_colors", "Lucide:palette")
    for _, key in ipairs({ "color_killer", "color_survivor", "color_generator", "color_item", "color_trap",
        "color_fake", "color_support", "color_pallet", "color_window", "color_chest" }) do
        ui.color(tab, key, "Lucide:palette")
    end
end

return M
