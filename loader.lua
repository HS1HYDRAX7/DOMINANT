local BASE = "https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/main/"
local ASSET_FOLDER = "Dominant/Assets"
local STALL_TIMEOUT = 25

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local PALETTE = {
    bg = Color3.fromRGB(10, 10, 10),
    accent = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(150, 150, 150),
    text = Color3.fromRGB(255, 255, 255),
    error = Color3.fromRGB(240, 120, 120),
    glowFrom = Color3.fromRGB(255, 255, 255),
    glowTo = Color3.fromRGB(210, 210, 210),
    glowBase = Color3.fromRGB(255, 255, 255),
    button = Color3.fromRGB(66, 66, 66),
    buttonHover = Color3.fromRGB(90, 90, 90),
}

local IMAGES = {
    font = "rbxassetid://12187365364",
    glow = "rbxassetid://8992230677",
    shadow = "rbxassetid://6014261993",
    logo = "rbxassetid://111673746737789",
}

local FINAL_W, FINAL_H = 460, 260
local INTRO_SIZE = 80
local SQUARE_TIME = 1.2

local TEXT = {
    en = { stall = "Step took too long", modules = "Loading modules", game = "Detecting game", key = "Waiting for key", window = "Building interface", ready = "Ready", failed = "Could not load Dominant", retry = "Retry", check = "Check your connection and retry" },
    pt = { stall = "Uma etapa demorou demais", modules = "Carregando módulos", game = "Detectando jogo", key = "Aguardando key", window = "Montando interface", ready = "Pronto", failed = "Não foi possível carregar o Dominant", retry = "Tentar de novo", check = "Verifique sua conexão e tente de novo" },
    es = { stall = "Un paso tardó demasiado", modules = "Cargando módulos", game = "Detectando juego", key = "Esperando key", window = "Construyendo interfaz", ready = "Listo", failed = "No se pudo cargar Dominant", retry = "Reintentar", check = "Revisa tu conexión e inténtalo de nuevo" },
    ru = { stall = "Этап выполняется слишком долго", modules = "Загрузка модулей", game = "Определение игры", key = "Ожидание ключа", window = "Сборка интерфейса", ready = "Готово", failed = "Не удалось загрузить Dominant", retry = "Повторить", check = "Проверьте соединение и повторите" },
}

local function savedLanguage()
    local ok, code = pcall(function()
        local path = "Dominant/session_" .. tostring(game.GameId) .. ".json"
        if isfile(path) then
            local decoded = HttpService:JSONDecode(readfile(path))
            return decoded.language
        end
        return nil
    end)
    if ok and type(code) == "string" and TEXT[code] then
        return code
    end
    return "en"
end

local T = TEXT[savedLanguage()]

local function make(className, props, parent)
    local instance = Instance.new(className)
    for key, value in pairs(props) do
        instance[key] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function corner(parent, radius)
    make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function tween(instance, time, props, style)
    local running = TweenService:Create(instance, TweenInfo.new(time, style or Enum.EasingStyle.Quad), props)
    running:Play()
    return running
end

local function fontOf(weight)
    local ok, font = pcall(function()
        return Font.new(IMAGES.font, weight, Enum.FontStyle.Normal)
    end)
    if ok then
        return font
    end
    if weight == Enum.FontWeight.Bold then
        return Enum.Font.GothamBold
    end
    return Enum.Font.Gotham
end

local function placeGui(gui)
    local ok = false
    if typeof(gethui) == "function" then
        ok = pcall(function()
            gui.Parent = gethui()
        end)
    end
    if not ok or not gui.Parent then
        ok = pcall(function()
            gui.Parent = CoreGui
        end)
        if not ok or not gui.Parent then
            gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end

local function glow(parent, w, h, x, y, transparency, rotation)
    local image = make("ImageLabel", {
        Size = UDim2.new(0, w, 0, h),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = IMAGES.glow,
        ImageColor3 = PALETTE.glowBase,
        ImageTransparency = transparency,
        ScaleType = Enum.ScaleType.Stretch,
    }, parent)
    make("UIGradient", {
        Rotation = rotation,
        Color = ColorSequence.new(PALETTE.glowFrom, PALETTE.glowTo),
    }, image)
