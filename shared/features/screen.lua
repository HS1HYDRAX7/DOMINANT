-- World: fullbright, fog removal, custom field of view and third person camera distance.
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local M = {}

function M.Register(ctx, data)
    local savedLight = nil
    local savedFog = nil
    local savedAtmospheres = {}
    local savedFov = nil
    local savedZoom = nil

    local function restoreProps(saved)
        if not saved then
            return
        end
        for key, value in pairs(saved) do
            pcall(function()
                Lighting[key] = value
            end)
        end
    end

    local function fullbrightStep()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(190, 190, 190)
        Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
    end

    local function noFogStep()
        Lighting.FogStart = 1e9
        Lighting.FogEnd = 1e9
        for _, atmosphere in ipairs(Lighting:GetChildren()) do
            if atmosphere:IsA("Atmosphere") then
                if savedAtmospheres[atmosphere] == nil then
                    savedAtmospheres[atmosphere] = atmosphere.Density
                end
                atmosphere.Density = 0
            end
        end
    end

    local function thirdPersonStep()
        local distance = math.max(0.5, tonumber(ctx.cfg.third_person_dist) or 10)
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = distance
            LocalPlayer.CameraMinZoomDistance = distance
        end)
    end

    ctx.addSetting("fullbright", false, function(value)
        if value then
            savedLight = savedLight or {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
            ctx.startLoop("fullbright", 0.25, fullbrightStep)
        else
            ctx.stopLoop("fullbright")
            restoreProps(savedLight)
            savedLight = nil
        end
    end)
    ctx.addSetting("no_fog", false, function(value)
        if value then
            savedFog = savedFog or { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
            ctx.startLoop("nofog", 0.5, noFogStep)
        else
            ctx.stopLoop("nofog")
            restoreProps(savedFog)
            savedFog = nil
            for atmosphere, density in pairs(savedAtmospheres) do
                pcall(function()
                    if atmosphere.Parent then
                        atmosphere.Density = density
                    end
                end)
            end
            savedAtmospheres = {}
        end
    end)
    ctx.addSetting("fov_on", false, function(value)
        if value then
            local camera = workspace.CurrentCamera
            if camera and savedFov == nil then
                savedFov = camera.FieldOfView
            end
            ctx.bind("fov", RunService.RenderStepped, function()
                local current = workspace.CurrentCamera
                if current then
                    current.FieldOfView = ctx.cfg.fov
                end
            end)
        else
            ctx.unbind("fov")
            local current = workspace.CurrentCamera
            if current and savedFov then
                current.FieldOfView = savedFov
            end
            savedFov = nil
        end
    end)
    ctx.addSetting("fov", 90)
    ctx.addSetting("third_person", false, function(value)
        if value then
            savedZoom = savedZoom or { min = LocalPlayer.CameraMinZoomDistance, max = LocalPlayer.CameraMaxZoomDistance }
            thirdPersonStep()
            ctx.startLoop("thirdperson", 0.5, thirdPersonStep)
        else
            ctx.stopLoop("thirdperson")
            if savedZoom then
                pcall(function()
                    LocalPlayer.CameraMaxZoomDistance = savedZoom.max
                    LocalPlayer.CameraMinZoomDistance = savedZoom.min
                end)
            end
            savedZoom = nil
        end
    end)
    ctx.addSetting("third_person_dist", 10, function()
        if ctx.cfg.third_person then
            thirdPersonStep()
        end
    end)

    ctx.onUnload(function()
        restoreProps(savedLight)
        restoreProps(savedFog)
    end)
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    ui.section(tab, "sec_lighting", "Lucide:sun")
    ui.toggle(tab, "fullbright", "Lucide:sun")
    ui.toggle(tab, "no_fog", "Lucide:cloud")

    ui.section(tab, "sec_camera", "Lucide:camera")
    ui.toggle(tab, "fov_on", "Lucide:scan")
    ui.slider(tab, "fov", 40, 120, 1, "Lucide:scan")
    ui.toggle(tab, "third_person", "Lucide:camera")
    ui.slider(tab, "third_person_dist", 2, 60, 1, "Lucide:ruler", " studs")
end

return M
