-- Automation: loot aura, instant prompts, open sesame, door tool and entity alerts.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.Register(ctx, data)
    local scan = ctx.modules:require("games/pressure/scan")
    local originalHold = {}
    local originalCollide = {}
    local lastAlert = {}

    local function adorneePart(target)
        if target:IsA("BasePart") then
            return target
        end
        if target:IsA("Model") then
            return target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    -- loot aura collects currency and keycards in range, like the original Pressure script
    local function lootStep()
        local root = ctx.state.root
        if not root then
            return
        end
        local radius = math.clamp(tonumber(ctx.cfg.loot_radius) or 5, 1, 30)
        for _, entry in ipairs(scan.items(data)) do
            local object = entry.object
            if entry.kind ~= "item" and object.Parent then
                local part = adorneePart(object)
                if part and (part.Position - root.Position).Magnitude <= radius then
                    local prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        pcall(function()
                            if ctx.caps.fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                local hold = prompt.HoldDuration
                                prompt.HoldDuration = 0
                                prompt:InputHoldBegin()
                                task.wait()
                                prompt:InputHoldEnd()
                                prompt.HoldDuration = hold
                            end
                        end)
                    end
                end
            end
        end
    end

    local function instantPrompt(prompt)
        if ctx.cfg.instant_prompts and originalHold[prompt] == nil and prompt.HoldDuration > 0 then
            originalHold[prompt] = prompt.HoldDuration
            prompt.HoldDuration = 0
        end
    end

    local function phaseDoor(part)
        if not part:IsA("BasePart") or not data.PhaseDoorNames[part.Name] then
            return
        end
        if originalCollide[part] == nil then
            originalCollide[part] = part.CanCollide
        end
        part.CanCollide = false
    end

    ctx.addSetting("loot_aura", false, function(value)
        if value then
            ctx.startLoop("loot", 0.15, lootStep)
        else
            ctx.stopLoop("loot")
        end
    end)
    ctx.addSetting("loot_radius", 5)
    ctx.addSetting("instant_prompts", false, function(value)
        ctx.unbind("prompts")
        if value then
            ctx.bind("prompts", ProximityPromptService.PromptShown, instantPrompt)
        else
            for prompt, hold in pairs(originalHold) do
                if prompt.Parent then
                    prompt.HoldDuration = hold
                end
            end
            originalHold = {}
        end
    end)
    ctx.addSetting("open_sesame", false, function(value)
        ctx.unbind("phasedoors")
        if value then
            local rooms = scan.rooms()
            if not rooms then
                ctx.notify(ctx.L("n_rooms_missing"), "warning", 3)
                return
            end
            for _, object in ipairs(rooms:GetDescendants()) do
                phaseDoor(object)
            end
            ctx.bind("phasedoors", rooms.DescendantAdded, function(object)
                task.defer(phaseDoor, object)
            end)
            ctx.notify(ctx.L("n_open_sesame"), "info", 4)
        else
            for part, original in pairs(originalCollide) do
                if part.Parent then
                    part.CanCollide = original
                end
            end
            originalCollide = {}
        end
    end)
    ctx.addSetting("entity_alert", false, function(value)
        ctx.unbind("entityalert")
        if value then
            ctx.bind("entityalert", workspace.ChildAdded, function(child)
                if data.Monsters[child.Name] then
                    local now = os.clock()
                    if not lastAlert[child.Name] or now - lastAlert[child.Name] > 8 then
                        lastAlert[child.Name] = now
                        ctx.notify(ctx.L("n_spawned", child.Name), "warning", 5)
                    end
                end
            end)
        end
    end)

    ctx.onUnload(function()
        for prompt, hold in pairs(originalHold) do
            if prompt.Parent then
                prompt.HoldDuration = hold
            end
        end
        for part, original in pairs(originalCollide) do
            if part.Parent then
                part.CanCollide = original
            end
        end
    end)

    -- Door tool: hides and disables doors within 10 studs of the player.
    M.doorYeet = function()
        local root = ctx.state.root
        local rooms = scan.rooms()
        if not root or not rooms then
            return
        end
        local done = {}
        for _, prompt in ipairs(rooms:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local door = prompt:FindFirstAncestorOfClass("Model")
                if door and not done[door] and string.find(door.Name:lower(), "door", 1, true) then
                    local parts = door:GetDescendants()
                    local near = false
                    for _, descendant in ipairs(parts) do
                        if descendant:IsA("BasePart") and (root.Position - descendant.Position).Magnitude <= 10 then
                            near = true
                            break
                        end
                    end
                    if near then
                        done[door] = true
                        for _, descendant in ipairs(parts) do
                            if descendant:IsA("BasePart") then
                                descendant.LocalTransparencyModifier = 1
                                descendant.CanCollide = false
                            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                                descendant.Transparency = 1
                            elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
                                descendant.Enabled = false
                            end
                        end
                    end
                end
            end
        end
    end
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    ui.section(tab, "sec_collect", "Lucide:hand")
    ui.toggle(tab, "loot_aura", "Lucide:package")
    ui.slider(tab, "loot_radius", 1, 30, 1, "Lucide:ruler", " studs")
    ui.toggle(tab, "instant_prompts", "Lucide:zap")

    ui.section(tab, "sec_doors", "Lucide:door-open")
    ui.toggle(tab, "open_sesame", "Lucide:door-open")
    ui.button(tab, "btn_door_yeet", "Lucide:door-closed", function()
        M.doorYeet()
    end)

    ui.section(tab, "sec_alerts", "Lucide:bell")
    ui.toggle(tab, "entity_alert", "Lucide:triangle-alert")
end

return M
