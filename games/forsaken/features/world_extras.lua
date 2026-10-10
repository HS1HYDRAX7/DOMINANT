local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local M = {}

function M.Register(ctx)
    local G = ctx.modules:require("games/forsaken/game")
    local watching = false
    local lastAlert = 0

    local function killerDoors()
        local map = G.mapModel()
        return map and (map:FindFirstChild("KillerDoors", true) or map:FindFirstChild("Killer Doors", true))
    end

    local function killerOnly()
        local map = G.mapModel()
        return map and map:FindFirstChild("KillerOnly", true)
    end

    local function applyKillerWalls()
        local disabled = ctx.cfg.kill_walls
        local doors = killerDoors()
        if not doors then
            return
        end
        local only = killerOnly()
        for _, door in ipairs(doors:GetChildren()) do
            if door:IsA("BasePart") and math.min(door.Size.X, door.Size.Z) <= 5 then
                if door:GetAttribute("DominantCollide") == nil then
                    door:SetAttribute("DominantCollide", door.CanCollide)
                end
                door.CanTouch = true
                door.CanCollide = (not disabled) and door:GetAttribute("DominantCollide") == true
                door.Color = disabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                if only then
                    local params = OverlapParams.new()
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.FilterDescendantsInstances = { only }
                    params.BruteForceAllSlow = true
                    for _, part in ipairs(workspace:GetPartBoundsInRadius(door.Position, 25, params)) do
                        part.CanCollide = not disabled
                    end
                end
            end
        end
    end

    local function applyFolders()
        local ingame = G.ingame()
        if not ingame then
            return
        end
        local cfg = ctx.cfg
        for _, child in ipairs(ingame:GetChildren()) do
            if child:IsA("Folder") and child.Name:find("JohnDoeTrail") then
                for _, part in ipairs(child:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not cfg.no_trails
                    end
                end
            elseif child:IsA("Folder") and child.Name:find("Shadows") then
                for _, part in ipairs(child:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = not cfg.no_footprints
                    end
                end
            elseif child.Name == "SpikeCollision" and child:IsA("BasePart") then
                child.Size = cfg.small_spikes and Vector3.new(11, 3.5, 3.5) or Vector3.new(11, 5, 5)
                child.Shape = cfg.small_spikes and Enum.PartType.Cylinder or Enum.PartType.Block
            end
        end
    end

    local function watch()
        if watching then
            return
        end
        local ingame = G.ingame()
        if not ingame then
            return
        end
        watching = true
        ctx.bind("worldwatch", ingame.ChildAdded, function(child)
            task.wait()
            if child.Name == "Map" then
                task.delay(2, applyKillerWalls)
            elseif child:IsA("Folder") and (child.Name:find("JohnDoeTrail") or child.Name:find("Shadows")) then
                local trail = child.Name:find("JohnDoeTrail") ~= nil
                local function tune(part)
                    if part:IsA("BasePart") then
                        local hidden = trail and ctx.cfg.no_trails or ((not trail) and ctx.cfg.no_footprints)
                        part.CanTouch = not hidden
                    end
                end
                for _, part in ipairs(child:GetChildren()) do
                    tune(part)
                end
                child.ChildAdded:Connect(tune)
            elseif child.Name == "SpikeCollision" then
                task.delay(3.5, applyFolders)
            end
        end)
    end

    for _, key in ipairs({ "no_trails", "no_footprints", "small_spikes" }) do
        ctx.addSetting(key, false, function()
            watch()
            applyFolders()
        end)
    end
    ctx.addSetting("kill_walls", false, function()
        watch()
        applyKillerWalls()
    end)

    local function ringStep()
        local root = ctx.state.root
        if not root then
            return
        end
        local items = G.items()
        local limit = math.min(#items, 40)
        if limit == 0 then
            return
        end
        local cfg = ctx.cfg
        local base = os.clock() * cfg.ring_speed
        local index = 0
        for _, tool in ipairs(items) do
            if index >= limit then
                break
            end
            local handle = tool.Parent ~= ctx.state.character and G.toolPart(tool)
            if handle then
                index += 1
                local angle = base + (index / limit) * math.pi * 2
                handle.CanCollide = false
                handle.AssemblyLinearVelocity = Vector3.zero
                handle.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(angle) * cfg.ring_radius, 1.5, math.sin(angle) * cfg.ring_radius))
            end
        end
    end

    ctx.addSetting("item_ring", false, function(value)
        if value then
            ctx.bind("itemring", RunService.RenderStepped, ringStep)
        else
            ctx.unbind("itemring")
        end
    end)
    ctx.addSetting("ring_radius", 12)
    ctx.addSetting("ring_speed", 1.5)

    ctx.addSetting("click_tp", false, function(value)
        ctx.unbind("clicktp")
        if not value then
            return
        end
        ctx.bind("clicktp", UIS.InputBegan, function(input, processed)
            if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            if not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                return
            end
            local hit = LocalPlayer:GetMouse().Hit
            local root = ctx.state.root
            if hit and root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end)

    local function nearestKiller(maxDistance)
        local root = ctx.state.root
        local folder = G.killers()
        if not root or not folder then
            return nil
        end
        local best, bestDistance = nil, maxDistance or math.huge
        for _, killer in ipairs(folder:GetChildren()) do
            local part = killer:FindFirstChild("HumanoidRootPart")
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if distance < bestDistance then
                    best, bestDistance = killer, distance
                end
            end
        end
        if best then
            return best, bestDistance
        end
        return nil
    end

    ctx.addSetting("killer_alert", false, function(value)
        ctx.stopLoop("killeralert")
        if not value then
            return
        end
        ctx.startLoop("killeralert", 0.5, function()
            local character = ctx.state.character
            local survivors = G.survivors()
            local isSurvivor = character ~= nil and survivors ~= nil and character.Parent == survivors
            if not isSurvivor or os.clock() - lastAlert < 6 then
                return
            end
            local killer, distance = nearestKiller(ctx.cfg.alert_range)
            if killer then
                lastAlert = os.clock()
                ctx.notify(ctx.L("n_killer_near", math.floor(distance)), "warning", 3)
            end
        end)
    end)
    ctx.addSetting("alert_range", 60)

    ctx.addSetting("spectate_killer", false, function(value)
        local camera = workspace.CurrentCamera
        if not value then
            ctx.unbind("spectate")
            local humanoid = ctx.state.humanoid
            if camera and humanoid then
                camera.CameraSubject = humanoid
            end
            return
        end
        ctx.bind("spectate", RunService.RenderStepped, function()
            local current = workspace.CurrentCamera
            local killers = G.killers()
            local killer = killers and killers:GetChildren()[1]
            local humanoid = killer and killer:FindFirstChildOfClass("Humanoid")
            if current and humanoid then
                current.CameraSubject = humanoid
            end
        end)
    end)

    ctx.onUnload(function()
        ctx.stopLoop("killeralert")
    end)
end

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_map", "Lucide:map")
    ui.toggle(tab, "kill_walls", "Lucide:door-open")
    ui.toggle(tab, "no_trails", "Lucide:eraser")
    ui.toggle(tab, "no_footprints", "Lucide:footprints")
    ui.toggle(tab, "small_spikes", "Lucide:triangle")

    ui.section(tab, "sec_ring", "Lucide:circle-dashed")
    ui.toggle(tab, "item_ring", "Lucide:circle-dashed")
    ui.slider(tab, "ring_radius", 4, 40, 1, "Lucide:ruler", " studs")
    ui.slider(tab, "ring_speed", 0.1, 6, 0.1, "Lucide:gauge")

    ui.section(tab, "sec_players", "Lucide:users")
    ui.toggle(tab, "click_tp", "Lucide:mouse-pointer-click")
    ui.toggle(tab, "killer_alert", "Lucide:triangle-alert")
    ui.slider(tab, "alert_range", 10, 200, 5, "Lucide:radar", " studs")
    ui.toggle(tab, "spectate_killer", "Lucide:eye")
end

return M
