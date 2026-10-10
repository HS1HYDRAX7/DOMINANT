local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local M = {}

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __color = { value.R, value.G, value.B } }
    end
    return value
end

local function decodeValue(value)
    if type(value) == "table" and value.__color then
        local c = value.__color
        return Color3.new(c[1], c[2], c[3])
    end
    return value
end

function M.new(config)
    local ctx = {
        config = config,
        defaults = {},
        cfg = {},
        hooks = {},
        hotkeys = {},
        loops = {},
        objects = {},
        unloadHandlers = {},
        characterCallbacks = {},
        state = { unloading = false, saveToken = 0, character = nil, humanoid = nil, root = nil },
        executor = "Unknown",
        game = "Unknown",
        library = nil,
        window = nil,
        ui = nil,
        modules = nil,
    }

    ctx.caps = {
        files = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function",
        clipboard = type(setclipboard) == "function",
        fireproximityprompt = type(fireproximityprompt) == "function",
        fps = type(setfpscap) == "function",
        hookmetamethod = type(hookmetamethod) == "function",
        require = type(require) == "function",
    }

    pcall(function()
        if type(identifyexecutor) == "function" then
            ctx.executor = tostring((identifyexecutor()))
        end
    end)

    function ctx.warn(text)
        warn("[" .. config.Title .. "] " .. tostring(text))
    end

    function ctx.status(text)
        ctx.warn(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = config.Title, Text = tostring(text), Duration = 6 })
        end)
    end

    function ctx.notify(text, kind, duration)
        if ctx.cfg.notifications == false then
            return
        end
        if ctx.sounds then
            ctx.sounds.play(ctx.sounds.forKind(kind))
        end
        if ctx.library and type(ctx.library.Notify) == "function" then
            local ok = pcall(function()
                ctx.library:Notify({
                    Title = config.Title,
                    Text = tostring(text),
                    Type = kind or "info",
                    Duration = duration or 4,
                })
            end)
            if ok then
                return
            end
        end
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = config.Title, Text = tostring(text), Duration = duration or 4 })
        end)
    end

    function ctx.copy(text)
        if not ctx.caps.clipboard then
            ctx.notify(ctx.L("n_clipboard_fail"), "warning", 3)
            return false
        end
        local ok = pcall(setclipboard, text)
        ctx.notify(ctx.L(ok and "n_copied" or "n_clipboard_fail"), ok and "success" or "warning", 3)
        return ok
    end

    function ctx.addSetting(key, default, hook)
        ctx.defaults[key] = default
        if ctx.cfg[key] == nil then
            ctx.cfg[key] = default
        end
        if hook then
            ctx.hooks[key] = hook
        end
    end

    function ctx.hook(key, fn)
        ctx.hooks[key] = fn
    end

    function ctx.apply(key, value)
        local hook = ctx.hooks[key]
        if hook then
            local ok, err = pcall(hook, value)
            if not ok then
                ctx.warn(key .. ": " .. tostring(err))
            end
        end
    end

    function ctx.set(key, value)
        ctx.cfg[key] = value
        ctx.apply(key, value)
        ctx.queueSave()
    end

    function ctx.applyAll()
        for key in pairs(ctx.hooks) do
            ctx.apply(key, ctx.cfg[key])
        end
    end

    function ctx.reset()
        for key, value in pairs(ctx.defaults) do
            ctx.cfg[key] = value
        end
    end

    function ctx.addHotkey(key, label, run)
        ctx.addSetting(key, "Unknown")
        table.insert(ctx.hotkeys, { key = key, label = label, run = run })
    end

    local function ensureFolders()
        pcall(function()
            if not isfolder(config.Folder) then
                makefolder(config.Folder)
            end
            if not isfolder(config.Folder .. "/configs") then
                makefolder(config.Folder .. "/configs")
            end
        end)
    end

    local function writeSettings(path)
        if not ctx.caps.files then
            return false
        end
        ensureFolders()
        local out = {}
        for key in pairs(ctx.defaults) do
            out[key] = encodeValue(ctx.cfg[key])
        end
        return (pcall(function()
            writefile(path, HttpService:JSONEncode(out))
        end))
    end

    local function readSettings(path)
        if not ctx.caps.files then
            return false
        end
        local okFile, raw = pcall(function()
            if isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if not okFile or type(raw) ~= "string" then
            return false
        end
        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not okDecode or type(decoded) ~= "table" then
            return false
        end
        for key, default in pairs(ctx.defaults) do
            local stored = decoded[key]
            if stored ~= nil then
                stored = decodeValue(stored)
                if typeof(stored) == typeof(default) then
                    ctx.cfg[key] = stored
                elseif type(default) == "number" and tonumber(stored) ~= nil then
                    ctx.cfg[key] = tonumber(stored)
                end
            end
        end
        return true
    end

    local function configPath(name)
        return config.Folder .. "/configs/" .. name .. ".json"
    end

    function ctx.saveSession()
        return writeSettings(config.SettingsFile)
    end

    function ctx.loadSession()
        return readSettings(config.SettingsFile)
    end

    function ctx.queueSave()
        ctx.state.saveToken += 1
        local token = ctx.state.saveToken
        task.delay(0.75, function()
            if ctx.state.saveToken == token and not ctx.state.unloading then
                ctx.saveSession()
            end
        end)
    end

    function ctx.sanitizeName(text)
        local clean = tostring(text or ""):gsub("[^%w_%-]", "")
        if clean == "" then
            clean = "default"
        end
        return clean
    end

    function ctx.listConfigs()
        local names = {}
        if not ctx.caps.files or type(listfiles) ~= "function" then
            return names
        end
        local ok, files = pcall(listfiles, config.Folder .. "/configs")
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = string.match(path, "([^/\\]+)%.json$")
                if name then
                    table.insert(names, name)
                end
            end
        end
        table.sort(names)
        return names
    end

    function ctx.saveConfig(name)
        return writeSettings(configPath(ctx.sanitizeName(name)))
    end

    function ctx.loadConfig(name)
        return readSettings(configPath(ctx.sanitizeName(name)))
    end

    function ctx.deleteConfig(name)
        if not ctx.caps.files or type(delfile) ~= "function" then
            return false
        end
        return (pcall(delfile, configPath(ctx.sanitizeName(name))))
    end

    function ctx.setAutoload(name)
        if not ctx.caps.files then
            return false
        end
        ensureFolders()
        return (pcall(writefile, config.Folder .. "/autoload.txt", ctx.sanitizeName(name)))
    end

    function ctx.getAutoload()
        if not ctx.caps.files then
            return nil
        end
        local ok, name = pcall(function()
            local path = config.Folder .. "/autoload.txt"
            if isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
        return nil
    end

    function ctx.stopLoop(name)
        ctx.loops[name] = nil
    end

    function ctx.startLoop(name, interval, callback)
        ctx.stopLoop(name)
        local token = {}
        ctx.loops[name] = token
        task.spawn(function()
            local failures = 0
            while ctx.loops[name] == token and not ctx.state.unloading do
                local ok, err = pcall(callback)
                if ok then
                    failures = 0
                else
                    failures += 1
                    if failures == 1 then
                        ctx.warn(name .. ": " .. tostring(err))
                    end
                    if failures >= 30 then
                        ctx.loops[name] = nil
                        ctx.warn(name .. " stopped after repeated errors")
                        break
                    end
                end
                task.wait(math.max(interval or 0.1, 0.03))
            end
        end)
    end

    function ctx.unbind(name)
        local key = "bind_" .. name
        local connection = ctx.objects[key]
        if connection then
            connection:Disconnect()
            ctx.objects[key] = nil
        end
    end

    function ctx.bind(name, signal, callback)
        ctx.unbind(name)
        local warned = false
        ctx.objects["bind_" .. name] = signal:Connect(function(...)
            local ok, err = pcall(callback, ...)
            if not ok and not warned then
                warned = true
                ctx.warn(name .. ": " .. tostring(err))
            end
        end)
    end

    function ctx.refreshCharacter(character)
        local state = ctx.state
        state.character = character
        state.humanoid = character and character:FindFirstChildOfClass("Humanoid") or nil
        state.root = character and character:FindFirstChild("HumanoidRootPart") or nil
    end

    function ctx.onCharacter(callback)
        table.insert(ctx.characterCallbacks, callback)
    end

    local function onCharacterAdded(character)
        character:WaitForChild("HumanoidRootPart", 10)
        ctx.refreshCharacter(character)
        for _, callback in ipairs(ctx.characterCallbacks) do
            task.spawn(function()
                pcall(callback, character)
            end)
        end
    end

    ctx.objects.charAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        task.spawn(onCharacterAdded, character)
    end)
    if LocalPlayer.Character then
        task.spawn(onCharacterAdded, LocalPlayer.Character)
    end

    function ctx.onUnload(callback)
        table.insert(ctx.unloadHandlers, callback)
    end

    function ctx.unload()
        if ctx.state.unloading then
            return
        end
        ctx.state.unloading = true
        ctx.notify(ctx.L("n_unloaded"), "info", 3)

        for key, default in pairs(ctx.defaults) do
            if type(default) == "boolean" and ctx.hooks[key] then
                pcall(ctx.hooks[key], false)
            end
        end
        for _, handler in ipairs(ctx.unloadHandlers) do
            pcall(handler)
        end
        for name in pairs(ctx.loops) do
            ctx.loops[name] = nil
        end
        for name, object in pairs(ctx.objects) do
            if typeof(object) == "RBXScriptConnection" then
                object:Disconnect()
            end
            ctx.objects[name] = nil
        end
        if ctx.library and type(ctx.library.Unload) == "function" then
            pcall(function()
                ctx.library:Unload()
            end)
        end

        local env = getgenv and getgenv() or _G
        if env.DominantInstance == ctx then
            env.DominantInstance = nil
        end
    end

    return ctx
end

return M
