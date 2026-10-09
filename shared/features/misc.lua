-- Misc: anti AFK, auto rejoin, rejoin, server hop, clipboard helpers, character reset and panic hotkey.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local M = {}

function M.Register(ctx, data)
    local function rejoin()
        ctx.notify(ctx.L("n_rejoining"), "info", 3)
        pcall(function()
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nRejoining")
                task.wait()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
    end

    local function serverHop()
        task.spawn(function()
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
            local okFetch, body = pcall(function()
                return game:HttpGet(url)
            end)
            local choices = {}
            if okFetch then
                local okDecode, decoded = pcall(function()
                    return HttpService:JSONDecode(body)
                end)
                if okDecode and type(decoded) == "table" and type(decoded.data) == "table" then
                    for _, server in ipairs(decoded.data) do
                        if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers - 1 then
                            table.insert(choices, server.id)
                        end
                    end
                end
            end
            if #choices == 0 then
                ctx.notify(ctx.L("n_no_servers"), "warning", 4)
                return
            end
            ctx.notify(ctx.L("n_hopping"), "info", 3)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, choices[math.random(1, #choices)], LocalPlayer)
            end)
        end)
    end

    ctx.addSetting("anti_afk", true, function(value)
        if value then
            ctx.bind("antiafk", LocalPlayer.Idled, function()
                pcall(function()
                    local virtualUser = game:GetService("VirtualUser")
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
            end)
        else
            ctx.unbind("antiafk")
        end
    end)
    ctx.addSetting("auto_rejoin", true, function(value)
        if value then
            ctx.bind("autorejoin", GuiService.ErrorMessageChanged, function(message)
                if message and message ~= "" and not ctx.state.unloading then
                    rejoin()
                end
            end)
        else
            ctx.unbind("autorejoin")
        end
    end)

    M.rejoin = rejoin
    M.serverHop = serverHop

    ctx.addHotkey("key_esp", "hotkey_esp", function()
        ctx.set("esp", not ctx.cfg.esp)
    end)
    ctx.addHotkey("key_panic", "hotkey_panic", function()
        for key, default in pairs(ctx.defaults) do
            if type(default) == "boolean" and ctx.cfg[key] == true and ctx.hooks[key] then
                ctx.set(key, false)
            end
        end
        ctx.notify(ctx.L("n_panic"), "warning", 2)
    end)
end

function M.Build(tab, ctx, data)
    local ui = ctx.ui
    ui.section(tab, "sec_utility", "Lucide:wrench")
    ui.toggle(tab, "anti_afk", "Lucide:timer")
    ui.toggle(tab, "auto_rejoin", "Lucide:power")
    ui.button(tab, "btn_reset_char", "Lucide:rotate-ccw", function()
        local humanoid = ctx.state.humanoid
        if humanoid then
            humanoid.Health = 0
        end
    end)

    ui.section(tab, "sec_server", "Lucide:server")
    ui.button(tab, "btn_rejoin", "Lucide:refresh-cw", function()
        M.rejoin()
    end)
    ui.button(tab, "btn_serverhop", "Lucide:log-out", function()
        M.serverHop()
    end)
    ui.button(tab, "btn_copy_jobid", "Lucide:copy", function()
        ctx.copy(game.JobId)
    end)
    ui.button(tab, "btn_copy_join", "Lucide:copy", function()
        ctx.copy(string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)", game.PlaceId, game.JobId))
    end)
end

return M