end

local function createScreen()
    local gui = make("ScreenGui", {
        Name = "Dominant",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    placeGui(gui)

    local main = make("Frame", {
        Size = UDim2.new(0, INTRO_SIZE, 0, INTRO_SIZE),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, gui)

    local shadow = make("ImageLabel", {
        Size = UDim2.new(1, 50, 1, 50),
        Position = UDim2.new(0, -25, 0, -25),
        BackgroundTransparency = 1,
        Image = IMAGES.shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
    }, main)

    local canvas = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = PALETTE.bg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    corner(canvas, 10)

    local border = make("UIStroke", {
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = PALETTE.accent,
        Transparency = 1,
    }, canvas)

    local decor = make("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
    }, canvas)
    corner(decor, 10)
    local decorFrame = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, FINAL_W, 0, FINAL_H),
        BackgroundTransparency = 1,
    }, decor)
    glow(decorFrame, 380, 140, 230, 266, 0.86, 270)
    glow(decorFrame, 100, 46, -8, 252, 0.75, 90)
    glow(decorFrame, 400, 184, 450, 8, 0.92, 90)
    glow(decorFrame, 70, 138, 5, -5, 0.78, 90)

    local logo = make("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 64, 0, 58),
        BackgroundTransparency = 1,
        Image = IMAGES.logo,
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
    }, canvas)

    local spinnerGroup = make("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 36),
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
    }, canvas)

    local track = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, spinnerGroup)
    corner(track, 1000)
    make("UIStroke", { Thickness = 2.5, Color = PALETTE.muted, Transparency = 0.75 }, track)

    local ring = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, spinnerGroup)
    corner(ring, 1000)
    local ringStroke = make("UIStroke", { Thickness = 2.5, Color = PALETTE.accent }, ring)
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.35, 0),
            NumberSequenceKeypoint.new(0.7, 1),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, ringStroke)
    local spin = TweenService:Create(ring, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 })

    local status = make("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 64),
        Size = UDim2.new(1, -40, 0, 16),
        BackgroundTransparency = 1,
        FontFace = fontOf(Enum.FontWeight.Regular),
        TextSize = 12,
        TextColor3 = PALETTE.muted,
        Text = T.modules,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, canvas)

    local retry = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 88),
        Size = UDim2.new(0, 160, 0, 30),
        BackgroundColor3 = PALETTE.button,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        FontFace = fontOf(Enum.FontWeight.Bold),
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        Text = T.retry,
        Visible = false,
    }, canvas)
    corner(retry, 8)
    retry.MouseEnter:Connect(function()
        retry.BackgroundColor3 = PALETTE.buttonHover
    end)
    retry.MouseLeave:Connect(function()
        retry.BackgroundColor3 = PALETTE.button
    end)

    local screen = { gui = gui, introDone = false, failed = false, onRetry = nil }
    local lastStep, lastChange = nil, os.clock()

    function screen.set(step)
        if screen.failed then
            return
        end
        lastStep = step
        lastChange = os.clock()
        status.Text = T[step] or step
        status.TextColor3 = PALETTE.muted
    end

    function screen.stalled()
        local watched = lastStep == "modules" or lastStep == "game" or lastStep == "window"
        return watched and not screen.failed and os.clock() - lastChange > STALL_TIMEOUT
    end

    function screen.intro()
        task.spawn(function()
            main.Size = UDim2.new(0, INTRO_SIZE - 20, 0, INTRO_SIZE - 20)
            local grow = tween(main, 0.6, { Size = UDim2.new(0, INTRO_SIZE, 0, INTRO_SIZE) }, Enum.EasingStyle.Quint)
            tween(canvas, 0.5, { BackgroundTransparency = 0 })
            tween(decor, 0.5, { GroupTransparency = 0 })
            tween(logo, 0.5, { ImageTransparency = 0 })
            tween(border, 0.5, { Transparency = 0.55 })
            tween(shadow, 0.5, { ImageTransparency = 0.6 })
            grow.Completed:Wait()
            task.wait(SQUARE_TIME - 0.6)

            tween(border, 0.7, { Transparency = 1 })
            local expand = tween(main, 0.85, { Size = UDim2.new(0, FINAL_W, 0, FINAL_H) }, Enum.EasingStyle.Quint)
            tween(logo, 0.7, { Position = UDim2.new(0.5, 0, 0.5, -20) }, Enum.EasingStyle.Quint)
            expand.Completed:Wait()

            local show = tween(spinnerGroup, 0.4, { GroupTransparency = 0 })
            tween(status, 0.4, { TextTransparency = 0 })
            show.Completed:Wait()
            spin:Play()
            screen.introDone = true
        end)
    end

    local function waitIntro()
        while not screen.introDone do
            task.wait()
        end
    end

    function screen.hide()
        gui.Enabled = false
    end

    function screen.show()
        gui.Enabled = true
    end

    function screen.setLogo(asset)
        if asset and asset ~= "" then
            logo.Image = asset
        end
    end

    function screen.fail(reason)
        task.spawn(function()
            waitIntro()
            screen.failed = true
            spin:Cancel()
            tween(spinnerGroup, 0.3, { GroupTransparency = 1 })
            local detail = reason and string.sub(tostring(reason), 1, 90) or T.check
            status.Text = T.failed .. ": " .. detail
            status.TextColor3 = PALETTE.error
            retry.Visible = true
        end)
    end

    function screen.restart()
        if not screen.failed then
            return
        end
        screen.failed = false
        retry.Visible = false
        status.Text = T.modules
        status.TextColor3 = PALETTE.muted
        tween(spinnerGroup, 0.3, { GroupTransparency = 0 })
        spin:Play()
    end

    retry.MouseButton1Click:Connect(function()
        screen.restart()
        if screen.onRetry then
            task.spawn(screen.onRetry)
        end
    end)

    function screen.finish()
        task.spawn(function()
            waitIntro()
            spin:Cancel()
            tween(spinnerGroup, 0.3, { GroupTransparency = 1 })
            tween(status, 0.3, { TextTransparency = 1 })
            tween(logo, 0.3, { ImageTransparency = 1 })
            tween(shadow, 0.4, { ImageTransparency = 1 })
            tween(decor, 0.4, { GroupTransparency = 1 })
            local last = tween(canvas, 0.4, { BackgroundTransparency = 1 })
            last.Completed:Wait()
            gui:Destroy()
        end)
    end

    screen.destroy = screen.finish
    return screen
