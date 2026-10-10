--[[
    Dominant for Pressure
    Built on the same structure as the Dominant script for Forsaken:
    Vind UI Reborn interface, Ophyn key system, hook based features and
    saved sessions. Pressure features (rooms, items, currency, keycards,
    monsters) follow the layout used by the Pressure script.
]]

local CONFIG = {
    Title = "Dominant",
    Description = "Pressure Premium Script",
    Logo = "rbxassetid://116590139091461",
    Theme = "Dark",
    Folder = "DominantPressure",
    Keys = { "dominant", "arroganthi", "1234" },
    SaveKey = false,
    VindUrl = "https://raw.githubusercontent.com/Skinny-yz/vindUI-Test/main/full.luau",
    OphynUrl = "https://ophyn.space/interface",
    Discord = "discord.gg/yourcode",
    Website = "https://example.com",
    SupportedGames = {},
    Version = "1.0.0",
    SettingsFile = "DominantPressure/session.json",
}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- CORE TABLE
local Dominant = {
    Version = CONFIG.Version,
    Cfg = {},
    Defaults = {},
    Hooks = {},
    Loops = {},
    Objects = {},
    CharacterCallbacks = {},
    Caps = {},
    Executor = "Unknown",
    Vind = nil,
    Window = nil,
    State = {
        Loaded = false,
        Unloading = false,
        Character = nil,
        Humanoid = nil,
        Root = nil,
        SaveToken = 0,
    },
}

local function hook(key, callback)
    Dominant.Hooks[key] = callback
end

local function keyFromName(name)
    local ok, key = pcall(function()
        return Enum.KeyCode[name]
    end)
    if ok and key then
        return key
    end
    return Enum.KeyCode.Unknown
end

local function yesNo(flag)
    return flag and "yes" or "no"
end

Dominant.Caps = {
    fireproximityprompt = type(fireproximityprompt) == "function",
    files = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function",
    clipboard = type(setclipboard) == "function",
}

pcall(function()
    if type(identifyexecutor) == "function" then
        Dominant.Executor = tostring((identifyexecutor()))
    end
end)

function Dominant.Warn(text)
    warn("[Dominant] " .. tostring(text))
end

function Dominant.Status(text)
    Dominant.Warn(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Dominant",
            Text = tostring(text),
            Duration = 6,
        })
    end)
end

function Dominant.Notify(text, kind, duration)
    if not Dominant.Cfg.notifications then
        return
    end
    local library = Dominant.Vind
    if library and type(library.Notify) == "function" then
        local ok = pcall(function()
            library:Notify({
                Title = CONFIG.Title,
                Text = text,
                Type = kind or "info",
                Duration = duration or 4,
            })
        end)
        if ok then
            return
        end
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = CONFIG.Title,
            Text = tostring(text),
            Duration = duration or 4,
        })
    end)
end

function Dominant.Copy(text)
    local ok = pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(text)
        else
            error("no clipboard")
        end
    end)
    if ok then
        Dominant.Notify("Copied to clipboard", "success", 3)
    else
        Dominant.Notify("Clipboard is not supported by your executor", "warning", 3)
    end
    return ok
end

-- DEFAULT SETTINGS
Dominant.Defaults = {
    -- Player
    cframe_speed = false,
    cframe_speed_value = 50,
    jumppower_on = false,
    jumppower = 50,
    infinite_jump = false,
    noclip = false,
    fly = false,
    fly_speed = 60,
    anti_afk = true,
    -- Automation
    loot_aura = false,
    loot_radius = 5,
    instant_prompts = false,
    -- Visuals
    esp = false,
    esp_monsters = true,
    esp_players = true,
    esp_items = true,
    esp_currency = true,
    esp_keycards = true,
    esp_text = true,
    esp_distance = true,
    esp_max_distance = 1000,
    esp_fill = 0.6,
    color_monster = Color3.fromRGB(200, 0, 0),
    color_player = Color3.fromRGB(60, 255, 120),
    -- World
    fullbright = false,
    no_fog = false,
    fov_on = false,
    fov = 90,
    third_person = false,
    third_person_dist = 10,
    -- Misc
    auto_rejoin = true,
    notifications = true,
    menu_key = "RightShift",
    key_fly = "Unknown",
    key_noclip = "Unknown",
    key_esp = "Unknown",
    key_panic = "Unknown",
}

function Dominant.Reset()
    for key, value in pairs(Dominant.Defaults) do
        Dominant.Cfg[key] = value
    end
end

Dominant.Reset()

function Dominant.Set(key, value)
    Dominant.Cfg[key] = value
    Dominant.Apply(key, value)
    Dominant.QueueSave()
end

function Dominant.Apply(key, value)
    local callback = Dominant.Hooks[key]
    if callback then
        local ok, err = pcall(callback, value)
        if not ok then
            Dominant.Warn(key .. ": " .. tostring(err))
        end
    end
end

function Dominant.ApplyAll()
    for key in pairs(Dominant.Hooks) do
        Dominant.Apply(key, Dominant.Cfg[key])
    end
end

-- SESSION SAVE / LOAD
local function ensureFolder(path)
    if type(isfolder) == "function" and type(makefolder) == "function" then
        pcall(function()
            if not isfolder(path) then
                makefolder(path)
            end
        end)
    end
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __color = { value.R, value.G, value.B } }
    elseif typeof(value) == "EnumItem" then
        return { __enum = tostring(value) }
    end
    return value
end

local function decodeValue(value)
    if type(value) == "table" and value.__color then
        return Color3.new(value.__color[1], value.__color[2], value.__color[3])
    end
    return value
end

function Dominant.SaveSession()
    if not Dominant.Caps.files then
        return false
    end
    ensureFolder(CONFIG.Folder)
    local out = {}
    for key, value in pairs(Dominant.Cfg) do
        out[key] = encodeValue(value)
    end
    return (pcall(function()
        writefile(CONFIG.SettingsFile, HttpService:JSONEncode(out))
    end))
end

