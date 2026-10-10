local M = {}

local function report(loading, step, progress)
    if loading then
        loading.set(step, progress)
    end
end

local function detectGame(games)
    local deadline = os.clock() + 15
    repeat
        local name = games.detect()
        if name then
            return name
        end
        task.wait(0.5)
    until os.clock() > deadline
    return nil
end

local function openWindow(ctx, gameModule, loading)
    local config = ctx.config
    local library, loadError = ctx.modules:require("core/vind").load(config)
    if not library then
        ctx.status("Interface failed: " .. tostring(loadError))
        ctx.applyAll()
        return
    end
    ctx.library = library

    local okWindow, window = pcall(function()
        return library:CreateWindow({
            Title = config.Title,
            Subtitle = ctx.game .. " · v" .. config.Version,
            Icon = config.WindowLogo or config.Logo,
            Size = UDim2.fromOffset(640, 455),
            MinSize = Vector2.new(500, 360),
            Draggable = true,
            Resizable = true,
            UseBlur = true,
            DefaultTab = "Home",
            TabWidth = 145,
            TabScrollbar = true,
        })
    end)
    if not okWindow or type(window) ~= "table" then
        ctx.status("Window failed: " .. tostring(window))
        ctx.applyAll()
        return
    end
    ctx.window = window

    local shared = ctx.modules:require("shared/ui_common")
    shared.home(window, ctx)
    if gameModule and gameModule.Build then
        local okBuild, buildError = pcall(gameModule.Build, window, ctx)
        if not okBuild then
            ctx.warn("game build failed: " .. tostring(buildError))
        end
    end
    shared.credits(window, ctx)
    ctx.modules:require("shared/chat").tab(window, ctx)
    shared.settings(window, ctx)

    ctx.applyAll()
    ctx.notify(ctx.L("n_loaded", tostring(ctx.cfg.menu_key)), "success", 5)
    if ctx.sounds then
        ctx.sounds.play("startup")
    end
    report(loading, "ready", 1)
    if loading then
        loading.destroy()
    end
end

function M.run(modules, config, loading)

    config.SettingsFile = config.Folder .. "/session_" .. tostring(game.GameId) .. ".json"
    local env = getgenv and getgenv() or _G
    local base = modules:require("core/base")
    local i18n = modules:require("core/i18n")
    local games = modules:require("games/index")
    local keys = modules:require("core/keysystem")

    local ctx = base.new(config)
    ctx.modules = modules
    i18n.new(ctx)
    for _, file in ipairs({ "shared/strings", "shared/strings_extra", "shared/strings_features", "shared/strings_background" }) do
        for code, pack in pairs(modules:require(file)) do
            ctx.addStrings(code, pack)
        end
    end
    ctx.ui = modules:require("core/ui").new(ctx)
    modules:require("shared/assets").new(ctx)
    modules:require("shared/sounds").new(ctx)

    config.WindowLogo = ctx.assets.get("logo") or config.Logo
    env.DominantInstance = ctx

    ctx.addSetting("language", "en")
    ctx.addSetting("menu_key", "RightShift")
    ctx.addSetting("notifications", true)

    local gameModule = nil
    ctx.changelog = {}
    report(loading, "game", 0.4)
    local gameName = detectGame(games)
    if gameName then
        local ok, result = pcall(function()
            return modules:require("games/" .. gameName .. "/init")
        end)
        if ok then
            gameModule = result
            ctx.game = result.Name or gameName
            local okLog, log = pcall(function()
                return modules:require("games/" .. gameName .. "/changelog")
            end)
            if okLog and type(log) == "table" then
                ctx.changelog = log
            end
            local okStrings, pack = pcall(function()
                return modules:require("games/" .. gameName .. "/strings")
            end)
            if okStrings then
                for code, strings in pairs(pack) do
                    ctx.addStrings(code, strings)
                end
            end
        else
            ctx.status("Game module failed: " .. tostring(result))
        end
    end

    ctx.gameOptions = gameModule and gameModule.Options or {}
    if gameModule and gameModule.Init then
        local ok, err = pcall(gameModule.Init, ctx)
        if not ok then
            ctx.warn("game init failed: " .. tostring(err))
        end
    end

    modules:require("shared/features/background").Register(ctx)
    modules:require("shared/sounds").Register(ctx)
    modules:require("shared/chat").Register(ctx)
    ctx.loadSession()
    local autoload = ctx.getAutoload()
    if autoload then
        ctx.loadConfig(autoload)
    end
    ctx.setLanguage(ctx.cfg.language)

    local started = false
    local function start()
        if started then
            return
        end
        started = true
        if loading then
            loading.show()
        end
        report(loading, "window", 0.7)
        openWindow(ctx, gameModule, loading)
        if loading then
            loading.destroy()
        end
    end

    report(loading, "key", 0.6)
    if loading then
        loading.hide()
    end
    keys.run(config, games.supportedIds(), start, ctx.status)
end

return M
