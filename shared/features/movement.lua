-- Movement: CFrame speed, jump power, infinite jump, noclip, fly, speed boost, ghost players, teleports and anchor.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local M = {}

function M.Register(ctx, data)
    local fly = { velocity = nil, gyro = nil }
    local noclipChanged = {}
    local anchor = nil

    local function cframeStep(dt)
        local root, humanoid = ctx.state.root, ctx.state.humanoid
        if not root or not humanoid or ctx.cfg.fly then
            return
        end
        local move = humanoid.MoveDirection
        if move.Magnitude > 0 then
            local speed = math.max(1, tonumber(ctx.cfg.cframe_speed_value) or 16)
            root.CFrame = root.CFrame + move.Unit * (speed * dt)
        end
    end

    local function applyJump()
        local humanoid = ctx.state.humanoid
        if humanoid and ctx.cfg.jumppower_on then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = ctx.cfg.jumppower
        end
    end

    local function stopFly()
        ctx.unbind("fly")
        if fly.velocity then
            fly.velocity:Destroy()
            fly.velocity = nil
        end
        if fly.gyro then
            fly.gyro:Destroy()
            fly.gyro = nil
        end
        local humanoid = ctx.state.humanoid
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function startFly()
        stopFly()
        local root, humanoid = ctx.state.root, ctx.state.humanoid
        if not root or not humanoid then
            return
        end
        local velocity = Instance.new("BodyVelocity")
        velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        velocity.Velocity = Vector3.zero
        velocity.Parent = root

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.P = 9e4
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        fly.velocity = velocity
        fly.gyro = gyro
        humanoid.PlatformStand = true

        ctx.bind("fly", RunService.RenderStepped, function()
            local camera = workspace.CurrentCamera
            if not camera or not velocity.Parent then
                return
            end
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += look
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= look
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.yAxis
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction -= Vector3.yAxis
            end
            local move = humanoid.MoveDirection
            if direction.Magnitude == 0 and move.Magnitude > 0 then
                direction = move
            end
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            velocity.Velocity = direction * ctx.cfg.fly_speed
            gyro.CFrame = camera.CFrame
        end)
    end

    local function noclipStep()
        local character = ctx.state.character
        if not character then
            return
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if noclipChanged[part] == nil then
                    noclipChanged[part] = true
                end
                part.CanCollide = false
            end
        end
    end

    local function restoreNoclip()
        for part, original in pairs(noclipChanged) do
            if part.Parent then
                part.CanCollide = original
            end
        end
        noclipChanged = {}
    end

    local function ghostStep()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if player ~= LocalPlayer and character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end

    local function speedBoost(dt)
        local root, humanoid = ctx.state.root, ctx.state.humanoid
        if not root or not humanoid then
            return
        end
        local boost = tonumber(ctx.cfg.speed_boost) or 0
        local move = humanoid.MoveDirection
        if boost > 0 and move.Magnitude > 0 then
            root.CFrame = root.CFrame + move * (boost * 60 * dt / 10)
        end
    end

    local function nearestRoot(farthest)
        local root = ctx.state.root
        if not root then
            return nil
        end
        local best, bestDistance = nil, farthest and -math.huge or math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local part = player ~= LocalPlayer and character and character:FindFirstChild("HumanoidRootPart")
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if (farthest and distance > bestDistance) or (not farthest and distance < bestDistance) then
                    best, bestDistance = part, distance
                end
            end
        end
        return best
    end

    local function teleport(farthest)
        local target = nearestRoot(farthest)
        local root = ctx.state.root
        if not target or not root then
            ctx.notify(ctx.L("n_no_player"), "warning", 3)
            return
        end
        root.CFrame = target.CFrame
    end

    ctx.addSetting("cframe_speed", false, function(value)
        if value then
            ctx.bind("cframe", RunService.Heartbeat, cframeStep)
        else
            ctx.unbind("cframe")
        end
    end)
    ctx.addSetting("cframe_speed_value", 50)
    ctx.addSetting("jumppower_on", false, function(value)
        if value then
            ctx.bind("jump", RunService.Heartbeat, applyJump)
        else
            ctx.unbind("jump")
        end
    end)
    ctx.addSetting("jumppower", 50, function()
        applyJump()
    end)
    ctx.addSetting("infinite_jump", false, function(value)
        if value then
            ctx.bind("infjump", UserInputService.JumpRequest, function()
                local humanoid = ctx.state.humanoid
                if humanoid and ctx.cfg.infinite_jump then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            ctx.unbind("infjump")
        end
    end)
    ctx.addSetting("noclip", false, function(value)
        if value then
            ctx.bind("noclip", RunService.Stepped, noclipStep)
        else
            ctx.unbind("noclip")
            restoreNoclip()
        end
    end)
    ctx.addSetting("fly", false, function(value)
        if value then
            startFly()
        else
            stopFly()
        end
    end)
    ctx.addSetting("fly_speed", 60)
    ctx.addSetting("speed_boost_on", false, function(value)
        if value then
            ctx.bind("speedboost", RunService.Heartbeat, speedBoost)
        else
            ctx.unbind("speedboost")
        end
    end)
    ctx.addSetting("speed_boost", 0)
    ctx.addSetting("ghost_players", false, function(value)
        if value then
            ctx.bind("ghost", RunService.Stepped, ghostStep)
        else
            ctx.unbind("ghost")
        end
    end)

    ctx.addHotkey("key_fly", "hotkey_fly", function()
        ctx.set("fly", not ctx.cfg.fly)
    end)
    ctx.addHotkey("key_noclip", "hotkey_noclip", function()
        ctx.set("noclip", not ctx.cfg.noclip)
    end)

    M.teleport = teleport
    M.dropAnchor = function()
        local root = ctx.state.root
        if root then
            anchor = root.CFrame
            ctx.notify(ctx.L("n_anchor_set"), "success", 3)
        end
    end
    M.beamUp = function()
        local root = ctx.state.root
        if not root then
            return
        end
        if not anchor then
            ctx.notify(ctx.L("n_no_anchor"), "warning", 3)
            return
        end
        root.CFrame = anchor
    end

    ctx.onUnload(function()
        stopFly()
        restoreNoclip()
    end)
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    ui.section(tab, "sec_speed", "Lucide:gauge")
    ui.toggle(tab, "cframe_speed", "Lucide:gauge")
    ui.number(tab, "cframe_speed_value", "Lucide:gauge", 1)
    ui.toggle(tab, "speed_boost_on", "Lucide:zap")
    ui.slider(tab, "speed_boost", 0, 20, 0.25, "Lucide:gauge", " boost")

    ui.section(tab, "sec_jump", "Lucide:arrow-up")
    ui.toggle(tab, "jumppower_on", "Lucide:arrow-up")
    ui.slider(tab, "jumppower", 0, 200, 5, "Lucide:arrow-up")
    ui.toggle(tab, "infinite_jump", "Lucide:chevrons-up")

    ui.section(tab, "sec_collision", "Lucide:ghost")
    ui.toggle(tab, "noclip", "Lucide:ghost")
    ui.toggle(tab, "ghost_players", "Lucide:users")

    ui.section(tab, "sec_flight", "Lucide:plane")
    ui.toggle(tab, "fly", "Lucide:plane")
    ui.slider(tab, "fly_speed", 10, 300, 5, "Lucide:wind")

    ui.section(tab, "sec_teleport", "Lucide:navigation")
    ui.button(tab, "btn_tp_nearest", "Lucide:navigation", function()
        M.teleport(false)
    end)
    ui.button(tab, "btn_tp_farthest", "Lucide:navigation", function()
        M.teleport(true)
    end)
    ui.button(tab, "btn_anchor_drop", "Lucide:anchor", function()
        M.dropAnchor()
    end)
    ui.button(tab, "btn_anchor_beam", "Lucide:arrow-up-from-line", function()
        M.beamUp()
    end)
end

return M
