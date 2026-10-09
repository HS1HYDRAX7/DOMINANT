-- Forsaken misc extras: performance mode, HUD, FPS cap, timed server hop, Infinite Yield and Dex launchers.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local M = {}

local INFINITE_YIELD = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
local DEX = "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"

function M.Register(ctx)
    local misc = ctx.modules:require("shared/features/misc")

    -- Performance mode: lowest quality, no shadows, no post effects.
    local saved = nil
    ctx.addSetting("performance_mode", false, function(value)
        local rendering
        pcall(function()
            rendering = settings().Rendering
        end)
        if value then
            saved = saved or { Quality = rendering and rendering.QualityLevel, Shadows = Lighting.GlobalShadows }
            pcall(function()
                rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            Lighting.GlobalShadows = false
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BloomEffect") then
                    effect.Enabled = false
                end
            end
        elseif saved then
            pcall(function()
                rendering.QualityLevel = saved.Quality
            end)
            Lighting.GlobalShadows = saved.Shadows
            saved = nil
        end
    end)

    -- HUD: small FPS and ping label in the corner.
    local hudGui = nil
    local function buildHud()
        if hudGui and hudGui.Parent then
            return hudGui
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "DominantHUD"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 60
        local placed = false
        if typeof(gethui) == "function" then
            placed = pcall(function()
                gui.Parent = gethui()
            end)
        end
        if not placed or not gui.Parent then
            pcall(function()
                gui.Parent = game:GetService("CoreGui")
            end)
            if not gui.Parent then
                gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
        end
        local label = Instance.new("TextLabel")
        label.Name = "Stats"
        label.Position = UDim2.fromOffset(12, 12)
        label.Size = UDim2.fromOffset(170, 24)
        label.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        label.BackgroundTransparency = 0.25
        label.BorderSizePixel = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = label
        hudGui = gui
        return gui
    end

    ctx.addSetting("hud", false, function(value)
        ctx.unbind("hud")
        if not value then
            if hudGui then
                hudGui:Destroy()
                hudGui = nil
            end
            return
        end
        local gui = buildHud()
        local frames, last = 0, os.clock()
        ctx.bind("hud", RunService.RenderStepped, function()
            frames += 1
            local now = os.clock()
            if now - last >= 0.5 then
                local fps = math.floor(frames / (now - last) + 0.5)
                local ping = math.floor(LocalPlayer:GetNetworkPing() * 2000)
                gui.Stats.Text = string.format("%s %d  |  %s %dms", ctx.L("hud_fps"), fps, ctx.L("hud_ping"), ping)
                frames, last = 0, now
            end
        end)
    end)

    -- FPS cap
    ctx.addSetting("fps_cap_on", false, function(value)
        if not ctx.caps.fps then
            if value then
                ctx.notify(ctx.L("n_unsupported"), "warning", 3)
            end
            return
        end
        setfpscap(value and ctx.cfg.fps_cap or 0)
    end)
    ctx.addSetting("fps_cap", 144, function(value)
        if ctx.caps.fps and ctx.cfg.fps_cap_on then
            setfpscap(value)
        end
    end)

    -- Timed server hop: joins another server every N minutes.
    local hopStart = 0
    ctx.addSetting("timed_hop_minutes", 10)
    ctx.addSetting("timed_hop", false, function(value)
        ctx.stopLoop("timedhop")
        if not value then
            return
        end
        hopStart = os.clock()
        ctx.startLoop("timedhop", 15, function()
            local minutes = math.max(1, tonumber(ctx.cfg.timed_hop_minutes) or 10)
            if os.clock() - hopStart >= minutes * 60 then
                hopStart = os.clock()
                misc.serverHop()
            end
        end)
    end)

    ctx.onUnload(function()
        if hudGui then
            hudGui:Destroy()
            hudGui = nil
        end
    end)
end

local function runRemote(ctx, url)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not ok then
        ctx.notify(tostring(err), "error", 4)
    end
end

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_performance", "Lucide:gauge")
    ui.toggle(tab, "performance_mode", "Lucide:zap")
    ui.toggle(tab, "hud", "Lucide:activity")
    ui.toggle(tab, "fps_cap_on", "Lucide:timer")
    ui.slider(tab, "fps_cap", 30, 360, 10, "Lucide:gauge")

    ui.section(tab, "sec_server", "Lucide:server")
    ui.toggle(tab, "timed_hop", "Lucide:log-out")
    ui.number(tab, "timed_hop_minutes", "Lucide:clock", 1)

    ui.section(tab, "sec_tools", "Lucide:wrench")
    ui.button(tab, "btn_infinite_yield", "Lucide:terminal", function()
        runRemote(ctx, INFINITE_YIELD)
    end)
    ui.button(tab, "btn_dex", "Lucide:search", function()
        runRemote(ctx, DEX)
    end)
end

return M
