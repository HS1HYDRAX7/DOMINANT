-- Dominant loader. The only file users execute:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/main/loader.lua"))()
local BASE = "https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/main/"

local env = getgenv and getgenv() or _G
local previous = env.DominantInstance
if previous and type(previous.unload) == "function" then
    pcall(previous.unload)
    task.wait(0.3)
end

-- Loading screen (Ophyn style). Shown while modules load, hidden while the key screen is open,
-- shown again while the window is built, then destroyed.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalizationService = game:GetService("LocalizationService")

local PALETTE = {
    dim = Color3.fromRGB(0, 0, 0),
    card = Color3.fromRGB(18, 22, 19),
    stroke = Color3.fromRGB(34, 42, 36),
    bar = Color3.fromRGB(28, 34, 29),
    text = Color3.fromRGB(238, 242, 238),
    muted = Color3.fromRGB(122, 132, 124),
    accent = Color3.fromRGB(70, 214, 110),
}

local STEPS = {
    en = { modules = "Loading modules", game = "Detecting game", key = "Waiting for key", window = "Building interface", ready = "Ready" },
    pt = { modules = "Carregando módulos", game = "Detectando jogo", key = "Aguardando key", window = "Montando interface", ready = "Pronto" },
    es = { modules = "Cargando módulos", game = "Detectando juego", key = "Esperando key", window = "Construyendo interfaz", ready = "Listo" },
    ru = { modules = "Загрузка модулей", game = "Определение игры", key = "Ожидание ключа", window = "Сборка интерфейса", ready = "Готово" },
}

local function localeCode()
    local ok, id = pcall(function()
        return LocalizationService.RobloxLocaleId
    end)
    local code = ok and type(id) == "string" and string.sub(id, 1, 2) or "en"
    if STEPS[code] then
        return code
    end
    return "en"
end

local function createLoadingScreen()
    local steps = STEPS[localeCode()]
    local gui = Instance.new("ScreenGui")
    gui.Name = "DominantLoading"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000
    local placed = false
    if typeof(gethui) == "function" then
        placed = pcall(function()
            gui.Parent = gethui()
        end)
    end
    if not placed or not gui.Parent then
        local coreOk = pcall(function()
            gui.Parent = game:GetService("CoreGui")
        end)
        if not coreOk or not gui.Parent then
            gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end

    local root = Instance.new("Frame")
    root.Size = UDim2.fromScale(1, 1)
    root.BackgroundColor3 = PALETTE.dim
    root.BackgroundTransparency = 0.45
    root.BorderSizePixel = 0
    root.Parent = gui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(360, 150)
    card.BackgroundColor3 = PALETTE.card
    card.BorderSizePixel = 0
    card.Parent = root
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card
    local outline = Instance.new("UIStroke")
    outline.Color = PALETTE.stroke
    outline.Thickness = 1
    outline.Parent = card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 26)
    title.Position = UDim2.new(0, 20, 0, 24)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = PALETTE.text
    title.Text = "Dominant"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = card

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Size = UDim2.new(1, -40, 0, 18)
    status.Position = UDim2.new(0, 20, 0, 58)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.TextColor3 = PALETTE.muted
    status.Text = steps.modules
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -40, 0, 8)
    track.Position = UDim2.new(0, 20, 0, 92)
    track.BackgroundColor3 = PALETTE.bar
    track.BorderSizePixel = 0
    track.Parent = card
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = PALETTE.accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local screen = {}

    -- step: one of modules, game, key, window, ready. progress: 0 to 1.
    function screen.set(step, progress)
        status.Text = steps[step] or step
        if progress then
            TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1),
            }):Play()
        end
    end

    function screen.setTitle(text)
        title.Text = tostring(text or "Dominant")
    end

    function screen.hide()
        root.Visible = false
    end

    function screen.show()
        root.Visible = true
    end

    function screen.destroy()
        gui:Destroy()
    end

    return screen
end

local loading = createLoadingScreen()
loading.set("modules", 0.1)

local Modules = loadstring(game:HttpGet(BASE .. "core/modules.lua"))()
local modules = Modules.new(BASE)
local config = modules:require("core/config")
loading.setTitle(config.Title)
loading.set("modules", 0.3)

local app = modules:require("core/app")
app.run(modules, config, loading)