function Dominant.LoadSession()
    if not Dominant.Caps.files then
        return false
    end
    local okFile, raw = pcall(function()
        if isfile(CONFIG.SettingsFile) then
            return readfile(CONFIG.SettingsFile)
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
    for key, default in pairs(Dominant.Defaults) do
        local stored = decoded[key]
        if stored ~= nil then
            stored = decodeValue(stored)
            if typeof(stored) == typeof(default) then
                Dominant.Cfg[key] = stored
            elseif type(default) == "number" and tonumber(stored) ~= nil then
                Dominant.Cfg[key] = tonumber(stored)
            elseif type(default) == "boolean" and type(stored) == "string" then
                local lower = string.lower(stored)
                if lower == "true" then
                    Dominant.Cfg[key] = true
                elseif lower == "false" then
                    Dominant.Cfg[key] = false
                end
            end
        end
    end
    return true
end

function Dominant.QueueSave()
    Dominant.State.SaveToken += 1
    local token = Dominant.State.SaveToken
    task.delay(0.75, function()
        if Dominant.State.SaveToken == token and not Dominant.State.Unloading then
            Dominant.SaveSession()
        end
    end)
end

-- LOOPS, EVENTS AND CHARACTER STATE
function Dominant.StartLoop(name, interval, callback)
    Dominant.StopLoop(name)
    local token = {}
    Dominant.Loops[name] = token
    task.spawn(function()
        local failures = 0
        while Dominant.Loops[name] == token and not Dominant.State.Unloading do
            local ok, err = pcall(callback)
            if ok then
                failures = 0
            else
                failures += 1
                if failures == 1 then
                    Dominant.Warn(name .. ": " .. tostring(err))
                end
                if failures >= 30 then
                    Dominant.Loops[name] = nil
                    Dominant.Warn(name .. " stopped after repeated errors")
                    break
                end
            end
            task.wait(math.max(interval or 0.1, 0.03))
        end
    end)
end

function Dominant.StopLoop(name)
    Dominant.Loops[name] = nil
end

function Dominant.Unbind(name)
    local key = "bind_" .. name
    local connection = Dominant.Objects[key]
    if connection then
        connection:Disconnect()
        Dominant.Objects[key] = nil
    end
end

function Dominant.Bind(name, signal, callback)
    Dominant.Unbind(name)
    local warned = false
    Dominant.Objects["bind_" .. name] = signal:Connect(function(...)
        local ok, err = pcall(callback, ...)
        if not ok and not warned then
            warned = true
            Dominant.Warn(name .. ": " .. tostring(err))
        end
    end)
end

function Dominant.RefreshCharacter(character)
    local state = Dominant.State
    state.Character = character
    state.Humanoid = character and character:FindFirstChildOfClass("Humanoid") or nil
    state.Root = character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function onCharacterAdded(character)
    character:WaitForChild("HumanoidRootPart", 10)
    Dominant.RefreshCharacter(character)
    for _, callback in ipairs(Dominant.CharacterCallbacks) do
        task.spawn(function()
            pcall(callback, character)
        end)
    end
end

Dominant.Objects.charAdded = LocalPlayer.CharacterAdded:Connect(function(character)
    task.spawn(onCharacterAdded, character)
end)

-- PRESSURE GAME HELPERS
local Game = {}

function Game.Rooms()
    local gameplay = workspace:FindFirstChild("GameplayFolder")
    return gameplay and gameplay:FindFirstChild("Rooms") or nil
end

function Game.WaitForRooms()
    local gameplay = workspace:WaitForChild("GameplayFolder", 10)
    return gameplay and gameplay:WaitForChild("Rooms", 10) or nil
end

function Game.FirePrompt(prompt)
    if Dominant.Caps.fireproximityprompt then
        if pcall(fireproximityprompt, prompt) then
            return true
        end
    end
    return (pcall(function()
        local hold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait()
        prompt:InputHoldEnd()
        prompt.HoldDuration = hold
    end))
end

-- COLORS AND PATTERNS
local YELLOW = Color3.fromRGB(255, 230, 0)
local GREEN = Color3.fromRGB(0, 255, 100)
local CYAN = Color3.fromRGB(100, 220, 255)
local RED = Color3.fromRGB(255, 0, 0)
local SOFT_RED = Color3.fromRGB(255, 50, 50)
local BROWN = Color3.fromRGB(180, 120, 40)
local BLUE = Color3.fromRGB(100, 100, 255)
local PURPLE = Color3.fromRGB(200, 0, 255)
local SKY = Color3.fromRGB(0, 180, 255)
local WHITE = Color3.fromRGB(255, 255, 255)

local KEYCARDS = {
    NormalKeyCard = { label = "Keycard", color = Color3.fromRGB(0, 0, 255) },
    InnerKeyCard = { label = "Inner Keycard", color = Color3.fromRGB(0, 120, 255) },
    PurpleKeyCard = { label = "Purple Keycard", color = Color3.fromRGB(170, 0, 255) },
    RidgeKeyCard = { label = "Ridge Keycard", color = Color3.fromRGB(255, 160, 0) },
    PasswordPaper = { label = "Password", color = WHITE },
}

-- each entry: { lua pattern, label, color }
local ITEM_PATTERNS = {
    { "Lantern", "Lantern", YELLOW },
    { "Flashlight", "Flashlight", YELLOW },
    { "Blacklight", "Blacklight", YELLOW },
    { "FlashBeacon", "Flash Beacon", YELLOW },
    { "Gummylight", "Gummylight", YELLOW },
    { "WindupLight", "Windup Light", YELLOW },
    { "Battery", "Battery", YELLOW },
    { "Medkit", "Medkit", GREEN },
    { "HealthBoost", "Health Boost", GREEN },
    { "Defib", "Defib", GREEN },
    { "SPRINT", "SPRINT", CYAN },
    { "[Nn]eostyk", "NeoStyk", CYAN },
    { "Scanner", "Scanner", SOFT_RED },
    { "CodeBreacher", "Code Breacher", RED },
    { "^Book$", "Book", BROWN },
    { "ToyRemote", "Toy Remote", BLUE },
}

local CURRENCY_PATTERNS = {
    { "^UCurrency5%-", "~5$", Color3.fromRGB(100, 220, 255) },
    { "^UCurrency10%-", "~10$", Color3.fromRGB(50, 180, 255) },
    { "^UCurrency15%-", "~15$", Color3.fromRGB(0, 150, 255) },
    { "^UCurrency25%-", "~25$", Color3.fromRGB(0, 100, 220) },
    { "^UCurrency50%-", "~50$", Color3.fromRGB(0, 80, 200) },
    { "^UCurrency100%-", "~100$", Color3.fromRGB(0, 50, 180) },
    { "^UCurrency200%-", "~200$", Color3.fromRGB(0, 30, 150) },
    { "^Currency5%-", "5$", Color3.fromRGB(180, 255, 100) },
    { "^Currency10%-", "10$", Color3.fromRGB(100, 220, 50) },
    { "^Currency15%-", "15$", Color3.fromRGB(50, 200, 50) },
    { "^Currency25%-", "25$", Color3.fromRGB(0, 180, 80) },
    { "^Currency50%-", "50$", Color3.fromRGB(0, 150, 255) },
    { "^Currency100%-", "100$", Color3.fromRGB(255, 200, 0) },
    { "^Currency200%-", "200$", Color3.fromRGB(255, 100, 0) },
    { "^Caps$", "Rare: Caps", PURPLE },
    { "^DoorsGold", "Rare: Doors Gold", PURPLE },
    { "^GOLDDD$", "Rare: GOLDDD", PURPLE },
    { "^HypnoCoin$", "Rare: Hypno Coin", PURPLE },
    { "^Regret$", "Rare: Regret", PURPLE },
    { "^Studs$", "Rare: Studs", PURPLE },
    { "^SuperCredits$", "Rare: Super Credits", PURPLE },
    { "^RareCurrency", "RARE$", PURPLE },
    { "^Blueprint$", "Blueprint", SKY },
}

local MONSTERS = {}
for _, name in ipairs({
    "A200", "A60", "Angler", "Bleach", "Bottomfeeder", "Bouncers", "CandleBearers", "CandleBrutes",
    "Eyefestation", "Eyefest", "Harbinger", "DeathAngel", "LopeePart", "Pandemonium", "Parasite", "Mirage",
    "Pipsqueak", "Rebarb", "Redeemer", "Skelepede", "Stan", "Divineroot", "TheEducator", "TheMindscape",
    "Painter", "Saboteur", "WitchingHour", "Blitz", "Squiddles", "NaviAI", "RottenCoral", "Searchlights",
    "DefenseSystem", "Froger", "Chainsmoker", "Pinkie", "WallDweller", "MeatWallDweller", "RottenWallDweller",
    "Bouncer", "SkeletonHead", "NoGood", "Coagulant", "TreeBody", "Coagulate", "DiVineRoot", "DwellerModel",
    "StatueHead", "StatueRoot", "RidgeAngler", "RidgeChainsmoker", "RidgePinkie", "RidgeBlitz", "RidgeFroger",
    "RidgePandemonium", "Anglemonium", "Frogermonium", "Blitzemonium", "Pandesmoker", "Pinkimonium", "DamageParts",
}) do
    MONSTERS[name] = true
end

local function matchList(list, name)
    for _, entry in ipairs(list) do
        if string.match(name, entry[1]) then
            return entry[2], entry[3]
        end
    end
    return nil
end

-- returns kind, label, color for Pressure items, or nil
local function classify(name)
    local keycard = KEYCARDS[name]
    if keycard then
        return "keycard", keycard.label, keycard.color
    end
    local label, color = matchList(CURRENCY_PATTERNS, name)
    if label then
        return "currency", label, color
    end
    label, color = matchList(ITEM_PATTERNS, name)
    if label then
        return "item", label, color
    end
    return nil
end

local function adorneePart(target)
    if target:IsA("BasePart") then
        return target
    end
    if target:IsA("Model") then
        return target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

-- ESP AND SCANNING
local ESP = { Objects = {}, Found = {}, ScanAt = 0 }

-- scans the rooms every 2 seconds and keeps only one entry per item
function ESP.Scan()
    local now = os.clock()
    if now - ESP.ScanAt < 2 then
        return ESP.Found
    end
    ESP.ScanAt = now
    local found = {}
    for _, rooms in ipairs(Game.ItemContainers()) do
        for _, object in ipairs(rooms:GetDescendants()) do
            if object:IsA("Model") or object:IsA("BasePart") then
                local parent = object.Parent
                local duplicate = object:IsA("BasePart") and parent ~= nil and parent:IsA("Model") and classify(parent.Name) ~= nil
                if not duplicate then
                    local kind, label, color = classify(object.Name)
                    if kind then
                        table.insert(found, { object = object, kind = kind, label = label, color = color })
                    end
                end
            end
        end
    end
    ESP.Found = found
    return found
end

function ESP.Collect()
    local cfg = Dominant.Cfg
    local list = {}
    if cfg.esp_monsters then
        for _, child in ipairs(workspace:GetChildren()) do
            if MONSTERS[child.Name] and (child:IsA("Model") or child:IsA("BasePart")) then
                table.insert(list, { target = child, kind = "monster", label = child.Name, color = cfg.color_monster })
            end
        end
    end
    if cfg.esp_players then
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if player ~= LocalPlayer and character then
                table.insert(list, { target = character, kind = "player", label = player.DisplayName, color = cfg.color_player })
            end
        end
    end
    for _, entry in ipairs(ESP.Scan()) do
        local wanted = (entry.kind == "item" and cfg.esp_items)
            or (entry.kind == "currency" and cfg.esp_currency)
            or (entry.kind == "keycard" and cfg.esp_keycards)
        if wanted then
            table.insert(list, { target = entry.object, kind = entry.kind, label = entry.label, color = entry.color })
        end
    end
    ESP.CollectRoomExtras(list)
    return list
end

function ESP.Create(target, kind, label, color)
    local part = adorneePart(target)
    if not part then
        return nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DominantHighlight"
    highlight.Adornee = target
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.OutlineColor = color
    highlight.Parent = target

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DominantLabel"
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(180, 32)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = part

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 13
    text.TextStrokeTransparency = 0.4
    text.TextColor3 = color
    text.Text = label
    text.Parent = billboard

    local entry = { Kind = kind, Highlight = highlight, Billboard = billboard, Label = text }
    ESP.Objects[target] = entry
    return entry
end

function ESP.Destroy(target)
    local entry = ESP.Objects[target]
    if not entry then
        return
    end
    pcall(function()
        entry.Highlight:Destroy()
    end)
    pcall(function()
        entry.Billboard:Destroy()
    end)
    ESP.Objects[target] = nil
end

function ESP.Clear()
    for target in pairs(ESP.Objects) do
        ESP.Destroy(target)
    end
end

function ESP.Step()
    local cfg = Dominant.Cfg
    local root = Dominant.State.Root
    if not cfg.esp or not root then
        return
    end
    local seen = {}
    for _, item in ipairs(ESP.Collect()) do
        local target = item.target
        local part = adorneePart(target)
        if part then
            local distance = (part.Position - root.Position).Magnitude
            if distance <= cfg.esp_max_distance then
                local entry = ESP.Objects[target] or ESP.Create(target, item.kind, item.label, item.color)
                if entry then
                    seen[target] = true
                    entry.Highlight.FillColor = item.color
                    entry.Highlight.FillTransparency = 1 - cfg.esp_fill
                    entry.Label.TextColor3 = item.color
                    entry.Billboard.Enabled = cfg.esp_text
                    local text = item.label
                    if cfg.esp_distance then
                        text = text .. " [" .. tostring(math.floor(distance)) .. "m]"
                    end
                    entry.Label.Text = text
                end
            end
        end
    end
    for target in pairs(ESP.Objects) do
        if not seen[target] or not target.Parent then
            ESP.Destroy(target)
        end
    end
end

-- FEATURE STATE
local Feat = {
    Fly = { Velocity = nil, Gyro = nil },
    Noclip = { Changed = {} },
    Light = { FullSaved = nil, FogSaved = nil, Atmospheres = {} },
    Camera = { FovSaved = nil, ZoomSaved = nil },
    Prompts = { Changed = {} },
    Hotkeys = {
        Order = { "key_fly", "key_noclip", "key_esp", "key_panic" },
        Map = { key_fly = "fly", key_noclip = "noclip", key_esp = "esp" },
    },
}

local Server = {}

-- MOVEMENT
local function cframeStep(dt)
    local root = Dominant.State.Root
    local humanoid = Dominant.State.Humanoid
    if not root or not humanoid or Dominant.Cfg.fly then
        return
    end
    local move = humanoid.MoveDirection
    if move.Magnitude > 0 then
        local speed = math.max(1, tonumber(Dominant.Cfg.cframe_speed_value) or 16)
        root.CFrame = root.CFrame + move.Unit * (speed * dt)
    end
end

local function applyJump()
    local humanoid = Dominant.State.Humanoid
    if humanoid and Dominant.Cfg.jumppower_on then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Dominant.Cfg.jumppower
    end
end

hook("cframe_speed", function(value)
    if value then
        Dominant.Bind("cframe", RunService.Heartbeat, cframeStep)
    else
        Dominant.Unbind("cframe")
    end
end)

hook("jumppower_on", function(value)
    if value then
        Dominant.Bind("jump", RunService.Heartbeat, applyJump)
    else
        Dominant.Unbind("jump")
    end
end)

hook("jumppower", function()
    applyJump()
end)

hook("infinite_jump", function(value)
    if value then
        Dominant.Bind("infjump", UserInputService.JumpRequest, function()
            local humanoid = Dominant.State.Humanoid
            if humanoid and Dominant.Cfg.infinite_jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        Dominant.Unbind("infjump")
    end
end)

function Feat.Fly.Stop()
    Dominant.Unbind("fly")
    if Feat.Fly.Velocity then
        Feat.Fly.Velocity:Destroy()
        Feat.Fly.Velocity = nil
    end
    if Feat.Fly.Gyro then
        Feat.Fly.Gyro:Destroy()
        Feat.Fly.Gyro = nil
    end
    local humanoid = Dominant.State.Humanoid
    if humanoid then
        humanoid.PlatformStand = false
    end
end

function Feat.Fly.Start()
    Feat.Fly.Stop()
    local root = Dominant.State.Root
    local humanoid = Dominant.State.Humanoid
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

    Feat.Fly.Velocity = velocity
    Feat.Fly.Gyro = gyro
    humanoid.PlatformStand = true

    Dominant.Bind("fly", RunService.RenderStepped, function()
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
        velocity.Velocity = direction * Dominant.Cfg.fly_speed
        gyro.CFrame = camera.CFrame
    end)
end

hook("fly", function(value)
    if value then
        Feat.Fly.Start()
    else
        Feat.Fly.Stop()
    end
end)

function Feat.Noclip.Restore()
    for part, original in pairs(Feat.Noclip.Changed) do
        if part.Parent then
            part.CanCollide = original
        end
    end
    Feat.Noclip.Changed = {}
end

hook("noclip", function(value)
    if not value then
        Dominant.Unbind("noclip")
        Feat.Noclip.Restore()
        return
    end
    Dominant.Bind("noclip", RunService.Stepped, function()
        local character = Dominant.State.Character
        if not character then
            return
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                if Feat.Noclip.Changed[part] == nil then
                    Feat.Noclip.Changed[part] = true
                end
                part.CanCollide = false
            end
        end
    end)
end)

-- UTILITIES
hook("anti_afk", function(value)
    if value then
        Dominant.Bind("antiafk", LocalPlayer.Idled, function()
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
    else
        Dominant.Unbind("antiafk")
    end
end)

-- AUTOMATION
local function lootStep()
    local root = Dominant.State.Root
    if not root then
        return
    end
    local radius = math.clamp(tonumber(Dominant.Cfg.loot_radius) or 5, 1, 30)
    for _, entry in ipairs(ESP.Scan()) do
        local object = entry.object
        -- loot aura collects currency and keycards, like the Pressure script
        if entry.kind ~= "item" and object.Parent then
            local part = adorneePart(object)
            if part and (part.Position - root.Position).Magnitude <= radius then
                local prompt = object:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    Game.FirePrompt(prompt)
                end
            end
        end
    end
end

hook("loot_aura", function(value)
    if value then
        Dominant.StartLoop("loot", 0.15, lootStep)
    else
        Dominant.StopLoop("loot")
    end
end)

local function instantPrompt(prompt)
    if Dominant.Cfg.instant_prompts and Feat.Prompts.Changed[prompt] == nil and prompt.HoldDuration > 0 then
        Feat.Prompts.Changed[prompt] = prompt.HoldDuration
        prompt.HoldDuration = 0
    end
end

hook("instant_prompts", function(value)
    Dominant.Unbind("prompts")
    if value then
        Dominant.Bind("prompts", ProximityPromptService.PromptShown, instantPrompt)
    else
        for prompt, hold in pairs(Feat.Prompts.Changed) do
            if prompt.Parent then
                prompt.HoldDuration = hold
            end
        end
        Feat.Prompts.Changed = {}
    end
end)

-- VISUALS
hook("esp", function(value)
    if value then
        Dominant.StartLoop("esp", 0.15, ESP.Step)
    else
        Dominant.StopLoop("esp")
        ESP.Clear()
    end
end)

-- WORLD
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

local function applyFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(190, 190, 190)
    Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
end

hook("fullbright", function(value)
    if value then
        if not Feat.Light.FullSaved then
            Feat.Light.FullSaved = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
        end
        Dominant.StartLoop("fullbright", 0.25, applyFullbright)
    else
        Dominant.StopLoop("fullbright")
        restoreProps(Feat.Light.FullSaved)
        Feat.Light.FullSaved = nil
    end
end)

local function applyNoFog()
    Lighting.FogStart = 1e9
    Lighting.FogEnd = 1e9
    for _, atmosphere in ipairs(Lighting:GetChildren()) do
        if atmosphere:IsA("Atmosphere") then
            if Feat.Light.Atmospheres[atmosphere] == nil then
                Feat.Light.Atmospheres[atmosphere] = atmosphere.Density
            end
            atmosphere.Density = 0
        end
    end
end

hook("no_fog", function(value)
    if value then
        if not Feat.Light.FogSaved then
            Feat.Light.FogSaved = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
        end
        Dominant.StartLoop("nofog", 0.5, applyNoFog)
    else
        Dominant.StopLoop("nofog")
        restoreProps(Feat.Light.FogSaved)
        Feat.Light.FogSaved = nil
        for atmosphere, density in pairs(Feat.Light.Atmospheres) do
            pcall(function()
                if atmosphere.Parent then
                    atmosphere.Density = density
                end
            end)
        end
        Feat.Light.Atmospheres = {}
    end
end)

hook("fov_on", function(value)
    if value then
        local camera = workspace.CurrentCamera
        if camera and Feat.Camera.FovSaved == nil then
            Feat.Camera.FovSaved = camera.FieldOfView
        end
        Dominant.Bind("fov", RunService.RenderStepped, function()
            local current = workspace.CurrentCamera
            if current then
                current.FieldOfView = Dominant.Cfg.fov
            end
        end)
    else
        Dominant.Unbind("fov")
        local current = workspace.CurrentCamera
        if current and Feat.Camera.FovSaved then
            current.FieldOfView = Feat.Camera.FovSaved
        end
        Feat.Camera.FovSaved = nil
    end
end)

local function applyThirdPerson()
    local distance = math.max(0.5, tonumber(Dominant.Cfg.third_person_dist) or 10)
    pcall(function()
        LocalPlayer.CameraMaxZoomDistance = distance
        LocalPlayer.CameraMinZoomDistance = distance
    end)
end

hook("third_person", function(value)
    if value then
        if Feat.Camera.ZoomSaved == nil then
            Feat.Camera.ZoomSaved = {
                min = LocalPlayer.CameraMinZoomDistance,
                max = LocalPlayer.CameraMaxZoomDistance,
            }
        end
        applyThirdPerson()
        Dominant.StartLoop("thirdperson", 0.5, applyThirdPerson)
    else
        Dominant.StopLoop("thirdperson")
        local saved = Feat.Camera.ZoomSaved
        if saved then
            pcall(function()
                LocalPlayer.CameraMaxZoomDistance = saved.max
                LocalPlayer.CameraMinZoomDistance = saved.min
            end)
        end
        Feat.Camera.ZoomSaved = nil
    end
end)

hook("third_person_dist", function()
    if Dominant.Cfg.third_person then
        applyThirdPerson()
    end
end)

-- SERVER
function Server.Rejoin()
    Dominant.Notify("Rejoining", "info", 3)
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

function Server.Hop()
    task.spawn(function()
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        local okFetch, body = pcall(function()
            return game:HttpGet(url)
        end)
        local choices = {}
        if okFetch then
            local okDecode, data = pcall(function()
                return HttpService:JSONDecode(body)
            end)
            if okDecode and type(data) == "table" and type(data.data) == "table" then
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers - 1 then
                        table.insert(choices, server.id)
                    end
                end
            end
        end
        if #choices == 0 then
            Dominant.Notify("No other servers found", "warning", 4)
            return
        end
        Dominant.Notify("Joining another server", "info", 3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, choices[math.random(1, #choices)], LocalPlayer)
        end)
    end)
end

hook("auto_rejoin", function(value)
    if value then
        Dominant.Bind("autorejoin", GuiService.ErrorMessageChanged, function(message)
            if message and message ~= "" and not Dominant.State.Unloading then
                Server.Rejoin()
            end
        end)
    else
        Dominant.Unbind("autorejoin")
    end
end)

-- HOTKEYS
function Feat.Hotkeys.Run(hotkey)
    if hotkey == "key_panic" then
        for key, default in pairs(Dominant.Defaults) do
            if type(default) == "boolean" and Dominant.Cfg[key] == true and Dominant.Hooks[key] then
                Dominant.Set(key, false)
            end
        end
        Dominant.Notify("Every feature was turned off", "warning", 2)
        return
    end
    local target = Feat.Hotkeys.Map[hotkey]
    if target then
        Dominant.Set(target, not Dominant.Cfg[target])
    end
end

-- CHARACTER CALLBACKS (re-apply features after respawn)
table.insert(Dominant.CharacterCallbacks, function()
    applyJump()
end)

table.insert(Dominant.CharacterCallbacks, function()
    if Dominant.Cfg.fly then
        task.delay(0.5, Feat.Fly.Start)
    end
end)

-- EXTRA FEATURES (ported from the Pressure script)

local DOOR_NAMES = { NormalDoor = true, BigDoor = true, DoubleDoorSewer = true, DoubleDoor = true, Airlock = true }
local PHASE_DOOR_NAMES = { NormalGatedDoor = true, NormalDoor = true, BigDoor = true, DoubleDoorSewer = true, DoubleDoor = true, LockedDoor = true }
local PANDEMONIUM_NAMES = { Pandemonium = true, Anglemonium = true, Frogermonium = true, Blitzemonium = true, Pandesmoker = true, Pinkimonium = true, RidgePandemonium = true }
local EXIT_DOOR_COLOR = Color3.fromRGB(0, 200, 100)
local LOCKER_COLOR = Color3.fromRGB(0, 255, 0)
local FAKE_DOOR_COLOR = Color3.fromRGB(180, 0, 0)

-- adds a setting to both the defaults (for saving) and the live config
local function addSetting(key, value)
    Dominant.Defaults[key] = value
    Dominant.Cfg[key] = value
end

addSetting("esp_doors", false)
addSetting("esp_lockers", false)
addSetting("esp_fake_doors", false)
addSetting("esp_generators", false)
addSetting("speed_boost_on", false)
addSetting("speed_boost", 0)
addSetting("ghost_players", false)
addSetting("open_sesame", false)
addSetting("entity_alert", false)

-- containers that hold dropped items
function Game.ItemContainers()
    local list = {}
    local rooms = Game.Rooms()
    if rooms then
        table.insert(list, rooms)
    end
    local gameplay = workspace:FindFirstChild("GameplayFolder")
    local dropped = gameplay and gameplay:FindFirstChild("DroppedItems")
    if dropped then
        table.insert(list, dropped)
    end
    local droppedWorkspace = workspace:FindFirstChild("DroppedItems")
    if droppedWorkspace then
        table.insert(list, droppedWorkspace)
    end
    return list
end

-- ROOM ESP: doors, lockers, fake doors and generators, refreshed every 2 seconds
ESP.Extra = {}
ESP.ExtraAt = 0

function ESP.ScanRoomExtras()
    local now = os.clock()
    if now - ESP.ExtraAt < 2 then
        return ESP.Extra
    end
    ESP.ExtraAt = now
    local found = {}
    local rooms = Game.Rooms()
    if rooms then
        for _, object in ipairs(rooms:GetDescendants()) do
            local name = object.Name
            if DOOR_NAMES[name] and object:IsA("BasePart") then
                table.insert(found, { kind = "door", object = object })
            elseif name == "MonsterLocker" then
                table.insert(found, { kind = "locker", object = object })
            elseif name == "Door" and object:IsA("BasePart") and object.Parent and object.Parent.Name == "TricksterDoor" then
                table.insert(found, { kind = "fakedoor", object = object })
            elseif (name == "PresetGenerator" or name == "Generator") and object:IsA("Model") then
                table.insert(found, { kind = "generator", object = object })
            end
        end
    end
    ESP.Extra = found
    return found
end

function ESP.CollectRoomExtras(list)
    local cfg = Dominant.Cfg
    for _, entry in ipairs(ESP.ScanRoomExtras()) do
        local object = entry.object
        if object.Parent then
            if entry.kind == "door" and cfg.esp_doors then
                table.insert(list, { target = object, kind = "door", label = "EXIT DOOR", color = EXIT_DOOR_COLOR })
            elseif entry.kind == "locker" and cfg.esp_lockers then
                table.insert(list, { target = object, kind = "locker", label = "Void Locker", color = LOCKER_COLOR })
            elseif entry.kind == "fakedoor" and cfg.esp_fake_doors then
                table.insert(list, { target = object, kind = "fakedoor", label = "GOOD PEOPLE DOOR", color = FAKE_DOOR_COLOR })
            elseif entry.kind == "generator" and cfg.esp_generators then
                local fixed = object:FindFirstChild("Fixed")
                local value = fixed and fixed.Value
                local pct = 0
                if type(value) == "boolean" then
                    pct = value and 100 or 0
                elseif type(value) == "number" then
                    pct = value
                end
                if pct < 100 then
                    local r = math.floor(255 * (1 - pct / 100))
                    local g = math.floor(255 * (pct / 100))
                    local target = object:FindFirstChild("ProxyPart") or object
                    table.insert(list, {
                        target = target,
                        kind = "generator",
                        label = "Generator " .. tostring(math.floor(pct)) .. "%",
                        color = Color3.fromRGB(r, g, 0),
                    })
                end
            end
        end
    end
end

-- ANTI REMOVALS: sweep the workspace and destroy whatever the matcher returns
Feat.Anti = { Conns = {} }

local function antiDisconnect(key)
    local list = Feat.Anti.Conns[key]
    if list then
        for _, connection in ipairs(list) do
            connection:Disconnect()
        end
    end
    Feat.Anti.Conns[key] = nil
end

local function antiRun(object, matcher)
    if not object.Parent then
        return
    end
    local ok, target = pcall(matcher, object)
    if ok and target and target.Parent then
        pcall(function()
            target:Destroy()
        end)
    end
end

function Feat.Anti.Enable(key, matcher)
    antiDisconnect(key)
    local list = {}
    Feat.Anti.Conns[key] = list
    for _, object in ipairs(workspace:GetDescendants()) do
        antiRun(object, matcher)
    end
    table.insert(list, workspace.DescendantAdded:Connect(function(object)
        task.defer(antiRun, object, matcher)
    end))
end

local function nameSetOf(...)
    local set = {}
    for _, name in ipairs({ ... }) do
        set[name] = true
    end
    return set
end

local function nameMatcher(names)
    return function(object)
        if names[object.Name] then
            return object
        end
        return nil
    end
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local ANTI_LIST = {
    {
        key = "eyefestation", label = "Anti Eyefestation", desc = "Removes Eyefestation hurt and camera effects",
        match = nameMatcher(nameSetOf("EyefestHurt", "EyefestationCameraEffect")),
    },
    {
        key = "pandemonium", label = "Spoof Pandemonium", desc = "Removes Pandemonium monsters",
        match = nameMatcher(PANDEMONIUM_NAMES),
    },
    {
        key = "pipsqueak", label = "Spoof Pipsqueak", desc = "Removes Pipsqueak monsters",
        match = function(object)
            if string.find(object.Name, "Pipsqueak", 1, true) or string.find(object.Name, "Pipsqeuak", 1, true) then
                return object
            end
            return nil
        end,
    },
    {
        key = "a200", label = "Spoof A200", desc = "Removes A200 monsters",
        match = function(object)
            if string.find(object.Name, "A200", 1, true) or string.find(object.Name, "A-200", 1, true) then
                return object
            end
            return nil
        end,
    },
    {
        key = "walldweller", label = "Remove WallDweller", desc = "Removes wall dwellers",
        match = nameMatcher(nameSetOf("WallDweller", "MeatWallDweller", "RottenWallDweller", "DwellerModel")),
    },
    {
        key = "bouncer", label = "Remove Bouncer", desc = "Removes bouncers",
        match = nameMatcher(nameSetOf("Bouncer", "Bouncers")),
    },
    {
        key = "skeletonhead", label = "Remove Skeleton Head", desc = "Removes skeleton heads",
        match = nameMatcher(nameSetOf("SkeletonHead")),
    },
    {
        key = "statue", label = "Remove Statue", desc = "Removes statue heads and roots",
        match = nameMatcher(nameSetOf("StatueRoot", "StatueHead")),
    },
    {
        key = "nogood", label = "Anti NoGood", desc = "Removes NoGood monsters",
        match = nameMatcher(nameSetOf("NoGood")),
    },
    {
        key = "skinless", label = "Remove SkinlessCorpse", desc = "Removes skinless corpses",
        match = nameMatcher(nameSetOf("SkinlessCorpse")),
    },
    {
        key = "cement", label = "Remove Cement Shoes", desc = "Removes cement shoes",
        match = function(object)
            if string.find(object.Name:lower(), "cement", 1, true) then
                return object
            end
            return nil
        end,
    },
    {
        key = "witchinghour", label = "Remove WitchingHour", desc = "Removes WitchingHour monsters",
        match = function(object)
            if object.Name:lower() == "witchinghour" then
                return object
            end
            return nil
        end,
    },
    {
        key = "divine", label = "Anti DiVine", desc = "Removes DiVine roots",
        match = nameMatcher(nameSetOf("DiVine", "DiVineRoot", "Divineroot")),
    },
    {
        key = "searchlights", label = "Remove Searchlights", desc = "Removes searchlights",
        match = nameMatcher(nameSetOf("Searchlights")),
    },
    {
        key = "monsterlocker", label = "Remove Monster Locker", desc = "Removes monster lockers",
        match = nameMatcher(nameSetOf("MonsterLocker")),
    },
    {
        key = "turrets", label = "Remove Turrets", desc = "Removes turrets and turret spawns",
        match = function(object)
            if object.Name == "Turret" or string.match(object.Name, "^TurretSpawn") then
                return object
            end
            return nil
        end,
    },
    {
        key = "tripwires", label = "Remove Tripwires", desc = "Removes tripwires",
        match = nameMatcher(nameSetOf("Tripwire", "TripwireSpawn")),
    },
    {
        key = "landmines", label = "Remove Landmines", desc = "Removes landmines",
        match = nameMatcher(nameSetOf("Landmine", "LandmineSpawn", "DrawerLandmine")),
    },
    {
        key = "squiddles", label = "Anti Squiddles", desc = "Removes squiddles",
        match = function(object)
            if object.Name == "SquiddleBuildup" and object.Parent and object.Parent.Name == "Face" and object.Parent.Parent then
                return object.Parent.Parent
            end
            if object.Name == "Squiddle" or object.Name == "SquiddleBase" then
                return object
            end
            return nil
        end,
    },
    {
        key = "coagulate", label = "Anti Coagulate", desc = "Removes coagulate and coagulant objects",
        match = function(object)
            local current = object
            while current and current ~= workspace and current ~= game do
                local lower = current.Name:lower()
                if string.find(lower, "coagulate", 1, true) or string.find(lower, "coagulant", 1, true) then
                    return current
                end
                current = current.Parent
            end
            return nil
        end,
    },
    {
        key = "edentrees", label = "Remove Edentrees", desc = "Removes Edentrees models",
        match = function(object)
            if object:IsA("Model") and not isPlayerCharacter(object) and string.match(object.Name, "^%l%l%l%l$") and object:FindFirstChild("RootPart") then
                return object
            end
            local parent = object.Parent
            if parent and parent:IsA("Model") and not isPlayerCharacter(parent) and string.match(parent.Name, "^%l%l%l%l$") and parent:FindFirstChild("RootPart") then
                return parent
            end
            return nil
        end,
    },
    {
        key = "damageparts", label = "Remove Damage Parts", desc = "Removes damage parts and electricity",
        match = function(object)
            local lower = object.Name:lower()
            if lower == "damagepart" or lower == "electricity" or lower == "damageparts" then
                return object
            end
            return nil
        end,
    },
    {
        key = "firewall", label = "Remove Firewall", desc = "Removes firewall walls",
        match = nameMatcher(nameSetOf("Firewall")),
    },
}

for _, entry in ipairs(ANTI_LIST) do
    local settingKey = "anti_" .. entry.key
    addSetting(settingKey, false)
    local matcher = entry.match
    hook(settingKey, function(value)
        if value then
            Feat.Anti.Enable(entry.key, matcher)
        else
            antiDisconnect(entry.key)
        end
    end)
end

-- OPEN SESAME: makes room doors non-collidable
Feat.Phase = { Originals = {} }

local function phaseProcess(part)
    if not part:IsA("BasePart") or not PHASE_DOOR_NAMES[part.Name] then
        return
    end
    if Feat.Phase.Originals[part] == nil then
        Feat.Phase.Originals[part] = part.CanCollide
    end
    part.CanCollide = false
end

hook("open_sesame", function(value)
    Dominant.Unbind("phasedoors")
    if value then
        local rooms = Game.Rooms()
        if not rooms then
            Dominant.Notify("Rooms not found yet", "warning", 3)
            return
        end
        for _, object in ipairs(rooms:GetDescendants()) do
            phaseProcess(object)
        end
        Dominant.Bind("phasedoors", rooms.DescendantAdded, function(object)
            task.defer(phaseProcess, object)
        end)
        Dominant.Notify("You can now walk through doors", "info", 4)
    else
        for part, original in pairs(Feat.Phase.Originals) do
            if part.Parent then
                part.CanCollide = original
            end
        end
        Feat.Phase.Originals = {}
    end
end)

function Feat.DoorYeet()
    local root = Dominant.State.Root
    local rooms = Game.Rooms()
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

-- SPEED BOOST
hook("speed_boost_on", function(value)
    if value then
        Dominant.Bind("speedboost", RunService.Heartbeat, function(dt)
            local root = Dominant.State.Root
            local humanoid = Dominant.State.Humanoid
            if not root or not humanoid then
                return
            end
            local boost = tonumber(Dominant.Cfg.speed_boost) or 0
            local move = humanoid.MoveDirection
            if boost > 0 and move.Magnitude > 0 then
                root.CFrame = root.CFrame + move * (boost * 60 * dt / 10)
            end
        end)
    else
        Dominant.Unbind("speedboost")
    end
end)

-- GHOST PLAYERS: other players stop colliding with you
hook("ghost_players", function(value)
    if value then
        Dominant.Bind("ghost", RunService.Stepped, function()
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                local character = otherPlayer.Character
                if otherPlayer ~= LocalPlayer and character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        Dominant.Unbind("ghost")
    end
end)

-- ENTITY ALERT: notifies when a monster spawns
local lastAlert = {}

hook("entity_alert", function(value)
    Dominant.Unbind("entityalert")
    if value then
        Dominant.Bind("entityalert", workspace.ChildAdded, function(child)
            if MONSTERS[child.Name] then
                local now = os.clock()
                if not lastAlert[child.Name] or now - lastAlert[child.Name] > 8 then
                    lastAlert[child.Name] = now
                    Dominant.Notify(child.Name .. " spawned!", "warning", 5)
                end
            end
        end)
    end
end)

-- TELEPORTS AND ANCHOR
Feat.Anchor = nil

local function nearestPlayerRoot(farthest)
    local root = Dominant.State.Root
    if not root then
        return nil
    end
    local best = nil
    local bestDistance = farthest and -math.huge or math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local part = player ~= LocalPlayer and character and character:FindFirstChild("HumanoidRootPart")
        if part then
            local distance = (part.Position - root.Position).Magnitude
            if (farthest and distance > bestDistance) or (not farthest and distance < bestDistance) then
                best = part
                bestDistance = distance
            end
        end
    end
    return best
end

function Feat.TeleportToPlayer(farthest)
    local target = nearestPlayerRoot(farthest)
    local root = Dominant.State.Root
    if not target or not root then
        Dominant.Notify("No player found", "warning", 3)
        return
    end
    root.CFrame = target.CFrame
end

function Feat.DropAnchor()
    local root = Dominant.State.Root
    if root then
        Feat.Anchor = root.CFrame
        Dominant.Notify("Anchor dropped", "success", 3)
    end
end

function Feat.BeamUp()
    local root = Dominant.State.Root
    if not root then
        return
    end
    if not Feat.Anchor then
        Dominant.Notify("No anchor saved", "warning", 3)
        return
    end
    root.CFrame = Feat.Anchor
end

-- INTERFACE HELPERS
local UI = {}

function UI.Load()
    local urls = { CONFIG.VindUrl }
    for _, url in ipairs(urls) do
        if type(url) == "string" and url ~= "" then
            local okFetch, body = pcall(function()
                return game:HttpGet(url)
            end)
            if okFetch and type(body) == "string" and #body >= 100 then
                local ok, library = pcall(function()
                    return loadstring(body)()
                end)
                if ok and type(library) == "table" then
                    pcall(function()
                        library:SetTheme(CONFIG.Theme)
                    end)
                    pcall(function()
                        library:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
                    end)
                    pcall(function()
                        library:SetScaleRange(0.75, 1.35)
                    end)
                    return library
                end
                Dominant.Warn("Failed to run Vind UI from " .. url .. ": " .. tostring(library))
            else
                Dominant.Warn("HttpGet failed for Vind: " .. url)
            end
        end
    end
    return nil
end

function UI.Toggle(tab, key, text, description, icon)
    tab:AddToggle({
        Text = text,
        Description = description,
        Icon = icon,
        Flag = key,
        Default = Dominant.Cfg[key],
        Callback = function(value)
            Dominant.Set(key, value)
        end,
    })
end

function UI.Slider(tab, key, text, minimum, maximum, step, suffix, icon)
    tab:AddSlider({
        Text = text,
        Icon = icon,
        Flag = key,
        Min = minimum,
        Max = maximum,
        Default = Dominant.Cfg[key],
        Increment = step,
        Suffix = suffix,
        Callback = function(value)
            Dominant.Set(key, value)
        end,
    })
end

function UI.Number(tab, key, text, icon, minimum)
    tab:AddTextbox({
        Text = text,
        Icon = icon,
        Placeholder = "Type any number",
        Default = tostring(Dominant.Cfg[key]),
        Callback = function(input)
            local cleaned = (tostring(input or ""):gsub(",", "."):gsub("[^%d%.%-]", ""))
            local value = tonumber(cleaned)
            if value then
                Dominant.Set(key, math.max(minimum or 1, value))
            end
        end,
    })
end

function UI.Color(tab, key, text, icon)
    tab:AddColorPicker({
        Text = text,
        Icon = icon,
        Default = Dominant.Cfg[key],
        Callback = function(color)
            Dominant.Set(key, color)
        end,
    })
end

function UI.Button(tab, text, description, icon, callback)
    tab:AddButton({
        Text = text,
        Description = description,
        Icon = icon,
        Callback = callback,
    })
end

function UI.Keybind(tab, text, icon, currentName, onPress, onChange)
    tab:AddKeybind({
        Text = text,
        Icon = icon,
        Default = keyFromName(currentName),
        Callback = function(key, kind)
            if kind == "press" then
                if onPress then
                    onPress()
                end
            elseif typeof(key) == "EnumItem" then
                if onChange then
                    onChange(key.Name)
                end
            end
        end,
    })
end

-- TABS
function UI.BuildHome(tab)
    tab:AddParagraph({
        Title = CONFIG.Title .. " for Pressure",
        Icon = "Lucide:crown",
        Text = "Automation, ESP and utilities in one interface. Press " .. Dominant.Cfg.menu_key .. " to open or close the menu.",
    })
    tab:AddSection("Status", "Lucide:activity")
    tab:AddParagraph({
        Title = "Executor",
        Icon = "Lucide:cpu",
        Text = Dominant.Executor .. " | files: " .. yesNo(Dominant.Caps.files) .. " | proximity prompts: " .. yesNo(Dominant.Caps.fireproximityprompt),
    })
    tab:AddSection("Credits", "Lucide:heart")
    tab:AddParagraph({
        Title = "Made by",
        Icon = "Lucide:bot",
        Text = "Claude Sonnet 5.5 and Jonathan. Based on the Dominant script for Forsaken.",
    })
end

function UI.BuildPlayer(tab)
    tab:AddSection("Movement", "Lucide:footprints")
    UI.Toggle(tab, "cframe_speed", "CFrame Speed", "Moves you with CFrame, with no upper limit", "Lucide:gauge")
    UI.Number(tab, "cframe_speed_value", "Speed Value", "Lucide:gauge", 1)
    UI.Toggle(tab, "jumppower_on", "Custom Jump Power", "Uses the jump power below", "Lucide:arrow-up")
    UI.Slider(tab, "jumppower", "Jump Power", 0, 200, 5, nil, "Lucide:arrow-up")
    UI.Toggle(tab, "infinite_jump", "Infinite Jump", "Jump again while in the air", "Lucide:chevrons-up")
    UI.Toggle(tab, "noclip", "Noclip", "Walk through walls", "Lucide:ghost")
    UI.Toggle(tab, "fly", "Fly", "Move freely with WASD, Space and Shift", "Lucide:plane")
    UI.Slider(tab, "fly_speed", "Fly Speed", 10, 300, 5, nil, "Lucide:wind")
    tab:AddSection("Utilities", "Lucide:wrench")
    UI.Toggle(tab, "anti_afk", "Anti AFK", "Prevents idle kicks", "Lucide:timer")
    UI.Button(tab, "Reset Character", "Kills your character so it respawns", "Lucide:rotate-ccw", function()
        local humanoid = Dominant.State.Humanoid
        if humanoid then
            humanoid.Health = 0
        end
    end)
end

function UI.BuildAutomation(tab)
    tab:AddSection("Collection", "Lucide:hand")
    UI.Toggle(tab, "loot_aura", "Loot Aura", "Collects currency and keycards within the radius", "Lucide:package")
    UI.Slider(tab, "loot_radius", "Loot Radius", 1, 30, 1, " studs", "Lucide:ruler")
    UI.Toggle(tab, "instant_prompts", "Instant Prompts", "Removes the hold time of prompts", "Lucide:zap")
end

function UI.BuildVisuals(tab)
    tab:AddSection("ESP", "Lucide:eye")
    UI.Toggle(tab, "esp", "Enable ESP", "Master switch for every ESP option", "Lucide:eye")
    UI.Toggle(tab, "esp_monsters", "Monsters", "Highlights monsters in the workspace", "Lucide:skull")
    UI.Toggle(tab, "esp_players", "Players", "Highlights other players", "Lucide:users")
    UI.Toggle(tab, "esp_items", "Items", "Lanterns, medkits, batteries and more", "Lucide:package")
    UI.Toggle(tab, "esp_currency", "Currency", "Cash piles and rare currency", "Lucide:coins")
    UI.Toggle(tab, "esp_keycards", "Keycards", "Keycards and password papers", "Lucide:key-round")
    UI.Toggle(tab, "esp_text", "Name Labels", "Shows the label above each target", "Lucide:type")
    UI.Toggle(tab, "esp_distance", "Show Distance", "Adds the distance in studs to the label", "Lucide:ruler")
    UI.Slider(tab, "esp_max_distance", "Max Distance", 100, 5000, 50, " studs", "Lucide:radar")
    UI.Slider(tab, "esp_fill", "Fill Opacity", 0, 1, 0.05, nil, "Lucide:droplet")
    tab:AddSection("Colors", "Lucide:palette")
    UI.Color(tab, "color_monster", "Monster Color", "Lucide:skull")
    UI.Color(tab, "color_player", "Player Color", "Lucide:users")
end

function UI.BuildWorld(tab)
    tab:AddSection("Lighting", "Lucide:sun")
    UI.Toggle(tab, "fullbright", "Fullbright", "Removes darkness from the map", "Lucide:sun")
    UI.Toggle(tab, "no_fog", "Remove Fog", "Clears fog and atmosphere density", "Lucide:cloud")
    tab:AddSection("Camera", "Lucide:camera")
    UI.Toggle(tab, "fov_on", "Custom FOV", "Uses the field of view below", "Lucide:scan")
    UI.Slider(tab, "fov", "Field Of View", 40, 120, 1, nil, "Lucide:scan")
    UI.Toggle(tab, "third_person", "Third Person", "Raises the minimum zoom so the camera stays behind you", "Lucide:camera")
    UI.Slider(tab, "third_person_dist", "Camera Distance", 2, 60, 1, " studs", "Lucide:ruler")
end

function UI.BuildMisc(tab)
    tab:AddSection("Server", "Lucide:server")
    UI.Button(tab, "Rejoin Server", "Rejoins the same server", "Lucide:refresh-cw", function()
        Server.Rejoin()
    end)
    UI.Button(tab, "Server Hop", "Joins another public server", "Lucide:log-out", function()
        Server.Hop()
    end)
    UI.Toggle(tab, "auto_rejoin", "Auto Rejoin On Kick", "Rejoins the same server after a kick", "Lucide:power")
    tab:AddSection("Clipboard", "Lucide:copy")
    UI.Button(tab, "Copy Job ID", "Copies the current server Job ID", "Lucide:copy", function()
        Dominant.Copy(game.JobId)
    end)
    UI.Button(tab, "Copy Join Script", "Copies a script that joins this server", "Lucide:copy", function()
        Dominant.Copy(string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)", game.PlaceId, game.JobId))
    end)
end

function UI.BuildSettings(tab)
    tab:AddSection("Interface", "Lucide:keyboard")
    UI.Keybind(tab, "Menu Key", "Lucide:keyboard", Dominant.Cfg.menu_key, function()
        if Dominant.Window then
            Dominant.Window:Toggle()
        end
    end, function(name)
        Dominant.Set("menu_key", name)
    end)
    UI.Toggle(tab, "notifications", "Notifications", "Shows popup messages", "Lucide:bell")

    tab:AddSection("Hotkeys", "Lucide:keyboard")
    UI.Keybind(tab, "Fly Hotkey", "Lucide:plane", Dominant.Cfg.key_fly, function()
        Feat.Hotkeys.Run("key_fly")
    end, function(name)
        Dominant.Set("key_fly", name)
    end)
    UI.Keybind(tab, "Noclip Hotkey", "Lucide:ghost", Dominant.Cfg.key_noclip, function()
        Feat.Hotkeys.Run("key_noclip")
    end, function(name)
        Dominant.Set("key_noclip", name)
    end)
    UI.Keybind(tab, "ESP Hotkey", "Lucide:eye", Dominant.Cfg.key_esp, function()
        Feat.Hotkeys.Run("key_esp")
    end, function(name)
        Dominant.Set("key_esp", name)
    end)
    UI.Keybind(tab, "Panic Key", "Lucide:octagon-x", Dominant.Cfg.key_panic, function()
        Feat.Hotkeys.Run("key_panic")
    end, function(name)
        Dominant.Set("key_panic", name)
    end)

    tab:AddSection("Configuration", "Lucide:save")
    UI.Button(tab, "Save Settings", "Saves every option to the session file", "Lucide:save", function()
        local ok = Dominant.SaveSession()
        Dominant.Notify(ok and "Settings saved" or "Could not save settings", ok and "success" or "error", 3)
    end)
    UI.Button(tab, "Load Settings", "Loads the saved session file", "Lucide:folder-open", function()
        if Dominant.LoadSession() then
            Dominant.ApplyAll()
            Dominant.Notify("Settings loaded", "success", 3)
        else
            Dominant.Notify("No saved settings found", "warning", 3)
        end
    end)
    UI.Button(tab, "Reset Settings", "Every option goes back to its default value", "Lucide:refresh-cw", function()
        Dominant.Reset()
        Dominant.ApplyAll()
        Dominant.SaveSession()
        Dominant.Notify("Settings reset", "info", 3)
    end)
    UI.Button(tab, "Unload Dominant", "Removes the interface and every feature", "Lucide:power", function()
        Dominant.Unload()
    end)
end

function UI.BuildMove(tab)
    tab:AddSection("Speed Boost", "Lucide:zap")
    UI.Toggle(tab, "speed_boost_on", "Enable Speed Boost", "Adds extra speed while you move", "Lucide:zap")
    UI.Slider(tab, "speed_boost", "Speed Boost Amount", 0, 20, 0.25, " boost", "Lucide:gauge")
    tab:AddSection("Collision", "Lucide:ghost")
    UI.Toggle(tab, "ghost_players", "Ghost Players", "Other players stop colliding with you", "Lucide:users")
    tab:AddSection("Teleports", "Lucide:navigation")
    UI.Button(tab, "Teleport To Nearest Player", "Teleports you next to the nearest player", "Lucide:navigation", function()
        Feat.TeleportToPlayer(false)
    end)
    UI.Button(tab, "Teleport To Farthest Player", "Teleports you next to the farthest player", "Lucide:navigation", function()
        Feat.TeleportToPlayer(true)
    end)
    UI.Button(tab, "Drop Anchor", "Saves your current position", "Lucide:anchor", function()
        Feat.DropAnchor()
    end)
    UI.Button(tab, "Beam Me Up", "Returns you to the saved anchor", "Lucide:arrow-up-from-line", function()
        Feat.BeamUp()
    end)
end

function UI.BuildAutomationExtra(tab)
    tab:AddSection("Doors", "Lucide:door-open")
    UI.Toggle(tab, "open_sesame", "Open Sesame", "Walk straight through room doors", "Lucide:door-open")
    UI.Button(tab, "Door YEET", "Removes doors within 10 studs", "Lucide:door-closed", function()
        Feat.DoorYeet()
    end)
    tab:AddSection("Alerts", "Lucide:bell")
    UI.Toggle(tab, "entity_alert", "Entity Alert", "Notifies you when a monster spawns", "Lucide:triangle-alert")
end

function UI.BuildVisualsExtra(tab)
    tab:AddSection("Room ESP", "Lucide:door-open")
    UI.Toggle(tab, "esp_doors", "Exit Doors", "Highlights exit doors", "Lucide:door-open")
    UI.Toggle(tab, "esp_lockers", "Void Lockers", "Highlights monster lockers", "Lucide:lock")
    UI.Toggle(tab, "esp_fake_doors", "Good People Doors", "Highlights the fake doors", "Lucide:door-closed")
    UI.Toggle(tab, "esp_generators", "Generators", "Shows generator progress by color", "Lucide:cog")
end

function UI.BuildAnti(tab)
    tab:AddSection("Monsters, Spawns and Encounters", "Lucide:shield")
    for _, entry in ipairs(ANTI_LIST) do
        UI.Toggle(tab, "anti_" .. entry.key, entry.label, entry.desc, "Lucide:shield")
    end
end

function UI.Build()
    local library = UI.Load()
    if not library then
        Dominant.Warn("Vind UI could not be loaded")
        return false
    end
    Dominant.Vind = library
    if type(library.CreateWindow) ~= "function" then
        Dominant.Warn("Vind has no CreateWindow")
        return false
    end

    local okWindow, Window = pcall(function()
        return library:CreateWindow({
            Title = CONFIG.Title,
            Subtitle = CONFIG.Description .. " · v" .. CONFIG.Version,
            Icon = CONFIG.Logo,
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
    if not okWindow or type(Window) ~= "table" then
        Dominant.Warn("CreateWindow failed: " .. tostring(Window))
        return false
    end
    Dominant.Window = Window

    local home = Window:AddTab({ Name = "Home", Icon = "Lucide:house" })
    local player = Window:AddTab({ Name = "Player", Icon = "Lucide:user" })
    local automation = Window:AddTab({ Name = "Automation", Icon = "Lucide:bot" })
    local visuals = Window:AddTab({ Name = "Visuals", Icon = "Lucide:eye" })
    local world = Window:AddTab({ Name = "World", Icon = "Lucide:map" })
    local misc = Window:AddTab({ Name = "Misc", Icon = "Lucide:wrench" })
    local anti = Window:AddTab({ Name = "Anti", Icon = "Lucide:shield" })
    local settings = Window:AddTab({ Name = "Settings", Icon = "Lucide:settings" })

    UI.BuildHome(home)
    UI.BuildPlayer(player)
    UI.BuildAutomation(automation)
    UI.BuildVisuals(visuals)
    UI.BuildWorld(world)
    UI.BuildMisc(misc)
    UI.BuildMove(player)
    UI.BuildAutomationExtra(automation)
    UI.BuildVisualsExtra(visuals)
    UI.BuildAnti(anti)
    UI.BuildSettings(settings)
    return true
end

-- LIFECYCLE
function Dominant.Unload()
    if Dominant.State.Unloading then
        return
    end
    Dominant.Notify("Dominant unloaded", "info", 3)
    Dominant.State.Unloading = true

    for key, default in pairs(Dominant.Defaults) do
        if type(default) == "boolean" and Dominant.Hooks[key] then
            pcall(Dominant.Hooks[key], false)
        end
    end
    for name in pairs(Dominant.Loops) do
        Dominant.Loops[name] = nil
    end
    for name, object in pairs(Dominant.Objects) do
        if typeof(object) == "RBXScriptConnection" then
            object:Disconnect()
        end
        Dominant.Objects[name] = nil
    end
    pcall(ESP.Clear)
    pcall(Feat.Fly.Stop)
    pcall(Feat.Noclip.Restore)

    if Dominant.Vind and type(Dominant.Vind.Unload) == "function" then
        pcall(function()
            Dominant.Vind:Unload()
        end)
    end

    local env = type(getgenv) == "function" and getgenv() or _G
    if env.DominantPressureInstance == Dominant then
        env.DominantPressureInstance = nil
    end
    Dominant.Window = nil
    Dominant.Vind = nil
end

function Dominant.Start()
    if Dominant.State.Loaded then
        return
    end
    Dominant.State.Loaded = true
    local ok, built = pcall(UI.Build)
    if not ok or built ~= true then
        Dominant.Status("Interface failed to build, features will still run")
    end
    Dominant.ApplyAll()
    Dominant.Notify("Dominant loaded. Press " .. Dominant.Cfg.menu_key .. " to toggle the menu.", "success", 5)
end

function Dominant.Launch()
    local env = type(getgenv) == "function" and getgenv() or _G

    if env.DominantSkipKey == true then
        Dominant.Start()
        return
    end

    Dominant.Status("Loading key system")
    local okLoad, Ophyn = pcall(function()
        return loadstring(game:HttpGet(CONFIG.OphynUrl))()
    end)
    if not okLoad or type(Ophyn) ~= "table" then
        Dominant.Status("Key system unavailable, starting without it")
        Dominant.Start()
        return
    end

    local supported = {}
    for _, id in ipairs(CONFIG.SupportedGames) do
        supported[id] = true
    end
    supported[game.GameId] = true
    supported[game.PlaceId] = true

    local logos = { CONFIG.Logo, "rbxassetid://111673746737789", false }
    for index, logo in ipairs(logos) do
        local attempt, attemptErr = pcall(function()
            Ophyn.new({
                Title = CONFIG.Title,
                Description = CONFIG.Description,
                Logo = logo or nil,
                Theme = CONFIG.Theme,
                Folder = CONFIG.Folder,
                getkey = false,
                Intro = "true",
                startintro_size = 80,
                squareintro_time = 1.2,
                Changelogocolor = true,
                Changeiconscolor = true,
                NotifStyle = "1",
                discord_link = CONFIG.Discord,
                website_link = CONFIG.Website,
                Discord = "false",
                Website = "true",
                SupportedGames = supported,
                KeySystem = {
                    Key = CONFIG.Keys,
                    SaveKey = CONFIG.SaveKey,
                },
                Callback = function()
                    Dominant.Start()
                end,
            })
        end)
        if attempt then
            Dominant.Status("Key system opened")
            return
        end
        Dominant.Status("Key system attempt " .. index .. " failed: " .. tostring(attemptErr))
    end

    Dominant.Status("Key system failed, starting without it")
    Dominant.Start()
end

-- ONE INSTANCE AT A TIME
do
    local env = type(getgenv) == "function" and getgenv() or _G
    local previous = env.DominantPressureInstance
    if previous and previous ~= Dominant and type(previous.Unload) == "function" then
        pcall(previous.Unload)
        task.wait(0.3)
    end
    env.DominantPressureInstance = Dominant
end

Dominant.LoadSession()
if Dominant.Cfg.menu_key == nil then
    Dominant.Cfg.menu_key = "RightShift"
end

if LocalPlayer.Character then
    task.spawn(onCharacterAdded, LocalPlayer.Character)
end

Dominant.Launch()