end

local function resolveLogo()
    local ok, asset = pcall(function()
        if type(writefile) ~= "function" or type(getcustomasset) ~= "function" then
            return nil
        end
        if not isfolder("Dominant") then
            makefolder("Dominant")
        end
        if not isfolder(ASSET_FOLDER) then
            makefolder(ASSET_FOLDER)
        end
        local path = ASSET_FOLDER .. "/logo.png"
        if not isfile(path) then
            writefile(path, game:HttpGet(BASE .. "assets/logo.png"))
        end
        return getcustomasset(path)
    end)
    if ok and type(asset) == "string" then
        return asset
    end
    return nil
end

local env = getgenv and getgenv() or _G
local previous = env.DominantInstance
if previous and type(previous.unload) == "function" then
    pcall(previous.unload)
    task.wait(0.3)
end

local screen = createScreen()
screen.intro()
task.spawn(function()
    screen.setLogo(resolveLogo())
end)

local function bootstrap()
    local attempt = {}
    screen.attempt = attempt
    task.spawn(function()
        for _ = 1, 600 do
            task.wait(1)
            if screen.attempt ~= attempt or screen.failed then
                return
            end
            if screen.stalled() then
                warn("[Dominant] loading step stalled")
                screen.fail(T.stall)
                return
            end
        end
    end)

    screen.set("modules")
    local ok, err = pcall(function()
        local Modules = loadstring(game:HttpGet(BASE .. "core/modules.lua"))()
        local modules = Modules.new(BASE)
        local config = modules:require("core/config")
        local app = modules:require("core/app")
        app.run(modules, config, screen)
    end)
    if not ok then
        warn("[Dominant] " .. tostring(err))
        screen.fail(err)
    end
end

screen.onRetry = bootstrap
task.spawn(bootstrap)
