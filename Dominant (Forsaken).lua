--[[
    Dominant for Forsaken
    Made by Claude Sonnet 5.5 & Jonathan
    Features merged from Goonsaken Hub and Forsaken Plus (Naiko Scripts)
]]

local CONFIG = {
    Title = "Dominant",
    Description = "Forsaken Premium Script",
    Logo = "rbxassetid://116590139091461",
    Theme = "Dark",
    Folder = "Dominant",
    Keys = { "dominant","arroganthi","1234" },
    SaveKey = false,
    VindUrl = "https://raw.githubusercontent.com/Skinny-yz/vindUI-Test/main/full.luau",
    VindFallbackUrl = "https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/refs/heads/main/vind-ui/vind-ui.lua",
    OphynUrl = "https://ophyn.space/interface",
    Discord = "discord.gg/yourcode",
    Website = "https://example.com",
    SupportedGames = { 6331902150, 7464167604, 18687417158, 83645629621104 },
    Authors = { "Claude Sonnet 5.5", "Jonathan" },
    Version = "1.9.4",
    LoaderUrl = "",
    SettingsFile = "Dominant/session.json",
    DefaultLanguage = "en",
    MenuKey = Enum.KeyCode.RightShift,
}

local Svc = setmetatable({}, {
    __index = function(self, name)
        local ok, service = pcall(game.GetService, game, name)
        if ok then
            rawset(self, name, service)
            return service
        end
        return nil
    end,
})

local Players = Svc.Players
local RunService = Svc.RunService
local LocalPlayer = Players.LocalPlayer

local Dominant = {
    Version = CONFIG.Version,
    Cfg = {},
    Defaults = {},
    Hooks = {},
    Loops = {},
    Conns = {},
    Objects = {},
    Strings = {},
    Lang = CONFIG.DefaultLanguage,
    Feat = {},
    UI = {},
    State = {
        Loaded = false,
        Unloading = false,
        Character = nil,
        Humanoid = nil,
        Root = nil,
        Animator = nil,
        LastSave = 0,
        SavePending = false,
    },
    Cache = {
        Generators = {},
        Items = {},
        LastScan = 0,
    },
}

Dominant.Languages = {
    { Code = "en", Name = "English" },
    { Code = "pt", Name = "Português" },
    { Code = "es", Name = "Español" },
    { Code = "ru", Name = "Русский" },
}

local function hasFileApi()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolder(path)
    if type(isfolder) == "function" and type(makefolder) == "function" then
        local ok = pcall(function()
            if not isfolder(path) then
                makefolder(path)
            end
        end)
        return ok
    end
    return false
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

Dominant.Defaults = {
    block_range_esp = false,
    color_block_ring = Color3.fromRGB(0, 200, 255),
    key_fly = "Unknown",
    key_noclip = "Unknown",
    key_esp = "Unknown",
    key_cframe = "Unknown",
    key_invisible = "Unknown",
    key_panic = "Unknown",
    guest_skip_special = false,
    auto_parry = false,
    no_fall = false,
    esp_pallets = false,
    esp_windows = false,
    esp_chests = false,
    color_pallet = Color3.fromRGB(200, 150, 255),
    color_window = Color3.fromRGB(150, 220, 255),
    color_chest = Color3.fromRGB(255, 180, 0),
    guest_abh = 0,
    drag_block = false,
    drag_stop = 3,
    drag_hold = 0.2,
    sprint_speed_on = false,
    sprint_speed = 26,
    stamina_custom = false,
    stamina_max = 100,
    stamina_regen = 20,
    stamina_drain = 15,
    gen_all = false,
    gen_all_interval = 1.5,
    gen_all_reset = false,
    guest_punch_wait = 0.08,
    guest_wallcheck = false,
    timed_hop = false,
    timed_hop_minutes = 10,
    language = CONFIG.DefaultLanguage,
    notifications = true,
    menu_key = "RightShift",
    key_fly = "Unknown",
    key_noclip = "Unknown",
    key_esp = "Unknown",
    key_cframe = "Unknown",
    key_invisible = "Unknown",
    key_panic = "Unknown",

    cframe_speed = false,
    cframe_speed_value = 50,
    always_sprint = false,
    spectate_killer = false,
    item_ring = false,
    ring_radius = 12,
    ring_speed = 1.5,
    click_tp = false,
    killer_alert = false,
    alert_range = 60,
    void_rush_speed = 60,
    void_rush_steer = true,
    jumppower_on = false,
    jumppower = 50,
    infinite_jump = false,
    noclip = false,
    fly = false,
    fly_speed = 60,
    anti_slow = false,
    infinite_stamina = false,
    anim_changer = "Original",
    enable_jumping = false,
    invisible = false,
    invincible = false,
    void_rush_control = false,
    controllable_dash = false,
    anti_afk = true,
    spin = false,
    spin_speed = 20,

    auto_gen = false,
    gen_cooldown = 4,
    gen_speedup = false,
    gen_override_grid = false,
    gen_grid = 6,
    auto_gen_remote = false,
    gen_loop_delay = 2.5,
    auto_pickup = false,
    pickup_range = 12,
    auto_escape = false,
    escape_cooldown = 0.5,
    auto_disarm = false,
    auto_popups = false,
    instant_prompts = false,

    guest_block = false,
    guest_block_range = 18,
    guest_strict_range = false,
    guest_facing = "Loose",
    guest_facing_check = true,
    guest_block_tp = false,
    guest_predictive = false,
    guest_predict_range = 10,
    guest_edge_delay = 3,
    guest_auto_punch = false,
    guest_charge_speed_on = false,
    guest_charge_speed = 2.833,
    guest_fling_punch = false,
    guest_fling_power = 10000,
    guest_punch_aim = false,
    guest_punch_prediction = 4,
    chance_aimbot = false,
    chance_prediction = 0.2,
    hitbox_mod = false,
    hitbox_range = 120,

    esp = false,
    esp_killers = true,
    esp_survivors = true,
    esp_generators = true,
    esp_items = true,
    esp_traps = true,
    esp_text = true,
    esp_distance = true,
    esp_health = true,
    esp_hide_done = false,
    esp_max_distance = 2500,
    esp_fill = 0.6,
    color_killer = Color3.fromRGB(255, 50, 50),
    color_survivor = Color3.fromRGB(60, 255, 120),
    color_generator = Color3.fromRGB(255, 230, 60),
    color_item = Color3.fromRGB(70, 170, 255),
    color_trap = Color3.fromRGB(255, 120, 40),
    color_fake = Color3.fromRGB(255, 165, 0),
    color_support = Color3.fromRGB(180, 0, 0),
    esp_support = true,
    esp_fake = true,
    esp_tracers = false,
    esp_tracer_origin = "Bottom",
    esp_tracer_thickness = 1.5,
    esp_outline_only = false,
    esp_text_size = 14,
    fov_on = false,
    fov = 90,
    zoom_on = false,
    zoom = 100,
    fullbright = false,
    no_fog = false,
    hide_injury = false,
    disable_blindness = false,
    show_chat = false,
    name_protect = false,
    stats_tracker = false,
    delete_ragdolls = false,

    kill_walls = false,
    no_trails = false,
    no_footprints = false,
    small_spikes = false,

    goon = false,
    laydown = false,
    custom_block_on = false,
    custom_block_id = "",
    custom_punch_on = false,
    custom_punch_id = "",
    custom_charge_on = false,
    custom_charge_id = "",
    sound_volume = 5,
    lms_song = "Burnout",

    auto_rejoin = true,
    fps_cap_on = false,
    fps_cap = 144,
    performance_mode = false,
    hud = false,

    bg_enabled = false,
    bg_path = "",
    bg_transparency = 0.45,
    bg_scale = "Crop",
    bg_window_transparency = 0.35,
}

function Dominant.Reset()
    for key, value in pairs(Dominant.Defaults) do
        Dominant.Cfg[key] = value
    end
end

Dominant.Reset()

function Dominant.Load()
    if not hasFileApi() then
        return false
    end
    local ok, raw = pcall(function()
        if isfile(CONFIG.SettingsFile) then
            return readfile(CONFIG.SettingsFile)
        end
        return nil
    end)
    if not ok or not raw then
        return false
    end
    local decoded
    ok, decoded = pcall(function()
        return Svc.HttpService:JSONDecode(raw)
    end)
    if not ok or type(decoded) ~= "table" then
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
                if lower == "true" or lower == "1" then
                    Dominant.Cfg[key] = true
                elseif lower == "false" or lower == "0" then
                    Dominant.Cfg[key] = false
                end
            elseif type(default) == "string" and (type(stored) == "string" or type(stored) == "number") then
                Dominant.Cfg[key] = tostring(stored)
            end
        end
    end
    return true
end

function Dominant.SaveNow()
    if not hasFileApi() then
        return false
    end
    ensureFolder("Dominant")
    local out = {}
    for key, value in pairs(Dominant.Cfg) do
        out[key] = encodeValue(value)
    end
    local ok = pcall(function()
        writefile(CONFIG.SettingsFile, Svc.HttpService:JSONEncode(out))
    end)
    Dominant.State.LastSave = os.clock()
    Dominant.State.SavePending = false
    return ok
end

function Dominant.QueueSave(immediate)
    if immediate then
        Dominant.State.SaveToken = (Dominant.State.SaveToken or 0) + 1
        Dominant.State.SavePending = false
        Dominant.SaveNow()
        return
    end
    Dominant.State.SaveToken = (Dominant.State.SaveToken or 0) + 1
    local token = Dominant.State.SaveToken
    Dominant.State.SavePending = true
    task.delay(0.75, function()
        if Dominant.State.SaveToken ~= token then
            return
        end
        Dominant.SaveNow()
    end)
end

Dominant.ConfigFolder = "Dominant"

function Dominant.SanitizeName(text)
    local cleaned = tostring(text or ""):gsub("[^%w _%-]", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
    cleaned = cleaned:sub(1, 32)
    if cleaned == "" then
        cleaned = "default"
    end
    return cleaned
end

function Dominant.ConfigPath(name)
    return Dominant.ConfigFolder .. "/" .. name .. ".json"
end

function Dominant.ConfigExists(name)
    if not hasFileApi() then
        return false
    end
    local ok, exists = pcall(function()
        return isfile(Dominant.ConfigPath(name))
    end)
    return ok and exists == true
end

function Dominant.WriteConfig(name)
    if not hasFileApi() then
        return false
    end
    ensureFolder(Dominant.ConfigFolder)
    local out = {}
    for key, value in pairs(Dominant.Cfg) do
        out[key] = encodeValue(value)
    end
    return (pcall(function()
        writefile(Dominant.ConfigPath(name), Svc.HttpService:JSONEncode(out))
    end))
end

function Dominant.ReadConfig(name)
    if not hasFileApi() or not Dominant.ConfigExists(name) then
        return nil
    end
    local okFile, raw = pcall(function()
        return readfile(Dominant.ConfigPath(name))
    end)
    if not okFile or type(raw) ~= "string" then
        return nil
    end
    local okDecode, decoded = pcall(function()
        return Svc.HttpService:JSONDecode(raw)
    end)
    if okDecode and type(decoded) == "table" then
        return decoded
    end
    return nil
end

function Dominant.ApplyDecoded(decoded)
    if type(decoded) ~= "table" then
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
                Dominant.Cfg[key] = lower == "true" or lower == "1"
            end
        end
    end
    return true
end

function Dominant.ListConfigs()
    local names = {}
    if type(listfiles) == "function" then
        local ok, files = pcall(listfiles, Dominant.ConfigFolder)
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name and name ~= "session" then
                    table.insert(names, name)
                end
            end
        end
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "-")
    end
    return names
end

function Dominant.ReadAutoload()
    if not hasFileApi() then
        return nil
    end
    local path = Dominant.ConfigFolder .. "/autoload.txt"
    local ok, raw = pcall(function()
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    if ok and type(raw) == "string" and raw ~= "" then
        return raw
    end
    return nil
end

function Dominant.SetAutoload(name)
    ensureFolder(Dominant.ConfigFolder)
    return (pcall(function()
        writefile(Dominant.ConfigFolder .. "/autoload.txt", name or "")
    end))
end

function Dominant.LoadAutoload()
    local name = Dominant.ReadAutoload()
    if not name then
        return false
    end
    local decoded = Dominant.ReadConfig(name)
    if decoded then
        Dominant.ApplyDecoded(decoded)
        return true
    end
    return false
end

Dominant.Load()
Dominant.LoadAutoload()
Dominant.Lang = Dominant.Cfg.language or CONFIG.DefaultLanguage

Dominant.Strings.en = {
    tab_home = "Home",
    tab_player = "Player",
    tab_auto = "Automation",
    tab_combat = "Combat",
    tab_visuals = "Visuals",
    tab_world = "World",
    tab_fun = "Fun & Audio",
    tab_misc = "Misc",
    tab_settings = "Settings",

    sub_info = "Information",
    sub_changelog = "Changelog",

    sec_welcome = "Welcome",
    sec_status = "Status",
    sec_movement = "Movement",
    sec_survival = "Survival",
    sec_abilities = "Abilities",
    sec_generators = "Generators",
    sec_helpers = "Helpers",
    sec_guest = "Guest 1337",
    sec_aim = "Aim & Hitbox",
    sec_esp = "ESP",
    sec_colors = "ESP Colors",
    sec_screen = "Camera & Screen",
    sec_privacy = "Privacy & Tracking",
    sec_map = "Map",
    sec_teleports = "Teleports",
    sec_anims = "Animations",
    sec_audio = "Audio",
    sec_server = "Server",
    sec_performance = "Performance",
    sec_language = "Language",
    sec_interface = "Interface",
    sec_config = "Configuration",
    sec_credits = "Credits",

    greet_morning = "Good morning",
    greet_afternoon = "Good afternoon",
    greet_evening = "Good evening",
    greet_night = "Burning the midnight oil",
    home_title = "Dominant for Forsaken",
    home_text = "Automation, combat helpers, ESP and more in one clean interface. Press %s to open or close the menu.",
    home_credits = "Made by Claude Sonnet 5.5 and Jonathan.",
    home_executor = "Executor: %s",
    home_caps = "require: %s | hookmetamethod: %s | files: %s",
    home_yes = "yes",
    home_no = "no",
    log_version = "Dominant 1.0.0",
    log_date = "Initial release",
    log_1 = "Merged Goonsaken Hub and Forsaken Plus features",
    log_2 = "Multi-language interface with live language switching",
    log_3 = "Rebuilt ESP, automation and combat modules",
    log_added = "Added",

    jumppower_on = "Custom Jump Power",
    jumppower = "Jump Power",
    infinite_jump = "Infinite Jump",
    infinite_jump_d = "Jump again while in the air",
    noclip = "Noclip",
    noclip_d = "Walk through walls",
    fly = "Fly",
    fly_d = "Move freely with WASD, Space and Shift",
    fly_speed = "Fly Speed",
    spin = "Spin",
    spin_speed = "Spin Speed",
    anti_slow = "Anti Slowness",
    anti_slow_d = "Removes every slowness effect",
    enable_jumping = "Enable Jumping",
    enable_jumping_d = "Allows jumping when the game disables it",
    invisible = "Invisible",
    invisible_d = "Hides your character from other players",
    invincible = "Invincible",
    invincible_d = "God mode that keeps abilities usable",
    void_rush_control = "Void Rush Control",
    void_rush_control_d = "Steer the Void Rush dash with the camera",
    controllable_dash = "Controllable Dash",
    controllable_dash_d = "Choose where the Coolkidd dash goes",
    anti_afk = "Anti AFK",
    anti_afk_d = "Prevents idle kicks",

    auto_gen = "Auto Generator Puzzles",
    auto_gen_d = "Solves generator puzzles for you",
    gen_cooldown = "Puzzle Delay",
    gen_cooldown_d = "Seconds between completions",
    gen_speedup = "Speed Up When Alone",
    gen_speedup_d = "Faster when nobody is near you",
    gen_override_grid = "Override Grid Size",
    gen_override_grid_d = "Changes the puzzle grid size",
    gen_grid = "Grid Size",
    auto_gen_remote = "Auto Generator (Remote)",
    auto_gen_remote_d = "Fires the nearest unfinished generator in a loop",
    gen_loop_delay = "Remote Delay",
    auto_pickup = "Auto Pickup",
    auto_pickup_d = "Picks up items near you",
    pickup_range = "Pickup Range",
    auto_escape = "Auto Escape Hook",
    auto_escape_d = "Escapes Nosferatu hook prompts",
    escape_cooldown = "Escape Press Delay",
    auto_disarm = "Auto Disarm",
    auto_disarm_d = "Disarms Azure traps instantly",
    auto_popups = "Auto Close 1x1x1x1 Popups",
    instant_prompts = "Instant Prompts",
    instant_prompts_d = "Removes the hold time of prompts",

    guest_block = "Auto Block",
    guest_block_d = "Blocks when a nearby killer starts an attack",
    guest_block_range = "Detection Range",
    guest_strict_range = "Strict Range",
    guest_strict_range_d = "Only blocks inside the detection range",
    guest_facing_check = "Facing Check",
    guest_facing = "Facing Mode",
    guest_block_tp = "Block Teleport",
    guest_block_tp_d = "Teleports in front of the killer after a block",
    guest_predictive = "Predictive Block",
    guest_predictive_d = "Blocks when a killer stays in range",
    guest_predict_range = "Predictive Range",
    guest_edge_delay = "Predictive Delay",
    guest_edge_delay_d = "Seconds before blocking",
    guest_auto_punch = "Auto Punch",
    guest_auto_punch_d = "Punches after a successful block",
    guest_charge_speed_on = "Custom Charge Speed",
    guest_charge_speed = "Charge Speed",
    guest_fling_punch = "Fling Punch",
    guest_fling_punch_d = "Adds force to your punch",
    guest_fling_power = "Fling Power",
    guest_punch_aim = "Punch Aimbot",
    guest_punch_aim_d = "Faces the killer while punching",
    guest_punch_prediction = "Punch Prediction",
    chance_aimbot = "Chance Aimbot",
    chance_aimbot_d = "Aims the flintlock at the killer",
    chance_prediction = "Aim Prediction",
    hitbox_mod = "Hitbox Assist",
    hitbox_mod_d = "Pulls your attacks toward the nearest target",
    hitbox_range = "Hitbox Range",
    opt_loose = "Loose",
    opt_strict = "Strict",

    esp = "Enable ESP",
    esp_d = "Master switch for every ESP option",
    esp_killers = "Killers",
    esp_survivors = "Survivors",
    esp_generators = "Generators",
    esp_items = "Items",
    esp_traps = "Traps & Spikes",
    esp_text = "Name Labels",
    esp_distance = "Show Distance",
    esp_health = "Show Health",
    esp_hide_done = "Hide Finished Generators",
    esp_max_distance = "Max Distance",
    esp_fill = "Fill Opacity",
    color_killer = "Killer Color",
    color_survivor = "Survivor Color",
    color_generator = "Generator Color",
    color_item = "Item Color",
    color_trap = "Trap Color",
    esp_generator_label = "Generator %d%%",
    fov_on = "Custom FOV",
    fov = "Field Of View",
    zoom_on = "Extended Zoom",
    zoom = "Max Zoom Distance",
    fullbright = "Fullbright",
    fullbright_d = "Removes darkness from the map",
    no_fog = "Remove Fog",
    hide_injury = "Hide Injury Effects",
    disable_blindness = "Disable Blindness",
    show_chat = "Show Chat",
    name_protect = "Name Protect",
    name_protect_d = "Hides player names in the interface",
    stats_tracker = "Stats Tracker",
    stats_tracker_d = "Shows a live list of players and roles",
    delete_ragdolls = "Delete Ragdolls",
    delete_ragdolls_d = "Removes ragdolls from the map",
    role_killer = "Killer",
    role_survivor = "Survivor",
    role_spectator = "Spectator",
    stats_title = "Players",
    protected_name = "Protected",

    kill_walls = "Disable Killer Walls",
    kill_walls_d = "Lets you pass through thin killer walls",
    no_trails = "Disable John Doe Trails",
    no_footprints = "Disable John Doe Footprints",
    small_spikes = "Smaller Spike Collisions",
    btn_tp_generator = "Teleport To Nearest Generator",
    btn_tp_random_gen = "Teleport To Random Generator",
    btn_tp_item = "Teleport To Nearest Item",
    btn_collect_items = "Collect Nearby Items",

    goon = "Goon Animation",
    laydown = "Lay Down Animation",
    custom_block_on = "Custom Block Animation",
    custom_block_id = "Block Animation ID",
    custom_punch_on = "Custom Punch Animation",
    custom_punch_id = "Punch Animation ID",
    custom_charge_on = "Custom Charge Animation",
    custom_charge_id = "Charge Animation ID",
    anim_id_hint = "Enter an animation ID",
    btn_stop_anims = "Stop All Animations",
    sound_id = "Play Sound By ID",
    sound_id_hint = "Enter a sound ID",
    sound_volume = "Sound Volume",
    lms_song = "LMS Song",
    btn_lms_replace = "Replace LMS Song",
    btn_stop_sound = "Stop Sound",

    auto_rejoin = "Auto Rejoin On Kick",
    auto_rejoin_d = "Rejoins the same server after a kick",
    fps_cap_on = "FPS Cap",
    fps_cap = "FPS Limit",
    performance_mode = "Performance Mode",
    performance_mode_d = "Lowers graphics quality for more FPS",
    hud = "Performance HUD",
    hud_d = "Shows FPS and ping on screen",
    hud_fps = "FPS",
    hud_ping = "Ping",
    btn_rejoin = "Rejoin Server",
    btn_serverhop = "Server Hop",
    btn_copy_jobid = "Copy Job ID",
    btn_copy_join = "Copy Join Script",
    btn_reset_char = "Reset Character",

    language = "Language",
    language_d = "Changes the language of the whole interface",
    notifications = "Notifications",
    menu_key = "Menu Key",
    menu_key_d = "Key that opens and closes the menu",
    btn_save = "Save Settings",
    btn_load = "Load Settings",
    btn_reset = "Reset Settings",
    btn_unload = "Unload Dominant",
    sec_background = "Background",
    bg_enabled = "Enable Background",
    bg_transparency = "Background Transparency",
    bg_browse = "Browse Workspace",
    bg_browse_d = "Open Dominant/Backgrounds folder tree",
    bg_refresh = "Refresh Files",
    bg_clear = "Clear Background",
    bg_apply = "Apply",
    bg_path = "Background Path",
    bg_folder_hint = "Put images in Dominant/Backgrounds",
    bg_no_files = "No images found in Dominant/Backgrounds",
    bg_applied = "Background applied",
    bg_failed = "Failed to load background",
    bg_gif_note = "GIF, PNG, JPG and JPEG are supported",
    bg_scale = "Background Scale",
    bg_window_transparency = "Window Transparency",
    confirm_reset_title = "Reset settings?",
    confirm_reset_text = "Every option goes back to its default value.",
    confirm_unload_title = "Unload Dominant?",
    confirm_unload_text = "The interface and every feature will be removed.",
    credits_line = "Claude Sonnet 5.5 and Jonathan",
    credits_sources = "Based on Goonsaken Hub and Forsaken Plus by Naiko Scripts",

    n_loaded = "Dominant loaded. Press %s to toggle the menu.",
    n_saved = "Settings saved",
    n_save_fail = "Could not save settings",
    n_loaded_cfg = "Settings loaded",
    n_reset = "Settings reset",
    n_lang = "Language changed",
    n_no_gen = "No generator found",
    n_no_item = "No item found",
    n_unsupported = "Not supported by your executor",
    n_copied = "Copied to clipboard",
    n_wrong_game = "This game is not supported",
    n_invincible_fail = "Failed to become invincible",
    n_requires = "Requires %s",
    n_serverhop = "Joining another server",
    n_serverhop_fail = "No other servers found",
    n_lms_ok = "LMS song replaced",
    n_lms_wait = "Waiting for the last survivor theme",
    n_sound_bad = "Invalid sound ID",
    n_rejoining = "Rejoining",
    n_unloaded = "Dominant unloaded",
    n_collected = "Items collected: %d",

    tab_debug = "Debug",
    sec_console = "Debug Console",
    sec_leaderboard = "Live Leaderboard",
    col_player = "Player",
    col_role = "Role",
    col_distance = "Distance",
    col_health = "Health",
    btn_clear_console = "Clear Console",
    btn_dump_state = "Dump State",
    debug_ready = "Debug console ready",
    debug_caps = "Generators: %d | Items: %d | Features on: %d",

    infinite_stamina = "Infinite Stamina",
    infinite_stamina_d = "Sprint without ever running out of stamina",
    esp_support = "Killer Minions",
    esp_fake = "Fake Generators",
    esp_tracers = "Tracers",
    esp_tracers_d = "Draws lines from the screen to every ESP target",
    esp_tracer_origin = "Tracer Origin",
    esp_tracer_thickness = "Tracer Thickness",
    esp_outline_only = "Outline Only",
    esp_text_size = "Label Size",
    color_fake = "Fake Generator Color",
    color_support = "Minion Color",
    opt_bottom = "Bottom",
    opt_center = "Center",
    opt_mouse = "Mouse",
    opt_original = "Original",
    anim_changer = "Animation Changer",
    anim_changer_d = "Replace your idle, walk and run animations with any character or skin",
    sec_animchanger = "Animation Changer",
    esp_fake_label = "Fake Generator",
    log_version2 = "Dominant 1.0.1",
    log_date2 = "Update",
    log_4 = "Stamina is now one simple infinite stamina toggle",
    log_5 = "Animation changer with every character and skin set",
    log_6 = "ESP rebuilt with tracers, minions, fake generators and trap detection",
    log_7 = "Ability remote also supports the newer buffer format",

    cframe_speed = "CFrame Speed",
    cframe_speed_d = "Moves you with CFrame, with no upper limit",
    cframe_speed_value = "Speed Value",
    number_hint = "Type any number, 1 or higher",
    void_rush_speed = "Dash Speed",
    void_rush_steer = "Steer With Camera",
    void_rush_steer_d = "Turns the dash toward your camera or movement keys",
    always_sprint = "Always Sprint",
    always_sprint_d = "Keeps sprinting on without holding the key",
    spectate_killer = "Spectate Killer",
    spectate_killer_d = "Moves your camera to the killer",
    btn_tp_killer = "Teleport To Killer",
    btn_tp_survivor = "Teleport To Nearest Survivor",
    n_no_target = "No target found",
    log_version3 = "Dominant 1.0.2",
    log_date3 = "Update",
    log_8 = "CFrame speed with a text field and no upper limit",
    log_9 = "Void Rush control only acts while dashing, with camera steering and custom speed",
    log_10 = "Always sprint, spectate killer and teleports to players",

    col_money = "Money",
    col_malice = "Malice",
    n_value_set = "%s set to %s",
    log_version4 = "Dominant 1.0.3",
    log_date4 = "Fixes",
    log_11 = "Loops stop and report repeated errors instead of spamming the console",
    log_12 = "Leaderboard shows money and malice when the game exposes them",
    log_13 = "Cached generator and item scans for better FPS",

    sec_hotkeys = "Hotkeys",
    hotkey_fly = "Fly Hotkey",
    hotkey_noclip = "Noclip Hotkey",
    hotkey_esp = "ESP Hotkey",
    hotkey_cframe = "CFrame Speed Hotkey",
    hotkey_invisible = "Invisible Hotkey",
    hotkey_panic = "Panic Key",
    hotkey_panic_d = "Turns every feature off at once",
    state_on = "ON",
    state_off = "OFF",
    n_panic = "Every feature was turned off",
    log_version5 = "Dominant 1.0.4",
    log_date5 = "Update",
    log_14 = "Hotkeys for fly, noclip, ESP, CFrame speed and invisible, plus a panic key",
    log_15 = "Noclip now uses a cached part list for better FPS",

    sec_ring = "Ring & Tools",
    item_ring = "Item Ring",
    item_ring_d = "Orbits nearby items around you",
    ring_radius = "Ring Radius",
    ring_speed = "Ring Speed",
    click_tp = "Ctrl + Click Teleport",
    click_tp_d = "Hold Ctrl and click to teleport",
    killer_alert = "Killer Alert",
    killer_alert_d = "Warns you when a killer gets close",
    alert_range = "Alert Range",
    sec_players = "Players",
    player_select = "Selected Player",
    btn_tp_player = "Teleport To Player",
    btn_spectate_player = "Spectate Player",
    btn_stop_spectate = "Stop Spectating",
    btn_refresh_players = "Refresh Player List",
    n_killer_near = "Killer nearby: %d studs",
}

Dominant.Strings.pt = {
    tab_home = "Início",
    tab_player = "Jogador",
    tab_auto = "Automação",
    tab_combat = "Combate",
    tab_visuals = "Visuais",
    tab_world = "Mundo",
    tab_fun = "Diversão e Áudio",
    tab_misc = "Diversos",
    tab_settings = "Configurações",

    sub_info = "Informações",
    sub_changelog = "Novidades",

    sec_welcome = "Boas-vindas",
    sec_status = "Status",
    sec_movement = "Movimento",
    sec_survival = "Sobrevivência",
    sec_abilities = "Habilidades",
    sec_generators = "Geradores",
    sec_helpers = "Ajudantes",
    sec_guest = "Guest 1337",
    sec_aim = "Mira e Hitbox",
    sec_esp = "ESP",
    sec_colors = "Cores do ESP",
    sec_screen = "Câmera e Tela",
    sec_privacy = "Privacidade e Rastreio",
    sec_map = "Mapa",
    sec_teleports = "Teleportes",
    sec_anims = "Animações",
    sec_audio = "Áudio",
    sec_server = "Servidor",
    sec_performance = "Desempenho",
    sec_language = "Idioma",
    sec_interface = "Interface",
    sec_config = "Configuração",
    sec_credits = "Créditos",

    greet_morning = "Bom dia",
    greet_afternoon = "Boa tarde",
    greet_evening = "Boa noite",
    greet_night = "Virando a madrugada",
    home_title = "Dominant para Forsaken",
    home_text = "Automação, ajudas de combate, ESP e mais em uma interface limpa. Aperte %s para abrir ou fechar o menu.",
    home_credits = "Feito por Claude Sonnet 5.5 e Jonathan.",
    home_executor = "Executor: %s",
    home_caps = "require: %s | hookmetamethod: %s | arquivos: %s",
    home_yes = "sim",
    home_no = "não",
    log_version = "Dominant 1.0.0",
    log_date = "Lançamento inicial",
    log_1 = "Recursos do Goonsaken Hub e do Forsaken Plus reunidos",
    log_2 = "Interface multi-idioma com troca de idioma ao vivo",
    log_3 = "Módulos de ESP, automação e combate refeitos",
    log_added = "Adicionado",

    jumppower_on = "Pulo Personalizado",
    jumppower = "Força do Pulo",
    infinite_jump = "Pulo Infinito",
    infinite_jump_d = "Pule de novo no ar",
    noclip = "Noclip",
    noclip_d = "Atravesse paredes",
    fly = "Voar",
    fly_d = "Mova-se livremente com WASD, Espaço e Shift",
    fly_speed = "Velocidade de Voo",
    spin = "Girar",
    spin_speed = "Velocidade do Giro",
    anti_slow = "Anti Lentidão",
    anti_slow_d = "Remove todos os efeitos de lentidão",
    enable_jumping = "Ativar Pulo",
    enable_jumping_d = "Permite pular quando o jogo desativa",
    invisible = "Invisível",
    invisible_d = "Esconde seu personagem dos outros jogadores",
    invincible = "Invencível",
    invincible_d = "Modo deus que mantém as habilidades usáveis",
    void_rush_control = "Controle do Void Rush",
    void_rush_control_d = "Direcione o dash do Void Rush com a câmera",
    controllable_dash = "Dash Controlável",
    controllable_dash_d = "Escolha para onde vai o dash do Coolkidd",
    anti_afk = "Anti AFK",
    anti_afk_d = "Evita kick por inatividade",

    auto_gen = "Puzzles de Gerador Automáticos",
    auto_gen_d = "Resolve os puzzles dos geradores por você",
    gen_cooldown = "Atraso do Puzzle",
    gen_cooldown_d = "Segundos entre as conclusões",
    gen_speedup = "Acelerar Quando Sozinho",
    gen_speedup_d = "Mais rápido quando ninguém está perto",
    gen_override_grid = "Alterar Tamanho da Grade",
    gen_override_grid_d = "Muda o tamanho da grade do puzzle",
    gen_grid = "Tamanho da Grade",
    auto_gen_remote = "Gerador Automático (Remote)",
    auto_gen_remote_d = "Ativa o gerador não terminado mais próximo em loop",
    gen_loop_delay = "Atraso do Remote",
    auto_pickup = "Coleta Automática",
    auto_pickup_d = "Pega itens perto de você",
    pickup_range = "Alcance da Coleta",
    auto_escape = "Escape Automático do Gancho",
    auto_escape_d = "Escapa do gancho do Nosferatu",
    escape_cooldown = "Atraso do Escape",
    auto_disarm = "Desarmar Automático",
    auto_disarm_d = "Desarma as armadilhas do Azure na hora",
    auto_popups = "Fechar Popups do 1x1x1x1",
    instant_prompts = "Prompts Instantâneos",
    instant_prompts_d = "Remove o tempo de segurar dos prompts",

    guest_block = "Bloqueio Automático",
    guest_block_d = "Bloqueia quando um assassino próximo inicia um ataque",
    guest_block_range = "Alcance de Detecção",
    guest_strict_range = "Alcance Estrito",
    guest_strict_range_d = "Só bloqueia dentro do alcance de detecção",
    guest_facing_check = "Checar Direção",
    guest_facing = "Modo de Direção",
    guest_block_tp = "Teleporte de Bloqueio",
    guest_block_tp_d = "Teleporta na frente do assassino após bloquear",
    guest_predictive = "Bloqueio Preditivo",
    guest_predictive_d = "Bloqueia quando um assassino fica no alcance",
    guest_predict_range = "Alcance Preditivo",
    guest_edge_delay = "Atraso Preditivo",
    guest_edge_delay_d = "Segundos antes de bloquear",
    guest_auto_punch = "Soco Automático",
    guest_auto_punch_d = "Soca depois de um bloqueio bem-sucedido",
    guest_charge_speed_on = "Velocidade de Carga Personalizada",
    guest_charge_speed = "Velocidade de Carga",
    guest_fling_punch = "Soco Arremessador",
    guest_fling_punch_d = "Adiciona força ao seu soco",
    guest_fling_power = "Força do Arremesso",
    guest_punch_aim = "Mira no Soco",
    guest_punch_aim_d = "Vira para o assassino ao socar",
    guest_punch_prediction = "Previsão do Soco",
    chance_aimbot = "Aimbot do Chance",
    chance_aimbot_d = "Mira o mosquete no assassino",
    chance_prediction = "Previsão da Mira",
    hitbox_mod = "Assistência de Hitbox",
    hitbox_mod_d = "Puxa seus ataques para o alvo mais próximo",
    hitbox_range = "Alcance da Hitbox",
    opt_loose = "Flexível",
    opt_strict = "Estrito",

    esp = "Ativar ESP",
    esp_d = "Chave geral de todas as opções de ESP",
    esp_killers = "Assassinos",
    esp_survivors = "Sobreviventes",
    esp_generators = "Geradores",
    esp_items = "Itens",
    esp_traps = "Armadilhas e Espinhos",
    esp_text = "Nomes",
    esp_distance = "Mostrar Distância",
    esp_health = "Mostrar Vida",
    esp_hide_done = "Ocultar Geradores Prontos",
    esp_max_distance = "Distância Máxima",
    esp_fill = "Opacidade do Preenchimento",
    color_killer = "Cor do Assassino",
    color_survivor = "Cor do Sobrevivente",
    color_generator = "Cor do Gerador",
    color_item = "Cor dos Itens",
    color_trap = "Cor das Armadilhas",
    esp_generator_label = "Gerador %d%%",
    fov_on = "FOV Personalizado",
    fov = "Campo de Visão",
    zoom_on = "Zoom Estendido",
    zoom = "Distância Máxima do Zoom",
    fullbright = "Fullbright",
    fullbright_d = "Remove a escuridão do mapa",
    no_fog = "Remover Neblina",
    hide_injury = "Ocultar Efeitos de Ferimento",
    disable_blindness = "Desativar Cegueira",
    show_chat = "Mostrar Chat",
    name_protect = "Proteger Nomes",
    name_protect_d = "Esconde os nomes dos jogadores na interface",
    stats_tracker = "Rastreador de Jogadores",
    stats_tracker_d = "Mostra uma lista ao vivo de jogadores e funções",
    delete_ragdolls = "Apagar Ragdolls",
    delete_ragdolls_d = "Remove os ragdolls do mapa",
    role_killer = "Assassino",
    role_survivor = "Sobrevivente",
    role_spectator = "Espectador",
    stats_title = "Jogadores",
    protected_name = "Protegido",

    kill_walls = "Desativar Paredes do Assassino",
    kill_walls_d = "Permite atravessar as paredes finas do assassino",
    no_trails = "Desativar Rastros do John Doe",
    no_footprints = "Desativar Pegadas do John Doe",
    small_spikes = "Colisão de Espinhos Menor",
    btn_tp_generator = "Teleportar ao Gerador Mais Próximo",
    btn_tp_random_gen = "Teleportar a um Gerador Aleatório",
    btn_tp_item = "Teleportar ao Item Mais Próximo",
    btn_collect_items = "Coletar Itens Próximos",

    goon = "Animação Goon",
    laydown = "Animação de Deitar",
    custom_block_on = "Animação de Bloqueio Personalizada",
    custom_block_id = "ID da Animação de Bloqueio",
    custom_punch_on = "Animação de Soco Personalizada",
    custom_punch_id = "ID da Animação de Soco",
    custom_charge_on = "Animação de Carga Personalizada",
    custom_charge_id = "ID da Animação de Carga",
    anim_id_hint = "Digite um ID de animação",
    btn_stop_anims = "Parar Todas as Animações",
    sound_id = "Tocar Som por ID",
    sound_id_hint = "Digite um ID de som",
    sound_volume = "Volume do Som",
    lms_song = "Música do LMS",
    btn_lms_replace = "Trocar Música do LMS",
    btn_stop_sound = "Parar Som",

    auto_rejoin = "Reentrar Automático ao Ser Kickado",
    auto_rejoin_d = "Volta para o mesmo servidor após um kick",
    fps_cap_on = "Limite de FPS",
    fps_cap = "Limite de FPS",
    performance_mode = "Modo Desempenho",
    performance_mode_d = "Reduz os gráficos para ganhar FPS",
    hud = "HUD de Desempenho",
    hud_d = "Mostra FPS e ping na tela",
    hud_fps = "FPS",
    hud_ping = "Ping",
    btn_rejoin = "Reentrar no Servidor",
    btn_serverhop = "Trocar de Servidor",
    btn_copy_jobid = "Copiar Job ID",
    btn_copy_join = "Copiar Script de Entrada",
    btn_reset_char = "Resetar Personagem",

    language = "Idioma",
    language_d = "Muda o idioma de toda a interface",
    notifications = "Notificações",
    menu_key = "Tecla do Menu",
    menu_key_d = "Tecla que abre e fecha o menu",
    btn_save = "Salvar Configurações",
    btn_load = "Carregar Configurações",
    btn_reset = "Redefinir Configurações",
    btn_unload = "Descarregar Dominant",
    sec_background = "Plano de Fundo",
    bg_enabled = "Ativar Plano de Fundo",
    bg_transparency = "Transparência do Fundo",
    bg_browse = "Explorar Workspace",
    bg_browse_d = "Abrir árvore da pasta Dominant/Backgrounds",
    bg_refresh = "Atualizar Arquivos",
    bg_clear = "Limpar Fundo",
    bg_apply = "Aplicar",
    bg_path = "Caminho do Fundo",
    bg_folder_hint = "Coloque imagens em Dominant/Backgrounds",
    bg_no_files = "Nenhuma imagem em Dominant/Backgrounds",
    bg_applied = "Plano de fundo aplicado",
    bg_failed = "Falha ao carregar o fundo",
    bg_gif_note = "GIF, PNG, JPG e JPEG são suportados",
    bg_scale = "Escala do Fundo",
    bg_window_transparency = "Transparência da Janela",
    confirm_reset_title = "Redefinir configurações?",
    confirm_reset_text = "Todas as opções voltam ao valor padrão.",
    confirm_unload_title = "Descarregar o Dominant?",
    confirm_unload_text = "A interface e todos os recursos serão removidos.",
    credits_line = "Claude Sonnet 5.5 e Jonathan",
    credits_sources = "Baseado no Goonsaken Hub e no Forsaken Plus da Naiko Scripts",

    n_loaded = "Dominant carregado. Aperte %s para abrir o menu.",
    n_saved = "Configurações salvas",
    n_save_fail = "Não foi possível salvar as configurações",
    n_loaded_cfg = "Configurações carregadas",
    n_reset = "Configurações redefinidas",
    n_lang = "Idioma alterado",
    n_no_gen = "Nenhum gerador encontrado",
    n_no_item = "Nenhum item encontrado",
    n_unsupported = "Não suportado pelo seu executor",
    n_copied = "Copiado para a área de transferência",
    n_wrong_game = "Este jogo não é suportado",
    n_invincible_fail = "Falha ao ficar invencível",
    n_requires = "Requer %s",
    n_serverhop = "Entrando em outro servidor",
    n_serverhop_fail = "Nenhum outro servidor encontrado",
    n_lms_ok = "Música do LMS trocada",
    n_lms_wait = "Aguardando o tema do último sobrevivente",
    n_sound_bad = "ID de som inválido",
    n_rejoining = "Reentrando",
    n_unloaded = "Dominant descarregado",
    n_collected = "Itens coletados: %d",

    tab_debug = "Debug",
    sec_console = "Console de Debug",
    sec_leaderboard = "Placar ao Vivo",
    col_player = "Jogador",
    col_role = "Função",
    col_distance = "Distância",
    col_health = "Vida",
    btn_clear_console = "Limpar Console",
    btn_dump_state = "Despejar Estado",
    debug_ready = "Console de debug pronto",
    debug_caps = "Geradores: %d | Itens: %d | Recursos ativos: %d",

    infinite_stamina = "Stamina Infinita",
    infinite_stamina_d = "Corra sem nunca ficar sem stamina",
    esp_support = "Capangas do Assassino",
    esp_fake = "Geradores Falsos",
    esp_tracers = "Tracers",
    esp_tracers_d = "Desenha linhas da tela até cada alvo do ESP",
    esp_tracer_origin = "Origem dos Tracers",
    esp_tracer_thickness = "Espessura dos Tracers",
    esp_outline_only = "Somente Contorno",
    esp_text_size = "Tamanho do Texto",
    color_fake = "Cor do Gerador Falso",
    color_support = "Cor dos Capangas",
    opt_bottom = "Embaixo",
    opt_center = "Centro",
    opt_mouse = "Mouse",
    opt_original = "Original",
    anim_changer = "Trocador de Animação",
    anim_changer_d = "Troca suas animações de parado, andar e correr por as de qualquer personagem ou skin",
    sec_animchanger = "Trocador de Animação",
    esp_fake_label = "Gerador Falso",
    log_version2 = "Dominant 1.0.1",
    log_date2 = "Atualização",
    log_4 = "Stamina agora é só um toggle de stamina infinita",
    log_5 = "Trocador de animação com todos os personagens e skins",
    log_6 = "ESP refeito com tracers, capangas, geradores falsos e detecção de armadilhas",
    log_7 = "O remote de habilidades também suporta o novo formato buffer",

    cframe_speed = "Velocidade CFrame",
    cframe_speed_d = "Move você com CFrame, sem limite máximo",
    cframe_speed_value = "Valor da Velocidade",
    number_hint = "Digite qualquer número, 1 ou mais",
    void_rush_speed = "Velocidade do Dash",
    void_rush_steer = "Direcionar Com a Câmera",
    void_rush_steer_d = "Vira o dash para a câmera ou para as teclas de movimento",
    always_sprint = "Sempre Correr",
    always_sprint_d = "Mantém a corrida ligada sem segurar a tecla",
    spectate_killer = "Assistir Assassino",
    spectate_killer_d = "Leva sua câmera para o assassino",
    btn_tp_killer = "Teleportar ao Assassino",
    btn_tp_survivor = "Teleportar ao Sobrevivente Mais Próximo",
    n_no_target = "Nenhum alvo encontrado",
    log_version3 = "Dominant 1.0.2",
    log_date3 = "Atualização",
    log_8 = "Velocidade CFrame com campo de texto e sem limite máximo",
    log_9 = "Controle do Void Rush só age durante o dash, com direção pela câmera e velocidade ajustável",
    log_10 = "Sempre correr, assistir assassino e teleportes para jogadores",

    col_money = "Dinheiro",
    col_malice = "Malícia",
    n_value_set = "%s definido para %s",
    log_version4 = "Dominant 1.0.3",
    log_date4 = "Correções",
    log_11 = "Loops param e avisam erros repetidos em vez de floodar o console",
    log_12 = "Placar mostra dinheiro e malícia quando o jogo expõe esses valores",
    log_13 = "Buscas de geradores e itens em cache para mais FPS",

    sec_hotkeys = "Atalhos",
    hotkey_fly = "Atalho do Voar",
    hotkey_noclip = "Atalho do Noclip",
    hotkey_esp = "Atalho do ESP",
    hotkey_cframe = "Atalho da Velocidade CFrame",
    hotkey_invisible = "Atalho do Invisível",
    hotkey_panic = "Tecla de Pânico",
    hotkey_panic_d = "Desliga todos os recursos de uma vez",
    state_on = "LIGADO",
    state_off = "DESLIGADO",
    n_panic = "Todos os recursos foram desligados",
    log_version5 = "Dominant 1.0.4",
    log_date5 = "Atualização",
    log_14 = "Atalhos para voar, noclip, ESP, velocidade CFrame e invisível, mais uma tecla de pânico",
    log_15 = "Noclip agora usa uma lista de partes em cache para mais FPS",

    sec_ring = "Anel e Ferramentas",
    item_ring = "Anel de Itens",
    item_ring_d = "Faz os itens próximos girarem em volta de você",
    ring_radius = "Raio do Anel",
    ring_speed = "Velocidade do Anel",
    click_tp = "Teleporte Ctrl + Clique",
    click_tp_d = "Segure Ctrl e clique para teleportar",
    killer_alert = "Alerta de Assassino",
    killer_alert_d = "Avisa quando um assassino chega perto",
    alert_range = "Alcance do Alerta",
    sec_players = "Jogadores",
    player_select = "Jogador Selecionado",
    btn_tp_player = "Teleportar ao Jogador",
    btn_spectate_player = "Assistir Jogador",
    btn_stop_spectate = "Parar de Assistir",
    btn_refresh_players = "Atualizar Lista de Jogadores",
    n_killer_near = "Assassino por perto: %d studs",
}

Dominant.Strings.es = {
    tab_home = "Inicio",
    tab_player = "Jugador",
    tab_auto = "Automatización",
    tab_combat = "Combate",
    tab_visuals = "Visuales",
    tab_world = "Mundo",
    tab_fun = "Diversión y Audio",
    tab_misc = "Varios",
    tab_settings = "Ajustes",

    sub_info = "Información",
    sub_changelog = "Novedades",

    sec_welcome = "Bienvenida",
    sec_status = "Estado",
    sec_movement = "Movimiento",
    sec_survival = "Supervivencia",
    sec_abilities = "Habilidades",
    sec_generators = "Generadores",
    sec_helpers = "Ayudas",
    sec_guest = "Guest 1337",
    sec_aim = "Puntería y Hitbox",
    sec_esp = "ESP",
    sec_colors = "Colores del ESP",
    sec_screen = "Cámara y Pantalla",
    sec_privacy = "Privacidad y Seguimiento",
    sec_map = "Mapa",
    sec_teleports = "Teletransportes",
    sec_anims = "Animaciones",
    sec_audio = "Audio",
    sec_server = "Servidor",
    sec_performance = "Rendimiento",
    sec_language = "Idioma",
    sec_interface = "Interfaz",
    sec_config = "Configuración",
    sec_credits = "Créditos",

    greet_morning = "Buenos días",
    greet_afternoon = "Buenas tardes",
    greet_evening = "Buenas noches",
    greet_night = "Trasnochando",
    home_title = "Dominant para Forsaken",
    home_text = "Automatización, ayudas de combate, ESP y más en una interfaz limpia. Pulsa %s para abrir o cerrar el menú.",
    home_credits = "Hecho por Claude Sonnet 5.5 y Jonathan.",
    home_executor = "Executor: %s",
    home_caps = "require: %s | hookmetamethod: %s | archivos: %s",
    home_yes = "sí",
    home_no = "no",
    log_version = "Dominant 1.0.0",
    log_date = "Lanzamiento inicial",
    log_1 = "Funciones de Goonsaken Hub y Forsaken Plus reunidas",
    log_2 = "Interfaz multi-idioma con cambio de idioma en vivo",
    log_3 = "Módulos de ESP, automatización y combate rehechos",
    log_added = "Añadido",

    jumppower_on = "Salto Personalizado",
    jumppower = "Fuerza de Salto",
    infinite_jump = "Salto Infinito",
    infinite_jump_d = "Salta de nuevo en el aire",
    noclip = "Noclip",
    noclip_d = "Atraviesa las paredes",
    fly = "Volar",
    fly_d = "Muévete libremente con WASD, Espacio y Shift",
    fly_speed = "Velocidad de Vuelo",
    spin = "Girar",
    spin_speed = "Velocidad de Giro",
    anti_slow = "Anti Lentitud",
    anti_slow_d = "Elimina todos los efectos de lentitud",
    enable_jumping = "Activar Salto",
    enable_jumping_d = "Permite saltar cuando el juego lo desactiva",
    invisible = "Invisible",
    invisible_d = "Oculta tu personaje a los demás jugadores",
    invincible = "Invencible",
    invincible_d = "Modo dios que mantiene las habilidades utilizables",
    void_rush_control = "Control de Void Rush",
    void_rush_control_d = "Dirige el dash de Void Rush con la cámara",
    controllable_dash = "Dash Controlable",
    controllable_dash_d = "Elige adónde va el dash de Coolkidd",
    anti_afk = "Anti AFK",
    anti_afk_d = "Evita la expulsión por inactividad",

    auto_gen = "Puzzles de Generador Automáticos",
    auto_gen_d = "Resuelve los puzzles de los generadores por ti",
    gen_cooldown = "Retraso del Puzzle",
    gen_cooldown_d = "Segundos entre finalizaciones",
    gen_speedup = "Acelerar Cuando Estás Solo",
    gen_speedup_d = "Más rápido cuando nadie está cerca",
    gen_override_grid = "Cambiar Tamaño de la Cuadrícula",
    gen_override_grid_d = "Cambia el tamaño de la cuadrícula del puzzle",
    gen_grid = "Tamaño de la Cuadrícula",
    auto_gen_remote = "Generador Automático (Remote)",
    auto_gen_remote_d = "Activa en bucle el generador sin terminar más cercano",
    gen_loop_delay = "Retraso del Remote",
    auto_pickup = "Recogida Automática",
    auto_pickup_d = "Recoge los objetos cercanos",
    pickup_range = "Alcance de Recogida",
    auto_escape = "Escape Automático del Gancho",
    auto_escape_d = "Escapa del gancho de Nosferatu",
    escape_cooldown = "Retraso del Escape",
    auto_disarm = "Desarmar Automático",
    auto_disarm_d = "Desarma al instante las trampas de Azure",
    auto_popups = "Cerrar Popups de 1x1x1x1",
    instant_prompts = "Prompts Instantáneos",
    instant_prompts_d = "Quita el tiempo de mantener de los prompts",

    guest_block = "Bloqueo Automático",
    guest_block_d = "Bloquea cuando un asesino cercano inicia un ataque",
    guest_block_range = "Rango de Detección",
    guest_strict_range = "Rango Estricto",
    guest_strict_range_d = "Solo bloquea dentro del rango de detección",
    guest_facing_check = "Comprobar Dirección",
    guest_facing = "Modo de Dirección",
    guest_block_tp = "Teletransporte de Bloqueo",
    guest_block_tp_d = "Te teletransporta frente al asesino tras bloquear",
    guest_predictive = "Bloqueo Predictivo",
    guest_predictive_d = "Bloquea cuando un asesino permanece en rango",
    guest_predict_range = "Rango Predictivo",
    guest_edge_delay = "Retraso Predictivo",
    guest_edge_delay_d = "Segundos antes de bloquear",
    guest_auto_punch = "Puñetazo Automático",
    guest_auto_punch_d = "Golpea tras un bloqueo exitoso",
    guest_charge_speed_on = "Velocidad de Carga Personalizada",
    guest_charge_speed = "Velocidad de Carga",
    guest_fling_punch = "Puñetazo Lanzador",
    guest_fling_punch_d = "Añade fuerza a tu puñetazo",
    guest_fling_power = "Fuerza de Lanzamiento",
    guest_punch_aim = "Puntería del Puñetazo",
    guest_punch_aim_d = "Se orienta al asesino al golpear",
    guest_punch_prediction = "Predicción del Puñetazo",
    chance_aimbot = "Aimbot de Chance",
    chance_aimbot_d = "Apunta el mosquete al asesino",
    chance_prediction = "Predicción de Puntería",
    hitbox_mod = "Asistencia de Hitbox",
    hitbox_mod_d = "Acerca tus ataques al objetivo más cercano",
    hitbox_range = "Rango de Hitbox",
    opt_loose = "Flexible",
    opt_strict = "Estricto",

    esp = "Activar ESP",
    esp_d = "Interruptor general de todas las opciones de ESP",
    esp_killers = "Asesinos",
    esp_survivors = "Supervivientes",
    esp_generators = "Generadores",
    esp_items = "Objetos",
    esp_traps = "Trampas y Pinchos",
    esp_text = "Nombres",
    esp_distance = "Mostrar Distancia",
    esp_health = "Mostrar Vida",
    esp_hide_done = "Ocultar Generadores Terminados",
    esp_max_distance = "Distancia Máxima",
    esp_fill = "Opacidad del Relleno",
    color_killer = "Color del Asesino",
    color_survivor = "Color del Superviviente",
    color_generator = "Color del Generador",
    color_item = "Color de Objetos",
    color_trap = "Color de Trampas",
    esp_generator_label = "Generador %d%%",
    fov_on = "FOV Personalizado",
    fov = "Campo de Visión",
    zoom_on = "Zoom Extendido",
    zoom = "Distancia Máxima de Zoom",
    fullbright = "Fullbright",
    fullbright_d = "Quita la oscuridad del mapa",
    no_fog = "Quitar Niebla",
    hide_injury = "Ocultar Efectos de Herida",
    disable_blindness = "Desactivar Ceguera",
    show_chat = "Mostrar Chat",
    name_protect = "Proteger Nombres",
    name_protect_d = "Oculta los nombres de jugadores en la interfaz",
    stats_tracker = "Rastreador de Jugadores",
    stats_tracker_d = "Muestra una lista en vivo de jugadores y roles",
    delete_ragdolls = "Borrar Ragdolls",
    delete_ragdolls_d = "Quita los ragdolls del mapa",
    role_killer = "Asesino",
    role_survivor = "Superviviente",
    role_spectator = "Espectador",
    stats_title = "Jugadores",
    protected_name = "Protegido",

    kill_walls = "Desactivar Paredes del Asesino",
    kill_walls_d = "Permite atravesar las paredes finas del asesino",
    no_trails = "Desactivar Rastros de John Doe",
    no_footprints = "Desactivar Huellas de John Doe",
    small_spikes = "Colisión de Pinchos Menor",
    btn_tp_generator = "Ir al Generador Más Cercano",
    btn_tp_random_gen = "Ir a un Generador Aleatorio",
    btn_tp_item = "Ir al Objeto Más Cercano",
    btn_collect_items = "Recoger Objetos Cercanos",

    goon = "Animación Goon",
    laydown = "Animación de Acostarse",
    custom_block_on = "Animación de Bloqueo Personalizada",
    custom_block_id = "ID de Animación de Bloqueo",
    custom_punch_on = "Animación de Puñetazo Personalizada",
    custom_punch_id = "ID de Animación de Puñetazo",
    custom_charge_on = "Animación de Carga Personalizada",
    custom_charge_id = "ID de Animación de Carga",
    anim_id_hint = "Introduce un ID de animación",
    btn_stop_anims = "Detener Todas las Animaciones",
    sound_id = "Reproducir Sonido por ID",
    sound_id_hint = "Introduce un ID de sonido",
    sound_volume = "Volumen del Sonido",
    lms_song = "Canción del LMS",
    btn_lms_replace = "Reemplazar Canción del LMS",
    btn_stop_sound = "Detener Sonido",

    auto_rejoin = "Reconectar Automático al Ser Expulsado",
    auto_rejoin_d = "Vuelve al mismo servidor tras una expulsión",
    fps_cap_on = "Límite de FPS",
    fps_cap = "Límite de FPS",
    performance_mode = "Modo Rendimiento",
    performance_mode_d = "Baja los gráficos para ganar FPS",
    hud = "HUD de Rendimiento",
    hud_d = "Muestra FPS y ping en pantalla",
    hud_fps = "FPS",
    hud_ping = "Ping",
    btn_rejoin = "Reentrar al Servidor",
    btn_serverhop = "Cambiar de Servidor",
    btn_copy_jobid = "Copiar Job ID",
    btn_copy_join = "Copiar Script de Unión",
    btn_reset_char = "Reiniciar Personaje",

    language = "Idioma",
    language_d = "Cambia el idioma de toda la interfaz",
    notifications = "Notificaciones",
    menu_key = "Tecla del Menú",
    menu_key_d = "Tecla que abre y cierra el menú",
    btn_save = "Guardar Ajustes",
    btn_load = "Cargar Ajustes",
    btn_reset = "Restablecer Ajustes",
    btn_unload = "Descargar Dominant",
    sec_background = "Fondo",
    bg_enabled = "Activar Fondo",
    bg_transparency = "Transparencia del Fondo",
    bg_browse = "Explorar Workspace",
    bg_browse_d = "Abrir árbol de Dominant/Backgrounds",
    bg_refresh = "Actualizar Archivos",
    bg_clear = "Quitar Fondo",
    bg_apply = "Aplicar",
    bg_path = "Ruta del Fondo",
    bg_folder_hint = "Pon imágenes en Dominant/Backgrounds",
    bg_no_files = "No hay imágenes en Dominant/Backgrounds",
    bg_applied = "Fondo aplicado",
    bg_failed = "Error al cargar el fondo",
    bg_gif_note = "Se admiten GIF, PNG, JPG y JPEG",
    bg_scale = "Escala del Fondo",
    bg_window_transparency = "Transparencia de la Ventana",
    confirm_reset_title = "¿Restablecer ajustes?",
    confirm_reset_text = "Todas las opciones vuelven a su valor predeterminado.",
    confirm_unload_title = "¿Descargar Dominant?",
    confirm_unload_text = "Se eliminarán la interfaz y todas las funciones.",
    credits_line = "Claude Sonnet 5.5 y Jonathan",
    credits_sources = "Basado en Goonsaken Hub y Forsaken Plus de Naiko Scripts",

    n_loaded = "Dominant cargado. Pulsa %s para abrir el menú.",
    n_saved = "Ajustes guardados",
    n_save_fail = "No se pudieron guardar los ajustes",
    n_loaded_cfg = "Ajustes cargados",
    n_reset = "Ajustes restablecidos",
    n_lang = "Idioma cambiado",
    n_no_gen = "No se encontró ningún generador",
    n_no_item = "No se encontró ningún objeto",
    n_unsupported = "No compatible con tu executor",
    n_copied = "Copiado al portapapeles",
    n_wrong_game = "Este juego no es compatible",
    n_invincible_fail = "No se pudo activar la invencibilidad",
    n_requires = "Requiere %s",
    n_serverhop = "Entrando a otro servidor",
    n_serverhop_fail = "No se encontraron otros servidores",
    n_lms_ok = "Canción del LMS reemplazada",
    n_lms_wait = "Esperando el tema del último superviviente",
    n_sound_bad = "ID de sonido no válido",
    n_rejoining = "Reconectando",
    n_unloaded = "Dominant descargado",
    n_collected = "Objetos recogidos: %d",

    tab_debug = "Debug",
    sec_console = "Consola de Debug",
    sec_leaderboard = "Clasificación en Vivo",
    col_player = "Jugador",
    col_role = "Rol",
    col_distance = "Distancia",
    col_health = "Vida",
    btn_clear_console = "Limpiar Consola",
    btn_dump_state = "Volcar Estado",
    debug_ready = "Consola de debug lista",
    debug_caps = "Generadores: %d | Objetos: %d | Funciones activas: %d",

    infinite_stamina = "Stamina Infinita",
    infinite_stamina_d = "Corre sin quedarte nunca sin stamina",
    esp_support = "Secuaces del Asesino",
    esp_fake = "Generadores Falsos",
    esp_tracers = "Tracers",
    esp_tracers_d = "Dibuja líneas desde la pantalla hasta cada objetivo del ESP",
    esp_tracer_origin = "Origen de los Tracers",
    esp_tracer_thickness = "Grosor de los Tracers",
    esp_outline_only = "Solo Contorno",
    esp_text_size = "Tamaño del Texto",
    color_fake = "Color del Generador Falso",
    color_support = "Color de los Secuaces",
    opt_bottom = "Abajo",
    opt_center = "Centro",
    opt_mouse = "Ratón",
    opt_original = "Original",
    anim_changer = "Cambiador de Animación",
    anim_changer_d = "Sustituye tus animaciones de reposo, caminar y correr por las de cualquier personaje o skin",
    sec_animchanger = "Cambiador de Animación",
    esp_fake_label = "Generador Falso",
    log_version2 = "Dominant 1.0.1",
    log_date2 = "Actualización",
    log_4 = "La stamina ahora es un simple interruptor de stamina infinita",
    log_5 = "Cambiador de animación con todos los personajes y skins",
    log_6 = "ESP rehecho con tracers, secuaces, generadores falsos y detección de trampas",
    log_7 = "El remote de habilidades también admite el nuevo formato buffer",

    cframe_speed = "Velocidad CFrame",
    cframe_speed_d = "Te mueve con CFrame, sin límite máximo",
    cframe_speed_value = "Valor de Velocidad",
    number_hint = "Escribe cualquier número, 1 o más",
    void_rush_speed = "Velocidad del Dash",
    void_rush_steer = "Dirigir Con la Cámara",
    void_rush_steer_d = "Gira el dash hacia la cámara o las teclas de movimiento",
    always_sprint = "Correr Siempre",
    always_sprint_d = "Mantiene el sprint activo sin mantener la tecla",
    spectate_killer = "Observar Asesino",
    spectate_killer_d = "Lleva tu cámara al asesino",
    btn_tp_killer = "Ir al Asesino",
    btn_tp_survivor = "Ir al Superviviente Más Cercano",
    n_no_target = "No se encontró ningún objetivo",
    log_version3 = "Dominant 1.0.2",
    log_date3 = "Actualización",
    log_8 = "Velocidad CFrame con campo de texto y sin límite máximo",
    log_9 = "El control de Void Rush solo actúa durante el dash, con dirección por cámara y velocidad ajustable",
    log_10 = "Correr siempre, observar asesino y teletransportes a jugadores",

    col_money = "Dinero",
    col_malice = "Malicia",
    n_value_set = "%s establecido en %s",
    log_version4 = "Dominant 1.0.3",
    log_date4 = "Correcciones",
    log_11 = "Los bucles se detienen y avisan de errores repetidos en vez de saturar la consola",
    log_12 = "La clasificación muestra dinero y malicia cuando el juego los expone",
    log_13 = "Búsquedas de generadores y objetos en caché para más FPS",

    sec_hotkeys = "Atajos",
    hotkey_fly = "Atajo de Volar",
    hotkey_noclip = "Atajo de Noclip",
    hotkey_esp = "Atajo de ESP",
    hotkey_cframe = "Atajo de Velocidad CFrame",
    hotkey_invisible = "Atajo de Invisible",
    hotkey_panic = "Tecla de Pánico",
    hotkey_panic_d = "Apaga todas las funciones de golpe",
    state_on = "ACTIVADO",
    state_off = "DESACTIVADO",
    n_panic = "Todas las funciones fueron apagadas",
    log_version5 = "Dominant 1.0.4",
    log_date5 = "Actualización",
    log_14 = "Atajos para volar, noclip, ESP, velocidad CFrame e invisible, más una tecla de pánico",
    log_15 = "Noclip ahora usa una lista de partes en caché para más FPS",

    sec_ring = "Anillo y Herramientas",
    item_ring = "Anillo de Objetos",
    item_ring_d = "Hace orbitar los objetos cercanos a tu alrededor",
    ring_radius = "Radio del Anillo",
    ring_speed = "Velocidad del Anillo",
    click_tp = "Teletransporte Ctrl + Clic",
    click_tp_d = "Mantén Ctrl y haz clic para teletransportarte",
    killer_alert = "Alerta de Asesino",
    killer_alert_d = "Te avisa cuando un asesino se acerca",
    alert_range = "Rango de Alerta",
    sec_players = "Jugadores",
    player_select = "Jugador Seleccionado",
    btn_tp_player = "Ir al Jugador",
    btn_spectate_player = "Observar Jugador",
    btn_stop_spectate = "Dejar de Observar",
    btn_refresh_players = "Actualizar Lista de Jugadores",
    n_killer_near = "Asesino cerca: %d studs",
}

Dominant.Strings.ru = {
    tab_home = "Главная",
    tab_player = "Игрок",
    tab_auto = "Автоматизация",
    tab_combat = "Бой",
    tab_visuals = "Визуал",
    tab_world = "Мир",
    tab_fun = "Развлечения и звук",
    tab_misc = "Разное",
    tab_settings = "Настройки",

    sub_info = "Информация",
    sub_changelog = "Список изменений",

    sec_welcome = "Добро пожаловать",
    sec_status = "Статус",
    sec_movement = "Движение",
    sec_survival = "Выживание",
    sec_abilities = "Способности",
    sec_generators = "Генераторы",
    sec_helpers = "Помощники",
    sec_guest = "Guest 1337",
    sec_aim = "Прицел и хитбокс",
    sec_esp = "ESP",
    sec_colors = "Цвета ESP",
    sec_screen = "Камера и экран",
    sec_privacy = "Приватность и слежение",
    sec_map = "Карта",
    sec_teleports = "Телепорты",
    sec_anims = "Анимации",
    sec_audio = "Аудио",
    sec_server = "Сервер",
    sec_performance = "Производительность",
    sec_language = "Язык",
    sec_interface = "Интерфейс",
    sec_config = "Конфигурация",
    sec_credits = "Авторы",

    greet_morning = "Доброе утро",
    greet_afternoon = "Добрый день",
    greet_evening = "Добрый вечер",
    greet_night = "Работаем до поздней ночи",
    home_title = "Dominant для Forsaken",
    home_text = "Автоматизация, помощь в бою, ESP и многое другое в одном аккуратном интерфейсе. Нажмите %s, чтобы открыть или закрыть меню.",
    home_credits = "Создано Claude Sonnet 5.5 и Jonathan.",
    home_executor = "Executor: %s",
    home_caps = "require: %s | hookmetamethod: %s | файлы: %s",
    home_yes = "да",
    home_no = "нет",
    log_version = "Dominant 1.0.0",
    log_date = "Первый выпуск",
    log_1 = "Объединены функции Goonsaken Hub и Forsaken Plus",
    log_2 = "Многоязычный интерфейс с переключением языка на лету",
    log_3 = "Переработаны модули ESP, автоматизации и боя",
    log_added = "Добавлено",

    jumppower_on = "Своя сила прыжка",
    jumppower = "Сила прыжка",
    infinite_jump = "Бесконечный прыжок",
    infinite_jump_d = "Прыгайте снова прямо в воздухе",
    noclip = "Noclip",
    noclip_d = "Проходите сквозь стены",
    fly = "Полёт",
    fly_d = "Свободное движение: WASD, пробел и Shift",
    fly_speed = "Скорость полёта",
    spin = "Вращение",
    spin_speed = "Скорость вращения",
    anti_slow = "Анти-замедление",
    anti_slow_d = "Убирает все эффекты замедления",
    enable_jumping = "Включить прыжки",
    enable_jumping_d = "Разрешает прыгать, когда игра это отключает",
    invisible = "Невидимость",
    invisible_d = "Скрывает вашего персонажа от других игроков",
    invincible = "Неуязвимость",
    invincible_d = "Режим бога, при котором способности работают",
    void_rush_control = "Управление Void Rush",
    void_rush_control_d = "Направляйте рывок Void Rush камерой",
    controllable_dash = "Управляемый рывок",
    controllable_dash_d = "Выбирайте направление рывка Coolkidd",
    anti_afk = "Анти AFK",
    anti_afk_d = "Защита от кика за бездействие",

    auto_gen = "Автопрохождение генераторов",
    auto_gen_d = "Решает головоломки генераторов за вас",
    gen_cooldown = "Задержка головоломки",
    gen_cooldown_d = "Секунды между завершениями",
    gen_speedup = "Ускорение в одиночку",
    gen_speedup_d = "Быстрее, когда рядом никого нет",
    gen_override_grid = "Изменить размер сетки",
    gen_override_grid_d = "Меняет размер сетки головоломки",
    gen_grid = "Размер сетки",
    auto_gen_remote = "Автогенератор (Remote)",
    auto_gen_remote_d = "Циклично активирует ближайший незавершённый генератор",
    gen_loop_delay = "Задержка Remote",
    auto_pickup = "Автоподбор",
    auto_pickup_d = "Подбирает предметы рядом с вами",
    pickup_range = "Радиус подбора",
    auto_escape = "Автопобег с крюка",
    auto_escape_d = "Освобождает от крюка Nosferatu",
    escape_cooldown = "Задержка побега",
    auto_disarm = "Автообезвреживание",
    auto_disarm_d = "Мгновенно обезвреживает ловушки Azure",
    auto_popups = "Закрывать окна 1x1x1x1",
    instant_prompts = "Мгновенные подсказки",
    instant_prompts_d = "Убирает время удержания подсказок",

    guest_block = "Автоблок",
    guest_block_d = "Блокирует, когда ближайший убийца начинает атаку",
    guest_block_range = "Радиус обнаружения",
    guest_strict_range = "Строгий радиус",
    guest_strict_range_d = "Блокирует только в радиусе обнаружения",
    guest_facing_check = "Проверка направления",
    guest_facing = "Режим направления",
    guest_block_tp = "Телепорт после блока",
    guest_block_tp_d = "Телепортирует перед убийцей после блока",
    guest_predictive = "Предиктивный блок",
    guest_predictive_d = "Блокирует, когда убийца долго находится рядом",
    guest_predict_range = "Радиус предикции",
    guest_edge_delay = "Задержка предикции",
    guest_edge_delay_d = "Секунды до блока",
    guest_auto_punch = "Автоудар",
    guest_auto_punch_d = "Бьёт после успешного блока",
    guest_charge_speed_on = "Своя скорость рывка",
    guest_charge_speed = "Скорость рывка",
    guest_fling_punch = "Отбрасывающий удар",
    guest_fling_punch_d = "Добавляет силу вашему удару",
    guest_fling_power = "Сила отбрасывания",
    guest_punch_aim = "Прицел для удара",
    guest_punch_aim_d = "Поворачивает к убийце при ударе",
    guest_punch_prediction = "Упреждение удара",
    chance_aimbot = "Аимбот Chance",
    chance_aimbot_d = "Наводит мушкет на убийцу",
    chance_prediction = "Упреждение прицела",
    hitbox_mod = "Помощь хитбокса",
    hitbox_mod_d = "Притягивает ваши атаки к ближайшей цели",
    hitbox_range = "Радиус хитбокса",
    opt_loose = "Мягкий",
    opt_strict = "Строгий",

    esp = "Включить ESP",
    esp_d = "Главный переключатель всех опций ESP",
    esp_killers = "Убийцы",
    esp_survivors = "Выжившие",
    esp_generators = "Генераторы",
    esp_items = "Предметы",
    esp_traps = "Ловушки и шипы",
    esp_text = "Имена",
    esp_distance = "Показывать дистанцию",
    esp_health = "Показывать здоровье",
    esp_hide_done = "Скрывать готовые генераторы",
    esp_max_distance = "Макс. дистанция",
    esp_fill = "Прозрачность заливки",
    color_killer = "Цвет убийцы",
    color_survivor = "Цвет выжившего",
    color_generator = "Цвет генератора",
    color_item = "Цвет предметов",
    color_trap = "Цвет ловушек",
    esp_generator_label = "Генератор %d%%",
    fov_on = "Свой FOV",
    fov = "Поле зрения",
    zoom_on = "Расширенный зум",
    zoom = "Макс. дистанция зума",
    fullbright = "Fullbright",
    fullbright_d = "Убирает темноту на карте",
    no_fog = "Убрать туман",
    hide_injury = "Скрыть эффекты ранения",
    disable_blindness = "Отключить ослепление",
    show_chat = "Показывать чат",
    name_protect = "Защита имён",
    name_protect_d = "Скрывает имена игроков в интерфейсе",
    stats_tracker = "Список игроков",
    stats_tracker_d = "Показывает список игроков и ролей в реальном времени",
    delete_ragdolls = "Удалять рэгдоллы",
    delete_ragdolls_d = "Убирает рэгдоллы с карты",
    role_killer = "Убийца",
    role_survivor = "Выживший",
    role_spectator = "Наблюдатель",
    stats_title = "Игроки",
    protected_name = "Скрыто",

    kill_walls = "Отключить стены убийцы",
    kill_walls_d = "Позволяет проходить сквозь тонкие стены убийцы",
    no_trails = "Отключить следы John Doe",
    no_footprints = "Отключить отпечатки John Doe",
    small_spikes = "Меньше столкновение шипов",
    btn_tp_generator = "Телепорт к ближайшему генератору",
    btn_tp_random_gen = "Телепорт к случайному генератору",
    btn_tp_item = "Телепорт к ближайшему предмету",
    btn_collect_items = "Собрать ближайшие предметы",

    goon = "Анимация Goon",
    laydown = "Анимация лежания",
    custom_block_on = "Своя анимация блока",
    custom_block_id = "ID анимации блока",
    custom_punch_on = "Своя анимация удара",
    custom_punch_id = "ID анимации удара",
    custom_charge_on = "Своя анимация рывка",
    custom_charge_id = "ID анимации рывка",
    anim_id_hint = "Введите ID анимации",
    btn_stop_anims = "Остановить все анимации",
    sound_id = "Воспроизвести звук по ID",
    sound_id_hint = "Введите ID звука",
    sound_volume = "Громкость звука",
    lms_song = "Песня LMS",
    btn_lms_replace = "Заменить песню LMS",
    btn_stop_sound = "Остановить звук",

    auto_rejoin = "Автовозврат после кика",
    auto_rejoin_d = "Возвращает на тот же сервер после кика",
    fps_cap_on = "Лимит FPS",
    fps_cap = "Значение лимита FPS",
    performance_mode = "Режим производительности",
    performance_mode_d = "Снижает графику ради большего FPS",
    hud = "HUD производительности",
    hud_d = "Показывает FPS и пинг на экране",
    hud_fps = "FPS",
    hud_ping = "Пинг",
    btn_rejoin = "Перезайти на сервер",
    btn_serverhop = "Сменить сервер",
    btn_copy_jobid = "Копировать Job ID",
    btn_copy_join = "Копировать скрипт входа",
    btn_reset_char = "Сбросить персонажа",

    language = "Язык",
    language_d = "Меняет язык всего интерфейса",
    notifications = "Уведомления",
    menu_key = "Клавиша меню",
    menu_key_d = "Клавиша открытия и закрытия меню",
    btn_save = "Сохранить настройки",
    btn_load = "Загрузить настройки",
    btn_reset = "Сбросить настройки",
    btn_unload = "Выгрузить Dominant",
    sec_background = "Фон",
    bg_enabled = "Включить фон",
    bg_transparency = "Прозрачность фона",
    bg_browse = "Обзор Workspace",
    bg_browse_d = "Открыть дерево Dominant/Backgrounds",
    bg_refresh = "Обновить файлы",
    bg_clear = "Убрать фон",
    bg_apply = "Применить",
    bg_path = "Путь фона",
    bg_folder_hint = "Кладите изображения в Dominant/Backgrounds",
    bg_no_files = "Нет изображений в Dominant/Backgrounds",
    bg_applied = "Фон применён",
    bg_failed = "Не удалось загрузить фон",
    bg_gif_note = "Поддерживаются GIF, PNG, JPG и JPEG",
    bg_scale = "Масштаб фона",
    bg_window_transparency = "Прозрачность окна",
    confirm_reset_title = "Сбросить настройки?",
    confirm_reset_text = "Все опции вернутся к значениям по умолчанию.",
    confirm_unload_title = "Выгрузить Dominant?",
    confirm_unload_text = "Интерфейс и все функции будут удалены.",
    credits_line = "Claude Sonnet 5.5 и Jonathan",
    credits_sources = "На основе Goonsaken Hub и Forsaken Plus от Naiko Scripts",

    n_loaded = "Dominant загружен. Нажмите %s, чтобы открыть меню.",
    n_saved = "Настройки сохранены",
    n_save_fail = "Не удалось сохранить настройки",
    n_loaded_cfg = "Настройки загружены",
    n_reset = "Настройки сброшены",
    n_lang = "Язык изменён",
    n_no_gen = "Генератор не найден",
    n_no_item = "Предмет не найден",
    n_unsupported = "Не поддерживается вашим executor",
    n_copied = "Скопировано в буфер обмена",
    n_wrong_game = "Эта игра не поддерживается",
    n_invincible_fail = "Не удалось стать неуязвимым",
    n_requires = "Требуется %s",
    n_serverhop = "Переход на другой сервер",
    n_serverhop_fail = "Другие серверы не найдены",
    n_lms_ok = "Песня LMS заменена",
    n_lms_wait = "Ожидание темы последнего выжившего",
    n_sound_bad = "Неверный ID звука",
    n_rejoining = "Перезаход",
    n_unloaded = "Dominant выгружен",
    n_collected = "Собрано предметов: %d",

    tab_debug = "Отладка",
    sec_console = "Консоль отладки",
    sec_leaderboard = "Таблица игроков",
    col_player = "Игрок",
    col_role = "Роль",
    col_distance = "Дистанция",
    col_health = "Здоровье",
    btn_clear_console = "Очистить консоль",
    btn_dump_state = "Вывести состояние",
    debug_ready = "Консоль отладки готова",
    debug_caps = "Генераторы: %d | Предметы: %d | Включено функций: %d",

    infinite_stamina = "Бесконечная выносливость",
    infinite_stamina_d = "Бегайте, не тратя выносливость",
    esp_support = "Приспешники убийцы",
    esp_fake = "Ложные генераторы",
    esp_tracers = "Трейсеры",
    esp_tracers_d = "Рисует линии от экрана до каждой цели ESP",
    esp_tracer_origin = "Начало трейсеров",
    esp_tracer_thickness = "Толщина трейсеров",
    esp_outline_only = "Только контур",
    esp_text_size = "Размер текста",
    color_fake = "Цвет ложного генератора",
    color_support = "Цвет приспешников",
    opt_bottom = "Снизу",
    opt_center = "Центр",
    opt_mouse = "Курсор",
    opt_original = "Оригинал",
    anim_changer = "Смена анимаций",
    anim_changer_d = "Заменяет анимации покоя, ходьбы и бега анимациями любого персонажа или скина",
    sec_animchanger = "Смена анимаций",
    esp_fake_label = "Ложный генератор",
    log_version2 = "Dominant 1.0.1",
    log_date2 = "Обновление",
    log_4 = "Выносливость теперь один простой переключатель бесконечной выносливости",
    log_5 = "Смена анимаций со всеми персонажами и скинами",
    log_6 = "ESP переработан: трейсеры, приспешники, ложные генераторы и ловушки",
    log_7 = "Remote способностей поддерживает новый формат buffer",

    cframe_speed = "Скорость CFrame",
    cframe_speed_d = "Двигает вас через CFrame, без верхнего предела",
    cframe_speed_value = "Значение скорости",
    number_hint = "Введите любое число от 1",
    void_rush_speed = "Скорость рывка",
    void_rush_steer = "Управление камерой",
    void_rush_steer_d = "Поворачивает рывок к камере или клавишам движения",
    always_sprint = "Всегда бежать",
    always_sprint_d = "Спринт включён без удержания клавиши",
    spectate_killer = "Наблюдать за убийцей",
    spectate_killer_d = "Переносит камеру на убийцу",
    btn_tp_killer = "Телепорт к убийце",
    btn_tp_survivor = "Телепорт к ближайшему выжившему",
    n_no_target = "Цель не найдена",
    log_version3 = "Dominant 1.0.2",
    log_date3 = "Обновление",
    log_8 = "Скорость CFrame с текстовым полем без верхнего предела",
    log_9 = "Управление Void Rush работает только во время рывка: камера и своя скорость",
    log_10 = "Всегда бежать, наблюдение за убийцей и телепорты к игрокам",

    col_money = "Деньги",
    col_malice = "Злоба",
    n_value_set = "%s: %s",
    log_version4 = "Dominant 1.0.3",
    log_date4 = "Исправления",
    log_11 = "Циклы останавливаются и сообщают о повторяющихся ошибках вместо спама в консоли",
    log_12 = "Таблица показывает деньги и злобу, если игра их раскрывает",
    log_13 = "Поиск генераторов и предметов кэшируется для лучшего FPS",

    sec_hotkeys = "Горячие клавиши",
    hotkey_fly = "Клавиша полёта",
    hotkey_noclip = "Клавиша Noclip",
    hotkey_esp = "Клавиша ESP",
    hotkey_cframe = "Клавиша скорости CFrame",
    hotkey_invisible = "Клавиша невидимости",
    hotkey_panic = "Клавиша паники",
    hotkey_panic_d = "Выключает все функции сразу",
    state_on = "ВКЛ",
    state_off = "ВЫКЛ",
    n_panic = "Все функции выключены",
    log_version5 = "Dominant 1.0.4",
    log_date5 = "Обновление",
    log_14 = "Горячие клавиши для полёта, noclip, ESP, скорости CFrame и невидимости, плюс клавиша паники",
    log_15 = "Noclip использует кэш частей для лучшего FPS",

    sec_ring = "Кольцо и инструменты",
    item_ring = "Кольцо предметов",
    item_ring_d = "Заставляет ближайшие предметы вращаться вокруг вас",
    ring_radius = "Радиус кольца",
    ring_speed = "Скорость кольца",
    click_tp = "Телепорт Ctrl + клик",
    click_tp_d = "Удерживайте Ctrl и кликните для телепорта",
    killer_alert = "Оповещение об убийце",
    killer_alert_d = "Предупреждает, когда убийца рядом",
    alert_range = "Радиус оповещения",
    sec_players = "Игроки",
    player_select = "Выбранный игрок",
    btn_tp_player = "Телепорт к игроку",
    btn_spectate_player = "Наблюдать за игроком",
    btn_stop_spectate = "Прекратить наблюдение",
    btn_refresh_players = "Обновить список игроков",
    n_killer_near = "Убийца рядом: %d стадов",
}

local function L(key, ...)
    local pack = Dominant.Strings[Dominant.Lang]
    local text = (pack and pack[key]) or Dominant.Strings.en[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then
            return formatted
        end
    end
    return text
end

Dominant.L = L

Dominant.Caps = {
    hookmetamethod = type(hookmetamethod) == "function",
    newcclosure = type(newcclosure) == "function",
    checkcaller = type(checkcaller) == "function",
    hookfunction = type(hookfunction) == "function",
    firesignal = type(firesignal) == "function",
    fireproximityprompt = type(fireproximityprompt) == "function",
    clipboard = type(setclipboard) == "function" or type(toclipboard) == "function",
    files = hasFileApi(),
    queue = type(queue_on_teleport) == "function" or (type(syn) == "table" and type(syn.queue_on_teleport) == "function"),
    fps = type(setfpscap) == "function",
    require = false,
}

Dominant.Executor = "Unknown"
pcall(function()
    if type(identifyexecutor) == "function" then
        Dominant.Executor = tostring((identifyexecutor()))
    end
end)

Dominant.LogBuffer = {}

function Dominant.Log(text, kind)
    kind = kind or Enum.MessageType.MessageOutput
    table.insert(Dominant.LogBuffer, { text, kind })
    if #Dominant.LogBuffer > 200 then
        table.remove(Dominant.LogBuffer, 1)
    end
    if Dominant.Console then
        pcall(function()
            Dominant.Console:Log(text, kind)
        end)
    end
end

function Dominant.Warn(text)
    warn(text)
    Dominant.Log(text, Enum.MessageType.MessageWarning)
end

function Dominant.DumpState()
    local active = 0
    for key in pairs(Dominant.Hooks) do
        if Dominant.Cfg[key] == true then
            active += 1
        end
    end
    local caps = Dominant.Caps
    local bound = 0
    for name in pairs(Dominant.Objects) do
        if type(name) == "string" and name:sub(1, 6) == "frame_" then
            bound += 1
        end
    end
    Dominant.Log(L("debug_frames", bound, active), Enum.MessageType.MessageInfo)
    Dominant.Log(L("debug_require", tostring(caps.require), tostring(Game.SprintModule() ~= nil)), Enum.MessageType.MessageInfo)
    Dominant.Log(L("home_executor", Dominant.Executor), Enum.MessageType.MessageInfo)
    Dominant.Log(L("home_caps", tostring(caps.require), tostring(caps.hookmetamethod), tostring(caps.files)), Enum.MessageType.MessageInfo)
    Dominant.Log(L("debug_caps", #Dominant.Game.Generators(), #Dominant.Game.Items(), active), Enum.MessageType.MessageInfo)
end

function Dominant.UpdateBoard()
    local board = Dominant.Board
    if not board then
        return
    end
    local root = Dominant.State.Root
    local roles = { killer = L("role_killer"), survivor = L("role_survivor"), spectator = L("role_spectator") }
    local rows = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local role = Dominant.Game.Role(character)
        local part = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        table.insert(rows, {
            name = Dominant.DisplayNameOf(player),
            role = role and roles[role] or "-",
            distance = (root and part) and math.floor((part.Position - root.Position).Magnitude) or 0,
            health = humanoid and math.floor(humanoid.Health) or 0,
            money = Dominant.FormatStat(Dominant.FindStat(player, "money")),
            malice = Dominant.FormatStat(Dominant.FindStat(player, "malice")),
        })
    end
    pcall(function()
        board:SetRows(rows)
    end)
end

function Dominant.Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Dominant.Conns, connection)
    return connection
end

function Dominant.Disconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

function Dominant.Safe(callback, ...)
    local ok, result = pcall(callback, ...)
    if not ok then
        Dominant.Warn("[Dominant] " .. tostring(result))
    end
    return ok, result
end

Dominant.ErrorState = {}

function Dominant.Failed(name, err)
    local state = Dominant.ErrorState[name]
    if not state then
        state = { count = 0, last = 0 }
        Dominant.ErrorState[name] = state
    end
    state.count += 1
    local now = os.clock()
    if now - state.last > 5 then
        state.last = now
        Dominant.Warn("[Dominant:" .. name .. "] " .. tostring(err))
    end
    return state.count
end

function Dominant.Succeeded(name)
    local state = Dominant.ErrorState[name]
    if state and state.count > 0 then
        state.count = 0
    end
end

function Dominant.StartLoop(name, interval, callback)
    Dominant.StopLoop(name)
    local token = {}
    Dominant.Loops[name] = token
    task.spawn(function()
        while Dominant.Loops[name] == token and not Dominant.State.Unloading do
            local ok, err = pcall(callback)
            if ok then
                Dominant.Succeeded(name)
            elseif Dominant.Failed(name, err) >= 30 then
                Dominant.Loops[name] = nil
                Dominant.Warn("[Dominant:" .. name .. "] stopped after repeated errors")
                break
            end
            if interval and interval > 0 then
                task.wait(interval)
            else
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

function Dominant.StopLoop(name)
    Dominant.Loops[name] = nil
end

function Dominant.BindFrame(name, event, callback)
    Dominant.UnbindFrame(name)
    Dominant.Objects["frame_" .. name] = RunService[event]:Connect(function(...)
        local ok, err = pcall(callback, ...)
        if ok then
            Dominant.Succeeded(name)
        elseif Dominant.Failed(name, err) >= 120 then
            Dominant.UnbindFrame(name)
            Dominant.Warn("[Dominant:" .. name .. "] stopped after repeated errors")
        end
    end)
end

function Dominant.UnbindFrame(name)
    local connection = Dominant.Objects["frame_" .. name]
    if connection then
        Dominant.Disconnect(connection)
        Dominant.Objects["frame_" .. name] = nil
    end
end

function Dominant.Notify(text, kind, duration)
    if not Dominant.Cfg.notifications then
        return
    end
    local lib = Dominant.Vind
    if lib and lib.Notify then
        pcall(function()
            lib:Notify({
                Title = CONFIG.Title,
                Text = text,
                Type = kind or "info",
                Duration = duration or 4,
            })
        end)
        return
    end
    pcall(function()
        Svc.StarterGui:SetCore("SendNotification", {
            Title = CONFIG.Title,
            Text = text,
            Duration = duration or 4,
        })
    end)
end

function Dominant.Copy(text)
    local ok = pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(text)
        elseif type(toclipboard) == "function" then
            toclipboard(text)
        else
            error("no clipboard")
        end
    end)
    if ok then
        Dominant.Notify(L("n_copied"), "success", 3)
    else
        Dominant.Notify(L("n_unsupported"), "warning", 3)
    end
    return ok
end

local Game = {}
Dominant.Game = Game

function Game.PlayersFolder()
    return workspace:FindFirstChild("Players")
end

function Game.Killers()
    local folder = Game.PlayersFolder()
    return folder and folder:FindFirstChild("Killers")
end

function Game.Survivors()
    local folder = Game.PlayersFolder()
    return folder and folder:FindFirstChild("Survivors")
end

function Game.Spectating()
    local folder = Game.PlayersFolder()
    return folder and folder:FindFirstChild("Spectating")
end

function Game.Ingame()
    local map = workspace:FindFirstChild("Map")
    return map and map:FindFirstChild("Ingame")
end

function Game.MapModel()
    local ingame = Game.Ingame()
    return ingame and ingame:FindFirstChild("Map")
end

function Game.PlayerGui()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

function Game.MainUI()
    local gui = Game.PlayerGui()
    return gui and gui:FindFirstChild("MainUI")
end

function Game.TempUI()
    local gui = Game.PlayerGui()
    return gui and gui:FindFirstChild("TemporaryUI")
end

function Game.Network()
    local modules = Svc.ReplicatedStorage:FindFirstChild("Modules")
    return modules and modules:FindFirstChild("Network")
end

function Game.Remote()
    local network = Game.Network()
    if not network then
        return nil
    end
    return network:FindFirstChild("RemoteEvent") or network:FindFirstChildOfClass("RemoteEvent")
end

function Game.IsOfficial()
    return game.GameId == 6331902150 or game.GameId == 7464167604
end

function Game.SprintModule()
    local systems = Svc.ReplicatedStorage:FindFirstChild("Systems")
    local character = systems and systems:FindFirstChild("Character")
    local gameFolder = character and character:FindFirstChild("Game")
    local module = gameFolder and gameFolder:FindFirstChild("Sprinting")
    if not module then
        return nil
    end
    local ok, result = pcall(require, module)
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

Dominant.Caps.require = false
function Game.SprintTableFallback()
    local cached = Dominant.Objects.sprintFallback
    if cached and rawget(cached, "MaxStamina") ~= nil then
        return cached
    end
    local now = os.clock()
    if now < (Dominant.Objects.sprintScanAt or 0) or type(getgc) ~= "function" then
        return nil
    end
    Dominant.Objects.sprintScanAt = now + 10
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then
        return nil
    end
    for _, value in ipairs(objects) do
        if type(value) == "table" and rawget(value, "MaxStamina") ~= nil and rawget(value, "StaminaLossDisabled") ~= nil then
            Dominant.Objects.sprintFallback = value
            return value
        end
    end
    return nil
end

function Game.SprintFind()
    local module = Game.SprintModule()
    if module then
        return module, "require"
    end
    local fallback = Game.SprintTableFallback()
    if fallback then
        return fallback, "getgc"
    end
    return nil, nil
end

function Dominant.RefreshCaps()
    if not Dominant.Caps.require then
        local ok, found = pcall(function()
            return Game.SprintFind() ~= nil
        end)
        Dominant.Caps.require = ok and found or false
    end
    return Dominant.Caps.require
end

function Game.UseAbility(name)
    local remote = Game.Remote()
    if not remote then
        return false
    end
    if Game.IsOfficial() then
        remote:FireServer("UseActorAbility", { name })
    else
        remote:FireServer("UseActorAbility", name)
        remote:FireServer("UseActorAbility", { name })
    end
    pcall(function()
        if type(buffer) == "table" and buffer.fromstring then
            local packed = buffer.fromstring(string.pack("<Bi4", 3, #name) .. name)
            remote:FireServer("UseActorAbility", { packed })
        end
    end)
    return true
end

function Game.Role(character)
    if not character then
        return nil
    end
    local parent = character.Parent
    if parent == Game.Killers() then
        return "killer"
    elseif parent == Game.Survivors() then
        return "survivor"
    elseif parent == Game.Spectating() then
        return "spectator"
    end
    return nil
end

function Game.Generators()
    local list = {}
    local map = Game.MapModel()
    if not map then
        return list
    end
    for _, object in ipairs(map:GetDescendants()) do
        if object.Name == "Generator" and object:IsA("Model") then
            table.insert(list, object)
        end
    end
    return list
end

function Game.GeneratorProgress(generator)
    local progress = generator:FindFirstChild("Progress")
    if progress and progress:IsA("ValueBase") then
        return progress.Value
    end
    local attribute = generator:GetAttribute("Progress")
    if type(attribute) == "number" then
        return attribute
    end
    return 0
end

function Game.GeneratorPosition(generator)
    local main = generator:FindFirstChild("Main")
    if main and main:IsA("BasePart") then
        return main.Position
    end
    if generator.PrimaryPart then
        return generator.PrimaryPart.Position
    end
    local ok, pivot = pcall(function()
        return generator:GetPivot().Position
    end)
    if ok then
        return pivot
    end
    return nil
end

function Game.NearestGenerator(onlyUnfinished)
    local root = Dominant.State.Root
    if not root then
        return nil
    end
    local best, bestDistance = nil, math.huge
    for _, generator in ipairs(Game.Generators()) do
        if not onlyUnfinished or Game.GeneratorProgress(generator) < 100 then
            local position = Game.GeneratorPosition(generator)
            if position then
                local distance = (position - root.Position).Magnitude
                if distance < bestDistance then
                    best, bestDistance = generator, distance
                end
            end
        end
    end
    return best, bestDistance
end

function Game.Items()
    local list = {}
    local ingame = Game.Ingame()
    if not ingame then
        return list
    end
    for _, object in ipairs(ingame:GetDescendants()) do
        if object:IsA("Tool") and object:FindFirstChildWhichIsA("BasePart") then
            table.insert(list, object)
        end
    end
    return list
end

function Game.ToolPart(tool)
    return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
end

function Game.NearestKiller(maxDistance)
    local root = Dominant.State.Root
    local folder = Game.Killers()
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
    return best, bestDistance
end

function Game.IsKillerPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

function Game.FirePrompt(prompt)
    if Dominant.Caps.fireproximityprompt then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then
            return true
        end
    end
    local ok = pcall(function()
        local hold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait()
        prompt:InputHoldEnd()
        prompt.HoldDuration = hold
    end)
    return ok
end

function Game.Teleport(cframe)
    local root = Dominant.State.Root
    if not root or not cframe then
        return false
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = cframe
    return true
end

function Dominant.RefreshCharacter(character)
    local state = Dominant.State
    state.Character = character
    state.Humanoid = character and character:FindFirstChildOfClass("Humanoid")
    state.Root = character and (character:FindFirstChild("HumanoidRootPart") or (state.Humanoid and state.Humanoid.RootPart))
    state.Animator = state.Humanoid and state.Humanoid:FindFirstChildOfClass("Animator")
end

function Dominant.WaitCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    character:WaitForChild("HumanoidRootPart", 10)
    if humanoid then
        humanoid:WaitForChild("Animator", 5)
    end
    Dominant.RefreshCharacter(character)
end

function Dominant.Apply(key, value)
    local hook = Dominant.Hooks[key]
    if hook then
        local ok, err = pcall(hook, value)
        if not ok then
            Dominant.Warn("[Dominant:" .. key .. "] " .. tostring(err))
        end
    end
end

function Dominant.Set(key, value, skipApply)
    Dominant.Cfg[key] = value
    Dominant.Log(string.format("%s = %s", key, tostring(value)))
    if not skipApply then
        Dominant.Apply(key, value)
    end
    Dominant.QueueSave()
end

function Dominant.Greeting()
    local hour = tonumber(os.date("%H")) or 12
    if hour < 5 then
        return L("greet_night")
    elseif hour < 12 then
        return L("greet_morning")
    elseif hour < 18 then
        return L("greet_afternoon")
    end
    return L("greet_evening")
end

function Dominant.Cached(name, ttl, builder)
    return function(...)
        local entry = Dominant.Cache["fn_" .. name]
        local now = os.clock()
        if entry and now - entry.time < ttl then
            return entry.value
        end
        local value = builder(...)
        Dominant.Cache["fn_" .. name] = { time = now, value = value }
        return value
    end
end

Game.Generators = Dominant.Cached("generators", 1, Game.Generators)
Game.Items = Dominant.Cached("items", 0.5, Game.Items)

Dominant.StatNames = {
    money = { money = true, cash = true, coins = true, coin = true, currency = true, credits = true },
    malice = { malice = true },
}
Dominant.StatCache = setmetatable({}, { __mode = "k" })

local function statMatches(kind, name)
    local lowered = name:lower()
    if Dominant.StatNames[kind][lowered] then
        return true
    end
    return kind == "money" and lowered:find("^money") ~= nil or kind == "malice" and lowered:find("^malice") ~= nil
end

function Dominant.FindStat(player, kind)
    local cache = Dominant.StatCache[player]
    if not cache then
        cache = {}
        Dominant.StatCache[player] = cache
    end
    local entry = cache[kind]
    if entry then
        if entry.Instance and entry.Instance.Parent then
            return entry.Instance.Value
        elseif entry.Attr and entry.Root and entry.Root.Parent then
            local value = entry.Root:GetAttribute(entry.Attr)
            if type(value) == "number" then
                return value
            end
        elseif not entry.Instance and not entry.Attr and os.clock() - entry.Time < 10 then
            return nil
        end
    end
    entry = { Time = os.clock() }
    cache[kind] = entry
    local roots = { player, player:FindFirstChild("PlayerData"), player:FindFirstChild("leaderstats"), player.Character }
    for _, root in ipairs(roots) do
        if root then
            for name, value in pairs(root:GetAttributes()) do
                if type(value) == "number" and statMatches(kind, name) then
                    entry.Root, entry.Attr = root, name
                    return value
                end
            end
            for _, object in ipairs(root:GetDescendants()) do
                if object:IsA("ValueBase") and type(object.Value) == "number" and statMatches(kind, object.Name) then
                    entry.Instance = object
                    return object.Value
                end
            end
        end
    end
    if kind == "money" and player == LocalPlayer then
        local main = Game.MainUI()
        local holder = main and main:FindFirstChild("Money", true)
        local label = holder and (holder:IsA("TextLabel") and holder or holder:FindFirstChildWhichIsA("TextLabel", true))
        local digits = label and label.Text:gsub("%D", "")
        if digits and digits ~= "" then
            return tonumber(digits)
        end
    end
    return nil
end

function Dominant.FormatStat(value)
    if type(value) ~= "number" then
        return "-"
    end
    local text = tostring(math.floor(value))
    return (text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local Feat = Dominant.Feat
Dominant.CharacterCallbacks = {}

function Dominant.OnCharacter(callback)
    table.insert(Dominant.CharacterCallbacks, callback)
end

local function hook(key, callback)
    Dominant.Hooks[key] = callback
end

local UIS = Svc.UserInputService

Feat.Walk = {}
function Feat.Walk.Step()
    local humanoid = Dominant.State.Humanoid
    if humanoid and Dominant.Cfg.jumppower_on then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Dominant.Cfg.jumppower
    end
end

hook("jumppower_on", function(value)
    if value then
        Dominant.BindFrame("walk", "Heartbeat", Feat.Walk.Step)
    else
        Dominant.UnbindFrame("walk")
        local humanoid = Dominant.State.Humanoid
        if humanoid and not Dominant.Cfg.enable_jumping then
            humanoid.JumpPower = 0
        end
    end
end)

Feat.CFrameSpeed = {}
function Feat.CFrameSpeed.Step(dt)
    local root = Dominant.State.Root
    local humanoid = Dominant.State.Humanoid
    local cfg = Dominant.Cfg
    if not root or not humanoid or root.Anchored or cfg.fly then
        return
    end
    if type(dt) ~= "number" or dt <= 0 then
        dt = 1 / 60
    end
    local move = humanoid.MoveDirection
    if move.Magnitude > 0 then
        local speed = math.max(1, tonumber(cfg.cframe_speed_value) or 1)
        root.CFrame = root.CFrame + move.Unit * (speed * dt)
    end
end

hook("cframe_speed", function(value)
    if value then
        Dominant.BindFrame("cframespeed", "Heartbeat", Feat.CFrameSpeed.Step)
    else
        Dominant.UnbindFrame("cframespeed")
    end
end)

hook("cframe_speed_value", function()
    if Dominant.Cfg.cframe_speed then
        Dominant.BindFrame("cframespeed", "Heartbeat", Feat.CFrameSpeed.Step)
    end
end)

hook("fly_speed", function()
    if Dominant.Cfg.fly then
        Feat.Fly.Start()
    end
end)

hook("spin_speed", function()
    if Dominant.Cfg.spin then
        Dominant.Apply("spin", true)
    end
end)

hook("jumppower", function()
    if Dominant.Cfg.jumppower_on then
        Dominant.Apply("jumppower_on", true)
    end
end)


hook("ring_speed", function()
    if Dominant.Cfg.item_ring then
        Dominant.Apply("item_ring", true)
    end
end)

hook("ring_radius", function()
    if Dominant.Cfg.item_ring then
        Dominant.Apply("item_ring", true)
    end
end)

hook("guest_charge_speed", function()
    if Dominant.Cfg.guest_charge_speed_on then
        Dominant.Apply("guest_charge_speed_on", true)
    end
end)

Feat.InfiniteJump = {}
hook("infinite_jump", function(value)
    Dominant.Disconnect(Dominant.Objects.infJump)
    Dominant.Objects.infJump = nil
    if value then
        Dominant.Objects.infJump = UIS.JumpRequest:Connect(function()
            local humanoid = Dominant.State.Humanoid
            if humanoid and Dominant.Cfg.infinite_jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

Feat.Noclip = { Changed = {}, Parts = {}, Refresh = 0, Character = nil }
function Feat.Noclip.Restore()
    for part, original in pairs(Feat.Noclip.Changed) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end
    Feat.Noclip.Changed = {}
end

hook("noclip", function(value)
    if not value then
        Dominant.UnbindFrame("noclip")
        Feat.Noclip.Restore()
        return
    end
    Dominant.BindFrame("noclip", "Stepped", function()
        local character = Dominant.State.Character
        if not character then
            return
        end
        local now = os.clock()
        if Feat.Noclip.Character ~= character or now - Feat.Noclip.Refresh > 1 then
            Feat.Noclip.Character = character
            Feat.Noclip.Refresh = now
            Feat.Noclip.Parts = {}
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(Feat.Noclip.Parts, part)
                end
            end
        end
        for _, part in ipairs(Feat.Noclip.Parts) do
            if part.CanCollide then
                Feat.Noclip.Changed[part] = true
                part.CanCollide = false
            end
        end
    end)
end)

Feat.Fly = {}
function Feat.Fly.Stop()
    Dominant.UnbindFrame("fly")
    local objects = Dominant.Objects
    if objects.flyVelocity then
        objects.flyVelocity:Destroy()
        objects.flyVelocity = nil
    end
    if objects.flyGyro then
        objects.flyGyro:Destroy()
        objects.flyGyro = nil
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
    Dominant.Objects.flyVelocity = velocity
    Dominant.Objects.flyGyro = gyro
    humanoid.PlatformStand = true
    Dominant.BindFrame("fly", "RenderStepped", function()
        local camera = workspace.CurrentCamera
        local currentRoot = Dominant.State.Root
        if not camera or not currentRoot or not velocity.Parent then
            return
        end
        local direction = Vector3.zero
        local look, right = camera.CFrame.LookVector, camera.CFrame.RightVector
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += look
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= look
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += right
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= right
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction -= Vector3.yAxis
        end
        local move = Dominant.State.Humanoid and Dominant.State.Humanoid.MoveDirection or Vector3.zero
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

hook("spin", function(value)
    if not value then
        Dominant.UnbindFrame("spin")
        return
    end
    Dominant.BindFrame("spin", "RenderStepped", function()
        local root = Dominant.State.Root
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Dominant.Cfg.spin_speed), 0)
        end
    end)
end)

Feat.AntiSlow = {}
function Feat.AntiSlow.Step()
    local character = Dominant.State.Character
    if not character then
        return
    end
    local speed = character:FindFirstChild("SpeedMultipliers")
    if speed then
        for _, child in ipairs(speed:GetChildren()) do
            if child:IsA("NumberValue") then
                local name = child.Name
                if name ~= "Sprinting" and name:lower() ~= "emoting" then
                    if name == "DirectionalMovement" or name == "FixingGenerator" or name:upper() == "ENRAGED" then
                        if child.Value < 1 then
                            child.Value = 1
                        end
                    elseif child.Value > 0.05 and child.Value < 1 then
                        child.Value = 1
                    end
                end
            end
        end
    end
    local fov = character:FindFirstChild("FOVMultipliers")
    local slowed = fov and fov:FindFirstChild("SlowedStatus")
    if slowed and slowed:IsA("NumberValue") and slowed.Value ~= 1 then
        slowed.Value = 1
    end
    local main = Game.MainUI()
    local container = main and main:FindFirstChild("StatusContainer")
    local indicator = container and container:FindFirstChild("Slowness")
    if indicator and indicator:IsA("GuiObject") then
        indicator.Visible = false
    end
end

hook("anti_slow", function(value)
    if value then
        Dominant.BindFrame("antislow", "Heartbeat", Feat.AntiSlow.Step)
    else
        Dominant.UnbindFrame("antislow")
    end
end)

Feat.Stamina = {}
function Feat.Stamina.Module()
    local now = os.clock()
    local cached = Dominant.Objects.sprintModule
    if cached and rawget(cached, "MaxStamina") ~= nil and now - (Dominant.Objects.sprintFetched or 0) < 1 then
        return cached
    end
    if not cached and now < (Dominant.Objects.sprintNextTry or 0) then
        return nil
    end
    local module, via = Game.SprintFind()
    Dominant.Objects.sprintModule = module
    Dominant.Objects.sprintFetched = now
    Dominant.Objects.sprintNextTry = now + (module and 0 or 5)
    if module and not Dominant.Objects.sprintLogged then
        Dominant.Objects.sprintLogged = true
        Dominant.Log(L("debug_sprint_found") .. " (" .. tostring(via) .. ")", Enum.MessageType.MessageInfo)
        Dominant.Log(string.format("Stamina=%s Max=%s Gain=%s LossDisabled=%s", tostring(module.Stamina), tostring(module.MaxStamina), tostring(module.StaminaGain), tostring(module.StaminaLossDisabled)), Enum.MessageType.MessageInfo)
    elseif not module and not Dominant.Objects.sprintMissLogged then
        Dominant.Objects.sprintMissLogged = true
        Dominant.Log(L("debug_sprint_missing"), Enum.MessageType.MessageWarning)
    end
    return module
end

function Feat.Stamina.Step(dt)
    local cfg = Dominant.Cfg
    local module = Feat.Stamina.Module()
    if not module then
        return
    end
    if cfg.stamina_custom then
        local maxStamina = math.max(1, tonumber(cfg.stamina_max) or 100)
        local regen = math.max(0, tonumber(cfg.stamina_regen) or 0)
        local drain = math.max(0, tonumber(cfg.stamina_drain) or 0)
        local humanoid = Dominant.State.Humanoid
        local moving = humanoid ~= nil and humanoid.MoveDirection.Magnitude > 0
        local sprinting = moving and (module.IsSprinting == true or (humanoid ~= nil and humanoid.WalkSpeed > 17))
        local current = tonumber(module.Stamina) or maxStamina
        local step = tonumber(dt) or (1 / 60)
        if sprinting then
            current -= drain * step
        else
            current += regen * step
        end
        current = math.clamp(current, 0, maxStamina)
        pcall(function()
            module.StaminaLossDisabled = true
            module.MaxStamina = maxStamina
            module.Stamina = current
        end)
        return
    end
    pcall(function()
        module.StaminaLossDisabled = true
        module.StaminaGain = 20
        module.MaxStamina = 999
    end)
end

Feat.Emotes = { List = {}, Data = {}, Track = nil, Selected = nil }

function Feat.Emotes.Load()
    local list, data = {}, {}
    local assets = Svc.ReplicatedStorage:FindFirstChild("Assets")
    local folder = assets and assets:FindFirstChild("Emotes")
    if folder then
        for _, module in ipairs(folder:GetChildren()) do
            if module:IsA("ModuleScript") then
                local ok, result = pcall(require, module)
                if ok and type(result) == "table" and type(result.AssetID) == "string" then
                    data[module.Name] = result
                    table.insert(list, module.Name)
                end
            end
        end
    end
    table.sort(list)
    Feat.Emotes.List = list
    Feat.Emotes.Data = data
    return list
end

function Feat.Emotes.Stop()
    if Feat.Emotes.Track then
        pcall(function()
            Feat.Emotes.Track:Stop(0.2)
        end)
        Feat.Emotes.Track = nil
    end
end

function Feat.Emotes.Play(name)
    local info = Feat.Emotes.Data[name]
    local animator = Dominant.State.Animator
    if not info or not animator then
        Dominant.Notify(L("n_emote_none"), "warning", 3)
        return
    end
    Feat.Emotes.Stop()
    local animation = Instance.new("Animation")
    animation.AnimationId = info.AssetID
    local ok, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        Feat.Emotes.Track = track
    else
        Dominant.Notify(L("n_emote_none"), "warning", 3)
    end
end

Feat.SprintSpeed = {}
function Feat.SprintSpeed.Step()
    local module = Dominant.Objects.sprintModule or Game.SprintModule()
    Dominant.Objects.sprintModule = module
    if module then
        pcall(function()
            module.SprintSpeed = math.clamp(tonumber(Dominant.Cfg.sprint_speed) or 26, 1, 40)
        end)
    end
end

hook("no_fall", function(value)
    if value then
        Dominant.BindFrame("nofall", "Heartbeat", function()
            local humanoid = Dominant.State.Humanoid
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            end
        end)
    else
        Dominant.UnbindFrame("nofall")
        local humanoid = Dominant.State.Humanoid
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        end
    end
end)

hook("sprint_speed_on", function(value)
    if value then
        if not Dominant.Caps.require then
            Dominant.RequireMissing("sprint_speed_on", "require")
            return
        end
        Dominant.BindFrame("sprintspeed", "Heartbeat", Feat.SprintSpeed.Step)
    else
        Dominant.UnbindFrame("sprintspeed")
    end
end)

hook("stamina_custom", function(value)
    if value then
        if not Dominant.Caps.require then
            Dominant.RequireMissing("stamina_custom", "require")
            return
        end
        Dominant.BindFrame("stamina", "Heartbeat", Feat.Stamina.Step)
    elseif not Dominant.Cfg.infinite_stamina then
        Dominant.UnbindFrame("stamina")
        local module = Dominant.Objects.sprintModule or Game.SprintModule()
        if module then
            module.StaminaLossDisabled = false
        end
    end
end)


hook("infinite_stamina", function(value)
    if value then
        if not Dominant.Caps.require then
            Dominant.RequireMissing("infinite_stamina", "require")
            return
        end
        Dominant.BindFrame("stamina", "Heartbeat", Feat.Stamina.Step)
    else
        Dominant.UnbindFrame("stamina")
        local module = Dominant.Objects.sprintModule or Game.SprintModule()
        if module then
            module.StaminaLossDisabled = false
        end
    end
end)

hook("enable_jumping", function(value)
    local humanoid = Dominant.State.Humanoid
    if not value then
        Dominant.UnbindFrame("enablejump")
        if humanoid and not Dominant.Cfg.jumppower_on then
            humanoid.JumpPower = 0
        end
        return
    end
    Dominant.BindFrame("enablejump", "Heartbeat", function()
        local current = Dominant.State.Humanoid
        if current and not Dominant.Cfg.jumppower_on then
            current.UseJumpPower = true
            if current.JumpPower <= 0 then
                current.JumpPower = 47
            end
        end
    end)
end)

Feat.Invisible = { Track = nil }
function Feat.Invisible.Step()
    local animator = Dominant.State.Animator
    local root = Dominant.State.Root
    if not animator or not root then
        return
    end
    local track = Feat.Invisible.Track
    if not track or not track.IsPlaying then
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://75804462760596"
        local ok, loaded = pcall(function()
            return animator:LoadAnimation(animation)
        end)
        if ok and loaded then
            loaded.Looped = true
            loaded.Priority = Enum.AnimationPriority.Action4
            loaded:Play()
            loaded:AdjustSpeed(0)
            Feat.Invisible.Track = loaded
            root.Transparency = 0.4
        end
    end
end

function Feat.Invisible.Stop()
    Dominant.StopLoop("invisible")
    if Feat.Invisible.Track then
        pcall(function()
            Feat.Invisible.Track:Stop()
        end)
        Feat.Invisible.Track = nil
    end
    local root = Dominant.State.Root
    if root then
        root.Transparency = 1
    end
end

hook("invisible", function(value)
    if value then
        Dominant.StartLoop("invisible", 0.5, Feat.Invisible.Step)
    else
        Feat.Invisible.Stop()
    end
end)

Feat.Invincible = { Underground = false, Hooked = false, Busy = false }
function Feat.Invincible.Supported()
    return Dominant.Caps.hookmetamethod and Dominant.Caps.newcclosure and Dominant.Caps.checkcaller and Dominant.Caps.require and Game.IsOfficial()
end

function Feat.Invincible.InstallHook()
    if Feat.Invincible.Hooked then
        return true
    end
    local network = Game.Network()
    local remote = network and network:WaitForChild("UnreliableRemoteEvent", 5)
    if not remote then
        return false
    end
    local original
    local ok = pcall(function()
        original = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if not checkcaller() and Feat.Invincible.Underground and Dominant.Cfg.invincible and self == remote and getnamecallmethod() == "FireServer" then
                local args = { ... }
                if args[1] == 1 then
                    return nil
                end
            end
            return original(self, ...)
        end))
    end)
    Feat.Invincible.Hooked = ok
    return ok
end

function Feat.Invincible.HitboxClear(hitbox, position)
    if not hitbox or not position then
        return false
    end
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.MaxParts = 1
    params.FilterDescendantsInstances = { hitbox }
    return #workspace:GetPartBoundsInRadius(position, 2.5, params) == 0
end

function Feat.Invincible.MoveTo(target)
    local root = Dominant.State.Root
    local character = Dominant.State.Character
    if not root or not character then
        return
    end
    local limit = os.clock() + 4
    local parts = {}
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            parts[part] = true
            part.CanCollide = false
        end
    end
    local body = Instance.new("BodyVelocity")
    body.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    body.Velocity = Vector3.zero
    body.Parent = root
    while (root.Position - target).Magnitude > 2 and os.clock() < limit do
        body.Velocity = (target - root.Position).Unit * 100
        RunService.RenderStepped:Wait()
    end
    body:Destroy()
    for part in pairs(parts) do
        if part.Parent then
            part.CanCollide = true
        end
    end
end

function Feat.Invincible.GoUnder()
    if Feat.Invincible.Busy or not Dominant.Cfg.invincible then
        return
    end
    local character = Dominant.State.Character
    local root = Dominant.State.Root
    local humanoid = Dominant.State.Humanoid
    local head = character and character:FindFirstChild("Head")
    if not (root and humanoid and head) or Game.Role(character) ~= "survivor" then
        return
    end
    Feat.Invincible.Busy = true
    local hitbox = character:FindFirstChild("QueryHitbox")
    local origin = root.CFrame
    local under = origin * CFrame.new(0, -22, 0)
    local tries = 0
    repeat
        tries += 1
        root.AssemblyLinearVelocity = Vector3.zero
        Feat.Invincible.MoveTo(under.Position)
        head.Anchored = true
        local deadline = os.clock() + 3.5
        repeat
            task.wait()
        until Feat.Invincible.HitboxClear(hitbox, origin.Position) or os.clock() > deadline or not root.Parent
        Feat.Invincible.Underground = true
        task.wait()
        root.AssemblyLinearVelocity = Vector3.zero
        head.Anchored = false
        root.CFrame = origin
        RunService.Heartbeat:Wait()
        root.AssemblyLinearVelocity = Vector3.zero
    until Feat.Invincible.HitboxClear(hitbox, origin.Position) or tries >= 3 or not root.Parent
    if tries >= 3 then
        Feat.Invincible.Underground = false
        Dominant.Cfg.invincible = false
        Dominant.Notify(L("n_invincible_fail"), "error", 5)
    end
    Feat.Invincible.Busy = false
end

hook("invincible", function(value)
    if not value then
        Feat.Invincible.Underground = false
        return
    end
    if not Feat.Invincible.Supported() then
        Dominant.RequireMissing("invincible", "hookmetamethod + require")
        return
    end
    if not Feat.Invincible.InstallHook() then
        Dominant.Cfg.invincible = false
        Dominant.Notify(L("n_invincible_fail"), "error", 5)
        return
    end
    task.spawn(Feat.Invincible.GoUnder)
end)

Dominant.OnCharacter(function(character)
    Feat.Invincible.Underground = false
    if Dominant.Cfg.invincible then
        task.delay(1.5, Feat.Invincible.GoUnder)
    end
end)

Feat.VoidRush = { Active = false }
function Feat.VoidRush.Stop()
    if not Feat.VoidRush.Active then
        return
    end
    Feat.VoidRush.Active = false
    local humanoid = Dominant.State.Humanoid
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.AutoRotate = true
        humanoid:Move(Vector3.zero)
    end
end

function Feat.VoidRush.Step()
    local character = Dominant.State.Character
    local humanoid = Dominant.State.Humanoid
    local root = Dominant.State.Root
    if not character or not humanoid or not root then
        return
    end
    if character:GetAttribute("VoidRushState") ~= "Dashing" then
        Feat.VoidRush.Stop()
        return
    end
    local cfg = Dominant.Cfg
    Feat.VoidRush.Active = true
    humanoid.WalkSpeed = math.max(1, tonumber(cfg.void_rush_speed) or 60)
    humanoid.AutoRotate = false
    if cfg.void_rush_steer then
        local wanted = humanoid.MoveDirection
        if wanted.Magnitude == 0 then
            local camera = workspace.CurrentCamera
            local look = camera and camera.CFrame.LookVector or root.CFrame.LookVector
            wanted = Vector3.new(look.X, 0, look.Z)
        end
        if wanted.Magnitude > 0 then
            local flat = Vector3.new(wanted.X, 0, wanted.Z).Unit
            root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + flat), 0.15)
        end
    end
    local look = root.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0 then
        humanoid:Move(flat.Unit)
    end
end

hook("void_rush_control", function(value)
    if value then
        Dominant.BindFrame("voidrush", "RenderStepped", Feat.VoidRush.Step)
    else
        Dominant.UnbindFrame("voidrush")
        Feat.VoidRush.Stop()
    end
end)

Feat.Dash = {}
function Feat.Dash.Attach(character)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then
        return
    end
    root.ChildAdded:Connect(function(child)
        if not child:IsA("LinearVelocity") then
            return
        end
        local humanoid = Dominant.State.Humanoid
        if not humanoid or not Dominant.Cfg.controllable_dash then
            return
        end
        if not character.Name:gsub("0", "O"):lower():find("coolkid") then
            return
        end
        local original = child.LineDirection
        local magnitude = original.Magnitude
        local speed = character:FindFirstChild("SpeedMultipliers")
        if speed then
            for _, value in ipairs(speed:GetChildren()) do
                if value.Name == "HinderedMovement" and value.Value == 0 then
                    value.Value = 0.005
                end
            end
        end
        local function update()
            if not Dominant.Cfg.controllable_dash then
                child.LineDirection = original
                return
            end
            local camera = workspace.CurrentCamera
            if humanoid.MoveDirection ~= Vector3.zero then
                child.LineDirection = humanoid.MoveDirection * magnitude
            elseif camera then
                local look = camera.CFrame.LookVector
                local flat = Vector3.new(look.X, 0, look.Z)
                if flat.Magnitude > 0 then
                    child.LineDirection = flat.Unit * magnitude
                    if child.LineVelocity > 0 then
                        root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + flat), 0.05)
                    end
                end
            end
        end
        update()
        local moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(update)
        local cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(update)
        child.Destroying:Once(function()
            moveConnection:Disconnect()
            cameraConnection:Disconnect()
        end)
    end)
end

Dominant.OnCharacter(function(character)
    task.spawn(Feat.Dash.Attach, character)
end)


hook("anti_afk", function(value)
    Dominant.Disconnect(Dominant.Objects.antiAfk)
    Dominant.Objects.antiAfk = nil
    if value then
        Dominant.Objects.antiAfk = LocalPlayer.Idled:Connect(function()
            pcall(function()
                local virtualUser = Svc.VirtualUser
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end)

Dominant.OnCharacter(function()
    local cfg = Dominant.Cfg
    if cfg.fly then
        task.delay(0.5, Feat.Fly.Start)
    end
    if cfg.invisible then
        Feat.Invisible.Track = nil
    end
    if cfg.enable_jumping then
        Dominant.Apply("enable_jumping", true)
    end
end)

Feat.Puzzle = { Installed = false, Busy = false }

function Feat.Puzzle.Key(point)
    return string.format("%d-%d", point.row, point.col)
end

function Feat.Puzzle.Direction(row1, col1, row2, col2)
    if row2 < row1 then
        return "up"
    elseif row2 > row1 then
        return "down"
    elseif col2 < col1 then
        return "left"
    elseif col2 > col1 then
        return "right"
    end
    return nil
end

function Feat.Puzzle.Opposite(direction)
    local map = { up = "down", down = "up", left = "right", right = "left" }
    return map[direction]
end

function Feat.Puzzle.Connections(last, point, nextPoint)
    local result = {}
    if last then
        local direction = Feat.Puzzle.Direction(point.row, point.col, last.row, last.col)
        direction = direction and Feat.Puzzle.Opposite(direction)
        if direction then
            result[direction] = true
        end
    end
    if nextPoint then
        local direction = Feat.Puzzle.Direction(point.row, point.col, nextPoint.row, nextPoint.col)
        if direction then
            result[direction] = true
        end
    end
    return result
end

function Feat.Puzzle.Adjacent(a, b)
    return math.abs(a.row - b.row) + math.abs(a.col - b.col) == 1
end

function Feat.Puzzle.Order(path, endpoints)
    if not path or #path == 0 then
        return path
    end
    local lookup = {}
    for _, point in ipairs(path) do
        lookup[Feat.Puzzle.Key(point)] = point
    end
    local start
    for _, endpoint in ipairs(endpoints or {}) do
        local match = lookup[Feat.Puzzle.Key(endpoint)]
        if match then
            start = match
            break
        end
    end
    if not start then
        for _, point in ipairs(path) do
            local neighbors = 0
            for _, other in ipairs(path) do
                if Feat.Puzzle.Adjacent(point, other) then
                    neighbors += 1
                end
            end
            if neighbors == 1 then
                start = point
                break
            end
        end
    end
    start = start or path[1]
    local ordered = { { row = start.row, col = start.col } }
    local remaining = {}
    for key, point in pairs(lookup) do
        remaining[key] = point
    end
    remaining[Feat.Puzzle.Key(start)] = nil
    local current = start
    while next(remaining) do
        local found
        for key, point in pairs(remaining) do
            if Feat.Puzzle.Adjacent(current, point) then
                found = key
                break
            end
        end
        if not found then
            return path
        end
        local point = remaining[found]
        table.insert(ordered, { row = point.row, col = point.col })
        remaining[found] = nil
        current = point
    end
    return ordered
end

function Feat.Puzzle.PlayersNear(distance)
    local root = Dominant.State.Root
    if not root then
        return false
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local part = player ~= LocalPlayer and character and character:FindFirstChild("HumanoidRootPart")
        if part and (part.Position - root.Position).Magnitude < distance then
            return true
        end
    end
    return false
end

function Feat.Puzzle.StepDelay()
    local cfg = Dominant.Cfg
    local base = cfg.gen_cooldown
    if cfg.gen_speedup and not Feat.Puzzle.PlayersNear(32) then
        base = 1.5
    end
    local grid = Dominant.Objects.currentGrid or cfg.gen_grid or 6
    local jitter = base * 0.1
    return math.max(0.02, Random.new():NextNumber(base - jitter, base + jitter) / (grid * grid))
end

function Feat.Puzzle.Solve(puzzle, ui)
    if not puzzle or not puzzle.Solution then
        return
    end
    local colors = {}
    for index = 1, #puzzle.Solution do
        table.insert(colors, index)
    end
    for index = #colors, 2, -1 do
        local swap = math.random(1, index)
        colors[index], colors[swap] = colors[swap], colors[index]
    end
    for _, color in ipairs(colors) do
        local path = puzzle.Solution[color]
        local endpoints = puzzle.targetPairs and puzzle.targetPairs[color]
        local ordered = Feat.Puzzle.Order(path, endpoints)
        puzzle.paths[color] = {}
        for index = 1, #ordered do
            if not Dominant.Cfg.auto_gen or not ui or not ui.Parent then
                return
            end
            local point = ordered[index]
            table.insert(puzzle.paths[color], { row = point.row, col = point.col })
            puzzle.gridConnections = puzzle.gridConnections or {}
            puzzle.gridConnections[Feat.Puzzle.Key(point)] = Feat.Puzzle.Connections(ordered[index - 1], point, ordered[index + 1])
            puzzle:updateGui()
            task.wait(Feat.Puzzle.StepDelay())
        end
    end
    if Dominant.Cfg.auto_gen and ui and ui.Parent then
        puzzle:checkForWin()
    end
end

function Feat.Puzzle.Install()
    if Feat.Puzzle.Installed then
        return true
    end
    if not Dominant.Caps.require then
        return false
    end
    local flow = Svc.ReplicatedStorage:FindFirstChild("FlowGame", true)
    if not flow then
        return false
    end
    local ok, module = pcall(require, flow)
    if not ok or type(module) ~= "table" or type(module.new) ~= "function" then
        return false
    end
    local original = module.new
    module.new = function(...)
        local args = { ... }
        if type(args[2]) == "number" or args[2] == nil then
            if Dominant.Cfg.gen_override_grid then
                args[2] = Dominant.Cfg.gen_grid
            end
            Dominant.Objects.currentGrid = args[2]
            local puzzle = original(table.unpack(args, 1, math.max(#args, 2)))
            if Dominant.Cfg.auto_gen then
                local ui = args[1]
                task.delay(0.35, function()
                    Dominant.Safe(Feat.Puzzle.Solve, puzzle, ui)
                end)
            end
            return puzzle
        end
        return original(...)
    end
    Feat.Puzzle.Installed = true
    return true
end

function Feat.Puzzle.RemoteFallback()
    if Feat.Puzzle.Busy then
        return
    end
    local gui = Game.PlayerGui()
    local root = Dominant.State.Root
    if not gui or not root or not gui:FindFirstChild("PuzzleUI") then
        return
    end
    for _, generator in ipairs(Game.Generators()) do
        local position = Game.GeneratorPosition(generator)
        if position and (position - root.Position).Magnitude < 8 then
            local remotes = generator:FindFirstChild("Remotes")
            local event = remotes and (remotes:FindFirstChild("RE") or remotes:FindFirstChildOfClass("RemoteEvent"))
            if event then
                Feat.Puzzle.Busy = true
                task.spawn(function()
                    while Dominant.Cfg.auto_gen and gui:FindFirstChild("PuzzleUI") and Game.GeneratorProgress(generator) < 100 do
                        local base = Dominant.Cfg.gen_cooldown
                        task.wait(Random.new():NextNumber(base * 0.9, base * 1.1))
                        if gui:FindFirstChild("PuzzleUI") then
                            event:FireServer()
                        end
                    end
                    Feat.Puzzle.Busy = false
                end)
            end
            break
        end
    end
end

hook("auto_gen", function(value)
    if not value then
        Dominant.StopLoop("autogen")
        return
    end
    local installed = Feat.Puzzle.Install()
    if not installed then
        Dominant.StartLoop("autogen", 0.5, Feat.Puzzle.RemoteFallback)
    end
end)

hook("gen_override_grid", function(value)
    if value and not Feat.Puzzle.Install() then
        Dominant.RequireMissing("gen_override_grid", "require")
    end
end)

Feat.GenRemote = {}
Feat.AllGens = {}
function Feat.AllGens.Step()
    local cfg = Dominant.Cfg
    local generator = Game.NearestGenerator(true)
    if not generator then
        Dominant.StopLoop("doallgens")
        Dominant.Set("gen_all", false)
        if cfg.gen_all_reset then
            Dominant.ResetCharacter()
        end
        Dominant.Notify(L("n_gen_all_done"), "success", 3)
        return
    end
    local position = Game.GeneratorPosition(generator)
    if position then
        Game.Teleport(CFrame.new(position + Vector3.new(0, 3.5, 5)))
    end
    local remotes = generator:FindFirstChild("Remotes")
    local event = remotes and (remotes:FindFirstChild("RE") or remotes:FindFirstChildOfClass("RemoteEvent"))
    if event then
        event:FireServer()
    end
    task.wait(math.max(0.2, tonumber(cfg.gen_all_interval) or 1.5))
end

hook("gen_all", function(value)
    if value then
        Dominant.StartLoop("doallgens", 0, Feat.AllGens.Step)
    else
        Dominant.StopLoop("doallgens")
    end
end)

function Feat.GenRemote.Step()
    local generator = Game.NearestGenerator(true)
    if not generator then
        return
    end
    local remotes = generator:FindFirstChild("Remotes")
    local event = remotes and (remotes:FindFirstChild("RE") or remotes:FindFirstChildOfClass("RemoteEvent"))
    if event then
        event:FireServer()
    end
    task.wait(Random.new():NextNumber(0, 0.4))
end

hook("auto_gen_remote", function(value)
    if value then
        Dominant.StartLoop("genremote", 0, function()
            Feat.GenRemote.Step()
            task.wait(Dominant.Cfg.gen_loop_delay)
        end)
    else
        Dominant.StopLoop("genremote")
    end
end)

Feat.Pickup = { Dropped = {} }
function Feat.Pickup.Collect(range)
    local root = Dominant.State.Root
    if not root then
        return 0
    end
    local count = 0
    for _, tool in ipairs(Game.Items()) do
        local part = Game.ToolPart(tool)
        local droppedAt = Feat.Pickup.Dropped[tool]
        if part and (not droppedAt or os.clock() - droppedAt > 1.5) and (part.Position - root.Position).Magnitude <= range then
            local prompt = tool:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                Game.FirePrompt(prompt)
                count += 1
            elseif type(firetouchinterest) == "function" then
                pcall(function()
                    firetouchinterest(root, part, 0)
                    firetouchinterest(root, part, 1)
                end)
                count += 1
            end
        end
    end
    return count
end

hook("auto_pickup", function(value)
    if value then
        local ingame = Game.Ingame()
        if ingame and not Dominant.Objects.pickupWatch then
            Dominant.Objects.pickupWatch = Dominant.Connect(ingame.ChildAdded, function(child)
                if child:IsA("Tool") then
                    Feat.Pickup.Dropped[child] = os.clock()
                end
            end)
        end
        Dominant.StartLoop("pickup", 0.35, function()
            Feat.Pickup.Collect(Dominant.Cfg.pickup_range)
        end)
    else
        Dominant.StopLoop("pickup")
    end
end)

Feat.Escape = { Watching = false }
function Feat.Escape.Fire()
    local killers = Game.Killers()
    local network = Game.Network()
    local remote = network and (network:FindFirstChildOfClass("RemoteEvent"))
    if not killers or not remote then
        return
    end
    for _, killer in ipairs(killers:GetChildren()) do
        if killer.Name:lower() == "nosferatu" then
            local player = Players:GetPlayerFromCharacter(killer)
            if player then
                remote:FireServer(player.Name .. "NosHookQTE", { true })
            end
        end
    end
end

function Feat.Escape.Watch()
    if Feat.Escape.Watching then
        return
    end
    local temp = Game.TempUI()
    if not temp then
        return
    end
    Feat.Escape.Watching = true
    Dominant.Connect(temp.ChildAdded, function(element)
        if element.Name:upper() == "QTE" and element:FindFirstChildOfClass("UIAspectRatioConstraint") then
            task.spawn(function()
                while element.Parent and element:IsA("GuiObject") and element.Visible do
                    local base = Dominant.Cfg.escape_cooldown
                    task.wait(Random.new():NextNumber(math.max(0.1, base - 0.2 * base), base + 0.2 * base))
                    if Dominant.Cfg.auto_escape then
                        Feat.Escape.Fire()
                    end
                end
            end)
        end
    end)
end

hook("auto_escape", function(value)
    if value then
        Feat.Escape.Watch()
    end
end)

Feat.Disarm = { Installed = false, Current = nil }
function Feat.Disarm.Install()
    if Feat.Disarm.Installed then
        return true
    end
    if not (Dominant.Caps.require and Dominant.Caps.hookfunction) then
        return false
    end
    local assets = Svc.ReplicatedStorage:FindFirstChild("Assets")
    local killers = assets and assets:FindFirstChild("Killers")
    local azure = killers and killers:FindFirstChild("Azure")
    local construct = azure and azure:FindFirstChild("clConstructQTE", true)
    if not construct then
        return false
    end
    local ok, module = pcall(require, construct)
    if not ok or type(module) ~= "table" or type(module.new) ~= "function" then
        return false
    end
    local original
    local hooked = pcall(function()
        original = hookfunction(module.new, function(...)
            local qte = original(...)
            task.delay(0.05, function()
                if type(qte) == "table" and qte.AddProgress then
                    if Dominant.Cfg.auto_disarm then
                        qte:AddProgress(100)
                    else
                        Feat.Disarm.Current = qte
                    end
                end
            end)
            return qte
        end)
    end)
    Feat.Disarm.Installed = hooked
    return hooked
end

hook("auto_disarm", function(value)
    if not value then
        return
    end
    if not Feat.Disarm.Install() then
        Dominant.RequireMissing("auto_disarm", "require + hookfunction")
        return
    end
    if Feat.Disarm.Current then
        pcall(function()
            Feat.Disarm.Current:AddProgress(100)
        end)
        Feat.Disarm.Current = nil
    end
end)

Feat.Popups = {}
function Feat.Popups.Step()
    local temp = Game.TempUI()
    if not temp then
        return
    end
    local manager = Svc.VirtualInputManager
    for _, element in ipairs(temp:GetChildren()) do
        if element.Name == "1x1x1x1Popup" and element:IsA("GuiObject") then
            local x = element.AbsolutePosition.X + element.AbsoluteSize.X / 2
            local y = element.AbsolutePosition.Y + element.AbsoluteSize.Y / 2 + 50
            manager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            manager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end
end

hook("auto_popups", function(value)
    if value then
        Dominant.StartLoop("popups", 0.05, Feat.Popups.Step)
    else
        Dominant.StopLoop("popups")
    end
end)

Feat.Prompts = { Changed = {} }
function Feat.Prompts.Apply(prompt)
    if prompt.HoldDuration > 0 then
        Feat.Prompts.Changed[prompt] = prompt.HoldDuration
        prompt.HoldDuration = 0
    end
end

hook("instant_prompts", function(value)
    Dominant.Disconnect(Dominant.Objects.promptShown)
    Dominant.Objects.promptShown = nil
    if value then
        Dominant.Objects.promptShown = Svc.ProximityPromptService.PromptShown:Connect(function(prompt)
            if Dominant.Cfg.instant_prompts then
                Feat.Prompts.Apply(prompt)
            end
        end)
    else
        for prompt, hold in pairs(Feat.Prompts.Changed) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = hold
            end
        end
        Feat.Prompts.Changed = {}
    end
end)

Feat.Combat = {
    TriggerAnims = {
        "126830014841198", "126355327951215", "121086746534252", "18885909645",
        "98456918873918", "105458270463374", "83829782357897", "125403313786645",
        "118298475669935", "82113744478546", "70371667919898", "99135633258223",
        "97167027849946", "109230267448394", "139835501033932", "126896426760253",
        "109667959938617", "126681776859538", "129976080405072", "121293883585738",
        "81639435858902", "137314737492715", "92173139187970", "106847695270773",
    },
    BlockAnims = { "72722244508749", "96959123077498" },
    PunchAnims = { "87259391926321" },
    ChargeAnims = { "106014898528300" },
    AttackAnims = {
        "100592913030351", "101771617803133", "103741352379819", "105458270463374",
        "106014898528300", "106086955212611", "106847695270773", "107640065977686",
        "108807732150251", "109230267448394", "109667959938617", "111313169447787",
        "114620047310688", "116618003477002", "118298475669935", "119462383658044",
        "120112897026015", "121086746534252", "121255898612475", "121293883585738",
        "122503338277352", "124243639579224", "125403313786645", "126355327951215",
        "126681776859538", "126830014841198", "127172483138092", "129843313690921",
        "129976080405072", "131430497821198", "131543461321709", "131696603025265",
        "133336594357903", "134958187822107", "136007065400978", "136323728355613",
        "137314737492715", "138040001965654", "140703210927645", "18885909645",
        "18885919947", "70371667919898", "70447634862911", "71685573690338",
        "73502073176819", "74707328554358", "77124578197357", "77448521277146",
        "81639435858902", "82113744478546", "82183356141401", "83829782357897",
        "84426150435898", "86096387000557", "86204001129974", "86545133269813",
        "86709774283672", "87259391926321", "89448354637442", "90499469533503",
        "92173139187970", "93069721274110", "94162446513587", "96173857867228",
        "97433060861952", "97623143664485", "97648548303678", "98031287364865",
    },
    LastBlock = 0,
    LastBlockTp = 0,
    PredictiveCooldown = 0,
    InRangeSince = nil,
    Punching = false,
}

local Combat = Feat.Combat
Combat.TriggerSet = {}
for _, id in ipairs(Combat.TriggerAnims) do
    Combat.TriggerSet[id] = true
end
Combat.AttackSet = {}
for _, id in ipairs(Combat.AttackAnims) do
    Combat.AttackSet[id] = true
end

function Combat.AnimId(track)
    return tostring(track.Animation.AnimationId):match("%d+")
end

function Combat.IsSurvivor()
    return Game.Role(Dominant.State.Character) == "survivor"
end

function Combat.IsFacing(localRoot, targetRoot)
    if not Dominant.Cfg.guest_facing_check then
        return true
    end
    local offset = localRoot.Position - targetRoot.Position
    if offset.Magnitude == 0 then
        return false
    end
    local dot = targetRoot.CFrame.LookVector:Dot(offset.Unit)
    if Dominant.Cfg.guest_facing == "Loose" then
        return dot > -0.3
    end
    return dot > 0
end

function Combat.Block()
    local now = os.clock()
    if now - Combat.LastBlock < 0.3 then
        return false
    end
    Combat.LastBlock = now
    return Combat.Press("Block", Enum.KeyCode.Q)
end

function Combat.AbilityButton(name)
    local main = Game.MainUI()
    local container = main and main:FindFirstChild("AbilityContainer")
    if not container then
        return nil
    end
    local button = container:FindFirstChild(name, true)
    if button and button:IsA("GuiButton") then
        return button
    end
    return nil
end

function Combat.ClickButton(button)
    if not button then
        return false
    end
    if Dominant.Caps.firesignal then
        local ok = pcall(function()
            firesignal(button.MouseButton1Click)
        end)
        if ok then
            return true
        end
    end
    local manager = Svc.VirtualInputManager
    if manager and button.Visible then
        local ok = pcall(function()
            local position = button.AbsolutePosition + button.AbsoluteSize / 2
            manager:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 1)
            task.wait(0.03)
            manager:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 1)
        end)
        if ok then
            return true
        end
    end
    return false
end

-- order: game remote (works on PC and mobile), then the on-screen ability button
-- (mobile), then a click on that button, then keyboard keys (PC)
function Combat.Press(name, key)
    if Game.UseAbility(name) then
        return true
    end
    local button = Combat.AbilityButton(name)
    if Combat.ClickButton(button) then
        return true
    end
    if UIS.TouchEnabled and not UIS.KeyboardEnabled then
        return false
    end
    return Combat.PressKey(key)
end

function Combat.PressKey(key)
    local manager = Svc.VirtualInputManager
    if not manager then
        return false
    end
    local ok = pcall(function()
        manager:SendKeyEvent(true, key, false, game)
        task.wait(0.03)
        manager:SendKeyEvent(false, key, false, game)
    end)
    return ok
end

function Combat.PlayCustom(kind)
    local cfg = Dominant.Cfg
    local id = cfg["custom_" .. kind .. "_id"]
    if cfg["custom_" .. kind .. "_on"] and id ~= "" then
        Feat.Anim.PlayId(id, kind)
    end
end

function Combat.KillerTracks(killer)
    local humanoid = killer:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        return animator:GetPlayingAnimationTracks()
    end
    return {}
end

function Combat.WallBetween(root, part)
    if not Dominant.Cfg.guest_wallcheck then
        return false
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Dominant.State.Character, part.Parent }
    local result = workspace:Raycast(root.Position, part.Position - root.Position, params)
    return result ~= nil and result.Instance.CanCollide
end

Combat.DetectBase = Vector3.new(5.2, 6, 5.65) * 2.2
Combat.SpecialFlags = { "RagingPace", "AbilityActive", "IsRaging", "GashingWound", "AbilityInvincible" }

function Combat.SpecialState(killer)
    local char = killer.Character or killer
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.WalkSpeed >= 19 then
        return true
    end
    for _, name in ipairs(Combat.SpecialFlags) do
        local value = char:FindFirstChild(name)
        if value and value:IsA("ValueBase") and value.Value == true then
            return true
        end
    end
    return false
end

function Combat.Parry()
    task.delay(0.08, function()
        local replicated = Svc.ReplicatedStorage
        local remote = replicated:FindFirstChild("Parry") or replicated:FindFirstChild("ParryEvent", true)
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end)
end
Combat.DetectOffset = CFrame.new(0, 0, -3.5)
Combat.BlockBusy = false
Combat.DragReadyAt = 0

function Combat.DetectBox(root, killers)
    local adjust = tonumber(Dominant.Cfg.guest_abh) or 0
    local size = Combat.DetectBase + Vector3.new(adjust, adjust, adjust)
    size = Vector3.new(math.max(0.1, size.X), math.max(0.1, size.Y), math.max(0.1, size.Z))
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = killers
    params.MaxParts = 1
    local cframe = root.CFrame * Combat.DetectOffset
    return #workspace:GetPartBoundsInBox(cframe, size, params) > 0
end

function Combat.DragFollow(killer)
    local cfg = Dominant.Cfg
    local now = os.clock()
    if now < Combat.DragReadyAt then
        return
    end
    Combat.DragReadyAt = now + 1.5
    local stop = math.max(0, tonumber(cfg.drag_stop) or 3)
    local hold = math.max(0, tonumber(cfg.drag_hold) or 0.2)
    task.spawn(function()
        local started = os.clock()
        while os.clock() - started < hold do
            local root = Dominant.State.Root
            local part = killer.Parent and killer:FindFirstChild("HumanoidRootPart")
            if not root or not part then
                break
            end
            local offset = part.Position - root.Position
            local flat = Vector3.new(offset.X, 0, offset.Z)
            if flat.Magnitude <= stop then
                break
            end
            local target = root.Position + flat.Unit * (flat.Magnitude - stop)
            root.CFrame = CFrame.new(target, Vector3.new(part.Position.X, target.Y, part.Position.Z))
            RunService.Heartbeat:Wait()
        end
    end)
end

function Combat.AutoBlockStep()
    if Combat.BlockBusy then
        return
    end
    local cfg = Dominant.Cfg
    local root = Dominant.State.Root
    local killers = Game.Killers()
    if not root or not killers or not Combat.IsSurvivor() then
        return
    end
    local range = cfg.guest_strict_range and cfg.guest_block_range or cfg.guest_block_range * 1.6
    local attacking = {}
    for _, killer in ipairs(killers:GetChildren()) do
        local part = killer:FindFirstChild("HumanoidRootPart")
        if part and Game.IsKillerPlayer(killer) and (part.Position - root.Position).Magnitude <= range and not Combat.WallBetween(root, part) and not (cfg.guest_skip_special and Combat.SpecialState(killer)) then
            for _, track in ipairs(Combat.KillerTracks(killer)) do
                local id = Combat.AnimId(track)
                if id and Combat.TriggerSet[id] and Combat.IsFacing(root, part) then
                    table.insert(attacking, killer)
                    break
                end
            end
        end
    end
    if #attacking == 0 then
        return
    end
    Combat.BlockBusy = true
    for _ = 1, 9 do
        if not Dominant.Cfg.guest_block or not Dominant.State.Root then
            break
        end
        if Combat.DetectBox(Dominant.State.Root, attacking) then
            if Combat.Block() then
                Combat.PlayCustom("block")
                if cfg.auto_parry then
                    Combat.Parry()
                end
                if cfg.drag_block then
                    Combat.DragFollow(attacking[1])
                end
            end
            break
        end
        task.wait(0.02)
    end
    Combat.BlockBusy = false
end

function Combat.PredictiveStep()
    local cfg = Dominant.Cfg
    local root = Dominant.State.Root
    if not root or not Combat.IsSurvivor() or os.clock() < Combat.PredictiveCooldown then
        return
    end
    local killer, distance = Game.NearestKiller(cfg.guest_predict_range)
    if killer and distance <= cfg.guest_predict_range and Game.IsKillerPlayer(killer) then
        if not Combat.InRangeSince then
            Combat.InRangeSince = os.clock()
        elseif os.clock() - Combat.InRangeSince >= cfg.guest_edge_delay then
            Combat.Block()
            Combat.PredictiveCooldown = os.clock() + 2
            Combat.InRangeSince = nil
        end
    else
        Combat.InRangeSince = nil
    end
end

function Combat.BlockTpStep()
    local humanoid = Dominant.State.Humanoid
    if not humanoid or os.clock() - Combat.LastBlockTp < 5 then
        return
    end
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = Combat.AnimId(track)
        if id and table.find(Combat.BlockAnims, id) then
            local killer = Game.NearestKiller(80)
            local target = killer and killer:FindFirstChild("HumanoidRootPart")
            if target and Game.IsKillerPlayer(killer) then
                Combat.LastBlockTp = os.clock()
                task.spawn(function()
                    local started = os.clock()
                    while os.clock() - started < 0.5 do
                        local root = Dominant.State.Root
                        if root and target.Parent then
                            root.CFrame = CFrame.new(target.Position + target.CFrame.LookVector * 6)
                        end
                        task.wait()
                    end
                end)
            end
            return
        end
    end
end

function Combat.GuestLoop()
    local cfg = Dominant.Cfg
    if cfg.guest_block then
        Combat.AutoBlockStep()
    end
    if cfg.guest_predictive then
        Combat.PredictiveStep()
    end
    if cfg.guest_block_tp then
        Combat.BlockTpStep()
    end
    if cfg.guest_charge_speed_on then
        local character = Dominant.State.Character
        local speed = character and character:FindFirstChild("SpeedMultipliers")
        local charge = speed and speed:FindFirstChild("Guest1337Charge")
        if charge then
            charge.Value = cfg.guest_charge_speed
        end
    end
end

function Combat.RefreshGuestLoop()
    local cfg = Dominant.Cfg
    if cfg.guest_block or cfg.guest_predictive or cfg.guest_block_tp or cfg.guest_charge_speed_on then
        Dominant.BindFrame("guest", "RenderStepped", Combat.GuestLoop)
    else
        Dominant.UnbindFrame("guest")
    end
end

for _, key in ipairs({ "guest_block", "guest_predictive", "guest_block_tp", "guest_charge_speed_on" }) do
    hook(key, Combat.RefreshGuestLoop)
end

function Combat.PunchActive()
    local character = Dominant.State.Character
    local speed = character and character:FindFirstChild("SpeedMultipliers")
    return speed and speed:FindFirstChild("PunchAbility") ~= nil
end

function Combat.PunchStep()
    local cfg = Dominant.Cfg
    local root = Dominant.State.Root
    if not root or not Combat.PunchActive() then
        return
    end
    if cfg.guest_fling_punch then
        local velocity = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = velocity * cfg.guest_fling_power + Vector3.new(0, cfg.guest_fling_power, 0)
        RunService.RenderStepped:Wait()
        root.AssemblyLinearVelocity = velocity
    end
    if cfg.guest_punch_aim then
        local killer = Game.NearestKiller(55)
        local part = killer and killer:FindFirstChild("HumanoidRootPart")
        if part then
            local velocity = part.AssemblyLinearVelocity
            local predicted = part.Position
            if velocity.Magnitude > 1 then
                predicted += velocity.Unit * cfg.guest_punch_prediction
            end
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(predicted.X, root.Position.Y, predicted.Z))
        end
    end
end

function Combat.RefreshPunchLoop()
    local cfg = Dominant.Cfg
    if cfg.guest_fling_punch or cfg.guest_punch_aim then
        Dominant.BindFrame("punch", "Heartbeat", Combat.PunchStep)
    else
        Dominant.UnbindFrame("punch")
    end
end

hook("guest_fling_punch", Combat.RefreshPunchLoop)
hook("guest_punch_aim", Combat.RefreshPunchLoop)

function Combat.ClickPunch()
    local main = Game.MainUI()
    local container = main and main:FindFirstChild("AbilityContainer")
    local button = container and container:FindFirstChild("Punch")
    if button and Dominant.Caps.firesignal then
        local ok = pcall(firesignal, button.MouseButton1Click)
        if ok then
            return
        end
    end
    Combat.Press("Punch", Enum.KeyCode.R)
end

function Combat.OnHit(character)
    if not Dominant.Cfg.guest_auto_punch then
        return
    end
    local speed = character:FindFirstChild("SpeedMultipliers")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local overheal = humanoid and humanoid:GetAttribute("Overheal")
    if not (speed and speed:FindFirstChild("GuestBlocking") and overheal and overheal >= 10) then
        return
    end
    if not Game.NearestKiller(55) then
        return
    end
    task.wait(math.max(0, tonumber(Dominant.Cfg.guest_punch_wait) or 0.08))
    character:SetAttribute("DisableShiftLockMovement", true)
    Combat.ClickPunch()
    local root = character:FindFirstChild("HumanoidRootPart")
    local fov = character:FindFirstChild("FOVMultipliers")
    local smoothed
    local follow = RunService.RenderStepped:Connect(function()
        local killer = Game.NearestKiller(55)
        local part = killer and killer:FindFirstChild("HumanoidRootPart")
        if not part or not root then
            return
        end
        local target = Vector3.new(part.Position.X, root.Position.Y, part.Position.Z)
        root.CFrame = CFrame.lookAt(root.Position, target)
        local desired = root.CFrame.LookVector * 32
        smoothed = smoothed and smoothed:Lerp(desired, 0.2) or desired
        root.AssemblyLinearVelocity = Vector3.new(smoothed.X, root.AssemblyLinearVelocity.Y, smoothed.Z)
    end)
    local deadline = os.clock() + 2
    repeat
        task.wait(0.1)
    until (fov and fov:FindFirstChild("HitRegistered")) or not speed:FindFirstChild("PunchAbility") or os.clock() > deadline
    follow:Disconnect()
    task.wait(0.2)
    character:SetAttribute("DisableShiftLockMovement", false)
end

Dominant.OnCharacter(function(character)
    character:GetAttributeChangedSignal("TimesHit"):Connect(function()
        Dominant.Safe(Combat.OnHit, character)
    end)
end)


function Combat.ChanceStep()
    local character = Dominant.State.Character
    local humanoid = Dominant.State.Humanoid
    local root = Dominant.State.Root
    if not (character and humanoid and root) then
        return
    end
    local flintlock = character:FindFirstChild("Flintlock")
    if flintlock and flintlock.Transparency == 0 then
        local killer = Game.NearestKiller(250)
        local part = killer and killer:FindFirstChild("HumanoidRootPart")
        if part then
            local predicted = part.Position + part.AssemblyLinearVelocity * Dominant.Cfg.chance_prediction
            humanoid.AutoRotate = false
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(predicted.X, root.Position.Y, predicted.Z))
            return
        end
    end
    humanoid.AutoRotate = true
end

hook("chance_aimbot", function(value)
    if value then
        Dominant.BindFrame("chance", "Heartbeat", Combat.ChanceStep)
    else
        Dominant.UnbindFrame("chance")
        local humanoid = Dominant.State.Humanoid
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end)

function Combat.HitboxStep()
    local humanoid = Dominant.State.Humanoid
    local root = Dominant.State.Root
    local character = Dominant.State.Character
    if not (humanoid and root and character) then
        return
    end
    local attacking = false
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = Combat.AnimId(track)
        if id and Combat.AttackSet[id] and track.Length > 0 and track.TimePosition / track.Length < 0.75 then
            attacking = true
            break
        end
    end
    if not attacking then
        return
    end
    local target
    local nearest = Dominant.Cfg.hitbox_range
    local function scan(list)
        for _, object in ipairs(list) do
            local part = object ~= character and object:FindFirstChild("HumanoidRootPart")
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if distance < nearest then
                    nearest, target = distance, part
                end
            end
        end
    end
    local folder = Game.PlayersFolder()
    if folder then
        for _, group in ipairs(folder:GetChildren()) do
            scan(group:GetChildren())
        end
    end
    local map = workspace:FindFirstChild("Map")
    local npcs = map and map:FindFirstChild("NPCs", true)
    if npcs then
        scan(npcs:GetChildren())
    end
    if not target then
        return
    end
    local ping = math.max(LocalPlayer:GetNetworkPing(), 0.03)
    local spread = Vector3.new(math.random() * 3 - 1.5, 0, math.random() * 3 - 1.5)
    local predicted = target.Position + spread + target.AssemblyLinearVelocity * (ping * 1.25)
    local previous = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = (predicted - root.Position) / (ping * 2)
    RunService.RenderStepped:Wait()
    root.AssemblyLinearVelocity = previous
end

hook("hitbox_mod", function(value)
    if value then
        Dominant.BindFrame("hitbox", "Heartbeat", Combat.HitboxStep)
    else
        Dominant.UnbindFrame("hitbox")
    end
end)

Feat.ESP = { Objects = {}, Folder = nil }
local ESP = Feat.ESP

function ESP.GetFolder()
    if ESP.Folder and ESP.Folder.Parent then
        return ESP.Folder
    end
    local folder = Instance.new("Folder")
    folder.Name = "DominantESP"
    local parent = (type(gethui) == "function" and gethui()) or Svc.CoreGui
    local ok = pcall(function()
        folder.Parent = parent
    end)
    if not ok then
        folder.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    ESP.Folder = folder
    return folder
end

function ESP.Color(kind)
    local cfg = Dominant.Cfg
    return cfg["color_" .. kind] or Color3.new(1, 1, 1)
end

function ESP.AdorneePart(target)
    if target:IsA("BasePart") then
        return target
    elseif target:IsA("Tool") then
        return Game.ToolPart(target)
    end
    return target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
end

function ESP.Create(target, kind)
    local folder = ESP.GetFolder()
    local highlight = Instance.new("Highlight")
    highlight.Name = "DominantHighlight"
    highlight.Adornee = target
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = ESP.Color(kind)
    highlight.OutlineColor = ESP.Color(kind)
    highlight.FillTransparency = 1 - Dominant.Cfg.esp_fill
    highlight.OutlineTransparency = 0
    highlight.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DominantLabel"
    billboard.Adornee = ESP.AdorneePart(target)
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(160, 34)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.MaxDistance = math.huge
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.4
    label.TextColor3 = ESP.Color(kind)
    label.Text = ""
    label.Parent = billboard

    local entry = {
        Target = target,
        Kind = kind,
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
    }
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
        entry.Billboard:Destroy()
    end)
    ESP.Objects[target] = nil
end

function ESP.Clear()
    for target in pairs(ESP.Objects) do
        ESP.Destroy(target)
    end
    if ESP.Folder then
        ESP.Folder:ClearAllChildren()
    end
end

function ESP.Position(target)
    if target:IsA("Model") then
        local part = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
        return part and part.Position
    elseif target:IsA("Tool") then
        local part = Game.ToolPart(target)
        return part and part.Position
    elseif target:IsA("BasePart") then
        return target.Position
    end
    return nil
end

Feat.BlockRing = { Part = nil }
function Feat.BlockRing.Ensure()
    local part = Feat.BlockRing.Part
    if part and part.Parent then
        return part
    end
    part = Instance.new("Part")
    part.Name = "DominantBlockRing"
    part.Shape = Enum.PartType.Cylinder
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = Enum.Material.ForceField
    part.Transparency = 1
    part.Parent = Feat.ESP.GetFolder()
    Feat.BlockRing.Part = part
    return part
end

function Feat.BlockRing.Step()
    local cfg = Dominant.Cfg
    local part = Feat.BlockRing.Ensure()
    local root = Dominant.State.Root
    if not root or not Feat.Combat.IsSurvivor() then
        part.Transparency = 1
        return
    end
    local radius = cfg.guest_strict_range and cfg.guest_block_range or cfg.guest_block_range * 1.6
    part.Size = Vector3.new(0.1, radius * 2, radius * 2)
    part.Color = cfg.color_block_ring
    part.Transparency = 0.75
    part.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
end

hook("block_range_esp", function(value)
    if value then
        Dominant.BindFrame("blockring", "RenderStepped", Feat.BlockRing.Step)
    else
        Dominant.UnbindFrame("blockring")
        if Feat.BlockRing.Part then
            Feat.BlockRing.Part:Destroy()
            Feat.BlockRing.Part = nil
        end
    end
end)

hook("esp", function(value)
    if value then
        Dominant.StartLoop("esp", 0.1, ESP.Step)
    else
        Dominant.StopLoop("esp")
        ESP.Clear()
    end
end)

Feat.Screen = {}
function Feat.Screen.Camera()
    return workspace.CurrentCamera
end

hook("fov_on", function(value)
    if value then
        Dominant.BindFrame("fov", "RenderStepped", function()
            local camera = Feat.Screen.Camera()
            if camera then
                camera.FieldOfView = Dominant.Cfg.fov
            end
        end)
    else
        Dominant.UnbindFrame("fov")
        local camera = Feat.Screen.Camera()
        if camera then
            camera.FieldOfView = 70
        end
    end
end)

hook("zoom_on", function(value)
    if value then
        Dominant.BindFrame("zoom", "RenderStepped", function()
            LocalPlayer.CameraMaxZoomDistance = Dominant.Cfg.zoom
        end)
    else
        Dominant.UnbindFrame("zoom")
        LocalPlayer.CameraMaxZoomDistance = Svc.StarterPlayer.CameraMaxZoomDistance
    end
end)

Feat.Light = { Saved = nil }
function Feat.Light.Snapshot()
    if Feat.Light.Saved then
        return
    end
    local lighting = Svc.Lighting
    Feat.Light.Saved = {
        Brightness = lighting.Brightness,
        ClockTime = lighting.ClockTime,
        FogEnd = lighting.FogEnd,
        FogStart = lighting.FogStart,
        GlobalShadows = lighting.GlobalShadows,
        Ambient = lighting.Ambient,
        OutdoorAmbient = lighting.OutdoorAmbient,
    }
end

hook("fullbright", function(value)
    if value then
        Feat.Light.Snapshot()
        Dominant.BindFrame("fullbright", "RenderStepped", function()
            local lighting = Svc.Lighting
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.fromRGB(190, 190, 190)
            lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
        end)
    else
        Dominant.UnbindFrame("fullbright")
        local saved = Feat.Light.Saved
        if saved then
            local lighting = Svc.Lighting
            lighting.Brightness = saved.Brightness
            lighting.ClockTime = saved.ClockTime
            lighting.GlobalShadows = saved.GlobalShadows
            lighting.Ambient = saved.Ambient
            lighting.OutdoorAmbient = saved.OutdoorAmbient
        end
    end
end)

hook("no_fog", function(value)
    if value then
        Feat.Light.Snapshot()
        Dominant.BindFrame("nofog", "RenderStepped", function()
            Svc.Lighting.FogEnd = 1e9
            Svc.Lighting.FogStart = 1e9
            for _, effect in ipairs(Svc.Lighting:GetChildren()) do
                if effect:IsA("Atmosphere") then
                    effect.Density = 0
                end
            end
        end)
    else
        Dominant.UnbindFrame("nofog")
        local saved = Feat.Light.Saved
        if saved then
            Svc.Lighting.FogEnd = saved.FogEnd
            Svc.Lighting.FogStart = saved.FogStart
        end
    end
end)

function Feat.Screen.Injury()
    local hidden = Dominant.Cfg.hide_injury
    local temp = Game.TempUI()
    if temp then
        for _, element in ipairs(temp:GetDescendants()) do
            if element:IsA("GuiObject") and (element.Name == "redFlash" or element.Name == "injuredVignette") then
                element.Visible = not hidden
            end
        end
    end
    local desaturation = Svc.Lighting:FindFirstChild("HealthDesaturation")
    if desaturation then
        desaturation.Enabled = not hidden
    end
end

hook("hide_injury", function(value)
    if value then
        Dominant.StartLoop("injury", 0.25, Feat.Screen.Injury)
    else
        Dominant.StopLoop("injury")
        Feat.Screen.Injury()
    end
end)

function Feat.Screen.Blindness()
    local blocked = Dominant.Cfg.disable_blindness
    local effect = Svc.Lighting:FindFirstChild("BlindnessBlur", true)
    if effect and effect:IsA("BlurEffect") then
        effect.Enabled = not blocked
    end
end

hook("disable_blindness", function(value)
    if value then
        Dominant.StartLoop("blindness", 0.25, Feat.Screen.Blindness)
    else
        Dominant.StopLoop("blindness")
        Feat.Screen.Blindness()
    end
end)

hook("show_chat", function(value)
    local config = Svc.TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    if not config then
        return
    end
    if value then
        config.Enabled = true
        Dominant.Objects.chatWatch = config:GetPropertyChangedSignal("Enabled"):Connect(function()
            if Dominant.Cfg.show_chat then
                config.Enabled = true
            end
        end)
    else
        Dominant.Disconnect(Dominant.Objects.chatWatch)
        Dominant.Objects.chatWatch = nil
    end
end)

Dominant.AnonChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
Dominant.AnonRng = Random.new()
Dominant.Anon = setmetatable({}, { __mode = "k" })

function Dominant.AnonCode(player)
    local existing = Dominant.Anon[player]
    if existing then
        return existing
    end
    local used = {}
    for _, value in pairs(Dominant.Anon) do
        used[value] = true
    end
    local code
    repeat
        local chars = {}
        for i = 1, 6 do
            local index = Dominant.AnonRng:NextInteger(1, #Dominant.AnonChars)
            chars[i] = Dominant.AnonChars:sub(index, index)
        end
        code = table.concat(chars)
    until not used[code]
    Dominant.Anon[player] = code
    return code
end

function Dominant.DisplayNameOf(player)
    if Dominant.Cfg.name_protect then
        return Dominant.AnonCode(player)
    end
    return player.DisplayName
end

function Dominant.Mask(text)
    if not Dominant.Cfg.name_protect or type(text) ~= "string" or text == "" then
        return text
    end
    local result = text
    for _, player in ipairs(Players:GetPlayers()) do
        local code = Dominant.AnonCode(player)
        for _, name in ipairs({ player.DisplayName, player.Name }) do
            if name ~= "" and result:find(name, 1, true) then
                local pattern = (name:gsub("%W", "%%%0"))
                result = result:gsub(pattern, code)
            end
        end
    end
    return result
end

Feat.Privacy = { Originals = setmetatable({}, { __mode = "k" }) }

function Feat.Privacy.Step()
    local gui = Game.PlayerGui()
    if gui then
        for _, element in ipairs(gui:GetDescendants()) do
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                local current = element.Text
                local masked = Dominant.Mask(current)
                if masked ~= current then
                    if Feat.Privacy.Originals[element] == nil then
                        Feat.Privacy.Originals[element] = current
                    end
                    element.Text = masked
                end
            end
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if Feat.Privacy.Originals[humanoid] == nil then
                Feat.Privacy.Originals[humanoid] = humanoid.DisplayName
            end
            local code = Dominant.AnonCode(player)
            if humanoid.DisplayName ~= code then
                humanoid.DisplayName = code
            end
        end
    end
    local spectating = Game.Spectating()
    if spectating then
        for _, character in ipairs(spectating:GetChildren()) do
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
    end
end

function Feat.Privacy.Restore()
    for object, original in pairs(Feat.Privacy.Originals) do
        pcall(function()
            if object:IsA("Humanoid") then
                object.DisplayName = original
            else
                object.Text = original
            end
        end)
    end
    Feat.Privacy.Originals = setmetatable({}, { __mode = "k" })
end

hook("name_protect", function(value)
    if value then
        Dominant.StartLoop("nameprotect", 0.5, Feat.Privacy.Step)
    else
        Dominant.StopLoop("nameprotect")
        Feat.Privacy.Restore()
    end
end)

Feat.Tracker = { Gui = nil, Rows = {} }
function Feat.Tracker.Build()
    if Feat.Tracker.Gui and Feat.Tracker.Gui.Parent then
        return Feat.Tracker.Gui
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "DominantTracker"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 50
    local parent = (type(gethui) == "function" and gethui()) or Svc.CoreGui
    local ok = pcall(function()
        gui.Parent = parent
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.AnchorPoint = Vector2.new(1, 0.5)
    frame.Position = UDim2.new(1, -12, 0.5, 0)
    frame.Size = UDim2.fromOffset(190, 40)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = frame
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = frame
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.LayoutOrder = 0
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    Feat.Tracker.Gui = gui
    return gui
end

function Feat.Tracker.Step()
    local gui = Feat.Tracker.Build()
    local panel = gui.Panel
    panel.Title.Text = L("stats_title")
    local colors = {
        killer = ESP.Color("killer"),
        survivor = ESP.Color("survivor"),
        spectator = Color3.fromRGB(170, 170, 170),
    }
    local roleNames = {
        killer = L("role_killer"),
        survivor = L("role_survivor"),
        spectator = L("role_spectator"),
    }
    local wanted = {}
    local order = 1
    for _, player in ipairs(Players:GetPlayers()) do
        local role = Game.Role(player.Character)
        if role then
            wanted[player] = true
            local row = Feat.Tracker.Rows[player]
            if not row then
                row = Instance.new("TextLabel")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 16)
                row.Font = Enum.Font.Gotham
                row.TextSize = 12
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.Parent = panel
                Feat.Tracker.Rows[player] = row
            end
            local name = Dominant.DisplayNameOf(player)
            row.LayoutOrder = order
            row.Text = string.format("%s - %s", name, roleNames[role])
            row.TextColor3 = colors[role]
            order += 1
        end
    end
    for player, row in pairs(Feat.Tracker.Rows) do
        if not wanted[player] then
            row:Destroy()
            Feat.Tracker.Rows[player] = nil
        end
    end
end

hook("stats_tracker", function(value)
    if value then
        Dominant.StartLoop("tracker", 0.5, Feat.Tracker.Step)
    else
        Dominant.StopLoop("tracker")
        if Feat.Tracker.Gui then
            Feat.Tracker.Gui:Destroy()
            Feat.Tracker.Gui = nil
            Feat.Tracker.Rows = {}
        end
    end
end)

hook("delete_ragdolls", function(value)
    if not value then
        Dominant.StopLoop("ragdolls")
        return
    end
    Dominant.StartLoop("ragdolls", 0.5, function()
        local folder = workspace:FindFirstChild("Ragdolls")
        if folder then
            folder:ClearAllChildren()
        end
    end)
end)

function Game.AllGenerators()
    local list = {}
    local map = Game.MapModel()
    if not map then
        return list
    end
    for _, object in ipairs(map:GetDescendants()) do
        if (object.Name == "Generator" or object.Name == "FakeGenerator") and object:IsA("Model") then
            table.insert(list, object)
        end
    end
    return list
end

Game.AllGenerators = Dominant.Cached("allgenerators", 1, Game.AllGenerators)

ESP.TrapWords = { "trap", "spike", "mine", "tripwire", "graffiti", "sentry", "dispenser", "bulb", "vine", "golem", "respawnlocation", "subspace" }

function ESP.IsTrap(object)
    local name = object.Name:lower()
    for _, word in ipairs(ESP.TrapWords) do
        if name:find(word, 1, true) then
            return true
        end
    end
    return object:FindFirstChild("Wire") ~= nil
end

function ESP.IsSupport(object)
    if not object:IsA("Model") or Players:GetPlayerFromCharacter(object) then
        return false
    end
    local humanoid = object:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.WalkSpeed ~= 16 and humanoid.WalkSpeed ~= 26 and object:FindFirstChild("HumanoidRootPart") ~= nil
end

function ESP.Wanted(target, kind)
    local cfg = Dominant.Cfg
    if kind == "killer" then
        return cfg.esp_killers
    elseif kind == "support" then
        return cfg.esp_support
    elseif kind == "survivor" then
        return cfg.esp_survivors
    elseif kind == "generator" then
        return cfg.esp_generators and not (cfg.esp_hide_done and Game.GeneratorProgress(target) >= 100)
    elseif kind == "fake" then
        return cfg.esp_fake
    elseif kind == "item" then
        return cfg.esp_items
    elseif kind == "trap" then
        return cfg.esp_traps
    elseif kind == "pallet" then
        return cfg.esp_pallets
    elseif kind == "window" then
        return cfg.esp_windows
    elseif kind == "chest" then
        return cfg.esp_chests
    end
    return false
end

function ESP.Describe(entry, distance)
    local cfg = Dominant.Cfg
    local target = entry.Target
    local parts = {}
    local kind = entry.Kind
    if kind == "killer" or kind == "survivor" then
        local player = Players:GetPlayerFromCharacter(target)
        local name = target.Name
        if player then
            name = Dominant.DisplayNameOf(player)
        end
        table.insert(parts, name)
        if cfg.esp_health then
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            if humanoid then
                table.insert(parts, string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
            end
        end
    elseif kind == "generator" then
        table.insert(parts, L("esp_generator_label", math.floor(Game.GeneratorProgress(target))))
    elseif kind == "fake" then
        table.insert(parts, L("esp_fake_label"))
    else
        table.insert(parts, target.Name)
    end
    if cfg.esp_distance then
        table.insert(parts, string.format("[%dm]", math.floor(distance)))
    end
    return table.concat(parts, " ")
end

function ESP.Collect()
    local list = {}
    local killers = Game.Killers()
    if killers then
        for _, model in ipairs(killers:GetChildren()) do
            if model ~= Dominant.State.Character then
                table.insert(list, { model, "killer" })
            end
        end
    end
    local survivors = Game.Survivors()
    if survivors then
        for _, model in ipairs(survivors:GetChildren()) do
            if model ~= Dominant.State.Character then
                table.insert(list, { model, "survivor" })
            end
        end
    end
    local now = os.clock()
    if now - Dominant.Cache.LastScan > 1.5 then
        Dominant.Cache.LastScan = now
        Dominant.Cache.Generators = Game.AllGenerators()
        Dominant.Cache.Items = Game.Items()
        local traps, support = {}, {}
        local ingame = Game.Ingame()
        if ingame then
            for _, object in ipairs(ingame:GetChildren()) do
                if ESP.IsSupport(object) then
                    table.insert(support, object)
                elseif object ~= Game.MapModel() and (object:IsA("Model") or object:IsA("BasePart")) and ESP.IsTrap(object) then
                    table.insert(traps, object)
                end
            end
            local map = Game.MapModel()
            if map then
                for _, object in ipairs(map:GetDescendants()) do
                    if (object:IsA("Model") or object:IsA("BasePart")) and object.Name ~= "Generator" and object.Name ~= "FakeGenerator" then
                        local lowered = object.Name:lower()
                        if lowered:find("graffiti", 1, true) or lowered:find("respawnlocation", 1, true) then
                            table.insert(traps, object)
                        end
                    end
                end
            end
        end
        local structures = {}
        local mapModel = Game.MapModel()
        if mapModel then
            for _, object in ipairs(mapModel:GetDescendants()) do
                if object:IsA("Model") or object:IsA("BasePart") then
                    local lowered = object.Name:lower()
                    local kind = nil
                    if lowered:find("pallet", 1, true) then
                        kind = "pallet"
                    elseif lowered:find("window", 1, true) then
                        kind = "window"
                    elseif lowered:find("chest", 1, true) or lowered:find("supply", 1, true) then
                        kind = "chest"
                    end
                    if kind then
                        table.insert(structures, { object, kind })
                    end
                end
            end
        end
        Dominant.Cache.Structures = structures
        Dominant.Cache.Traps = traps
        Dominant.Cache.Support = support
    end
    for _, generator in ipairs(Dominant.Cache.Generators) do
        if generator.Parent then
            table.insert(list, { generator, generator.Name == "FakeGenerator" and "fake" or "generator" })
        end
    end
    for _, tool in ipairs(Dominant.Cache.Items) do
        if tool.Parent then
            table.insert(list, { tool, "item" })
        end
    end
    for _, trap in ipairs(Dominant.Cache.Traps or {}) do
        if trap.Parent then
            table.insert(list, { trap, "trap" })
        end
    end
    for _, pair in ipairs(Dominant.Cache.Structures or {}) do
        if pair[1].Parent then
            table.insert(list, pair)
        end
    end
    for _, unit in ipairs(Dominant.Cache.Support or {}) do
        if unit.Parent then
            table.insert(list, { unit, "support" })
        end
    end
    return list
end

function ESP.Step()
    local cfg = Dominant.Cfg
    local root = Dominant.State.Root
    if not cfg.esp or not root then
        return
    end
    local seen = {}
    for _, pair in ipairs(ESP.Collect()) do
        local target, kind = pair[1], pair[2]
        local position = ESP.Position(target)
        if position and ESP.Wanted(target, kind) then
            local distance = (position - root.Position).Magnitude
            if distance <= cfg.esp_max_distance then
                seen[target] = true
                local entry = ESP.Objects[target] or ESP.Create(target, kind)
                local color = ESP.Color(kind)
                local highlight = entry.Highlight
                highlight.FillColor = color
                highlight.OutlineColor = color
                highlight.FillTransparency = cfg.esp_outline_only and 1 or (1 - cfg.esp_fill)
                highlight.Enabled = true
                entry.Label.TextColor3 = color
                entry.Label.TextSize = cfg.esp_text_size
                entry.Billboard.Enabled = cfg.esp_text
                if cfg.esp_text then
                    entry.Label.Text = ESP.Describe(entry, distance)
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

Feat.Tracers = { Lines = {}, Gui = nil }
local Tracers = Feat.Tracers

function Tracers.Backend()
    if Tracers.Gui and Tracers.Gui.Parent then
        return Tracers.Gui
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "DominantTracers"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 40
    local parent = (type(gethui) == "function" and gethui()) or Svc.CoreGui
    local ok = pcall(function()
        gui.Parent = parent
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    Tracers.Gui = gui
    return gui
end

function Tracers.NewLine()
    if type(Drawing) == "table" and type(Drawing.new) == "function" then
        local ok, line = pcall(Drawing.new, "Line")
        if ok and line then
            line.Visible = false
            line.Transparency = 1
            return {
                Set = function(_, from, to, color, thickness)
                    line.From, line.To, line.Color, line.Thickness = from, to, color, thickness
                    line.Visible = true
                end,
                Hide = function()
                    line.Visible = false
                end,
                Destroy = function()
                    pcall(function()
                        line:Remove()
                    end)
                end,
            }
        end
    end
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Visible = false
    frame.Parent = Tracers.Backend()
    return {
        Set = function(_, from, to, color, thickness)
            local delta = to - from
            frame.BackgroundColor3 = color
            frame.Size = UDim2.fromOffset(delta.Magnitude, thickness)
            frame.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
            frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
            frame.Visible = true
        end,
        Hide = function()
            frame.Visible = false
        end,
        Destroy = function()
            frame:Destroy()
        end,
    }
end

function Tracers.Origin(camera)
    local size = camera.ViewportSize
    local mode = Dominant.Cfg.esp_tracer_origin
    if mode == "Center" then
        return Vector2.new(size.X / 2, size.Y / 2)
    elseif mode == "Mouse" then
        return UIS:GetMouseLocation()
    end
    return Vector2.new(size.X / 2, size.Y)
end

function Tracers.Step()
    local cfg = Dominant.Cfg
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local origin = Tracers.Origin(camera)
    for target, entry in pairs(ESP.Objects) do
        local line = Tracers.Lines[target]
        if not line then
            line = Tracers.NewLine()
            Tracers.Lines[target] = line
        end
        local position = ESP.Position(target)
        if position and cfg.esp then
            local screen, visible = camera:WorldToViewportPoint(position)
            if visible then
                line:Set(origin, Vector2.new(screen.X, screen.Y), ESP.Color(entry.Kind), cfg.esp_tracer_thickness)
            else
                line:Hide()
            end
        else
            line:Hide()
        end
    end
    for target, line in pairs(Tracers.Lines) do
        if not ESP.Objects[target] then
            line:Destroy()
            Tracers.Lines[target] = nil
        end
    end
end

function Tracers.Clear()
    for target, line in pairs(Tracers.Lines) do
        line:Destroy()
        Tracers.Lines[target] = nil
    end
    if Tracers.Gui then
        Tracers.Gui:Destroy()
        Tracers.Gui = nil
    end
end

hook("esp_tracers", function(value)
    if value then
        Dominant.BindFrame("tracers", "RenderStepped", Tracers.Step)
    else
        Dominant.UnbindFrame("tracers")
        Tracers.Clear()
    end
end)

Feat.World = { Watching = false }
local World = Feat.World

function World.DoorsFolder()
    local map = Game.MapModel()
    return map and (map:FindFirstChild("KillerDoors", true) or map:FindFirstChild("Killer Doors", true))
end

function World.KillerOnly()
    local map = Game.MapModel()
    return map and map:FindFirstChild("KillerOnly", true)
end

function World.ApplyKillerWalls()
    local disabled = Dominant.Cfg.kill_walls
    local doors = World.DoorsFolder()
    if not doors then
        return
    end
    local only = World.KillerOnly()
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

function World.ApplyFolders()
    local ingame = Game.Ingame()
    if not ingame then
        return
    end
    local cfg = Dominant.Cfg
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

function World.Watch()
    if World.Watching then
        return
    end
    local ingame = Game.Ingame()
    if not ingame then
        return
    end
    World.Watching = true
    Dominant.Connect(ingame.ChildAdded, function(child)
        task.wait()
        if child.Name == "Map" then
            task.delay(2, World.ApplyKillerWalls)
        elseif child:IsA("Folder") and (child.Name:find("JohnDoeTrail") or child.Name:find("Shadows")) then
            local function tune(part)
                if part:IsA("BasePart") then
                    local trail = child.Name:find("JohnDoeTrail") ~= nil
                    part.CanTouch = not (trail and Dominant.Cfg.no_trails or (not trail) and Dominant.Cfg.no_footprints)
                end
            end
            for _, part in ipairs(child:GetChildren()) do
                tune(part)
            end
            child.ChildAdded:Connect(tune)
        elseif child.Name == "SpikeCollision" then
            task.delay(3.5, World.ApplyFolders)
        end
    end)
end

for _, key in ipairs({ "no_trails", "no_footprints", "small_spikes" }) do
    hook(key, function()
        World.Watch()
        World.ApplyFolders()
    end)
end

hook("kill_walls", function()
    World.Watch()
    World.ApplyKillerWalls()
end)

function World.TeleportToGenerator(random)
    local target
    if random then
        local list = Game.Generators()
        target = list[math.random(1, math.max(#list, 1))]
    else
        target = Game.NearestGenerator(true) or Game.NearestGenerator(false)
    end
    local position = target and Game.GeneratorPosition(target)
    if not position then
        Dominant.Notify(L("n_no_gen"), "warning", 3)
        return
    end
    Game.Teleport(CFrame.new(position + Vector3.new(0, 3.5, 5)))
end

function World.TeleportToItem()
    local root = Dominant.State.Root
    if not root then
        return
    end
    local best, bestDistance
    for _, tool in ipairs(Game.Items()) do
        local part = Game.ToolPart(tool)
        if part then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = part, distance
            end
        end
    end
    if not best then
        Dominant.Notify(L("n_no_item"), "warning", 3)
        return
    end
    Game.Teleport(CFrame.new(best.Position + Vector3.new(0, 3, 0)))
end

function World.CollectItems()
    local count = Feat.Pickup.Collect(60)
    if count == 0 then
        Dominant.Notify(L("n_no_item"), "warning", 3)
    else
        Dominant.Notify(L("n_collected", count), "success", 3)
    end
end

Feat.Anim = { Loops = {}, Custom = {} }
local Anim = Feat.Anim

function Anim.Load(id)
    local animator = Dominant.State.Animator
    if not animator then
        return nil
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = id:find("rbxassetid") and id or ("rbxassetid://" .. id)
    local ok, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    return ok and track or nil
end

function Anim.PlayId(id, kind)
    local now = os.clock()
    if Anim.Custom[kind] and now - Anim.Custom[kind] < 3 then
        return
    end
    Anim.Custom[kind] = now
    local track = Anim.Load(id)
    if track then
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()
    end
end

function Anim.StartLoop(key, id, offset)
    Anim.StopLoop(key)
    local track = Anim.Load(id)
    if not track then
        return
    end
    track.Looped = true
    track:Play()
    if offset then
        track.TimePosition = offset
    end
    Anim.Loops[key] = track
end

function Anim.StopLoop(key)
    local track = Anim.Loops[key]
    if track then
        pcall(function()
            track:Stop()
        end)
        Anim.Loops[key] = nil
    end
end

function Anim.StopAll()
    for key in pairs(Anim.Loops) do
        Anim.StopLoop(key)
    end
    local animator = Dominant.State.Animator
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end
    end
end

hook("goon", function(value)
    if value then
        Anim.StartLoop("goon", "rbxassetid://72042024")
    else
        Anim.StopLoop("goon")
    end
end)

hook("laydown", function(value)
    if value then
        Anim.StartLoop("laydown", "rbxassetid://181526230", 0.2)
    else
        Anim.StopLoop("laydown")
    end
end)

Dominant.OnCharacter(function()
    Anim.Loops = {}
    if Dominant.Cfg.goon then
        task.delay(0.5, function()
            Anim.StartLoop("goon", "rbxassetid://72042024")
        end)
    end
    if Dominant.Cfg.laydown then
        task.delay(0.5, function()
            Anim.StartLoop("laydown", "rbxassetid://181526230", 0.2)
        end)
    end
end)

function Anim.ReplaceStep()
    local animator = Dominant.State.Animator
    local cfg = Dominant.Cfg
    if not animator then
        return
    end
    local groups = {
        { "block", cfg.custom_block_on, cfg.custom_block_id, Combat.BlockAnims },
        { "punch", cfg.custom_punch_on, cfg.custom_punch_id, Combat.PunchAnims },
        { "charge", cfg.custom_charge_on, cfg.custom_charge_id, Combat.ChargeAnims },
    }
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local id = Combat.AnimId(track)
        for _, group in ipairs(groups) do
            local kind, enabled, custom, list = group[1], group[2], group[3], group[4]
            if enabled and custom ~= "" and id and table.find(list, id) and id ~= custom then
                local last = Anim.Custom[kind]
                if not last or os.clock() - last >= 3 then
                    track:Stop()
                    Anim.PlayId(custom, kind)
                    return
                end
            end
        end
    end
end

function Anim.RefreshReplace()
    local cfg = Dominant.Cfg
    if cfg.custom_block_on or cfg.custom_punch_on or cfg.custom_charge_on then
        Dominant.StartLoop("animreplace", 0.1, Anim.ReplaceStep)
    else
        Dominant.StopLoop("animreplace")
    end
end

for _, key in ipairs({ "custom_block_on", "custom_punch_on", "custom_charge_on" }) do
    hook(key, Anim.RefreshReplace)
end

Feat.Audio = {
    Songs = {
        ["Burnout"] = "rbxassetid://130101085745481",
        ["Compass"] = "rbxassetid://127298326178102",
        ["Vanity"] = "rbxassetid://137266220091579",
        ["Close To Me"] = "rbxassetid://90022574613230",
        ["Plead"] = "rbxassetid://80564889711353",
        ["Creation Of Hatred"] = "rbxassetid://115884097233860",
    },
    SongOrder = { "Burnout", "Compass", "Vanity", "Close To Me", "Plead", "Creation Of Hatred" },
}
local Audio = Feat.Audio

function Audio.Player()
    local sound = Dominant.Objects.sound
    if sound and sound.Parent then
        return sound
    end
    sound = Instance.new("Sound")
    sound.Name = "DominantSound"
    sound.Looped = false
    sound.Parent = workspace
    Dominant.Objects.sound = sound
    return sound
end

function Audio.Play(text)
    local id = tonumber((tostring(text):gsub("%D", "")))
    if not id then
        Dominant.Notify(L("n_sound_bad"), "warning", 3)
        return
    end
    local sound = Audio.Player()
    sound.Volume = Dominant.Cfg.sound_volume
    sound.SoundId = "rbxassetid://" .. id
    sound:Play()
end

function Audio.Stop()
    local sound = Dominant.Objects.sound
    if sound then
        sound:Stop()
    end
end

hook("sound_volume", function(value)
    local sound = Dominant.Objects.sound
    if sound then
        sound.Volume = value
    end
end)

function Audio.ReplaceLms()
    local song = Audio.Songs[Dominant.Cfg.lms_song]
    if not song then
        return
    end
    Dominant.Notify(L("n_lms_wait"), "info", 3)
    task.spawn(function()
        local themes = workspace:WaitForChild("Themes", 30)
        local theme = themes and themes:WaitForChild("LastSurvivor", 120)
        if theme then
            theme.SoundId = song
            theme:Play()
            Dominant.Notify(L("n_lms_ok"), "success", 3)
        end
    end)
end

Feat.Server = {}
local Server = Feat.Server

function Server.QueueReload()
    if CONFIG.LoaderUrl == "" then
        return
    end
    local queue = queue_on_teleport or (syn and syn.queue_on_teleport)
    if queue then
        pcall(queue, string.format("loadstring(game:HttpGet(%q))()", CONFIG.LoaderUrl))
    end
end

function Server.Rejoin()
    Dominant.Notify(L("n_rejoining"), "info", 3)
    Server.QueueReload()
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining")
            task.wait()
            Svc.TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            Svc.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

function Server.Hop()
    task.spawn(function()
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        local ok, body = pcall(function()
            return game:HttpGet(url)
        end)
        local data = ok and select(2, pcall(function()
            return Svc.HttpService:JSONDecode(body)
        end))
        local choices = {}
        if type(data) == "table" and type(data.data) == "table" then
            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers - 1 then
                    table.insert(choices, server.id)
                end
            end
        end
        if #choices == 0 then
            Dominant.Notify(L("n_serverhop_fail"), "warning", 4)
            return
        end
        Dominant.Notify(L("n_serverhop"), "info", 3)
        Server.QueueReload()
        pcall(function()
            Svc.TeleportService:TeleportToPlaceInstance(game.PlaceId, choices[math.random(1, #choices)], LocalPlayer)
        end)
    end)
end

hook("auto_rejoin", function(value)
    Dominant.Disconnect(Dominant.Objects.autoRejoin)
    Dominant.Objects.autoRejoin = nil
    if value then
        Dominant.Objects.autoRejoin = Svc.GuiService.ErrorMessageChanged:Connect(function(message)
            if message and message ~= "" and not Dominant.State.Unloading then
                Server.Rejoin()
            end
        end)
    end
end)

hook("fps_cap_on", function(value)
    if not Dominant.Caps.fps then
        if value then
            Dominant.Notify(L("n_unsupported"), "warning", 3)
        end
        return
    end
    setfpscap(value and Dominant.Cfg.fps_cap or 0)
end)

hook("fps_cap", function(value)
    if Dominant.Caps.fps and Dominant.Cfg.fps_cap_on then
        setfpscap(value)
    end
end)

Feat.Performance = { Saved = nil }
hook("performance_mode", function(value)
    local lighting = Svc.Lighting
    local rendering
    pcall(function()
        rendering = settings().Rendering
    end)
    if value then
        Feat.Performance.Saved = Feat.Performance.Saved or {
            Quality = rendering and rendering.QualityLevel,
            Shadows = lighting.GlobalShadows,
        }
        pcall(function()
            rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        lighting.GlobalShadows = false
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
    elseif Feat.Performance.Saved then
        pcall(function()
            rendering.QualityLevel = Feat.Performance.Saved.Quality
        end)
        lighting.GlobalShadows = Feat.Performance.Saved.Shadows
        Feat.Performance.Saved = nil
    end
end)

Feat.HUD = { Gui = nil, Frames = 0, Last = 0 }
function Feat.HUD.Build()
    if Feat.HUD.Gui and Feat.HUD.Gui.Parent then
        return Feat.HUD.Gui
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "DominantHUD"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 60
    local parent = (type(gethui) == "function" and gethui()) or Svc.CoreGui
    local ok = pcall(function()
        gui.Parent = parent
    end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    local label = Instance.new("TextLabel")
    label.Name = "Stats"
    label.AnchorPoint = Vector2.new(0, 0)
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
    Feat.HUD.Gui = gui
    return gui
end

hook("hud", function(value)
    if not value then
        Dominant.UnbindFrame("hud")
        if Feat.HUD.Gui then
            Feat.HUD.Gui:Destroy()
            Feat.HUD.Gui = nil
        end
        return
    end
    local gui = Feat.HUD.Build()
    Feat.HUD.Frames, Feat.HUD.Last = 0, os.clock()
    Dominant.BindFrame("hud", "RenderStepped", function()
        Feat.HUD.Frames += 1
        local now = os.clock()
        if now - Feat.HUD.Last >= 0.5 then
            local fps = math.floor(Feat.HUD.Frames / (now - Feat.HUD.Last) + 0.5)
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 2000)
            gui.Stats.Text = string.format("%s %d  |  %s %dms", L("hud_fps"), fps, L("hud_ping"), ping)
            Feat.HUD.Frames, Feat.HUD.Last = 0, now
        end
    end)
end)

function Dominant.CopyJobId()
    Dominant.Copy(game.JobId)
end

function Dominant.CopyJoinScript()
    Dominant.Copy(string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)", game.PlaceId, game.JobId))
end

function Dominant.ResetCharacter()
    local humanoid = Dominant.State.Humanoid
    if humanoid then
        humanoid.Health = 0
    end
end

Feat.AnimChanger = { Sets = nil, Names = {}, Index = {}, Cache = {} }
local AC = Feat.AnimChanger

local function animDigits(id)
    return tostring(id or ""):match("%d+")
end

function AC.Build()
    if AC.Sets then
        return AC.Sets
    end
    AC.Sets = {}
    if not Dominant.Caps.require then
        return AC.Sets
    end
    local assets = Svc.ReplicatedStorage:FindFirstChild("Assets")
    if not assets then
        return AC.Sets
    end
    for _, folderName in ipairs({ "Killers", "Survivors", "Skins" }) do
        local folder = assets:FindFirstChild(folderName)
        if folder then
            for _, object in ipairs(folder:GetDescendants()) do
                if object:IsA("ModuleScript") and object.Name == "Config" and object.Parent and not object.Parent:IsA("Model") then
                    local ok, data = pcall(require, object)
                    local animations = ok and type(data) == "table" and data.Animations
                    if type(animations) == "table" and type(data.DisplayName) == "string" and type(animations.Idle) == "string" and type(animations.Walk) == "string" and type(animations.Run) == "string" then
                        local name = data.DisplayName
                        if name:find("Milestone") then
                            name = object.Parent.Parent.Name .. " " .. (name:gsub("Milestone ", ""))
                        end
                        if not AC.Sets[name] then
                            AC.Sets[name] = {
                                Idle = animDigits(animations.Idle),
                                Walk = animDigits(animations.Walk),
                                Run = animDigits(animations.Run),
                            }
                            table.insert(AC.Names, name)
                            for kind, id in pairs(AC.Sets[name]) do
                                AC.Index[id] = kind
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(AC.Names)
    return AC.Sets
end

function AC.StopOverrides()
    for id, track in pairs(AC.Cache) do
        pcall(function()
            track:Stop(0.2)
        end)
        AC.Cache[id] = nil
    end
end

function AC.Track(animator, id)
    local track = AC.Cache[id]
    if track then
        return track
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. id
    animation:SetAttribute("DominantOverride", true)
    local ok, loaded = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    if ok and loaded then
        loaded.Looped = true
        loaded.Priority = Enum.AnimationPriority.Movement
        AC.Cache[id] = loaded
        return loaded
    end
    return nil
end

function AC.Step()
    local set = AC.Sets and AC.Sets[Dominant.Cfg.anim_changer]
    local animator = Dominant.State.Animator
    local humanoid = Dominant.State.Humanoid
    if not set or not animator or not humanoid or not animator.Parent then
        return
    end
    local sprint = Dominant.Objects.sprintModule or Game.SprintModule()
    Dominant.Objects.sprintModule = sprint
    local moving = humanoid.MoveDirection ~= Vector3.zero
    local kind = "Idle"
    if moving then
        kind = (sprint and sprint.IsSprinting) and "Run" or "Walk"
    end
    local wanted = set[kind]
    if not wanted then
        return
    end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local animation = track.Animation
        local id = animation and animDigits(animation.AnimationId)
        if animation and animation:GetAttribute("DominantOverride") then
            if id ~= wanted then
                track:Stop(0.2)
            end
        elseif id and AC.Index[id] then
            track:Stop(0.2)
        end
    end
    local override = AC.Track(animator, wanted)
    if override and not override.IsPlaying then
        override:Play(0.15)
    end
end

hook("anim_changer", function(value)
    if value == "Original" then
        Dominant.StopLoop("animchanger")
        AC.StopOverrides()
        return
    end
    AC.Build()
    if not AC.Sets[value] then
        Dominant.RequireMissing("anim_changer", "require")
        return
    end
    AC.StopOverrides()
    Dominant.StartLoop("animchanger", 0.1, AC.Step)
end)

Dominant.OnCharacter(function()
    AC.Cache = {}
end)

Feat.Extras = {}
local Extras = Feat.Extras

function Extras.SprintStep()
    local module = Dominant.Objects.sprintModule
    if not module then
        module = Game.SprintModule()
        Dominant.Objects.sprintModule = module
    end
    if module and not module.IsSprinting then
        module.IsSprinting = true
        if module.__sprintedEvent then
            pcall(function()
                module.__sprintedEvent:Fire(true)
            end)
        end
    end
end

hook("always_sprint", function(value)
    if value then
        if not Dominant.Caps.require then
            Dominant.RequireMissing("always_sprint", "require")
            return
        end
        Dominant.BindFrame("alwayssprint", "Heartbeat", Extras.SprintStep)
    else
        Dominant.UnbindFrame("alwayssprint")
        local module = Dominant.Objects.sprintModule
        if module then
            module.IsSprinting = false
            if module.__sprintedEvent then
                pcall(function()
                    module.__sprintedEvent:Fire(false)
                end)
            end
        end
    end
end)

function Extras.TeleportToRole(role)
    local root = Dominant.State.Root
    local folder = role == "killer" and Game.Killers() or Game.Survivors()
    if not root or not folder then
        return
    end
    local best, bestDistance
    for _, model in ipairs(folder:GetChildren()) do
        local part = model ~= Dominant.State.Character and model:FindFirstChild("HumanoidRootPart")
        if part then
            local distance = (part.Position - root.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                best, bestDistance = part, distance
            end
        end
    end
    if not best then
        Dominant.Notify(L("n_no_target"), "warning", 3)
        return
    end
    Game.Teleport(best.CFrame * CFrame.new(0, 0, 5))
end

hook("spectate_killer", function(value)
    local camera = workspace.CurrentCamera
    if not value then
        Dominant.UnbindFrame("spectate")
        local humanoid = Dominant.State.Humanoid
        if camera and humanoid then
            camera.CameraSubject = humanoid
        end
        return
    end
    Dominant.BindFrame("spectate", "RenderStepped", function()
        local current = workspace.CurrentCamera
        local killers = Game.Killers()
        local killer = killers and killers:GetChildren()[1]
        local humanoid = killer and killer:FindFirstChildOfClass("Humanoid")
        if current and humanoid then
            current.CameraSubject = humanoid
        end
    end)
end)

Feat.Ring = {}
local Ring = Feat.Ring

function Ring.Step()
    local root = Dominant.State.Root
    if not root then
        return
    end
    local items = Game.Items()
    local limit = math.min(#items, 40)
    if limit == 0 then
        return
    end
    local cfg = Dominant.Cfg
    local base = os.clock() * cfg.ring_speed
    local index = 0
    for _, tool in ipairs(items) do
        if index >= limit then
            break
        end
        local handle = tool.Parent ~= Dominant.State.Character and Game.ToolPart(tool)
        if handle then
            index += 1
            local angle = base + (index / limit) * math.pi * 2
            handle.CanCollide = false
            handle.AssemblyLinearVelocity = Vector3.zero
            handle.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(angle) * cfg.ring_radius, 1.5, math.sin(angle) * cfg.ring_radius))
        end
    end
end

hook("item_ring", function(value)
    if value then
        Dominant.BindFrame("itemring", "RenderStepped", Ring.Step)
    else
        Dominant.UnbindFrame("itemring")
    end
end)

hook("click_tp", function(value)
    Dominant.Disconnect(Dominant.Objects.clickTp)
    Dominant.Objects.clickTp = nil
    if not value then
        return
    end
    Dominant.Objects.clickTp = UIS.InputBegan:Connect(function(input, processed)
        if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 or not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            return
        end
        local hit = LocalPlayer:GetMouse().Hit
        if hit then
            Game.Teleport(CFrame.new(hit.Position + Vector3.new(0, 3, 0)))
        end
    end)
end)

Ring.LastAlert = 0
hook("killer_alert", function(value)
    if not value then
        Dominant.StopLoop("killeralert")
        return
    end
    Dominant.StartLoop("killeralert", 0.5, function()
        if not Combat.IsSurvivor() or os.clock() - Ring.LastAlert < 6 then
            return
        end
        local killer, distance = Game.NearestKiller(Dominant.Cfg.alert_range)
        if killer then
            Ring.LastAlert = os.clock()
            Dominant.Notify(L("n_killer_near", math.floor(distance)), "warning", 3)
        end
    end)
end)

function Ring.Target()
    local player = Dominant.Objects.selectedPlayer
    if player and player.Parent == Players then
        return player
    end
    return nil
end

function Ring.TeleportToPlayer()
    local player = Ring.Target()
    local part = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not part then
        Dominant.Notify(L("n_no_target"), "warning", 3)
        return
    end
    Game.Teleport(part.CFrame * CFrame.new(0, 0, 5))
end

function Ring.StopSpectate()
    Dominant.UnbindFrame("spectateplayer")
    local camera = workspace.CurrentCamera
    local humanoid = Dominant.State.Humanoid
    if camera and humanoid then
        camera.CameraSubject = humanoid
    end
end

function Ring.Spectate()
    local player = Ring.Target()
    if not player then
        Dominant.Notify(L("n_no_target"), "warning", 3)
        return
    end
    Dominant.BindFrame("spectateplayer", "RenderStepped", function()
        local camera = workspace.CurrentCamera
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if camera and humanoid then
            camera.CameraSubject = humanoid
        end
    end)
end

function Ring.PlayerNames()
    local names, lookup = {}, {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local label = player.DisplayName .. " (@" .. player.Name .. ")"
            table.insert(names, label)
            lookup[label] = player
        end
    end
    table.sort(names)
    if #names == 0 then
        names = { "-" }
    end
    return names, lookup
end


Feat.Background = {
    Root = "Dominant/Backgrounds",
    Ext = { png = true, jpg = true, jpeg = true, gif = true },
    Gui = nil,
    Selected = nil,
    GifToken = nil,
    GifFrames = nil,
}

function Feat.Background.Ensure()
    ensureFolder("Dominant")
    ensureFolder(Feat.Background.Root)
end

function Feat.Background.IsImage(path)
    local lower = string.lower(tostring(path or ""))
    local ext = lower:match("%.([%w]+)$")
    return ext and Feat.Background.Ext[ext] == true
end

function Feat.Background.IsGif(path)
    return string.lower(tostring(path or "")):match("%.gif$") ~= nil
end

function Feat.Background.Basename(path)
    return tostring(path or ""):gsub("\\", "/"):match("([^/]+)$") or tostring(path)
end

function Feat.Background.Tree(path, depth)
    depth = depth or 0
    local nodes = {}
    if type(listfiles) ~= "function" then
        return nodes
    end
    path = path or Feat.Background.Root
    local ok, entries = pcall(listfiles, path)
    if not ok or type(entries) ~= "table" then
        return nodes
    end
    local folders, files = {}, {}
    for _, entry in ipairs(entries) do
        local name = Feat.Background.Basename(entry)
        local isDir = false
        if type(isfolder) == "function" then
            local folderOk, folder = pcall(isfolder, entry)
            isDir = folderOk and folder == true
        end
        if isDir then
            table.insert(folders, { Path = entry, Name = name, Depth = depth, Kind = "folder" })
        elseif Feat.Background.IsImage(entry) then
            table.insert(files, {
                Path = entry,
                Name = name,
                Depth = depth,
                Kind = "file",
                Gif = Feat.Background.IsGif(entry),
            })
        end
    end
    table.sort(folders, function(a, b) return a.Name:lower() < b.Name:lower() end)
    table.sort(files, function(a, b) return a.Name:lower() < b.Name:lower() end)
    for _, folder in ipairs(folders) do
        table.insert(nodes, folder)
        if depth < 8 then
            for _, child in ipairs(Feat.Background.Tree(folder.Path, depth + 1)) do
                table.insert(nodes, child)
            end
        end
    end
    for _, file in ipairs(files) do
        table.insert(nodes, file)
    end
    return nodes
end

function Feat.Background.List(path, depth)
    local nodes = Feat.Background.Tree(path, depth)
    local files = {}
    for _, node in ipairs(nodes) do
        if node.Kind == "file" then
            table.insert(files, node)
        end
    end
    return files
end

function Feat.Background.Resolve(path)
    if not path or path == "" then
        return nil
    end
    path = tostring(path):gsub("\\", "/")
    if path:match("^%d+$") then
        return "rbxassetid://" .. path
    end
    if path:find("rbxassetid://", 1, true) or path:find("rbxthumb://", 1, true) or path:find("rbxasset://", 1, true) then
        return path
    end
    local candidates = {}
    local function push(fn)
        if type(fn) == "function" then
            table.insert(candidates, fn)
        end
    end
    push(getcustomasset)
    push(getsynasset)
    if type(getgenv) == "function" then
        local g = getgenv()
        push(g.getcustomasset)
        push(g.getsynasset)
    end
    if type(getfenv) == "function" then
        local okEnv, env = pcall(getfenv)
        if okEnv and type(env) == "table" then
            push(env.getcustomasset)
            push(env.getsynasset)
        end
    end
    local tries = {
        path,
        path:gsub("^%./", ""),
        "workspace/" .. path,
        "Workspace/" .. path,
    }
    local name = path:match("([^/]+)$")
    if name then
        table.insert(tries, "Dominant/Backgrounds/" .. name)
        table.insert(tries, name)
    end
    for _, fn in ipairs(candidates) do
        for _, tryPath in ipairs(tries) do
            local ok, asset = pcall(fn, tryPath)
            if ok and type(asset) == "string" and asset ~= "" then
                return asset
            end
        end
    end
    return nil
end

function Feat.Background.StopGif()
    Feat.Background.GifToken = nil
    Feat.Background.GifFrames = nil
end

function Feat.Background.CollectFrames(gifPath)
    local frames = {}
    local stem = Feat.Background.Basename(gifPath):gsub("%.[^%.]+$", "")
    local candidates = {
        Feat.Background.Root .. "/frames/" .. stem,
        Feat.Background.Root .. "/" .. stem .. "_frames",
        Feat.Background.Root .. "/" .. stem,
        "gif_player/frames",
    }
    local function pushFolder(folder)
        if type(listfiles) ~= "function" then
            return
        end
        local ok, entries = pcall(listfiles, folder)
        if not ok or type(entries) ~= "table" then
            return
        end
        local ordered = {}
        for _, entry in ipairs(entries) do
            local lower = string.lower(tostring(entry))
            if lower:match("%.png$") or lower:match("%.jpg$") or lower:match("%.jpeg$") then
                table.insert(ordered, entry)
            end
        end
        table.sort(ordered)
        for _, entry in ipairs(ordered) do
            local asset = Feat.Background.Resolve(entry)
            if asset then
                table.insert(frames, asset)
            end
        end
    end
    for _, folder in ipairs(candidates) do
        if type(isfolder) == "function" then
            local ok, isDir = pcall(isfolder, folder)
            if ok and isDir then
                pushFolder(folder)
                if #frames > 0 then
                    return frames
                end
            end
        end
    end
    local numbered = {}
    for i = 1, 5000 do
        local png = string.format("%s/frame_%04d.png", Feat.Background.Root, i)
        local jpg = string.format("%s/frame_%04d.jpg", Feat.Background.Root, i)
        local path = nil
        if type(isfile) == "function" then
            local okPng, hasPng = pcall(isfile, png)
            local okJpg, hasJpg = pcall(isfile, jpg)
            if okPng and hasPng then
                path = png
            elseif okJpg and hasJpg then
                path = jpg
            end
        end
        if not path then
            break
        end
        local asset = Feat.Background.Resolve(path)
        if asset then
            table.insert(numbered, asset)
        end
    end
    if #numbered > 0 then
        return numbered
    end
    return frames
end

function Feat.Background.GetBackgroundImage()
    local window = Dominant.Window
    if not window then
        return nil
    end
    if window._BackgroundImage and window._BackgroundImage.Parent then
        return window._BackgroundImage
    end
    local gui = window._gui or window.Instance
    if gui then
        local existing = gui:FindFirstChild("WindowBackground")
        if existing and existing:IsA("ImageLabel") then
            return existing
        end
    end
    return nil
end

function Feat.Background.PlayGif(frames, fps)
    Feat.Background.StopGif()
    if not frames or #frames == 0 then
        return false
    end
    local token = {}
    Feat.Background.GifToken = token
    Feat.Background.GifFrames = frames
    fps = math.clamp(tonumber(fps) or 12, 1, 60)
    local delay = 1 / fps
    task.spawn(function()
        local index = 1
        while Feat.Background.GifToken == token and not Dominant.State.Unloading do
            local image = Feat.Background.GetBackgroundImage()
            if image then
                image.Image = frames[index]
                image.ImageTransparency = math.clamp(tonumber(Dominant.Cfg.bg_transparency) or 0.7, 0, 1)
                image.Visible = true
            end
            index += 1
            if index > #frames then
                index = 1
            end
            task.wait(delay)
        end
    end)
    return true
end

function Feat.Background.Apply(path, opts)
    opts = opts or {}
    local silent = opts.Silent == true
    local window = Dominant.Window
    Feat.Background.StopGif()
    local transparency = math.clamp(tonumber(Dominant.Cfg.bg_transparency) or 0.45, 0, 1)
    local scaleName = tostring(opts.ScaleType or Dominant.Cfg.bg_scale or "Crop")
    local winTransparency = math.clamp(tonumber(Dominant.Cfg.bg_window_transparency) or 0.35, 0, 1)

    local function syncFlag(flag, value)
        local api = Dominant.Vind and Dominant.Vind.Flags and Dominant.Vind.Flags[flag]
        if api and type(api.Set) == "function" then
            pcall(function()
                api:Set(value, true)
            end)
        end
    end

    local function persist(enabled, storedPath)
        Dominant.Cfg.bg_enabled = enabled and true or false
        Dominant.Cfg.bg_path = storedPath or ""
        Dominant.Cfg.bg_scale = scaleName
        if not silent then
            syncFlag("bg_enabled", Dominant.Cfg.bg_enabled)
            Dominant.QueueSave(true)
        end
    end

    local function getGui()
        if not window then
            return nil
        end
        return window._gui or window.Instance or (window.GetGui and window:GetGui())
    end

    local function scaleEnum()
        if scaleName == "Fit" then
            return Enum.ScaleType.Fit
        elseif scaleName == "Stretch" then
            return Enum.ScaleType.Stretch
        end
        return Enum.ScaleType.Crop
    end

    local function forceImage(asset, sourcePath)
        if not window then
            return false
        end
        local okSet = false
        if type(window.SetBackground) == "function" then
            okSet = pcall(function()
                window:SetBackground({
                    Image = asset or "",
                    SourcePath = sourcePath or path or "",
                    Transparency = transparency,
                    ScaleType = scaleName,
                })
            end)
        end
        local gui = getGui()
        local label = window._BackgroundImage
        if not label and gui then
            label = gui:FindFirstChild("WindowBackground")
        end
        if not label and gui then
            label = Instance.new("ImageLabel")
            label.Name = "WindowBackground"
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.ScaleType = scaleEnum()
            label.ZIndex = 1
            label.Parent = gui
            window._BackgroundImage = label
        end
        if label then
            label.Image = asset or ""
            label.ImageTransparency = transparency
            label.Visible = type(asset) == "string" and asset ~= ""
            label.ScaleType = scaleEnum()
            if gui and label.Parent ~= gui then
                label.Parent = gui
            end
            window._BackgroundImage = label
        end
        if type(window.SetBackgroundTransparency) == "function" then
            pcall(function()
                window:SetBackgroundTransparency(winTransparency)
            end)
        elseif gui and gui:IsA("GuiObject") then
            pcall(function()
                gui.BackgroundTransparency = winTransparency
            end)
        end
        local applied = type(asset) == "string" and asset ~= "" and label and label.Image ~= ""
        return okSet or applied and true or false
    end

    if not path or path == "" then
        if window then
            forceImage("")
            if type(window.ClearBackground) == "function" then
                pcall(function()
                    window:ClearBackground()
                end)
            end
        end
        persist(false, "")
        return true
    end

    if not window then
        Dominant.Cfg.bg_path = path
        Dominant.Cfg.bg_enabled = true
        if not silent then
            Dominant.QueueSave(true)
        end
        return false
    end

    if Feat.Background.IsGif(path) then
        local frames = Feat.Background.CollectFrames(path)
        local first = Feat.Background.Resolve(path) or frames[1]
        if not first then
            Dominant.Warn("[Dominant] Background resolve failed: " .. tostring(path))
            return false
        end
        forceImage(first, path)
        if #frames > 1 then
            Feat.Background.PlayGif(frames, 12)
        end
        persist(true, path)
        return true
    end

    local asset = Feat.Background.Resolve(path)
    if not asset then
        Dominant.Warn("[Dominant] Background resolve failed: " .. tostring(path))
        if not silent then
            Dominant.Notify(L("bg_failed"), "error", 4)
        end
        return false
    end
    local ok = forceImage(asset, path)
    persist(true, path)
    Dominant.Log("[Background] " .. tostring(path) .. " -> " .. tostring(asset))
    return ok ~= false
end

function Feat.Background.Refresh()
    if not Dominant.Cfg.bg_enabled then
        Feat.Background.Apply("")
        return
    end
    if Dominant.Cfg.bg_path and Dominant.Cfg.bg_path ~= "" then
        Feat.Background.Apply(Dominant.Cfg.bg_path)
    end
end

function Feat.Background.CloseBrowser()
    if Feat.Background.Gui then
        pcall(function()
            Feat.Background.Gui:Destroy()
        end)
        Feat.Background.Gui = nil
    end
end

function Feat.Background.OpenBrowser()
    Feat.Background.Ensure()
    Feat.Background.CloseBrowser()

    local parent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
    local theme = {
        Bg = Color3.fromRGB(16, 16, 16),
        Surface = Color3.fromRGB(24, 24, 24),
        Card = Color3.fromRGB(30, 30, 34),
        Text = Color3.fromRGB(240, 240, 240),
        Dim = Color3.fromRGB(150, 150, 155),
        Accent = Color3.fromRGB(255, 90, 90),
        Border = Color3.fromRGB(255, 255, 255),
    }
    if Dominant.Vind and Dominant.Vind.Theme then
        local t = Dominant.Vind.Theme
        theme.Bg = t.Background or theme.Bg
        theme.Surface = t.Surface or theme.Surface
        theme.Card = t.Card or theme.Card
        theme.Text = t.Text or theme.Text
        theme.Dim = t.TextDim or theme.Dim
        theme.Accent = t.Accent or theme.Accent
    end

    local function corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    local function stroke(parent, transparency)
        local s = Instance.new("UIStroke")
        s.Color = theme.Border
        s.Transparency = transparency or 0.9
        s.Thickness = 1
        s.Parent = parent
        return s
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DominantBackgroundExplorer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10050
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    Feat.Background.Gui = gui

    local dim = Instance.new("TextButton")
    dim.Name = "Dim"
    dim.AutoButtonColor = false
    dim.Text = ""
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 0.5
    dim.Size = UDim2.fromScale(1, 1)
    dim.ZIndex = 1
    dim.Parent = gui

    local win = Instance.new("Frame")
    win.Name = "Explorer"
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.Size = UDim2.fromOffset(520, 340)
    win.BackgroundColor3 = theme.Bg
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.ZIndex = 2
    win.Parent = gui
    corner(win, 12)
    stroke(win, 0.88)

    local top = Instance.new("Frame")
    top.BackgroundTransparency = 1
    top.Size = UDim2.new(1, 0, 0, 40)
    top.ZIndex = 3
    top.Parent = win

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(14, 6)
    title.Size = UDim2.new(1, -50, 0, 16)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text
    title.Text = L("bg_browse")
    title.ZIndex = 4
    title.Parent = top

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(14, 22)
    subtitle.Size = UDim2.new(1, -50, 0, 14)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextColor3 = theme.Dim
    subtitle.Text = Feat.Background.Root
    subtitle.ZIndex = 4
    subtitle.Parent = top

    local closeBtn = Instance.new("TextButton")
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = theme.Dim
    closeBtn.BackgroundColor3 = theme.Card
    closeBtn.BackgroundTransparency = 0.25
    closeBtn.Size = UDim2.fromOffset(26, 26)
    closeBtn.Position = UDim2.new(1, -34, 0, 7)
    closeBtn.ZIndex = 5
    closeBtn.Parent = top
    corner(closeBtn, 7)

    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(12, 42)
    body.Size = UDim2.new(1, -24, 1, -86)
    body.ZIndex = 3
    body.Parent = win

    local side = Instance.new("Frame")
    side.BackgroundColor3 = theme.Surface
    side.BorderSizePixel = 0
    side.Size = UDim2.new(0.48, -4, 1, 0)
    side.ZIndex = 4
    side.Parent = body
    corner(side, 10)

    local sideScroll = Instance.new("ScrollingFrame")
    sideScroll.BackgroundTransparency = 1
    sideScroll.BorderSizePixel = 0
    sideScroll.Position = UDim2.fromOffset(6, 6)
    sideScroll.Size = UDim2.new(1, -12, 1, -12)
    sideScroll.ScrollBarThickness = 2
    sideScroll.ScrollBarImageColor3 = theme.Dim
    sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sideScroll.ZIndex = 5
    sideScroll.Parent = side
    local sideList = Instance.new("UIListLayout")
    sideList.Padding = UDim.new(0, 2)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Parent = sideScroll

    local preview = Instance.new("Frame")
    preview.BackgroundColor3 = theme.Surface
    preview.BorderSizePixel = 0
    preview.Position = UDim2.new(0.48, 4, 0, 0)
    preview.Size = UDim2.new(0.52, -4, 1, 0)
    preview.ZIndex = 4
    preview.Parent = body
    corner(preview, 10)

    local previewImage = Instance.new("ImageLabel")
    previewImage.BackgroundColor3 = theme.Card
    previewImage.BackgroundTransparency = 0.15
    previewImage.BorderSizePixel = 0
    previewImage.Position = UDim2.fromOffset(8, 8)
    previewImage.Size = UDim2.new(1, -16, 1, -58)
    previewImage.ScaleType = Enum.ScaleType.Crop
    previewImage.Image = ""
    previewImage.ZIndex = 5
    previewImage.Parent = preview
    corner(previewImage, 8)

    local previewName = Instance.new("TextLabel")
    previewName.BackgroundTransparency = 1
    previewName.Position = UDim2.new(0, 10, 1, -46)
    previewName.Size = UDim2.new(1, -20, 0, 16)
    previewName.Font = Enum.Font.GothamMedium
    previewName.TextSize = 12
    previewName.TextXAlignment = Enum.TextXAlignment.Left
    previewName.TextTruncate = Enum.TextTruncate.AtEnd
    previewName.TextColor3 = theme.Text
    previewName.Text = L("bg_no_files")
    previewName.ZIndex = 5
    previewName.Parent = preview

    local previewPath = Instance.new("TextLabel")
    previewPath.BackgroundTransparency = 1
    previewPath.Position = UDim2.new(0, 10, 1, -28)
    previewPath.Size = UDim2.new(1, -20, 0, 22)
    previewPath.Font = Enum.Font.Gotham
    previewPath.TextSize = 10
    previewPath.TextXAlignment = Enum.TextXAlignment.Left
    previewPath.TextYAlignment = Enum.TextYAlignment.Top
    previewPath.TextWrapped = true
    previewPath.TextColor3 = theme.Dim
    previewPath.Text = L("bg_folder_hint")
    previewPath.ZIndex = 5
    previewPath.Parent = preview

    local footer = Instance.new("Frame")
    footer.BackgroundTransparency = 1
    footer.Position = UDim2.new(0, 12, 1, -38)
    footer.Size = UDim2.new(1, -24, 0, 28)
    footer.ZIndex = 4
    footer.Parent = win
    local footerList = Instance.new("UIListLayout")
    footerList.FillDirection = Enum.FillDirection.Horizontal
    footerList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    footerList.Padding = UDim.new(0, 6)
    footerList.Parent = footer

    local function makeBtn(text, primary)
        local btn = Instance.new("TextButton")
        btn.AutoButtonColor = false
        btn.Text = text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextColor3 = primary and Color3.new(1, 1, 1) or theme.Text
        btn.BackgroundColor3 = primary and theme.Accent or theme.Card
        btn.BackgroundTransparency = primary and 0 or 0.1
        btn.Size = UDim2.fromOffset(primary and 88 or 78, 28)
        btn.ZIndex = 5
        btn.Parent = footer
        corner(btn, 8)
        return btn
    end

    local clearBtn = makeBtn(L("bg_clear"), false)
    local refreshBtn = makeBtn(L("bg_refresh"), false)
    local applyBtn = makeBtn(L("bg_apply"), true)

    local selectedRow, selectedNode = nil, nil

    local function selectNode(node, row)
        selectedNode = node
        Feat.Background.Selected = node and node.Path or nil
        if selectedRow and selectedRow.Parent then
            selectedRow.BackgroundTransparency = 1
        end
        selectedRow = row
        if row then
            row.BackgroundTransparency = 0.45
        end
        if node and node.Kind == "file" then
            local asset = Feat.Background.Resolve(node.Path)
            previewImage.Image = asset or ""
            previewName.Text = node.Name .. (node.Gif and "  · GIF" or "")
            previewPath.Text = node.Path
        else
            previewImage.Image = ""
            previewName.Text = node and node.Name or L("bg_no_files")
            previewPath.Text = node and node.Path or L("bg_folder_hint")
        end
    end

    local function rebuildTree()
        for _, child in ipairs(sideScroll:GetChildren()) do
            if child:IsA("GuiObject") and child ~= sideList then
                child:Destroy()
            end
        end
        local nodes = Feat.Background.Tree()
        if #nodes == 0 then
            local empty = Instance.new("TextLabel")
            empty.BackgroundTransparency = 1
            empty.Size = UDim2.new(1, 0, 0, 36)
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 11
            empty.TextColor3 = theme.Dim
            empty.TextWrapped = true
            empty.Text = L("bg_no_files")
            empty.ZIndex = 6
            empty.Parent = sideScroll
            selectNode(nil, nil)
            return
        end
        for index, node in ipairs(nodes) do
            local row = Instance.new("TextButton")
            row.AutoButtonColor = false
            row.Text = ""
            row.BackgroundColor3 = theme.Accent
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 24)
            row.LayoutOrder = index
            row.ZIndex = 6
            row.Parent = sideScroll
            corner(row, 6)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Position = UDim2.fromOffset(6 + node.Depth * 10, 0)
            label.Size = UDim2.new(1, -10 - node.Depth * 10, 1, 0)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.TextColor3 = node.Kind == "folder" and theme.Dim or theme.Text
            local prefix = node.Kind == "folder" and "▸ " or (node.Gif and "● " or "· ")
            label.Text = prefix .. node.Name
            label.ZIndex = 7
            label.Parent = row

            row.MouseButton1Click:Connect(function()
                selectNode(node, row)
            end)

            if Feat.Background.Selected and node.Path == Feat.Background.Selected then
                selectNode(node, row)
            end
        end
    end

    dim.MouseButton1Click:Connect(Feat.Background.CloseBrowser)
    closeBtn.MouseButton1Click:Connect(Feat.Background.CloseBrowser)
    refreshBtn.MouseButton1Click:Connect(function()
        Feat.Background.Ensure()
        rebuildTree()
        Dominant.Notify(L("bg_refresh"), "info", 2)
    end)
    clearBtn.MouseButton1Click:Connect(function()
        Feat.Background.Apply("")
        selectNode(nil, nil)
        Dominant.Notify(L("bg_clear"), "info", 2)
    end)
    applyBtn.MouseButton1Click:Connect(function()
        if not selectedNode or selectedNode.Kind ~= "file" then
            Dominant.Notify(L("bg_no_files"), "warning", 3)
            return
        end
        if Feat.Background.Apply(selectedNode.Path) then
            Dominant.Notify(L("bg_applied"), "success", 3)
            Feat.Background.CloseBrowser()
        else
            Dominant.Notify(L("bg_failed"), "error", 3)
        end
    end)

    rebuildTree()
end


hook("bg_enabled", function(value)
    if value then
        if Dominant.Cfg.bg_path and Dominant.Cfg.bg_path ~= "" then
            local ok = Feat.Background.Apply(Dominant.Cfg.bg_path)
            if not ok then
                Dominant.RestoreBackground()
            end
            task.defer(function()
                local window = Dominant.Window
                local label = window and (window._BackgroundImage or (window._gui and window._gui:FindFirstChild("WindowBackground")))
                if not label or label.Image == "" then
                    Dominant.RestoreBackground()
                end
            end)
            if not ok then
                local label = Dominant.Window and Dominant.Window._BackgroundImage
                if not (label and label.Image ~= "") then
                    Dominant.Cfg.bg_enabled = false
                    Dominant.QueueSave(true)
                    Dominant.Notify(L("bg_failed"), "error", 3)
                end
            end
        else
            Dominant.Cfg.bg_enabled = false
            Dominant.QueueSave(true)
            Dominant.Notify(L("bg_folder_hint"), "warning", 4)
        end
    else
        local pathKeep = Dominant.Cfg.bg_path
        Feat.Background.StopGif()
        local window = Dominant.Window
        if window then
            if type(window.ClearBackground) == "function" then
                pcall(function()
                    window:ClearBackground()
                end)
            elseif type(window.SetBackground) == "function" then
                pcall(function()
                    window:SetBackground({ Image = "" })
                end)
            end
        end
        Dominant.Cfg.bg_enabled = false
        Dominant.Cfg.bg_path = pathKeep or ""
        Dominant.QueueSave(true)
    end
end)

hook("bg_transparency", function(value)
    Dominant.Cfg.bg_transparency = math.clamp(tonumber(value) or 0.45, 0, 1)
    Dominant.QueueSave()
    local window = Dominant.Window
    if not window then
        return
    end
    if Dominant.Cfg.bg_enabled and Dominant.Cfg.bg_path ~= "" then
        if Feat.Background.IsGif(Dominant.Cfg.bg_path) and Feat.Background.GifFrames then
            local image = Feat.Background.GetBackgroundImage()
            if image then
                image.ImageTransparency = Dominant.Cfg.bg_transparency
            end
            return
        end
        if type(window.SetBackground) == "function" then
            local asset = Feat.Background.Resolve(Dominant.Cfg.bg_path)
            if asset then
                pcall(function()
                    window:SetBackground({
                        Image = asset,
                        SourcePath = Dominant.Cfg.bg_path,
                        Transparency = Dominant.Cfg.bg_transparency,
                        ScaleType = Dominant.Cfg.bg_scale or "Crop",
                    })
                end)
            end
        end
    end
end)

hook("bg_scale", function(value)
    Dominant.Cfg.bg_scale = tostring(value or "Crop")
    Dominant.QueueSave()
    if Dominant.Cfg.bg_enabled and Dominant.Cfg.bg_path ~= "" then
        Feat.Background.Apply(Dominant.Cfg.bg_path, { ScaleType = Dominant.Cfg.bg_scale })
    end
end)

hook("bg_window_transparency", function(value)
    Dominant.Cfg.bg_window_transparency = math.clamp(tonumber(value) or 0.35, 0, 1)
    Dominant.QueueSave()
    local window = Dominant.Window
    if window and type(window.SetBackgroundTransparency) == "function" then
        pcall(function()
            window:SetBackgroundTransparency(Dominant.Cfg.bg_window_transparency)
        end)
    end
end)


local UI = Dominant.UI
UI.Elements = {}

local ExtraStrings = {
    en = {
        block_range_esp = "Block Range Circle",
        block_range_esp_d = "Shows the auto block area around you",
        color_block_ring = "Block Range Color",
        log_version28 = "Dominant 1.9.4",
        log_date28 = "Update",
        log_46 = "Block range circle shows the auto block area around you",
        log_47 = "Removed duplicated ESP functions and unused stubs",
        tab_credits = "Credits",
        btn_open_credits = "Open Credits Tab",
        btn_open_credits_d = "Creates a tab with the people and projects behind Dominant",
        credits_section_people = "Creators",
        credits_section_tools = "Built With",
        credits_section_notice = "Notices",
        credit_jonathan = "Jonathan",
        credit_jonathan_d = "Creator and project owner",
        credit_claude = "Claude Sonnet 5.5",
        credit_claude_d = "Co-developer: code, script merging and interface",
        credit_grok = "Grok (latest version)",
        credit_grok_d = "Co-developer and idea support",
        credit_ana = "Ana",
        credit_ana_d = "Thanks for being part of Dominant",
        notice_vind = "Vind UI Reborn: interface library",
        notice_ophyn = "Ophyn: key system and loader",
        notice_naiko = "Forsaken Plus by Naiko Scripts: open source reference, original credits kept",
        notice_goon = "Goonsaken Hub: feature reference",
        notice_cursed = "CursedHub Forsaken by LSSOPS: ESP and remote reference",
        notice_noli = "Noli void rush control by skibidi399: Void Rush reference",
        notice_stamina = "Infinite stamina values from an open source sprint script",
        notice_disclaimer = "Each project belongs to its authors. Dominant only credits them.",
        timed_hop = "Timed Server Hop",
        timed_hop_d = "Switches to another server after the set number of minutes",
        timed_hop_minutes = "Minutes Per Server",
        log_version6 = "Dominant 1.1.0",
        log_date6 = "Update",
        log_16 = "Fixed features that needed a toggle off and on after loading",
        log_17 = "Timed server hop with its own minutes setting",
        log_18 = "Credits tab with creators and third-party notices",
        log_19 = "Infinite stamina also keeps stamina gain and max stamina set",
        credits_section_dominant = "Dominant Creators",
        log_version9 = "Dominant 1.1.4",
        log_date9 = "Fix",
        log_22 = "Background waits for the window to open before it is applied",
        log_23 = "Credits are sections with paragraphs, separated by project",
        log_version27 = "Dominant 1.9.3",
        log_date27 = "Fix",
        log_50 = "Shows status messages on screen at each step, adds the current game to the key system list and accepts the Forsaken layout",
        log_version26 = "Dominant 1.9.2",
        log_date26 = "Fix",
        log_49 = "Key system retries with the default logo, reports each failure to the console and can be skipped with DominantSkipKey",
        log_version25 = "Dominant 1.9.1",
        log_date25 = "Fix",
        log_48 = "Fixed a missing hotkey table that stopped the menu from finishing its build, so saved options and the background were not applied at startup",
        config_name = "Config Name",
        config_name_hint = "Type a name, e.g. legit or rage",
        config_pick = "Saved Configs",
        btn_config_save = "Save",
        btn_config_overwrite = "Overwrite",
        btn_config_load = "Load",
        btn_config_delete = "Delete",
        btn_config_autoload = "Set As Autoload",
        btn_config_refresh = "Refresh List",
        n_config_saved = "Config \"%s\" saved",
        n_config_exists = "Config \"%s\" already exists, use Overwrite",
        n_config_missing = "Config \"%s\" not found",
        n_config_loaded = "Config \"%s\" loaded",
        n_config_deleted = "Config \"%s\" deleted",
        n_config_autoload = "\"%s\" will load automatically",
        confirm_delete_title = "Delete config?",
        confirm_delete_text = "Delete \"%s\"? This cannot be undone.",
        log_version24 = "Dominant 1.9.0",
        log_date24 = "Update",
        log_46 = "Named configs with Save, Overwrite, Load and Delete, stored in the Dominant folder",
        log_47 = "Startup loads your autoload config, or your last session",
        sec_emotes = "Emotes",
        emote_pick = "Emote",
        btn_play_emote = "Play Emote",
        btn_stop_emote = "Stop Emote",
        n_emote_none = "No emote could be played",
        log_version23 = "Dominant 1.8.0",
        log_date23 = "Update",
        log_44 = "Self emote menu that plays emotes on your own character",
        log_45 = "Sprint and stamina fall back to the game table when require fails",
        guest_skip_special = "Skip Special Attacks",
        guest_skip_special_d = "Does not block Raging Pace or Gashing Wound (can skip fast killers)",
        auto_parry = "Auto Parry",
        auto_parry_d = "Fires the parry remote shortly after a block",
        no_fall = "No Fall Damage",
        no_fall_d = "Stops the falling states so landings do not hurt",
        esp_pallets = "Pallet ESP",
        esp_windows = "Window ESP",
        esp_chests = "Chest ESP",
        color_pallet = "Pallet ESP Color",
        color_window = "Window ESP Color",
        color_chest = "Chest ESP Color",
        log_version22 = "Dominant 1.7.0",
        log_date22 = "Update",
        log_42 = "Auto block skips killers in Raging Pace or Gashing Wound when enabled",
        log_43 = "Auto parry, no fall damage and ESP for pallets, windows and chests",
        guest_abh = "Hitbox Adjust",
        guest_abh_d = "Grows (+) or shrinks (-) the detection box for Auto Block",
        drag_block = "Drag Block",
        drag_block_d = "After a block, moves you toward the killer",
        drag_stop = "Stop Distance",
        drag_stop_d = "Studs from the killer where the drag stops",
        drag_hold = "Drag Duration",
        drag_hold_d = "Seconds the drag lasts",
        log_version21 = "Dominant 1.6.0",
        log_date21 = "Update",
        log_40 = "Auto Block now uses a detection box in front of you, like the reference script",
        log_41 = "Drag Block moves you toward the killer after a block",
        log_version20 = "Dominant 1.5.4",
        log_date20 = "Fix",
        log_39 = "Stamina re-reads the sprint module every second and logs its values to the Debug console",
        log_version19 = "Dominant 1.5.3",
        log_date19 = "Update",
        log_38 = "Auto block and punch work on mobile and PC through the game remote, the on-screen button or keys",
        log_version18 = "Dominant 1.5.2",
        log_date18 = "Fix",
        log_37 = "Block and punch fall back to keyboard keys when the game remote is missing",
        sprint_speed_on = "Custom Sprint Speed",
        sprint_speed_on_d = "Sets the sprint speed (max 40)",
        sprint_speed = "Sprint Speed",
        sprint_speed_d = "Value from 1 to 40",
        log_version17 = "Dominant 1.5.1",
        log_date17 = "Update",
        log_36 = "Custom sprint speed, up to 40",
        stamina_custom = "Custom Stamina",
        stamina_custom_d = "Uses your own max, regeneration and drain values",
        stamina_max = "Max Stamina",
        stamina_max_d = "Max stamina amount",
        stamina_regen = "Regeneration Per Second",
        stamina_regen_d = "How much stamina comes back each second when not sprinting",
        stamina_drain = "Drain Per Second",
        stamina_drain_d = "How much stamina is used each second while sprinting (0 = no drain)",
        log_version16 = "Dominant 1.5.0",
        log_date16 = "Update",
        log_34 = "Custom stamina: max, regeneration and drain per second",
        log_35 = "Saved options are switched off and on at startup so they start working",
        sec_tools = "Tools",
        btn_infinite_yield = "Run Infinite Yield",
        btn_infinite_yield_d = "Loads the Infinite Yield admin commands",
        btn_dex = "Run Dex Explorer++",
        btn_dex_d = "Loads the Dex Explorer++ instance viewer",
        n_tool_ok = "%s loaded",
        n_tool_fail = "Could not load %s",
        notice_infinite = "Infinite Yield by EdgeIY: admin commands, loaded only when you press the button",
        notice_dex = "Dex Explorer++ by AZYsGithub: instance explorer, loaded only when you press the button",
        log_version15 = "Dominant 1.4.0",
        log_date15 = "Update",
        log_33 = "Tools section runs Infinite Yield and Dex Explorer++ on demand",
        debug_sprint_found = "Sprint module found, infinite stamina is being applied",
        debug_sprint_missing = "Sprint module NOT found yet, retrying",
        debug_frames = "Bound frame loops: %d | enabled options: %d",
        debug_require = "Require capability: %s | sprint module visible now: %s",
        log_version14 = "Dominant 1.3.2",
        log_date14 = "Fix",
        log_32 = "Debug console shows whether the stamina module is found and how many loops are running",
        log_version13 = "Dominant 1.3.1",
        log_date13 = "Fix",
        log_31 = "Saved options stay on when sprint, stamina, animation changer, grid or disarm load late",
        log_version12 = "Dominant 1.3.0",
        log_date12 = "Update",
        log_29 = "Name protect replaces names with a random 6 character code",
        log_30 = "Turning it off restores every name, and the Credits have their own tab",
        gen_all = "Auto Do All Generators",
        gen_all_d = "Teleports to each unfinished generator and completes it",
        gen_all_interval = "Generator Interval",
        gen_all_reset = "Reset After All Generators",
        gen_all_reset_d = "Resets your character once every generator is finished",
        guest_punch_wait = "Punch Wait",
        guest_punch_wait_d = "Seconds to wait after a successful block before punching",
        guest_wallcheck = "Wall Check",
        guest_wallcheck_d = "Blocks nothing while a solid wall is between you and the killer",
        n_gen_all_done = "No unfinished generators left",
        log_version11 = "Dominant 1.2.0",
        log_date11 = "Update",
        log_26 = "Auto Do All Generators with interval and reset options",
        log_27 = "Wall check and adjustable punch wait for Guest 1337",
        log_28 = "Console no longer repeats its own messages",
        log_version10 = "Dominant 1.1.5",
        log_date10 = "Fix",
        log_24 = "Uses the same Vind UI build as the official example, with the old one as fallback",
        log_25 = "Credits show up even if one element is not supported by the loaded Vind build",
        credits_section_vind = "Vind UI Creators",
        credit_vind_skinny_d = "~90% of the UI, and organization of the Touchline script and its functions",
        credit_vind_shezz_d = "Sub-tabs, and suggestions for the UI and script",
        credit_vind_noskills_d = "Suggestions for the UI, and developer of Touchline script functions",
        credit_vind_luxy_d = "Mobile UI tester, and developer of Touchline script functions",
        credit_vind_elusive_d = "Suggestions for the UI, and main contributor to getting it launched fast",
        log_version8 = "Dominant 1.1.2",
        log_date8 = "Update",
        log_21 = "Credits tab lists the Vind UI creators",
        btn_vind_credits = "Open Vind Credits Panel",
        btn_vind_credits_d = "Opens the default Vind UI credits panel with its creators",
        n_vind_credits_fail = "This Vind UI build has no default credits panel",
        log_version7 = "Dominant 1.1.1",
        log_date7 = "Fix",
        log_20 = "Settings button opens the official Vind UI credits panel with its creators",
    },
    pt = {
        block_range_esp = "Círculo do Alcance do Bloqueio",
        block_range_esp_d = "Mostra a área do auto bloqueio ao seu redor",
        color_block_ring = "Cor do Alcance do Bloqueio",
        log_version28 = "Dominant 1.9.4",
        log_date28 = "Atualização",
        log_46 = "O círculo mostra a área do auto bloqueio ao seu redor",
        log_47 = "Removidas funções de ESP duplicadas e stubs sem uso",
        tab_credits = "Créditos",
        btn_open_credits = "Abrir Aba de Créditos",
        btn_open_credits_d = "Cria uma aba com as pessoas e projetos por trás do Dominant",
        credits_section_people = "Criadores",
        credits_section_tools = "Feito Com",
        credits_section_notice = "Avisos",
        credit_jonathan = "Jonathan",
        credit_jonathan_d = "Criador e dono do projeto",
        credit_claude = "Claude Sonnet 5.5",
        credit_claude_d = "Co-desenvolvedor: código, junção de scripts e interface",
        credit_grok = "Grok (versão mais recente)",
        credit_grok_d = "Co-desenvolvedor e apoio em ideias",
        credit_ana = "Ana",
        credit_ana_d = "Obrigado por fazer parte do Dominant",
        notice_vind = "Vind UI Reborn: biblioteca de interface",
        notice_ophyn = "Ophyn: sistema de key e loader",
        notice_naiko = "Forsaken Plus da Naiko Scripts: referência open source, créditos originais mantidos",
        notice_goon = "Goonsaken Hub: referência de recursos",
        notice_cursed = "CursedHub Forsaken da LSSOPS: referência de ESP e remote",
        notice_noli = "Controle do Void Rush do Noli por skibidi399: referência do Void Rush",
        notice_stamina = "Valores de stamina infinita de um script de sprint open source",
        notice_disclaimer = "Cada projeto pertence aos seus autores. O Dominant apenas os credita.",
        timed_hop = "Troca de Servidor por Tempo",
        timed_hop_d = "Troca para outro servidor após o número de minutos definido",
        timed_hop_minutes = "Minutos por Servidor",
        log_version6 = "Dominant 1.1.0",
        log_date6 = "Atualização",
        log_16 = "Corrigidos recursos que precisavam desligar e ligar o toggle depois de carregar",
        log_17 = "Troca de servidor por tempo com ajuste próprio de minutos",
        log_18 = "Aba de créditos com criadores e avisos de terceiros",
        log_19 = "Stamina infinita também mantém o ganho e o máximo de stamina",
        credits_section_dominant = "Criadores do Dominant",
        log_version9 = "Dominant 1.1.4",
        log_date9 = "Correção",
        log_22 = "O background espera a janela abrir antes de ser aplicado",
        log_23 = "Os créditos viraram seções com parágrafos, separados por projeto",
        log_version27 = "Dominant 1.9.3",
        log_date27 = "Correção",
        log_50 = "Mostra mensagens de status na tela em cada etapa, adiciona o jogo atual à lista do sistema de key e aceita o layout do Forsaken",
        log_version26 = "Dominant 1.9.2",
        log_date26 = "Correção",
        log_49 = "O sistema de key tenta de novo com a logo padrão, mostra cada falha no console e pode ser pulado com DominantSkipKey",
        log_version25 = "Dominant 1.9.1",
        log_date25 = "Correção",
        log_48 = "Corrigida uma tabela de atalhos que não existia e impedia o menu de terminar de montar, então as opções salvas e o fundo não eram aplicados na inicialização",
        config_name = "Nome da Configuração",
        config_name_hint = "Digite um nome, ex: legit ou rage",
        config_pick = "Configurações Salvas",
        btn_config_save = "Salvar",
        btn_config_overwrite = "Sobrescrever",
        btn_config_load = "Carregar",
        btn_config_delete = "Deletar",
        btn_config_autoload = "Definir Como Automática",
        btn_config_refresh = "Atualizar Lista",
        n_config_saved = "Configuração \"%s\" salva",
        n_config_exists = "A configuração \"%s\" já existe, use Sobrescrever",
        n_config_missing = "Configuração \"%s\" não encontrada",
        n_config_loaded = "Configuração \"%s\" carregada",
        n_config_deleted = "Configuração \"%s\" deletada",
        n_config_autoload = "\"%s\" será carregada automaticamente",
        confirm_delete_title = "Deletar configuração?",
        confirm_delete_text = "Deletar \"%s\"? Isso não pode ser desfeito.",
        log_version24 = "Dominant 1.9.0",
        log_date24 = "Atualização",
        log_46 = "Configurações nomeadas com Salvar, Sobrescrever, Carregar e Deletar, guardadas na pasta Dominant",
        log_47 = "Ao iniciar carrega sua configuração automática, ou sua última sessão",
        sec_emotes = "Emotes",
        emote_pick = "Emote",
        btn_play_emote = "Tocar Emote",
        btn_stop_emote = "Parar Emote",
        n_emote_none = "Não foi possível tocar o emote",
        log_version23 = "Dominant 1.8.0",
        log_date23 = "Atualização",
        log_44 = "Menu de emotes que toca emotes só no seu próprio personagem",
        log_45 = "Sprint e stamina usam a tabela do jogo quando o require falha",
        guest_skip_special = "Ignorar Ataques Especiais",
        guest_skip_special_d = "Não bloqueia Raging Pace nem Gashing Wound (pode ignorar assassinos rápidos)",
        auto_parry = "Aparar Automático",
        auto_parry_d = "Dispara o remote de aparar logo depois de um bloqueio",
        no_fall = "Sem Dano de Queda",
        no_fall_d = "Impede os estados de queda para que a aterrissagem não machuque",
        esp_pallets = "ESP de Pallet",
        esp_windows = "ESP de Janela",
        esp_chests = "ESP de Baú",
        color_pallet = "ESP de Pallet Color",
        color_window = "ESP de Janela Color",
        color_chest = "ESP de Baú Color",
        log_version22 = "Dominant 1.7.0",
        log_date22 = "Atualização",
        log_42 = "O auto bloqueio ignora assassinos em Raging Pace ou Gashing Wound quando ativado",
        log_43 = "Aparar automático, sem dano de queda e ESP para pallets, janelas e baús",
        guest_abh = "Ajuste da Hitbox",
        guest_abh_d = "Aumenta (+) ou diminui (-) a caixa de detecção do Auto Bloqueio",
        drag_block = "Arrastar Bloqueio",
        drag_block_d = "Depois de bloquear, puxa você em direção ao assassino",
        drag_stop = "Distância de Parada",
        drag_stop_d = "Studs do assassino onde o arrasto para",
        drag_hold = "Duração do Arrasto",
        drag_hold_d = "Segundos que o arrasto dura",
        log_version21 = "Dominant 1.6.0",
        log_date21 = "Atualização",
        log_40 = "O Auto Bloqueio agora usa uma caixa de detecção na sua frente, como o script de referência",
        log_41 = "O Arrastar Bloqueio puxa você em direção ao assassino depois de bloquear",
        log_version20 = "Dominant 1.5.4",
        log_date20 = "Correção",
        log_39 = "A stamina relê o módulo de sprint a cada segundo e mostra os valores no console de Debug",
        log_version19 = "Dominant 1.5.3",
        log_date19 = "Atualização",
        log_38 = "Auto bloqueio e soco funcionam no mobile e no PC pelo remote, pelo botão na tela ou pelas teclas",
        log_version18 = "Dominant 1.5.2",
        log_date18 = "Correção",
        log_37 = "Bloqueio e soco usam as teclas do teclado quando o remote do jogo não é encontrado",
        sprint_speed_on = "Velocidade de Corrida Personalizada",
        sprint_speed_on_d = "Define a velocidade de corrida (máximo 40)",
        sprint_speed = "Velocidade de Corrida",
        sprint_speed_d = "Valor de 1 a 40",
        log_version17 = "Dominant 1.5.1",
        log_date17 = "Atualização",
        log_36 = "Velocidade de corrida personalizada, até 40",
        stamina_custom = "Stamina Personalizada",
        stamina_custom_d = "Usa seus próprios valores de máximo, regeneração e gasto",
        stamina_max = "Stamina Máxima",
        stamina_max_d = "Quantidade máxima de stamina",
        stamina_regen = "Regeneração Por Segundo",
        stamina_regen_d = "Quanto de stamina volta a cada segundo sem correr",
        stamina_drain = "Gasto Por Segundo",
        stamina_drain_d = "Quanto de stamina é usada a cada segundo correndo (0 = sem gasto)",
        log_version16 = "Dominant 1.5.0",
        log_date16 = "Atualização",
        log_34 = "Stamina personalizada: máximo, regeneração e gasto por segundo",
        log_35 = "As opções salvas são desligadas e ligadas de novo na inicialização para funcionarem logo",
        sec_tools = "Ferramentas",
        btn_infinite_yield = "Executar Infinite Yield",
        btn_infinite_yield_d = "Carrega os comandos de admin do Infinite Yield",
        btn_dex = "Executar Dex Explorer++",
        btn_dex_d = "Carrega o explorador de instâncias Dex Explorer++",
        n_tool_ok = "%s carregado",
        n_tool_fail = "Não foi possível carregar %s",
        notice_infinite = "Infinite Yield por EdgeIY: comandos de admin, carregados só quando você aperta o botão",
        notice_dex = "Dex Explorer++ por AZYsGithub: explorador de instâncias, carregado só quando você aperta o botão",
        log_version15 = "Dominant 1.4.0",
        log_date15 = "Update",
        log_33 = "Tools section runs Infinite Yield and Dex Explorer++ on demand",
        debug_sprint_found = "Módulo de sprint encontrado, a stamina infinita está sendo aplicada",
        debug_sprint_missing = "Módulo de sprint AINDA não encontrado, tentando de novo",
        debug_frames = "Loops ativos: %d | opções ligadas: %d",
        debug_require = "Capacidade require: %s | módulo de sprint visível agora: %s",
        log_version14 = "Dominant 1.3.2",
        log_date14 = "Correção",
        log_32 = "O console de Debug mostra se o módulo de stamina foi encontrado e quantos loops estão rodando",
        log_version13 = "Dominant 1.3.1",
        log_date13 = "Correção",
        log_31 = "Opções salvas continuam ligadas quando sprint, stamina, trocador de animação, grade ou desarmar carregam depois",
        log_version12 = "Dominant 1.3.0",
        log_date12 = "Atualização",
        log_29 = "A proteção de nome troca nomes por um código aleatório de 6 caracteres",
        log_30 = "Desligar restaura todos os nomes, e os créditos têm aba própria",
        gen_all = "Fazer Todos os Geradores Automaticamente",
        gen_all_d = "Teleporta para cada gerador não terminado e completa",
        gen_all_interval = "Intervalo dos Geradores",
        gen_all_reset = "Resetar Após Todos os Geradores",
        gen_all_reset_d = "Reseta seu personagem quando todos os geradores estiverem prontos",
        guest_punch_wait = "Espera do Soco",
        guest_punch_wait_d = "Segundos de espera depois de um bloqueio bem-sucedido antes de socar",
        guest_wallcheck = "Checar Parede",
        guest_wallcheck_d = "Não bloqueia enquanto houver uma parede sólida entre você e o assassino",
        n_gen_all_done = "Não há mais geradores pendentes",
        log_version11 = "Dominant 1.2.0",
        log_date11 = "Atualização",
        log_26 = "Fazer Todos os Geradores com opções de intervalo e reset",
        log_27 = "Checagem de parede e espera de soco ajustável para o Guest 1337",
        log_28 = "O console não repete mais as próprias mensagens",
        log_version10 = "Dominant 1.1.5",
        log_date10 = "Correção",
        log_24 = "Usa a mesma build da Vind UI do exemplo oficial, com a antiga como reserva",
        log_25 = "Os créditos aparecem mesmo se um elemento não for suportado pela build carregada",
        credits_section_vind = "Criadores da Vind UI",
        credit_vind_skinny_d = "~90% da UI e organização do script Touchline e das suas funções",
        credit_vind_shezz_d = "Sub-abas e sugestões para a UI e o script",
        credit_vind_noskills_d = "Sugestões para a UI e desenvolvedor das funções do script Touchline",
        credit_vind_luxy_d = "Testador da UI no mobile e desenvolvedor das funções do script Touchline",
        credit_vind_elusive_d = "Sugestões para a UI e principal colaborador para lançar rápido",
        log_version8 = "Dominant 1.1.2",
        log_date8 = "Atualização",
        log_21 = "Aba de créditos lista os criadores da Vind UI",
        btn_vind_credits = "Abrir Painel de Créditos da Vind",
        btn_vind_credits_d = "Abre o painel de créditos padrão da Vind UI com os criadores",
        n_vind_credits_fail = "Esta versão da Vind UI não tem painel de créditos padrão",
        log_version7 = "Dominant 1.1.1",
        log_date7 = "Correção",
        log_20 = "Botão em Settings abre o painel oficial de créditos da Vind UI com os criadores",
    },
    es = {
        block_range_esp = "Círculo de Alcance de Bloqueo",
        block_range_esp_d = "Muestra el área del auto bloqueo a tu alrededor",
        color_block_ring = "Color del Alcance de Bloqueo",
        log_version28 = "Dominant 1.9.4",
        log_date28 = "Actualización",
        log_46 = "El círculo muestra el área del auto bloqueo a tu alrededor",
        log_47 = "Eliminadas funciones de ESP duplicadas y stubs sin uso",
        tab_credits = "Créditos",
        btn_open_credits = "Abrir Pestaña de Créditos",
        btn_open_credits_d = "Crea una pestaña con las personas y proyectos detrás de Dominant",
        credits_section_people = "Creadores",
        credits_section_tools = "Hecho Con",
        credits_section_notice = "Avisos",
        credit_jonathan = "Jonathan",
        credit_jonathan_d = "Creador y dueño del proyecto",
        credit_claude = "Claude Sonnet 5.5",
        credit_claude_d = "Co-desarrollador: código, unión de scripts e interfaz",
        credit_grok = "Grok (versión más reciente)",
        credit_grok_d = "Co-desarrollador y apoyo en ideas",
        credit_ana = "Ana",
        credit_ana_d = "Gracias por ser parte de Dominant",
        notice_vind = "Vind UI Reborn: biblioteca de interfaz",
        notice_ophyn = "Ophyn: sistema de clave y loader",
        notice_naiko = "Forsaken Plus de Naiko Scripts: referencia open source, créditos originales conservados",
        notice_goon = "Goonsaken Hub: referencia de funciones",
        notice_cursed = "CursedHub Forsaken de LSSOPS: referencia de ESP y remote",
        notice_noli = "Control del Void Rush de Noli por skibidi399: referencia del Void Rush",
        notice_stamina = "Valores de stamina infinita de un script de sprint open source",
        notice_disclaimer = "Cada proyecto pertenece a sus autores. Dominant solo los acredita.",
        timed_hop = "Cambio de Servidor por Tiempo",
        timed_hop_d = "Cambia a otro servidor tras los minutos configurados",
        timed_hop_minutes = "Minutos por Servidor",
        log_version6 = "Dominant 1.1.0",
        log_date6 = "Actualización",
        log_16 = "Corregidas funciones que necesitaban apagar y encender el interruptor tras cargar",
        log_17 = "Cambio de servidor por tiempo con ajuste propio de minutos",
        log_18 = "Pestaña de créditos con creadores y avisos de terceros",
        log_19 = "La stamina infinita también mantiene la ganancia y el máximo de stamina",
        credits_section_dominant = "Creadores de Dominant",
        log_version9 = "Dominant 1.1.4",
        log_date9 = "Corrección",
        log_22 = "El fondo espera a que la ventana se abra antes de aplicarse",
        log_23 = "Los créditos ahora son secciones con párrafos, separadas por proyecto",
        log_version27 = "Dominant 1.9.3",
        log_date27 = "Corrección",
        log_50 = "Muestra mensajes de estado en pantalla en cada paso, añade el juego actual a la lista del sistema de key y acepta el diseño de Forsaken",
        log_version26 = "Dominant 1.9.2",
        log_date26 = "Corrección",
        log_49 = "El sistema de key reintenta con el logo predeterminado, muestra cada fallo en la consola y puede omitirse con DominantSkipKey",
        log_version25 = "Dominant 1.9.1",
        log_date25 = "Corrección",
        log_48 = "Corregida una tabla de atajos que no existía y impedía terminar de montar el menú, así que las opciones guardadas y el fondo no se aplicaban al iniciar",
        config_name = "Nombre de Configuración",
        config_name_hint = "Escribe un nombre, ej: legit o rage",
        config_pick = "Configuraciones Guardadas",
        btn_config_save = "Guardar",
        btn_config_overwrite = "Sobrescribir",
        btn_config_load = "Cargar",
        btn_config_delete = "Eliminar",
        btn_config_autoload = "Establecer Como Automática",
        btn_config_refresh = "Actualizar Lista",
        n_config_saved = "Configuración \"%s\" guardada",
        n_config_exists = "La configuración \"%s\" ya existe, usa Sobrescribir",
        n_config_missing = "Configuración \"%s\" no encontrada",
        n_config_loaded = "Configuración \"%s\" cargada",
        n_config_deleted = "Configuración \"%s\" eliminada",
        n_config_autoload = "\"%s\" se cargará automáticamente",
        confirm_delete_title = "¿Eliminar configuración?",
        confirm_delete_text = "¿Eliminar \"%s\"? No se puede deshacer.",
        log_version24 = "Dominant 1.9.0",
        log_date24 = "Actualización",
        log_46 = "Configuraciones con nombre: Guardar, Sobrescribir, Cargar y Eliminar, guardadas en la carpeta Dominant",
        log_47 = "Al iniciar carga tu configuración automática o tu última sesión",
        sec_emotes = "Emotes",
        emote_pick = "Emote",
        btn_play_emote = "Reproducir Emote",
        btn_stop_emote = "Detener Emote",
        n_emote_none = "No se pudo reproducir el emote",
        log_version23 = "Dominant 1.8.0",
        log_date23 = "Actualización",
        log_44 = "Menú de emotes que reproduce emotes solo en tu propio personaje",
        log_45 = "El sprint y la stamina usan la tabla del juego cuando falla el require",
        guest_skip_special = "Ignorar Ataques Especiales",
        guest_skip_special_d = "No bloquea Raging Pace ni Gashing Wound (puede ignorar asesinos rápidos)",
        auto_parry = "Parada Automática",
        auto_parry_d = "Dispara el remote de parada poco después de un bloqueo",
        no_fall = "Sin Daño por Caída",
        no_fall_d = "Evita los estados de caída para que el aterrizaje no dañe",
        esp_pallets = "ESP de Pallet",
        esp_windows = "ESP de Ventana",
        esp_chests = "ESP de Cofre",
        color_pallet = "ESP de Pallet Color",
        color_window = "ESP de Ventana Color",
        color_chest = "ESP de Cofre Color",
        log_version22 = "Dominant 1.7.0",
        log_date22 = "Actualización",
        log_42 = "El auto bloqueo ignora asesinos en Raging Pace o Gashing Wound si está activado",
        log_43 = "Parada automática, sin daño por caída y ESP para pallets, ventanas y cofres",
        guest_abh = "Ajuste de Hitbox",
        guest_abh_d = "Agranda (+) o reduce (-) la caja de detección del Auto Bloqueo",
        drag_block = "Arrastrar Bloqueo",
        drag_block_d = "Después de bloquear, te acerca al asesino",
        drag_stop = "Distancia de Parada",
        drag_stop_d = "Studs del asesino donde se detiene el arrastre",
        drag_hold = "Duración del Arrastre",
        drag_hold_d = "Segundos que dura el arrastre",
        log_version21 = "Dominant 1.6.0",
        log_date21 = "Actualización",
        log_40 = "El Auto Bloqueo ahora usa una caja de detección frente a ti, como el script de referencia",
        log_41 = "El Arrastrar Bloqueo te acerca al asesino después de bloquear",
        log_version20 = "Dominant 1.5.4",
        log_date20 = "Corrección",
        log_39 = "La stamina vuelve a leer el módulo de sprint cada segundo y muestra sus valores en la consola de Debug",
        log_version19 = "Dominant 1.5.3",
        log_date19 = "Actualización",
        log_38 = "El auto bloqueo y el golpe funcionan en móvil y PC mediante el remote, el botón en pantalla o las teclas",
        log_version18 = "Dominant 1.5.2",
        log_date18 = "Corrección",
        log_37 = "Bloqueo y golpe usan las teclas del teclado cuando no se encuentra el remote del juego",
        sprint_speed_on = "Velocidad de Sprint Personalizada",
        sprint_speed_on_d = "Define la velocidad de sprint (máximo 40)",
        sprint_speed = "Velocidad de Sprint",
        sprint_speed_d = "Valor de 1 a 40",
        log_version17 = "Dominant 1.5.1",
        log_date17 = "Actualización",
        log_36 = "Velocidad de sprint personalizada, hasta 40",
        stamina_custom = "Stamina Personalizada",
        stamina_custom_d = "Usa tus propios valores de máximo, regeneración y gasto",
        stamina_max = "Stamina Máxima",
        stamina_max_d = "Cantidad máxima de stamina",
        stamina_regen = "Regeneración Por Segundo",
        stamina_regen_d = "Cuánta stamina vuelve cada segundo sin correr",
        stamina_drain = "Gasto Por Segundo",
        stamina_drain_d = "Cuánta stamina se usa cada segundo corriendo (0 = sin gasto)",
        log_version16 = "Dominant 1.5.0",
        log_date16 = "Actualización",
        log_34 = "Stamina personalizada: máximo, regeneración y gasto por segundo",
        log_35 = "Las opciones guardadas se apagan y encienden al iniciar para que funcionen de inmediato",
        sec_tools = "Herramientas",
        btn_infinite_yield = "Ejecutar Infinite Yield",
        btn_infinite_yield_d = "Carga los comandos de admin de Infinite Yield",
        btn_dex = "Ejecutar Dex Explorer++",
        btn_dex_d = "Carga el explorador de instancias Dex Explorer++",
        n_tool_ok = "%s cargado",
        n_tool_fail = "No se pudo cargar %s",
        notice_infinite = "Infinite Yield por EdgeIY: comandos de admin, cargados solo al pulsar el botón",
        notice_dex = "Dex Explorer++ por AZYsGithub: explorador de instancias, cargado solo al pulsar el botón",
        log_version15 = "Dominant 1.4.0",
        log_date15 = "Update",
        log_33 = "Tools section runs Infinite Yield and Dex Explorer++ on demand",
        debug_sprint_found = "Módulo de sprint encontrado, se está aplicando la stamina infinita",
        debug_sprint_missing = "Módulo de sprint AÚN no encontrado, reintentando",
        debug_frames = "Bucles activos: %d | opciones activas: %d",
        debug_require = "Capacidad require: %s | módulo de sprint visible ahora: %s",
        log_version14 = "Dominant 1.3.2",
        log_date14 = "Corrección",
        log_32 = "La consola de Debug muestra si se encontró el módulo de stamina y cuántos bucles están activos",
        log_version13 = "Dominant 1.3.1",
        log_date13 = "Corrección",
        log_31 = "Las opciones guardadas siguen activas cuando sprint, stamina, cambiador de animación, cuadrícula o desarmar cargan tarde",
        log_version12 = "Dominant 1.3.0",
        log_date12 = "Actualización",
        log_29 = "La protección de nombre cambia los nombres por un código aleatorio de 6 caracteres",
        log_30 = "Al apagarla se restauran todos los nombres, y los créditos tienen su propia pestaña",
        gen_all = "Hacer Todos los Generadores Automáticamente",
        gen_all_d = "Te teletransporta a cada generador sin terminar y lo completa",
        gen_all_interval = "Intervalo de Generadores",
        gen_all_reset = "Reiniciar Tras Todos los Generadores",
        gen_all_reset_d = "Reinicia tu personaje cuando todos los generadores estén listos",
        guest_punch_wait = "Espera del Golpe",
        guest_punch_wait_d = "Segundos de espera tras un bloqueo exitoso antes de golpear",
        guest_wallcheck = "Comprobar Pared",
        guest_wallcheck_d = "No bloquea mientras haya una pared sólida entre tú y el asesino",
        n_gen_all_done = "No quedan generadores pendientes",
        log_version11 = "Dominant 1.2.0",
        log_date11 = "Actualización",
        log_26 = "Hacer Todos los Generadores con opciones de intervalo y reinicio",
        log_27 = "Comprobación de pared y espera de golpe ajustable para Guest 1337",
        log_28 = "La consola ya no repite sus propios mensajes",
        log_version10 = "Dominant 1.1.5",
        log_date10 = "Corrección",
        log_24 = "Usa la misma build de Vind UI del ejemplo oficial, con la anterior como respaldo",
        log_25 = "Los créditos aparecen aunque un elemento no sea compatible con la build cargada",
        credits_section_vind = "Creadores de Vind UI",
        credit_vind_skinny_d = "~90% de la UI y organización del script Touchline y sus funciones",
        credit_vind_shezz_d = "Sub-pestañas y sugerencias para la UI y el script",
        credit_vind_noskills_d = "Sugerencias para la UI y desarrollador de las funciones del script Touchline",
        credit_vind_luxy_d = "Probador de la UI en móvil y desarrollador de las funciones del script Touchline",
        credit_vind_elusive_d = "Sugerencias para la UI y principal colaborador para lanzarla rápido",
        log_version8 = "Dominant 1.1.2",
        log_date8 = "Actualización",
        log_21 = "La pestaña de créditos muestra a los creadores de Vind UI",
        btn_vind_credits = "Abrir Panel de Créditos de Vind",
        btn_vind_credits_d = "Abre el panel de créditos predeterminado de Vind UI con sus creadores",
        n_vind_credits_fail = "Esta versión de Vind UI no tiene panel de créditos predeterminado",
        log_version7 = "Dominant 1.1.1",
        log_date7 = "Corrección",
        log_20 = "El botón de Ajustes abre el panel oficial de créditos de Vind UI con sus creadores",
    },
    ru = {
        block_range_esp = "Круг радиуса блока",
        block_range_esp_d = "Показывает зону авто-блока вокруг вас",
        color_block_ring = "Цвет радиуса блока",
        log_version28 = "Dominant 1.9.4",
        log_date28 = "Обновление",
        log_46 = "Круг показывает зону авто-блока вокруг вас",
        log_47 = "Удалены дублирующиеся функции ESP и неиспользуемые заглушки",
        tab_credits = "Титры",
        btn_open_credits = "Открыть вкладку титров",
        btn_open_credits_d = "Создаёт вкладку с людьми и проектами, стоящими за Dominant",
        credits_section_people = "Авторы",
        credits_section_tools = "Использованы",
        credits_section_notice = "Уведомления",
        credit_jonathan = "Jonathan",
        credit_jonathan_d = "Создатель и владелец проекта",
        credit_claude = "Claude Sonnet 5.5",
        credit_claude_d = "Соавтор: код, объединение скриптов и интерфейс",
        credit_grok = "Grok (последняя версия)",
        credit_grok_d = "Соавтор и помощь с идеями",
        credit_ana = "Ana",
        credit_ana_d = "Спасибо, что вы часть Dominant",
        notice_vind = "Vind UI Reborn: библиотека интерфейса",
        notice_ophyn = "Ophyn: система ключей и загрузчик",
        notice_naiko = "Forsaken Plus от Naiko Scripts: открытый исходный код, оригинальные авторы сохранены",
        notice_goon = "Goonsaken Hub: справочник функций",
        notice_cursed = "CursedHub Forsaken от LSSOPS: справочник ESP и remote",
        notice_noli = "Управление Void Rush от skibidi399: справочник Void Rush",
        notice_stamina = "Значения бесконечной выносливости из открытого скрипта спринта",
        notice_disclaimer = "Каждый проект принадлежит своим авторам. Dominant только указывает их.",
        timed_hop = "Смена сервера по таймеру",
        timed_hop_d = "Переходит на другой сервер через заданное количество минут",
        timed_hop_minutes = "Минут на сервер",
        log_version6 = "Dominant 1.1.0",
        log_date6 = "Обновление",
        log_16 = "Исправлены функции, которые требовали выключить и включить переключатель после загрузки",
        log_17 = "Смена сервера по таймеру с собственной настройкой минут",
        log_18 = "Вкладка титров с авторами и уведомлениями о сторонних проектах",
        log_19 = "Бесконечная выносливость также поддерживает прирост и максимум выносливости",
        credits_section_dominant = "Авторы Dominant",
        log_version9 = "Dominant 1.1.4",
        log_date9 = "Исправление",
        log_22 = "Фон применяется после того, как окно открылось",
        log_23 = "Титры теперь разделы с абзацами, отдельно по проектам",
        log_version27 = "Dominant 1.9.3",
        log_date27 = "Исправление",
        log_50 = "Показывает сообщения о статусе на экране на каждом шаге, добавляет текущую игру в список системы ключей и принимает структуру Forsaken",
        log_version26 = "Dominant 1.9.2",
        log_date26 = "Исправление",
        log_49 = "Система ключей повторяет попытку со стандартным логотипом, выводит каждую ошибку в консоль и может быть пропущена через DominantSkipKey",
        log_version25 = "Dominant 1.9.1",
        log_date25 = "Исправление",
        log_48 = "Исправлена отсутствовавшая таблица горячих клавиш, из-за которой меню не завершало сборку, и сохранённые опции и фон не применялись при запуске",
        config_name = "Название конфигурации",
        config_name_hint = "Введите имя, например legit или rage",
        config_pick = "Сохранённые конфигурации",
        btn_config_save = "Сохранить",
        btn_config_overwrite = "Перезаписать",
        btn_config_load = "Загрузить",
        btn_config_delete = "Удалить",
        btn_config_autoload = "Сделать автозагрузкой",
        btn_config_refresh = "Обновить список",
        n_config_saved = "Конфигурация \"%s\" сохранена",
        n_config_exists = "Конфигурация \"%s\" уже есть, используйте Перезаписать",
        n_config_missing = "Конфигурация \"%s\" не найдена",
        n_config_loaded = "Конфигурация \"%s\" загружена",
        n_config_deleted = "Конфигурация \"%s\" удалена",
        n_config_autoload = "\"%s\" будет загружаться автоматически",
        confirm_delete_title = "Удалить конфигурацию?",
        confirm_delete_text = "Удалить \"%s\"? Это нельзя отменить.",
        log_version24 = "Dominant 1.9.0",
        log_date24 = "Обновление",
        log_46 = "Именованные конфигурации: сохранить, перезаписать, загрузить и удалить, в папке Dominant",
        log_47 = "При запуске загружается автоматическая конфигурация или последняя сессия",
        sec_emotes = "Эмоции",
        emote_pick = "Эмоция",
        btn_play_emote = "Проиграть эмоцию",
        btn_stop_emote = "Остановить эмоцию",
        n_emote_none = "Не удалось проиграть эмоцию",
        log_version23 = "Dominant 1.8.0",
        log_date23 = "Обновление",
        log_44 = "Меню эмоций, которое проигрывает эмоции только на вашем персонаже",
        log_45 = "Спринт и выносливость используют таблицу игры, если require не работает",
        guest_skip_special = "Игнорировать спец-атаки",
        guest_skip_special_d = "Не блокирует Raging Pace и Gashing Wound (может пропускать быстрых убийц)",
        auto_parry = "Авто-парри",
        auto_parry_d = "Отправляет remote парри вскоре после блока",
        no_fall = "Без урона от падения",
        no_fall_d = "Отключает состояния падения, чтобы приземление не наносило урон",
        esp_pallets = "ESP палетов",
        esp_windows = "ESP окон",
        esp_chests = "ESP сундуков",
        color_pallet = "ESP палетов Color",
        color_window = "ESP окон Color",
        color_chest = "ESP сундуков Color",
        log_version22 = "Dominant 1.7.0",
        log_date22 = "Обновление",
        log_42 = "Авто-блок пропускает убийц в Raging Pace или Gashing Wound, если включено",
        log_43 = "Авто-парри, без урона от падения и ESP для палетов, окон и сундуков",
        guest_abh = "Настройка хитбокса",
        guest_abh_d = "Увеличивает (+) или уменьшает (-) зону обнаружения авто-блока",
        drag_block = "Перетаскивание блока",
        drag_block_d = "После блока подтягивает вас к убийце",
        drag_stop = "Дистанция остановки",
        drag_stop_d = "Стадов от убийцы, где перетаскивание останавливается",
        drag_hold = "Длительность перетаскивания",
        drag_hold_d = "Секунды, в течение которых длится перетаскивание",
        log_version21 = "Dominant 1.6.0",
        log_date21 = "Обновление",
        log_40 = "Авто-блок теперь использует зону обнаружения перед вами, как скрипт-референс",
        log_41 = "Перетаскивание блока подтягивает вас к убийце после блока",
        log_version20 = "Dominant 1.5.4",
        log_date20 = "Исправление",
        log_39 = "Выносливость перечитывает модуль спринта раз в секунду и выводит его значения в консоль отладки",
        log_version19 = "Dominant 1.5.3",
        log_date19 = "Обновление",
        log_38 = "Авто-блок и удар работают на телефоне и ПК через remote, кнопку на экране или клавиши",
        log_version18 = "Dominant 1.5.2",
        log_date18 = "Исправление",
        log_37 = "Блок и удар используют клавиши клавиатуры, если remote игры не найден",
        sprint_speed_on = "Своя скорость спринта",
        sprint_speed_on_d = "Задаёт скорость спринта (максимум 40)",
        sprint_speed = "Скорость спринта",
        sprint_speed_d = "Значение от 1 до 40",
        log_version17 = "Dominant 1.5.1",
        log_date17 = "Обновление",
        log_36 = "Своя скорость спринта, до 40",
        stamina_custom = "Своя выносливость",
        stamina_custom_d = "Использует ваши значения максимума, восстановления и траты",
        stamina_max = "Максимум выносливости",
        stamina_max_d = "Максимальный запас выносливости",
        stamina_regen = "Восстановление в секунду",
        stamina_regen_d = "Сколько выносливости восстанавливается каждую секунду без бега",
        stamina_drain = "Трата в секунду",
        stamina_drain_d = "Сколько выносливости тратится каждую секунду при беге (0 = без траты)",
        log_version16 = "Dominant 1.5.0",
        log_date16 = "Обновление",
        log_34 = "Своя выносливость: максимум, восстановление и трата в секунду",
        log_35 = "Сохранённые опции выключаются и включаются при запуске, чтобы сразу работать",
        sec_tools = "Инструменты",
        btn_infinite_yield = "Запустить Infinite Yield",
        btn_infinite_yield_d = "Загружает админ-команды Infinite Yield",
        btn_dex = "Запустить Dex Explorer++",
        btn_dex_d = "Загружает просмотрщик экземпляров Dex Explorer++",
        n_tool_ok = "%s загружен",
        n_tool_fail = "Не удалось загрузить %s",
        notice_infinite = "Infinite Yield от EdgeIY: админ-команды, загружаются только по нажатию кнопки",
        notice_dex = "Dex Explorer++ от AZYsGithub: просмотр экземпляров, загружается только по нажатию кнопки",
        log_version15 = "Dominant 1.4.0",
        log_date15 = "Update",
        log_33 = "Tools section runs Infinite Yield and Dex Explorer++ on demand",
        debug_sprint_found = "Модуль спринта найден, применяется бесконечная выносливость",
        debug_sprint_missing = "Модуль спринта ещё НЕ найден, повторная попытка",
        debug_frames = "Активных циклов: %d | включённых опций: %d",
        debug_require = "Возможность require: %s | модуль спринта виден сейчас: %s",
        log_version14 = "Dominant 1.3.2",
        log_date14 = "Исправление",
        log_32 = "Консоль отладки показывает, найден ли модуль выносливости и сколько циклов работает",
        log_version13 = "Dominant 1.3.1",
        log_date13 = "Исправление",
        log_31 = "Сохранённые опции остаются включёнными, если спринт, выносливость, смена анимаций, сетка или обезвреживание загружаются позже",
        log_version12 = "Dominant 1.3.0",
        log_date12 = "Обновление",
        log_29 = "Защита имён заменяет имена случайным кодом из 6 символов",
        log_30 = "При выключении все имена возвращаются, а титры теперь на своей вкладке",
        gen_all = "Автоматически пройти все генераторы",
        gen_all_d = "Телепортирует к каждому незавершённому генератору и завершает его",
        gen_all_interval = "Интервал генераторов",
        gen_all_reset = "Сброс после всех генераторов",
        gen_all_reset_d = "Сбрасывает персонажа, когда все генераторы готовы",
        guest_punch_wait = "Задержка удара",
        guest_punch_wait_d = "Секунды ожидания после успешного блока перед ударом",
        guest_wallcheck = "Проверка стены",
        guest_wallcheck_d = "Не блокирует, пока между вами и убийцей стена",
        n_gen_all_done = "Незавершённых генераторов не осталось",
        log_version11 = "Dominant 1.2.0",
        log_date11 = "Обновление",
        log_26 = "Автопрохождение всех генераторов с интервалом и сбросом",
        log_27 = "Проверка стены и настраиваемая задержка удара для Guest 1337",
        log_28 = "Консоль больше не повторяет свои сообщения",
        log_version10 = "Dominant 1.1.5",
        log_date10 = "Исправление",
        log_24 = "Использует ту же сборку Vind UI, что и официальный пример, старая — запасной вариант",
        log_25 = "Титры отображаются, даже если какой-то элемент не поддерживается загруженной сборкой Vind",
        credits_section_vind = "Авторы Vind UI",
        credit_vind_skinny_d = "~90% интерфейса и организация скрипта Touchline и его функций",
        credit_vind_shezz_d = "Вложенные вкладки и предложения по интерфейсу и скрипту",
        credit_vind_noskills_d = "Предложения по интерфейсу и разработчик функций скрипта Touchline",
        credit_vind_luxy_d = "Тестирование интерфейса на мобильных и разработчик функций скрипта Touchline",
        credit_vind_elusive_d = "Предложения по интерфейсу и главный участник, ускоривший запуск",
        log_version8 = "Dominant 1.1.2",
        log_date8 = "Обновление",
        log_21 = "Вкладка титров показывает авторов Vind UI",
        btn_vind_credits = "Открыть панель титров Vind",
        btn_vind_credits_d = "Открывает стандартную панель титров Vind UI с авторами",
        n_vind_credits_fail = "Эта версия Vind UI не имеет стандартной панели титров",
        log_version7 = "Dominant 1.1.1",
        log_date7 = "Исправление",
        log_20 = "Кнопка в настройках открывает официальную панель титров Vind UI с авторами",
    },
}
for code, pack in pairs(ExtraStrings) do
    for key, value in pairs(pack) do
        Dominant.Strings[code][key] = value
    end
end

function UI.OpenVindCredits()
    local window = Dominant.Window
    if not window then
        return
    end
    if type(window.AddDefaultCreditsPanel) ~= "function" then
        Dominant.Notify(L("n_vind_credits_fail"), "warning", 4)
        return
    end
    if Dominant.Objects.vindCreditsOpened then
        pcall(function()
            window:SelectTab(L("tab_credits"))
        end)
        return
    end
    local ok, err = pcall(function()
        window:AddDefaultCreditsPanel()
    end)
    if ok then
        Dominant.Objects.vindCreditsOpened = true
    else
        Dominant.Warn("[Dominant] Vind credits panel failed: " .. tostring(err))
        Dominant.Notify(L("n_vind_credits_fail"), "warning", 4)
    end
end

function UI.FillCredits(tab)
    local function try(fn)
        local ok, err = pcall(fn)
        if not ok then
            Dominant.Warn("[Dominant] credits: " .. tostring(err))
        end
    end
    local function section(key, icon)
        try(function() tab:AddSection(L(key), icon) end)
    end
    local function paragraph(title, icon, text)
        try(function() tab:AddParagraph({ Title = title, Icon = icon, Text = text }) end)
    end
    section("credits_section_dominant", "Lucide:code")
    paragraph(L("credit_jonathan"), "Lucide:crown", L("credit_jonathan_d"))
    paragraph(L("credit_claude"), "Lucide:bot", L("credit_claude_d"))
    paragraph(L("credit_grok"), "Lucide:sparkles", L("credit_grok_d"))
    paragraph(L("credit_ana"), "Lucide:heart", L("credit_ana_d"))
    section("credits_section_vind", "Lucide:heart-handshake")
    paragraph("Skinny", "Lucide:palette", L("credit_vind_skinny_d"))
    paragraph("Shezz", "Lucide:layout-grid", L("credit_vind_shezz_d"))
    paragraph("NoSkills", "Lucide:lightbulb", L("credit_vind_noskills_d"))
    paragraph("Luxy_00", "Lucide:smartphone", L("credit_vind_luxy_d"))
    paragraph("Elusive", "Lucide:rocket", L("credit_vind_elusive_d"))
    section("credits_section_notice", "Lucide:info")
    paragraph("Vind UI Reborn", "Lucide:layout-dashboard", L("notice_vind"))
    paragraph("Ophyn", "Lucide:key", L("notice_ophyn"))
    paragraph("Naiko Scripts", "Lucide:git-branch", L("notice_naiko"))
    paragraph("Goonsaken Hub", "Lucide:swords", L("notice_goon"))
    paragraph("CursedHub Forsaken", "Lucide:skull", L("notice_cursed"))
    paragraph("Noli Void Rush", "Lucide:navigation", L("notice_noli"))
    paragraph("Sprint values", "Lucide:battery-charging", L("notice_stamina"))
    paragraph("Infinite Yield", "Lucide:terminal", L("notice_infinite"))
    paragraph("Dex Explorer++", "Lucide:search", L("notice_dex"))
    paragraph(L("credits_line"), "Lucide:scale", L("notice_disclaimer"))
end

function UI.OpenCredits()
    local window = Dominant.Window
    if not window then
        return
    end
    pcall(function()
        window:SelectTab(L("tab_credits"))
    end)
end

Dominant.Retry = {
    { "auto_escape", function() return not Feat.Escape.Watching end },
    { "show_chat", function() return not Dominant.Objects.chatWatch end },
    { "kill_walls", function() return not Feat.World.Watching end },
    { "no_trails", function() return not Feat.World.Watching end },
    { "no_footprints", function() return not Feat.World.Watching end },
    { "small_spikes", function() return not Feat.World.Watching end },
    { "auto_gen", function() return not Feat.Puzzle.Installed and not Dominant.Loops.autogen end },
    { "auto_disarm", function() return not Feat.Disarm.Installed end },
    { "goon", function() return not Feat.Anim.Loops.goon end },
    { "laydown", function() return not Feat.Anim.Loops.laydown end },
    { "auto_pickup", function() return not Dominant.Loops.pickup end },
    { "instant_prompts", function() return not Dominant.Objects.promptShown end },
    { "auto_rejoin", function() return not Dominant.Objects.autoRejoin end },
    { "timed_hop", function() return not Dominant.Loops.timedhop end },
    { "infinite_stamina", function() return not Dominant.Objects["frame_stamina"] end },
    { "stamina_custom", function() return not Dominant.Objects["frame_stamina"] end },
    { "sprint_speed_on", function() return not Dominant.Objects["frame_sprintspeed"] end },
    { "always_sprint", function() return not Dominant.Objects["frame_alwayssprint"] end },
    { "gen_override_grid", function() return not Feat.Puzzle.Installed end },
    { "anim_changer", function() return not Dominant.Loops.animchanger end },
}

function Dominant.WatchdogStep()
    local now = os.clock()
    if not Dominant.Caps.require and now >= (Dominant.Objects.capsRetryAt or 0) then
        Dominant.Objects.capsRetryAt = now + 3
        if Dominant.RefreshCaps() then
            Dominant.ApplyEnabled()
        end
    end
    for _, entry in ipairs(Dominant.Retry) do
        local key, missing = entry[1], entry[2]
        local value = Dominant.Cfg[key]
        local active = value == true or (type(value) == "string" and value ~= "Original")
        if active and Dominant.Hooks[key] and missing() then
            Dominant.Apply(key, value)
        end
    end
    local window = Dominant.Window
    if Dominant.Cfg.bg_enabled and Dominant.Cfg.bg_path ~= "" and window then
        local label = window._BackgroundImage
        local healthy = label and label.Parent and label.Visible and label.Image ~= ""
        if not healthy and now >= (Dominant.Objects.bgRetryAt or 0) then
            Dominant.Objects.bgRetryAt = now + 10
            pcall(Feat.Background.Apply, Dominant.Cfg.bg_path, { Silent = true })
        end
    end
end

function Dominant.EnsureWatchdog()
    if not Dominant.Loops.watchdog and not Dominant.State.Unloading then
        Dominant.StartLoop("watchdog", 2, Dominant.WatchdogStep)
    end
end

hook("timed_hop", function(value)
    if value then
        Dominant.Objects.hopStart = os.clock()
        Dominant.StartLoop("timedhop", 15, function()
            local minutes = math.max(1, tonumber(Dominant.Cfg.timed_hop_minutes) or 10)
            if os.clock() - (Dominant.Objects.hopStart or 0) >= minutes * 60 then
                Dominant.Objects.hopStart = os.clock()
                Feat.Server.Hop()
            end
        end)
    else
        Dominant.StopLoop("timedhop")
    end
end)


function UI.Load()
    local urls = { CONFIG.VindUrl, CONFIG.VindFallbackUrl }
    if type(getgenv) == "function" and type(getgenv().DominantVindUrl) == "string" and getgenv().DominantVindUrl ~= "" then
        urls = { getgenv().DominantVindUrl }
    end
    local library
    for _, url in ipairs(urls) do
        if type(url) == "string" and url ~= "" then
            local okFetch, body = pcall(function()
                return game:HttpGet(url)
            end)
            if okFetch and type(body) == "string" and #body >= 100 then
                local ok, loaded = pcall(function()
                    return loadstring(body)()
                end)
                if ok and type(loaded) == "table" then
                    library = loaded
                    break
                end
                Dominant.Warn("[Dominant] Failed to run Vind UI from " .. url .. ": " .. tostring(loaded))
            else
                Dominant.Warn("[Dominant] HttpGet failed for Vind: " .. url)
            end
        end
    end
    if not library then
        return nil
    end
    if type(library.SetTheme) == "function" then
        local okTheme, themeErr = pcall(function()
            library:SetTheme(CONFIG.Theme)
        end)
        if not okTheme then
            Dominant.Warn("[Dominant] SetTheme failed: " .. tostring(themeErr))
            pcall(function()
                library:SetTheme("Dark")
            end)
        end
    end
    if type(library.PreloadIcons) == "function" then
        pcall(function()
            library:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
        end)
    end
    if type(library.SetScaleRange) == "function" then
        pcall(function()
            library:SetScaleRange(0.75, 1.35)
        end)
    end
    if type(library.SetMobileScaleReference) == "function" then
        pcall(function()
            library:SetMobileScaleReference(450)
        end)
    end
    if type(library.ShowIntro) == "function" then
        pcall(function()
            library:ShowIntro({
                Enabled = true,
                Title = CONFIG.Title,
                Eyebrow = "WELCOME BACK",
                Subtitle = CONFIG.Description,
                Logo = "Lucide:crown",
                UseBlur = true,
                Transparency = 0.22,
                Shimmer = true,
                Duration = 2.6,
                Skippable = true,
                ReducedMotion = false,
            }):Wait()
        end)
    end
    return library
end

function UI.Describe(key)
    local text = L(key .. "_d")
    if text == key .. "_d" then
        return nil
    end
    return text
end

function UI.Helpers(Window)
    local helpers = {}

    function helpers.Toggle(parent, key, icon)
        local element = parent:AddToggle({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Flag = key,
            Default = Dominant.Cfg[key],
            Callback = function(value)
                Dominant.Set(key, value)
            end,
        })
        UI.Elements[key] = element
        return element
    end

    function helpers.Slider(parent, key, min, max, step, icon, suffix)
        return parent:AddSlider({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Flag = key,
            Min = min,
            Max = max,
            Default = Dominant.Cfg[key],
            Increment = step,
            Suffix = suffix,
            Callback = function(value)
                Dominant.Set(key, value)
            end,
        })
    end

    function helpers.Dropdown(parent, key, options, icon, current, onChange)
        return parent:AddDropdown({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Options = options,
            Default = current or Dominant.Cfg[key],
            Flag = key,
            Callback = function(value)
                if type(value) == "table" then
                    value = value[1]
                end
                if type(onChange) == "function" then
                    onChange(value)
                else
                    Dominant.Set(key, value)
                end
            end,
        })
    end

    function helpers.Textbox(parent, key, hintKey, icon)
        return parent:AddTextbox({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Placeholder = L(hintKey),
            Default = tostring(Dominant.Cfg[key] or ""),
            Callback = function(text)
                Dominant.Set(key, (tostring(text):gsub("%D", "")))
            end,
        })
    end

    function helpers.Number(parent, key, icon, min)
        local pending = 0
        return parent:AddTextbox({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Placeholder = L("number_hint"),
            Default = tostring(Dominant.Cfg[key]),
            Callback = function(text, enter)
                local cleaned = tostring(text or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
                local value = tonumber(cleaned)
                if not value then
                    return
                end
                value = math.max(min or 1, value)
                Dominant.Cfg[key] = value
                Dominant.Apply(key, value)
                Dominant.QueueSave()
                pending += 1
                local ticket = pending
                if enter then
                    Dominant.Notify(L("n_value_set", L(key), tostring(value)), "info", 2)
                else
                    task.delay(0.35, function()
                        if ticket == pending then
                            Dominant.Notify(L("n_value_set", L(key), tostring(value)), "info", 2)
                        end
                    end)
                end
            end,
        })
    end

    function helpers.Color(parent, key, icon)
        return parent:AddColorPicker({
            Text = L(key),
            Icon = icon,
            Default = Dominant.Cfg[key],
            Callback = function(color)
                Dominant.Set(key, color)
            end,
        })
    end

    function helpers.Button(parent, key, icon, callback)
        return parent:AddButton({
            Text = L(key),
            Description = UI.Describe(key),
            Icon = icon,
            Callback = callback,
        })
    end

    function helpers.Section(parent, key, icon)
        parent:AddSection(L(key), icon)
    end

    return helpers
end

function UI.BuildHome(Window, tabs, H)
    local info = tabs.Home:AddSubTab({ Name = L("sub_info"), Icon = "Lucide:layout-dashboard" })
    local keyName = Dominant.Cfg.menu_key
    info:AddCard({
        UserId = LocalPlayer.UserId,
        Title = Dominant.Greeting() .. ", " .. LocalPlayer.DisplayName,
        Description = L("home_title"),
    })
    info:AddSystemInfoGrid({ Description = L("home_executor", Dominant.Executor) })
    H.Section(info, "sec_welcome", "Lucide:sparkles")
    info:AddParagraph({
        Title = L("home_title"),
        Icon = "Lucide:crown",
        Text = L("home_text", keyName) .. "\n\n" .. L("home_credits"),
    })
    H.Section(info, "sec_status", "Lucide:activity")
    local caps = Dominant.Caps
    local function yes(flag)
        return flag and L("home_yes") or L("home_no")
    end
    info:AddParagraph({
        Title = L("home_executor", Dominant.Executor),
        Icon = "Lucide:terminal",
        Text = L("home_caps", yes(caps.require), yes(caps.hookmetamethod), yes(caps.files)),
    })

    local changelog = tabs.Home:AddSubTab({ Name = L("sub_changelog"), Icon = "Lucide:file-text" })
    changelog:AddChangelogEntry({
        Version = L("log_version28"),
        Date = L("log_date28"),
        Changes = {
            { Type = "Added", Text = L("log_46") },
            { Type = "Changed", Text = L("log_47") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version27"),
        Date = L("log_date27"),
        Changes = {
            { Type = "Fixed", Text = L("log_50") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version26"),
        Date = L("log_date26"),
        Changes = {
            { Type = "Fixed", Text = L("log_49") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version25"),
        Date = L("log_date25"),
        Changes = {
            { Type = "Fixed", Text = L("log_48") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version24"),
        Date = L("log_date24"),
        Changes = {
            { Type = "Added", Text = L("log_46") },
            { Type = "Changed", Text = L("log_47") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version23"),
        Date = L("log_date23"),
        Changes = {
            { Type = "Added", Text = L("log_44") },
            { Type = "Fixed", Text = L("log_45") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version22"),
        Date = L("log_date22"),
        Changes = {
            { Type = "Added", Text = L("log_42") },
            { Type = "Added", Text = L("log_43") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version21"),
        Date = L("log_date21"),
        Changes = {
            { Type = "Changed", Text = L("log_40") },
            { Type = "Added", Text = L("log_41") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version20"),
        Date = L("log_date20"),
        Changes = {
            { Type = "Fixed", Text = L("log_39") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version19"),
        Date = L("log_date19"),
        Changes = {
            { Type = "Changed", Text = L("log_38") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version18"),
        Date = L("log_date18"),
        Changes = {
            { Type = "Fixed", Text = L("log_37") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version17"),
        Date = L("log_date17"),
        Changes = {
            { Type = "Added", Text = L("log_36") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version16"),
        Date = L("log_date16"),
        Changes = {
            { Type = "Added", Text = L("log_34") },
            { Type = "Fixed", Text = L("log_35") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version15"),
        Date = L("log_date15"),
        Changes = {
            { Type = "Added", Text = L("log_33") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version14"),
        Date = L("log_date14"),
        Changes = {
            { Type = "Added", Text = L("log_32") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version13"),
        Date = L("log_date13"),
        Changes = {
            { Type = "Fixed", Text = L("log_31") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version12"),
        Date = L("log_date12"),
        Changes = {
            { Type = "Added", Text = L("log_29") },
            { Type = "Added", Text = L("log_30") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version11"),
        Date = L("log_date11"),
        Changes = {
            { Type = "Added", Text = L("log_26") },
            { Type = "Added", Text = L("log_27") },
            { Type = "Changed", Text = L("log_28") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version10"),
        Date = L("log_date10"),
        Changes = {
            { Type = "Fixed", Text = L("log_24") },
            { Type = "Fixed", Text = L("log_25") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version9"),
        Date = L("log_date9"),
        Changes = {
            { Type = "Fixed", Text = L("log_22") },
            { Type = "Changed", Text = L("log_23") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version8"),
        Date = L("log_date8"),
        Changes = {
            { Type = "Added", Text = L("log_21") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version7"),
        Date = L("log_date7"),
        Changes = {
            { Type = "Fixed", Text = L("log_20") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version6"),
        Date = L("log_date6"),
        Changes = {
            { Type = "Fixed", Text = L("log_16") },
            { Type = "Added", Text = L("log_17") },
            { Type = "Added", Text = L("log_18") },
            { Type = "Changed", Text = L("log_19") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version5"),
        Date = L("log_date5"),
        Changes = {
            { Type = "Added", Text = L("log_14") },
            { Type = "Changed", Text = L("log_15") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version5"),
        Date = L("log_date5"),
        Changes = {
            { Type = "Added", Text = L("log_14") },
            { Type = "Added", Text = L("log_15") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version4"),
        Date = L("log_date4"),
        Changes = {
            { Type = "Fixed", Text = L("log_11") },
            { Type = "Added", Text = L("log_12") },
            { Type = "Changed", Text = L("log_13") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version3"),
        Date = L("log_date3"),
        Changes = {
            { Type = "Added", Text = L("log_8") },
            { Type = "Changed", Text = L("log_9") },
            { Type = "Added", Text = L("log_10") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version2"),
        Date = L("log_date2"),
        Changes = {
            { Type = "Changed", Text = L("log_4") },
            { Type = "Added", Text = L("log_5") },
            { Type = "Added", Text = L("log_6") },
            { Type = "Added", Text = L("log_7") },
        },
    })
    changelog:AddChangelogEntry({
        Version = L("log_version"),
        Date = L("log_date"),
        Changes = {
            { Type = "Added", Text = L("log_1") },
            { Type = "Added", Text = L("log_2") },
            { Type = "Added", Text = L("log_3") },
        },
    })
end

function UI.BuildPlayer(tab, H)
    H.Section(tab, "sec_movement", "Lucide:footprints")
    H.Toggle(tab, "cframe_speed", "Lucide:gauge")
    H.Slider(tab, "cframe_speed_value", 1, 250, 1, "Lucide:gauge")
    H.Number(tab, "cframe_speed_value", "Lucide:gauge", 1)
    H.Toggle(tab, "always_sprint", "Lucide:footprints")
    H.Toggle(tab, "jumppower_on", "Lucide:arrow-up")
    H.Slider(tab, "jumppower", 0, 200, 5, "Lucide:arrow-up")
    H.Toggle(tab, "infinite_jump", "Lucide:chevrons-up")
    H.Toggle(tab, "noclip", "Lucide:ghost")
    H.Toggle(tab, "fly", "Lucide:plane")
    H.Slider(tab, "fly_speed", 10, 200, 5, "Lucide:wind")
    H.Toggle(tab, "spin", "Lucide:refresh-cw")
    H.Slider(tab, "spin_speed", 1, 60, 1, "Lucide:refresh-cw")
    H.Toggle(tab, "enable_jumping", "Lucide:move-up")
    H.Toggle(tab, "no_fall", "Lucide:arrow-down")

    H.Section(tab, "sec_survival", "Lucide:shield")
    H.Toggle(tab, "invincible", "Lucide:shield-check")
    H.Toggle(tab, "invisible", "Lucide:eye-off")
    H.Toggle(tab, "anti_slow", "Lucide:zap")
    H.Toggle(tab, "infinite_stamina", "Lucide:battery-charging")
    H.Toggle(tab, "stamina_custom", "Lucide:sliders-horizontal")
    H.Number(tab, "stamina_max", "Lucide:battery-full", 1)
    H.Number(tab, "stamina_regen", "Lucide:battery-charging", 0)
    H.Number(tab, "stamina_drain", "Lucide:battery-low", 0)
    H.Toggle(tab, "sprint_speed_on", "Lucide:zap")
    H.Number(tab, "sprint_speed", "Lucide:gauge", 1)
    H.Toggle(tab, "anti_afk", "Lucide:timer")

    H.Section(tab, "sec_abilities", "Lucide:wand-sparkles")
    H.Toggle(tab, "void_rush_control", "Lucide:navigation")
    H.Number(tab, "void_rush_speed", "Lucide:gauge", 1)
    H.Toggle(tab, "void_rush_steer", "Lucide:compass")
    H.Toggle(tab, "controllable_dash", "Lucide:move-right")
end

function UI.BuildAutomation(tab, H)
    H.Section(tab, "sec_generators", "Lucide:cog")
    H.Toggle(tab, "auto_gen", "Lucide:puzzle")
    H.Slider(tab, "gen_cooldown", 1.5, 8, 0.25, "Lucide:timer", "s")
    H.Toggle(tab, "gen_speedup", "Lucide:fast-forward")
    H.Toggle(tab, "gen_override_grid", "Lucide:grid-3x3")
    H.Slider(tab, "gen_grid", 4, 12, 1, "Lucide:grid-3x3")
    H.Toggle(tab, "auto_gen_remote", "Lucide:repeat")
    H.Slider(tab, "gen_loop_delay", 0.5, 6, 0.1, "Lucide:timer", "s")
    H.Toggle(tab, "gen_all", "Lucide:map-pin-check")
    H.Slider(tab, "gen_all_interval", 0.5, 10, 0.5, "Lucide:timer", "s")
    H.Toggle(tab, "gen_all_reset", "Lucide:rotate-ccw")

    H.Section(tab, "sec_helpers", "Lucide:bot")
    H.Toggle(tab, "auto_pickup", "Lucide:hand")
    H.Slider(tab, "pickup_range", 4, 40, 1, "Lucide:radius", " studs")
    H.Toggle(tab, "auto_escape", "Lucide:log-out")
    H.Slider(tab, "escape_cooldown", 0.2, 1.2, 0.1, "Lucide:timer", "s")
    H.Toggle(tab, "auto_disarm", "Lucide:wrench")
    H.Toggle(tab, "auto_popups", "Lucide:mouse-pointer-click")
    H.Toggle(tab, "instant_prompts", "Lucide:zap")
end

function UI.BuildCombat(tab, H)
    H.Section(tab, "sec_guest", "Lucide:shield-half")
    H.Toggle(tab, "guest_block", "Lucide:shield")
    H.Slider(tab, "guest_block_range", 6, 40, 1, "Lucide:radius", " studs")
    H.Toggle(tab, "guest_strict_range", "Lucide:target")
    H.Toggle(tab, "guest_wallcheck", "Lucide:brick-wall")
    H.Toggle(tab, "block_range_esp", "Lucide:circle-dashed")
    H.Color(tab, "color_block_ring", "Lucide:palette")
    H.Toggle(tab, "guest_skip_special", "Lucide:ban")
    H.Toggle(tab, "auto_parry", "Lucide:shield-check")
    H.Slider(tab, "guest_abh", -3, 5, 0.25, "Lucide:box", " studs")
    H.Toggle(tab, "drag_block", "Lucide:move")
    H.Number(tab, "drag_stop", "Lucide:ruler", 0)
    H.Number(tab, "drag_hold", "Lucide:timer", 0)
    H.Toggle(tab, "guest_facing_check", "Lucide:scan-eye")
    local loose, strict = L("opt_loose"), L("opt_strict")
    H.Dropdown(tab, "guest_facing", { loose, strict }, "Lucide:compass", Dominant.Cfg.guest_facing == "Loose" and loose or strict, function(value)
        Dominant.Set("guest_facing", value == loose and "Loose" or "Strict")
    end)
    H.Toggle(tab, "guest_block_tp", "Lucide:locate-fixed")
    H.Toggle(tab, "guest_predictive", "Lucide:brain")
    H.Slider(tab, "guest_predict_range", 4, 30, 1, "Lucide:radius", " studs")
    H.Slider(tab, "guest_edge_delay", 0.5, 8, 0.5, "Lucide:timer", "s")
    H.Toggle(tab, "guest_auto_punch", "Lucide:hand-metal")
    H.Slider(tab, "guest_punch_wait", 0, 1, 0.01, "Lucide:timer", "s")
    H.Toggle(tab, "guest_charge_speed_on", "Lucide:gauge")
    H.Slider(tab, "guest_charge_speed", 1, 6, 0.1, "Lucide:gauge")
    H.Toggle(tab, "guest_fling_punch", "Lucide:rocket")
    H.Slider(tab, "guest_fling_power", 1000, 30000, 500, "Lucide:rocket")
    H.Toggle(tab, "guest_punch_aim", "Lucide:crosshair")
    H.Slider(tab, "guest_punch_prediction", 0, 12, 1, "Lucide:crosshair", " studs")

    H.Section(tab, "sec_aim", "Lucide:crosshair")
    H.Toggle(tab, "chance_aimbot", "Lucide:crosshair")
    H.Slider(tab, "chance_prediction", 0, 1, 0.05, "Lucide:clock", "s")
    H.Toggle(tab, "hitbox_mod", "Lucide:box")
    H.Slider(tab, "hitbox_range", 20, 200, 5, "Lucide:radius", " studs")
end

function UI.BuildVisuals(tab, H)
    H.Section(tab, "sec_esp", "Lucide:eye")
    H.Toggle(tab, "esp", "Lucide:eye")
    H.Toggle(tab, "esp_killers", "Lucide:skull")
    H.Toggle(tab, "esp_survivors", "Lucide:users")
    H.Toggle(tab, "esp_generators", "Lucide:cog")
    H.Toggle(tab, "esp_items", "Lucide:package")
    H.Toggle(tab, "esp_pallets", "Lucide:rectangle-horizontal")
    H.Toggle(tab, "esp_windows", "Lucide:app-window")
    H.Toggle(tab, "esp_chests", "Lucide:gift")
    H.Toggle(tab, "esp_traps", "Lucide:triangle-alert")
    H.Toggle(tab, "esp_support", "Lucide:bug")
    H.Toggle(tab, "esp_fake", "Lucide:circle-help")
    H.Toggle(tab, "esp_tracers", "Lucide:spline")
    local bottom, center, mouse = L("opt_bottom"), L("opt_center"), L("opt_mouse")
    local names = { Bottom = bottom, Center = center, Mouse = mouse }
    H.Dropdown(tab, "esp_tracer_origin", { bottom, center, mouse }, "Lucide:crosshair", names[Dominant.Cfg.esp_tracer_origin], function(value)
        local chosen = value == center and "Center" or value == mouse and "Mouse" or "Bottom"
        Dominant.Set("esp_tracer_origin", chosen)
    end)
    H.Slider(tab, "esp_tracer_thickness", 1, 5, 0.5, "Lucide:minus")
    H.Toggle(tab, "esp_outline_only", "Lucide:square")
    H.Slider(tab, "esp_text_size", 9, 24, 1, "Lucide:type")
    H.Toggle(tab, "esp_text", "Lucide:type")
    H.Toggle(tab, "esp_distance", "Lucide:ruler")
    H.Toggle(tab, "esp_health", "Lucide:heart")
    H.Toggle(tab, "esp_hide_done", "Lucide:eye-off")
    H.Slider(tab, "esp_max_distance", 100, 5000, 100, "Lucide:radius", " studs")
    H.Slider(tab, "esp_fill", 0, 1, 0.05, "Lucide:droplet")

    H.Section(tab, "sec_colors", "Lucide:palette")
    H.Color(tab, "color_killer", "Lucide:palette")
    H.Color(tab, "color_survivor", "Lucide:palette")
    H.Color(tab, "color_generator", "Lucide:palette")
    H.Color(tab, "color_item", "Lucide:palette")
    H.Color(tab, "color_trap", "Lucide:palette")
    H.Color(tab, "color_pallet", "Lucide:palette")
    H.Color(tab, "color_window", "Lucide:palette")
    H.Color(tab, "color_chest", "Lucide:palette")
    H.Color(tab, "color_fake", "Lucide:palette")
    H.Color(tab, "color_support", "Lucide:palette")

    H.Section(tab, "sec_screen", "Lucide:monitor")
    H.Toggle(tab, "fov_on", "Lucide:scan")
    H.Slider(tab, "fov", 40, 120, 1, "Lucide:scan")
    H.Toggle(tab, "zoom_on", "Lucide:zoom-in")
    H.Slider(tab, "zoom", 20, 500, 10, "Lucide:zoom-in")
    H.Toggle(tab, "fullbright", "Lucide:sun")
    H.Toggle(tab, "no_fog", "Lucide:cloud-off")
    H.Toggle(tab, "hide_injury", "Lucide:bandage")
    H.Toggle(tab, "disable_blindness", "Lucide:glasses")
    H.Toggle(tab, "show_chat", "Lucide:message-square")

    H.Section(tab, "sec_privacy", "Lucide:lock")
    H.Toggle(tab, "name_protect", "Lucide:user-x")
    H.Toggle(tab, "stats_tracker", "Lucide:list")
    H.Toggle(tab, "delete_ragdolls", "Lucide:trash-2")
end

function UI.BuildWorld(tab, H)
    H.Section(tab, "sec_map", "Lucide:map")
    H.Toggle(tab, "kill_walls", "Lucide:brick-wall")
    H.Toggle(tab, "no_trails", "Lucide:footprints")
    H.Toggle(tab, "no_footprints", "Lucide:paw-print")
    H.Toggle(tab, "small_spikes", "Lucide:triangle")

    H.Section(tab, "sec_teleports", "Lucide:map-pin")
    H.Button(tab, "btn_tp_generator", "Lucide:cog", function()
        Feat.World.TeleportToGenerator(false)
    end)
    H.Button(tab, "btn_tp_random_gen", "Lucide:shuffle", function()
        Feat.World.TeleportToGenerator(true)
    end)
    H.Button(tab, "btn_tp_item", "Lucide:package", Feat.World.TeleportToItem)
    H.Button(tab, "btn_collect_items", "Lucide:hand", Feat.World.CollectItems)
    H.Button(tab, "btn_tp_killer", "Lucide:skull", function()
        Feat.Extras.TeleportToRole("killer")
    end)
    H.Button(tab, "btn_tp_survivor", "Lucide:users", function()
        Feat.Extras.TeleportToRole("survivor")
    end)
    H.Toggle(tab, "spectate_killer", "Lucide:video")

    H.Section(tab, "sec_ring", "Lucide:orbit")
    H.Toggle(tab, "item_ring", "Lucide:orbit")
    H.Slider(tab, "ring_radius", 4, 40, 1, "Lucide:radius", " studs")
    H.Slider(tab, "ring_speed", 0.2, 6, 0.1, "Lucide:rotate-cw")
    H.Toggle(tab, "click_tp", "Lucide:mouse-pointer-click")
    H.Toggle(tab, "killer_alert", "Lucide:siren")
    H.Slider(tab, "alert_range", 20, 200, 5, "Lucide:radius", " studs")

    H.Section(tab, "sec_players", "Lucide:users")
    local names, lookup = Feat.Ring.PlayerNames()
    Dominant.Objects.selectedPlayer = nil
    H.Dropdown(tab, "player_select", names, "Lucide:user-search", names[1], function(value)
        Dominant.Objects.selectedPlayer = lookup[value]
    end)
    Dominant.Objects.selectedPlayer = lookup[names[1]]
    H.Button(tab, "btn_tp_player", "Lucide:map-pin", Feat.Ring.TeleportToPlayer)
    H.Button(tab, "btn_spectate_player", "Lucide:video", Feat.Ring.Spectate)
    H.Button(tab, "btn_stop_spectate", "Lucide:video-off", Feat.Ring.StopSpectate)
    H.Button(tab, "btn_refresh_players", "Lucide:refresh-cw", function()
        UI.Rebuild("tab_world")
    end)
end

function UI.BuildFun(tab, H)
    H.Section(tab, "sec_animchanger", "Lucide:shirt")
    pcall(Feat.AnimChanger.Build)
    local original = L("opt_original")
    local choices = { original }
    for _, name in ipairs(Feat.AnimChanger.Names) do
        table.insert(choices, name)
    end
    H.Dropdown(tab, "anim_changer", choices, "Lucide:shirt", Dominant.Cfg.anim_changer == "Original" and original or Dominant.Cfg.anim_changer, function(value)
        Dominant.Set("anim_changer", value == original and "Original" or value)
    end)

    H.Section(tab, "sec_emotes", "Lucide:smile")
    local emoteList = Feat.Emotes.Load()
    if #emoteList == 0 then
        emoteList = { "-" }
    end
    Feat.Emotes.Selected = emoteList[1]
    H.Dropdown(tab, "emote_pick", emoteList, "Lucide:list", emoteList[1], function(value)
        Feat.Emotes.Selected = value
    end)
    H.Button(tab, "btn_play_emote", "Lucide:play", function()
        Feat.Emotes.Play(Feat.Emotes.Selected)
    end)
    H.Button(tab, "btn_stop_emote", "Lucide:square", Feat.Emotes.Stop)

    H.Section(tab, "sec_anims", "Lucide:person-standing")
    H.Toggle(tab, "goon", "Lucide:person-standing")
    H.Toggle(tab, "laydown", "Lucide:bed")
    H.Toggle(tab, "custom_block_on", "Lucide:shield")
    H.Textbox(tab, "custom_block_id", "anim_id_hint", "Lucide:hash")
    H.Toggle(tab, "custom_punch_on", "Lucide:hand-metal")
    H.Textbox(tab, "custom_punch_id", "anim_id_hint", "Lucide:hash")
    H.Toggle(tab, "custom_charge_on", "Lucide:zap")
    H.Textbox(tab, "custom_charge_id", "anim_id_hint", "Lucide:hash")
    H.Button(tab, "btn_stop_anims", "Lucide:square", Feat.Anim.StopAll)

    H.Section(tab, "sec_audio", "Lucide:music")
    tab:AddTextbox({
        Text = L("sound_id"),
        Icon = "Lucide:music-2",
        Placeholder = L("sound_id_hint"),
        Default = "",
        Callback = function(text, enter)
            if enter then
                Feat.Audio.Play(text)
            end
        end,
    })
    H.Slider(tab, "sound_volume", 0, 10, 0.5, "Lucide:volume-2")
    H.Button(tab, "btn_stop_sound", "Lucide:volume-x", Feat.Audio.Stop)
    H.Dropdown(tab, "lms_song", Feat.Audio.SongOrder, "Lucide:disc-3", nil, function(value)
        Dominant.Set("lms_song", value)
    end)
    H.Button(tab, "btn_lms_replace", "Lucide:replace", Feat.Audio.ReplaceLms)
end

function Dominant.RunTool(url, name)
    local okFetch, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not okFetch or type(body) ~= "string" or #body < 50 then
        Dominant.Warn("[Dominant] could not download " .. name .. ": " .. tostring(body))
        Dominant.Notify(L("n_tool_fail", name), "error", 4)
        return
    end
    local compiled, compileErr = loadstring(body, "=" .. name)
    if not compiled then
        Dominant.Warn("[Dominant] could not compile " .. name .. ": " .. tostring(compileErr))
        Dominant.Notify(L("n_tool_fail", name), "error", 4)
        return
    end
    local okRun, runErr = pcall(compiled)
    if not okRun then
        Dominant.Warn("[Dominant] " .. name .. " failed: " .. tostring(runErr))
        Dominant.Notify(L("n_tool_fail", name), "error", 4)
        return
    end
    Dominant.Notify(L("n_tool_ok", name), "success", 3)
end

function UI.BuildMisc(tab, H)
    H.Section(tab, "sec_tools", "Lucide:wrench")
    H.Button(tab, "btn_infinite_yield", "Lucide:terminal", function()
        task.spawn(Dominant.RunTool, "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "Infinite Yield")
    end)
    H.Button(tab, "btn_dex", "Lucide:search", function()
        task.spawn(Dominant.RunTool, "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua", "Dex Explorer++")
    end)
    H.Section(tab, "sec_server", "Lucide:server")
    H.Toggle(tab, "auto_rejoin", "Lucide:rotate-ccw")
    H.Button(tab, "btn_rejoin", "Lucide:rotate-ccw", Feat.Server.Rejoin)
    H.Button(tab, "btn_serverhop", "Lucide:shuffle", Feat.Server.Hop)
    H.Toggle(tab, "timed_hop", "Lucide:timer")
    H.Number(tab, "timed_hop_minutes", "Lucide:timer", 1)
    H.Button(tab, "btn_copy_jobid", "Lucide:copy", Dominant.CopyJobId)
    H.Button(tab, "btn_copy_join", "Lucide:clipboard", Dominant.CopyJoinScript)
    H.Button(tab, "btn_reset_char", "Lucide:skull", Dominant.ResetCharacter)

    H.Section(tab, "sec_performance", "Lucide:gauge")
    H.Toggle(tab, "hud", "Lucide:activity")
    H.Toggle(tab, "fps_cap_on", "Lucide:gauge")
    H.Slider(tab, "fps_cap", 30, 360, 5, "Lucide:gauge")
    H.Toggle(tab, "performance_mode", "Lucide:cpu")
end

function UI.BuildDebug(tab, H)
    H.Section(tab, "sec_console", "Lucide:terminal")
    local console = tab:AddConsole({ Height = 180, AutoCapture = false })
    Dominant.Console = console
    for _, entry in ipairs(Dominant.LogBuffer) do
        pcall(function()
            console:Log(entry[1], entry[2])
        end)
    end
    H.Button(tab, "btn_clear_console", "Lucide:eraser", function()
        Dominant.LogBuffer = {}
        pcall(function()
            console:Clear()
        end)
    end)
    H.Button(tab, "btn_dump_state", "Lucide:bug", Dominant.DumpState)

    H.Section(tab, "sec_leaderboard", "Lucide:trophy")
    Dominant.Board = tab:AddTable({
        Title = L("sec_leaderboard"),
        Height = 170,
        Columns = {
            { Key = "name", Label = L("col_player"), Weight = 2 },
            { Key = "role", Label = L("col_role"), Weight = 2 },
            { Key = "distance", Label = L("col_distance"), Weight = 1, Align = "Right" },
            { Key = "health", Label = L("col_health"), Weight = 1, Align = "Right" },
            { Key = "money", Label = L("col_money"), Weight = 1.5, Align = "Right" },
            { Key = "malice", Label = L("col_malice"), Weight = 1.5, Align = "Right" },
        },
        Rows = {},
    })
    Dominant.StartLoop("board", 1, Dominant.UpdateBoard)
    Dominant.Log(L("debug_ready"), Enum.MessageType.MessageInfo)
end

function UI.BuildSettings(Window, tab, H)
    H.Section(tab, "sec_language", "Lucide:languages")
    local names, current = {}, Dominant.Languages[1].Name
    for _, language in ipairs(Dominant.Languages) do
        table.insert(names, language.Name)
        if language.Code == Dominant.Lang then
            current = language.Name
        end
    end
    H.Dropdown(tab, "language", names, "Lucide:languages", current, function(value)
        for _, language in ipairs(Dominant.Languages) do
            if language.Name == value and language.Code ~= Dominant.Lang then
                Dominant.SetLanguage(language.Code)
                break
            end
        end
    end)

    H.Section(tab, "sec_interface", "Lucide:layout-dashboard")
    H.Toggle(tab, "notifications", "Lucide:bell")

    H.Section(tab, "sec_background", "Lucide:image")
    tab:AddParagraph({
        Title = L("bg_folder_hint"),
        Icon = "Lucide:folder",
        Text = L("bg_gif_note"),
    })
    H.Toggle(tab, "bg_enabled", "Lucide:image")
    tab:AddTextbox({
        Text = L("bg_path"),
        Description = L("bg_folder_hint"),
        Icon = "Lucide:file-image",
        Flag = "bg_path",
        Default = Dominant.Cfg.bg_path or "",
        Placeholder = "Dominant/Backgrounds/bg.png",
        Callback = function(text, enter)
            Dominant.Cfg.bg_path = tostring(text or "")
            Dominant.QueueSave(true)
            if enter and Dominant.Cfg.bg_path ~= "" then
                if Feat.Background.Apply(Dominant.Cfg.bg_path) then
                    Dominant.Notify(L("bg_applied"), "success", 3)
                else
                    Dominant.Notify(L("bg_failed"), "error", 3)
                end
            end
        end,
    })
    H.Dropdown(tab, "bg_scale", { "Crop", "Fit", "Stretch" }, "Lucide:maximize", Dominant.Cfg.bg_scale or "Crop", function(value)
        Dominant.Set("bg_scale", value)
    end)
    H.Slider(tab, "bg_transparency", 0, 1, 0.05, "Lucide:blend")
    H.Slider(tab, "bg_window_transparency", 0, 0.8, 0.05, "Lucide:app-window")
    H.Button(tab, "bg_browse", "Lucide:folder-tree", function()
        Feat.Background.OpenBrowser()
    end)
    H.Button(tab, "bg_refresh", "Lucide:refresh-cw", function()
        Feat.Background.Ensure()
        Feat.Background.Refresh()
        Dominant.Notify(L("bg_refresh"), "info", 2)
    end)
    H.Button(tab, "bg_clear", "Lucide:x", function()
        Feat.Background.Apply("")
        Dominant.Notify(L("bg_clear"), "info", 2)
    end)
    H.Button(tab, "bg_apply", "Lucide:check", function()
        local path = Dominant.Cfg.bg_path
        if type(Dominant.Vind) == "table" and Dominant.Vind.Flags and Dominant.Vind.Flags.bg_path and Dominant.Vind.Flags.bg_path.Get then
            path = Dominant.Vind.Flags.bg_path:Get() or path
            Dominant.Cfg.bg_path = tostring(path or "")
        end
        if not path or path == "" then
            Dominant.Notify(L("bg_folder_hint"), "warning", 3)
            return
        end
        if Feat.Background.Apply(path) then
            Dominant.Notify(L("bg_applied"), "success", 3)
        else
            Dominant.Notify(L("bg_failed"), "error", 3)
        end
    end)
    tab:AddKeybind({
        Text = L("menu_key"),
        Description = UI.Describe("menu_key"),
        Icon = "Lucide:keyboard",
        Default = Enum.KeyCode[Dominant.Cfg.menu_key] or CONFIG.MenuKey,
        Callback = function(key, kind)
            if kind == "press" then
                Window:Toggle()
            elseif typeof(key) == "EnumItem" then
                Dominant.Set("menu_key", key.Name, true)
            end
        end,
    })

    H.Section(tab, "sec_hotkeys", "Lucide:keyboard")
    for _, hotkey in ipairs(Feat.Hotkeys.Order) do
        local label = "hotkey_" .. hotkey:sub(5)
        tab:AddKeybind({
            Text = L(label),
            Description = UI.Describe(label),
            Icon = "Lucide:keyboard",
            Default = Enum.KeyCode[Dominant.Cfg[hotkey]] or Enum.KeyCode.Unknown,
            Callback = function(key, kind)
                if kind == "press" then
                    Feat.Hotkeys.Run(hotkey)
                elseif typeof(key) == "EnumItem" then
                    Dominant.Set(hotkey, key.Name, true)
                end
            end,
        })
    end

    H.Section(tab, "sec_config", "Lucide:save")
    Dominant.Objects.configName = Dominant.SanitizeName(Dominant.Objects.configName or Dominant.ReadAutoload())
    tab:AddTextbox({
        Text = L("config_name"),
        Icon = "Lucide:pencil",
        Placeholder = L("config_name_hint"),
        Default = Dominant.Objects.configName,
        Callback = function(text)
            Dominant.Objects.configName = Dominant.SanitizeName(text)
        end,
    })
    local configs = Dominant.ListConfigs()
    local current = Dominant.Objects.configName
    local initial = configs[1]
    for _, name in ipairs(configs) do
        if name == current then
            initial = name
        end
    end
    H.Dropdown(tab, "config_pick", configs, "Lucide:list", initial, function(value)
        if value ~= "-" then
            Dominant.Objects.configName = Dominant.SanitizeName(value)
        end
    end)
    H.Button(tab, "btn_config_save", "Lucide:save", function()
        Dominant.ConfigAction("save")
    end)
    H.Button(tab, "btn_config_overwrite", "Lucide:file-pen", function()
        Dominant.ConfigAction("overwrite")
    end)
    H.Button(tab, "btn_config_load", "Lucide:folder-open", function()
        Dominant.ConfigAction("load")
    end)
    H.Button(tab, "btn_config_delete", "Lucide:trash-2", function()
        Dominant.ConfigAction("delete")
    end)
    H.Button(tab, "btn_config_autoload", "Lucide:zap", function()
        Dominant.ConfigAction("autoload")
    end)
    H.Button(tab, "btn_config_refresh", "Lucide:refresh-cw", function()
        UI.Rebuild("tab_settings")
    end)
    H.Button(tab, "btn_reset", "Lucide:rotate-ccw", function()
        Dominant.Vind:Confirm({
            Title = L("confirm_reset_title"),
            Text = L("confirm_reset_text"),
            Window = Window,
            Callback = function(confirmed)
                if confirmed then
                    Dominant.Teardown(true)
                    Dominant.Reset()
                    Dominant.Cfg.language = Dominant.Lang
                    Dominant.SaveNow()
                    Dominant.Notify(L("n_reset"), "warning", 3)
                    UI.Rebuild("tab_settings")
                end
            end,
        })
    end)
    H.Button(tab, "btn_unload", "Lucide:power", function()
        Dominant.Vind:Confirm({
            Title = L("confirm_unload_title"),
            Text = L("confirm_unload_text"),
            Window = Window,
            Callback = function(confirmed)
                if confirmed then
                    Dominant.Unload()
                end
            end,
        })
    end)

    H.Section(tab, "sec_credits", "Lucide:heart")
    H.Button(tab, "btn_open_credits", "Lucide:heart", UI.OpenCredits)
    H.Button(tab, "btn_vind_credits", "Lucide:users", UI.OpenVindCredits)
    pcall(function()
        tab:AddParagraph({
            Title = L("credits_line"),
            Icon = "Lucide:crown",
            Text = L("credits_sources") .. "\nDominant " .. CONFIG.Version,
        })
    end)
end

function UI.Build(selectKey)
    local library = UI.Load()
    if not library then
        return false
    end
    Dominant.Vind = library
    UI.Elements = {}
    if type(library.CreateWindow) ~= "function" then
        Dominant.Warn("[Dominant] Vind has no CreateWindow")
        return false
    end
    local okWindow, Window = pcall(function()
        return library:CreateWindow({
            Title = CONFIG.Title,
            Subtitle = CONFIG.Description .. " · v" .. CONFIG.Version,
            Icon = "rbxassetid://116590139091461",
            Size = UDim2.fromOffset(640, 455),
            MinSize = Vector2.new(500, 360),
            Draggable = true,
            Resizable = true,
            UseBlur = true,
            DefaultTab = L(selectKey or "tab_home"),
            TabWidth = 145,
            TabScrollbar = true,
        })
    end)
    if not okWindow or type(Window) ~= "table" then
        Dominant.Warn("[Dominant] CreateWindow failed: " .. tostring(Window))
        return false
    end
    Dominant.Window = Window
    local H = UI.Helpers(Window)
    local tabs = {
        Home = Window:AddTab({ Name = L("tab_home"), Icon = "Lucide:house" }),
        Credits = Window:AddTab({ Name = L("tab_credits"), Icon = "Lucide:heart" }),
        Player = Window:AddTab({ Name = L("tab_player"), Icon = "Lucide:user" }),
        Auto = Window:AddTab({ Name = L("tab_auto"), Icon = "Lucide:bot" }),
        Combat = Window:AddTab({ Name = L("tab_combat"), Icon = "Lucide:swords" }),
        Visuals = Window:AddTab({ Name = L("tab_visuals"), Icon = "Lucide:eye" }),
        World = Window:AddTab({ Name = L("tab_world"), Icon = "Lucide:map" }),
        Fun = Window:AddTab({ Name = L("tab_fun"), Icon = "Lucide:music" }),
        Misc = Window:AddTab({ Name = L("tab_misc"), Icon = "Lucide:wrench" }),
        Debug = Window:AddTab({ Name = L("tab_debug"), Icon = "Lucide:terminal" }),
        Settings = Window:AddTab({ Name = L("tab_settings"), Icon = "Lucide:settings" }),
    }
    UI.BuildHome(Window, tabs, H)
    UI.FillCredits(tabs.Credits)
    UI.BuildPlayer(tabs.Player, H)
    UI.BuildAutomation(tabs.Auto, H)
    UI.BuildCombat(tabs.Combat, H)
    UI.BuildVisuals(tabs.Visuals, H)
    UI.BuildWorld(tabs.World, H)
    UI.BuildFun(tabs.Fun, H)
    UI.BuildMisc(tabs.Misc, H)
    UI.BuildDebug(tabs.Debug, H)
    UI.BuildSettings(Window, tabs.Settings, H)
    pcall(function()
        Window:SelectTab(L(selectKey or "tab_home"))
    end)
    pcall(function()
        Window:Open()
    end)
    Feat.Background.Ensure()
    Dominant.ApplyStartupBackground()
    return true
end

function Dominant.ConfigAction(kind)
    local name = Dominant.SanitizeName(Dominant.Objects.configName)
    Dominant.Objects.configName = name
    if kind == "save" then
        if Dominant.ConfigExists(name) then
            Dominant.Notify(L("n_config_exists", name), "warning", 4)
            return
        end
        Dominant.Notify(Dominant.WriteConfig(name) and L("n_config_saved", name) or L("n_save_fail"), "success", 3)
        UI.Rebuild("tab_settings")
    elseif kind == "overwrite" then
        Dominant.Notify(Dominant.WriteConfig(name) and L("n_config_saved", name) or L("n_save_fail"), "success", 3)
        UI.Rebuild("tab_settings")
    elseif kind == "load" then
        local decoded = Dominant.ReadConfig(name)
        if not decoded then
            Dominant.Notify(L("n_config_missing", name), "warning", 4)
            return
        end
        Dominant.Teardown(true)
        Dominant.ApplyDecoded(decoded)
        Dominant.Lang = Dominant.Cfg.language or Dominant.Lang
        Dominant.SaveNow()
        Dominant.ResyncEnabled()
        Dominant.Notify(L("n_config_loaded", name), "success", 3)
        UI.Rebuild("tab_settings")
    elseif kind == "delete" then
        if not Dominant.ConfigExists(name) then
            Dominant.Notify(L("n_config_missing", name), "warning", 4)
            return
        end
        Dominant.Vind:Confirm({
            Title = L("confirm_delete_title"),
            Text = L("confirm_delete_text", name),
            Window = Dominant.Window,
            Callback = function(confirmed)
                if not confirmed then
                    return
                end
                local ok = pcall(function()
                    delfile(Dominant.ConfigPath(name))
                end)
                if Dominant.ReadAutoload() == name then
                    Dominant.SetAutoload("")
                end
                Dominant.Notify(ok and L("n_config_deleted", name) or L("n_save_fail"), ok and "success" or "error", 3)
                UI.Rebuild("tab_settings")
            end,
        })
    elseif kind == "autoload" then
        if not Dominant.ConfigExists(name) then
            Dominant.WriteConfig(name)
        end
        Dominant.SetAutoload(name)
        Dominant.Notify(L("n_config_autoload", name), "success", 3)
    end
end

function UI.Rebuild(selectKey)
    task.defer(function()
        if Dominant.State.Unloading then
            return
        end
        if Dominant.Vind and Dominant.Vind.Unload then
            pcall(function()
                Dominant.Vind:Unload()
            end)
        end
        task.wait(0.25)
        UI.Build(selectKey)
    end)
end

function Dominant.SetLanguage(code)
    if not Dominant.Strings[code] then
        return
    end
    Dominant.Lang = code
    Dominant.Cfg.language = code
    Dominant.SaveNow()
    UI.Rebuild("tab_settings")
    task.delay(1, function()
        Dominant.Notify(L("n_lang"), "success", 3)
    end)
end

function Dominant.ResyncEnabled(fromRespawn)
    Dominant.EnsureWatchdog()
    local skip = {
        bg_enabled = true,
        bg_transparency = true,
        bg_scale = true,
        bg_window_transparency = true,
        bg_path = true,
    }
    local on, other = {}, {}
    for key in pairs(Dominant.Hooks) do
        if not skip[key] and not (fromRespawn and key == "invincible") then
            local value = Dominant.Cfg[key]
            if value == true then
                table.insert(on, key)
            elseif type(value) ~= "boolean" and value ~= Dominant.Defaults[key] then
                table.insert(other, key)
            end
        end
    end
    for _, key in ipairs(on) do
        Dominant.Apply(key, false)
    end
    task.wait(0.25)
    for _, key in ipairs(on) do
        Dominant.Apply(key, true)
    end
    for _, key in ipairs(other) do
        Dominant.Apply(key, Dominant.Cfg[key])
    end
end

function Dominant.ApplyEnabled(fromRespawn)
    Dominant.EnsureWatchdog()
    local skip = {
        bg_enabled = true,
        bg_transparency = true,
        bg_scale = true,
        bg_window_transparency = true,
        bg_path = true,
    }
    for key in pairs(Dominant.Hooks) do
        if skip[key] or (fromRespawn and key == "invincible") then
            continue
        end
        local value = Dominant.Cfg[key]
        local default = Dominant.Defaults[key]
        if value == true or (type(value) ~= "boolean" and value ~= default) then
            Dominant.Apply(key, value)
        end
    end
end

function Dominant.ApplyStartupBackground()
    if Dominant.State.Unloading or not Dominant.Cfg.bg_enabled then
        return
    end
    local path = Dominant.Cfg.bg_path
    if type(path) ~= "string" or path == "" then
        return
    end
    Dominant.State.BgStartId = (Dominant.State.BgStartId or 0) + 1
    local startId = Dominant.State.BgStartId

    local function stale()
        return Dominant.State.Unloading
            or Dominant.State.BgStartId ~= startId
            or not Dominant.Cfg.bg_enabled
            or Dominant.Cfg.bg_path ~= path
    end

    task.spawn(function()
        local deadline = os.clock() + 20
        while not stale() and os.clock() < deadline do
            local window = Dominant.Window
            if window and type(window.IsOpen) == "function" and window:IsOpen() and not window._busy then
                break
            end
            task.wait(0.1)
        end
        for _ = 1, 4 do
            if stale() then
                return
            end
            local label = Dominant.Window and Dominant.Window._BackgroundImage
            if label and label.Parent and label.Visible and label.Image ~= "" then
                return
            end
            pcall(Feat.Background.Apply, path, { Silent = true })
            task.wait(0.8)
        end
    end)
end

function Dominant.RestoreBackground()
    if Dominant.State.Unloading then
        return false
    end
    if not Dominant.Cfg.bg_enabled then
        return false
    end
    local path = Dominant.Cfg.bg_path
    if type(path) ~= "string" or path == "" then
        return false
    end

    -- cancel previous watcher
    Dominant.State.BgRestoreId = (Dominant.State.BgRestoreId or 0) + 1
    local restoreId = Dominant.State.BgRestoreId
    Dominant.State.BgRestorePending = true

    task.spawn(function()
        local deadline = os.clock() + 6
        local tries = 0
        while os.clock() < deadline do
            if Dominant.State.Unloading or Dominant.State.BgRestoreId ~= restoreId then
                return
            end
            if not Dominant.Cfg.bg_enabled or Dominant.Cfg.bg_path ~= path then
                Dominant.State.BgRestorePending = false
                return
            end

            local window = Dominant.Window
            if window and type(window.SetBackground) == "function" then
                tries += 1
                local asset = Feat.Background.Resolve(path)
                if not asset and Feat.Background.IsGif(path) then
                    local frames = Feat.Background.CollectFrames(path)
                    asset = frames[1]
                end

                if asset then
                    local transparency = math.clamp(tonumber(Dominant.Cfg.bg_transparency) or 0.45, 0, 1)
                    local scaleName = tostring(Dominant.Cfg.bg_scale or "Crop")
                    local winT = math.clamp(tonumber(Dominant.Cfg.bg_window_transparency) or 0.35, 0, 1)

                    pcall(function()
                        window:SetBackground({
                            Image = asset,
                            SourcePath = path,
                            Transparency = transparency,
                            ScaleType = scaleName,
                        })
                    end)
                    pcall(function()
                        if window.SetBackgroundTransparency then
                            window:SetBackgroundTransparency(winT)
                        end
                    end)

                    local gui = window._gui or window.Instance
                    local label = window._BackgroundImage
                    if not label and gui then
                        label = gui:FindFirstChild("WindowBackground")
                    end
                    if not label and gui then
                        label = Instance.new("ImageLabel")
                        label.Name = "WindowBackground"
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.fromScale(1, 1)
                        label.ScaleType = Enum.ScaleType.Crop
                        label.ZIndex = 1
                        label.Parent = gui
                        window._BackgroundImage = label
                    end
                    if label then
                        label.Image = asset
                        label.ImageTransparency = transparency
                        label.Visible = true
                        if scaleName == "Fit" then
                            label.ScaleType = Enum.ScaleType.Fit
                        elseif scaleName == "Stretch" then
                            label.ScaleType = Enum.ScaleType.Stretch
                        else
                            label.ScaleType = Enum.ScaleType.Crop
                        end
                        if gui and label.Parent ~= gui then
                            label.Parent = gui
                        end
                    end

                    if label and label.Image ~= "" and label.Visible then
                        Dominant.State.BgRestorePending = false
                        Dominant.Log("[Background] auto-applied (" .. tostring(tries) .. "): " .. path)
                        return
                    end
                else
                    Dominant.Warn("[Background] resolve failed try " .. tostring(tries) .. ": " .. path)
                end
            end
            task.wait(0.35)
        end
        Dominant.State.BgRestorePending = false
        Dominant.Warn("[Dominant] Background auto-apply timed out: " .. tostring(path))
    end)
    return true
end


function Dominant.Teardown(soft)
    local skip = {
        bg_enabled = true,
        bg_transparency = true,
        bg_scale = true,
        bg_window_transparency = true,
    }
    for key, callback in pairs(Dominant.Hooks) do
        if skip[key] then
            continue
        end
        local default = Dominant.Defaults[key]
        if type(default) == "boolean" then
            pcall(callback, false)
        end
    end
    pcall(Dominant.Hooks.anim_changer, "Original")
    pcall(Feat.Tracers.Clear)
    for name in pairs(Dominant.Loops) do
        Dominant.Loops[name] = nil
    end
    for name, object in pairs(Dominant.Objects) do
        if type(name) == "string" and name:sub(1, 6) == "frame_" then
            Dominant.Disconnect(object)
            Dominant.Objects[name] = nil
        end
    end
    pcall(Feat.ESP.Clear)
    pcall(Feat.Fly.Stop)
    pcall(Feat.Noclip.Restore)
    pcall(Feat.Anim.StopAll)
    pcall(Feat.Audio.Stop)
    if not soft then
        local humanoid = Dominant.State.Humanoid
        if humanoid then
            humanoid.AutoRotate = true
            humanoid.WalkSpeed = 16
        end
    end
end

function Dominant.Unload()
    if Dominant.State.Unloading then
        return
    end
    Dominant.State.Unloading = true
    pcall(Feat.Background.StopGif)
    pcall(Feat.Background.CloseBrowser)
    Dominant.Notify(L("n_unloaded"), "info", 3)
    Dominant.Teardown(false)
    for _, connection in ipairs(Dominant.Conns) do
        Dominant.Disconnect(connection)
    end
    Dominant.Conns = {}
    for name, object in pairs(Dominant.Objects) do
        if typeof(object) == "RBXScriptConnection" then
            Dominant.Disconnect(object)
        elseif typeof(object) == "Instance" then
            pcall(function()
                object:Destroy()
            end)
        end
        Dominant.Objects[name] = nil
    end
    if Feat.ESP and Feat.ESP.Folder then
        pcall(function()
            Feat.ESP.Folder:Destroy()
        end)
    end
    if Feat.Tracker and Feat.Tracker.Gui then
        pcall(function()
            Feat.Tracker.Gui:Destroy()
        end)
    end
    if Feat.HUD and Feat.HUD.Gui then
        pcall(function()
            Feat.HUD.Gui:Destroy()
        end)
    end
    Dominant.SaveNow()
    local vind = Dominant.Vind
    Dominant.Vind = nil
    Dominant.Window = nil
    if vind and type(vind.Unload) == "function" then
        pcall(function()
            vind:Unload()
        end)
    end
    local env = type(getgenv) == "function" and getgenv() or _G
    env.DominantLoaded = nil
    env.DominantInstance = nil
    Dominant.State.Unloading = false
    Dominant.State.Loaded = false
end

function Dominant.Supported()
    for _, id in ipairs(CONFIG.SupportedGames) do
        if game.GameId == id or game.PlaceId == id then
            return true
        end
    end
    local players = workspace:FindFirstChild("Players")
    if players and players:FindFirstChild("Killers") then
        return true
    end
    return workspace:GetAttribute("ServerType") ~= nil
end

Dominant.Warned = {}
function Dominant.RequireMissing(key, need)
    if Dominant.Caps.require and need == "require" then
        return false
    end
    if Dominant.Warned[key] == nil then
        Dominant.Warned[key] = true
        Dominant.Notify(L("n_requires", need), "warning", 4)
    end
    return true
end

Feat.Hotkeys = {
    Order = { "key_fly", "key_noclip", "key_esp", "key_cframe", "key_invisible", "key_panic" },
    Map = {
        key_fly = "fly",
        key_noclip = "noclip",
        key_esp = "esp",
        key_cframe = "cframe_speed",
        key_invisible = "invisible",
    },
}

function Feat.Hotkeys.Run(hotkey)
    if hotkey == "key_panic" then
        for key, default in pairs(Dominant.Defaults) do
            if type(default) == "boolean" and Dominant.Cfg[key] == true and Dominant.Hooks[key] then
                Dominant.Set(key, false)
            end
        end
        Dominant.Notify(L("hotkey_panic"), "warning", 2)
        return
    end
    local target = Feat.Hotkeys.Map[hotkey]
    if target then
        Dominant.Set(target, not Dominant.Cfg[target])
    end
end

function Dominant.Start()
    local env = type(getgenv) == "function" and getgenv() or _G

    if env.DominantInstance and env.DominantInstance ~= Dominant then
        pcall(function()
            if type(env.DominantInstance.Unload) == "function" then
                env.DominantInstance.Unload()
            end
        end)
        task.wait(0.35)
    elseif env.DominantLoaded and Dominant.State.Loaded then
        if Dominant.Window then
            pcall(function()
                Dominant.Window:Open()
            end)
            Dominant.Notify("Dominant is already running", "warning", 3)
            return
        end
        pcall(Dominant.Unload)
        task.wait(0.25)
    end

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    Dominant.State.Unloading = false
    Dominant.State.Loaded = false
    env.DominantLoaded = true
    env.DominantInstance = Dominant

    local function onCharacter(character)
        Dominant.WaitCharacter(character)
        for _, callback in ipairs(Dominant.CharacterCallbacks) do
            local ok, err = pcall(callback, character)
            if not ok then
                Dominant.Warn("[Dominant] " .. tostring(err))
            end
        end
        if Dominant.State.Loaded then
            task.delay(1, function()
                if not Dominant.State.Unloading then
                    Dominant.ResyncEnabled(true)
                end
            end)
        end
    end

    if LocalPlayer.Character then
        onCharacter(LocalPlayer.Character)
    end
    Dominant.Connect(LocalPlayer.CharacterAdded, function(character)
        task.spawn(onCharacter, character)
    end)

    local built, buildResult = pcall(UI.Build, "tab_home")
    if built and buildResult then
        Dominant.Status("Interface ready")
    end
    if not built then
        Dominant.Status("Interface error: " .. tostring(buildResult))
        if not Dominant.Window then
            env.DominantLoaded = nil
            env.DominantInstance = nil
            Dominant.State.Loaded = false
            return
        end
    elseif not buildResult then
        env.DominantLoaded = nil
        env.DominantInstance = nil
        Dominant.State.Loaded = false
        return
    end
    Dominant.State.Loaded = true
    local capsDeadline = os.clock() + 10
    repeat
        Dominant.RefreshCaps()
        if Dominant.Caps.require then
            break
        end
        task.wait(0.5)
    until os.clock() > capsDeadline
    Dominant.ResyncEnabled()
    Dominant.ApplyStartupBackground()
    Dominant.Notify(L("n_loaded", Dominant.Cfg.menu_key), "success", 5)
end

function Dominant.Status(text)
    local message = tostring(text)
    warn("[Dominant] " .. message)
    pcall(function()
        Svc.StarterGui:SetCore("SendNotification", {
            Title = "Dominant",
            Text = message,
            Duration = 8,
        })
    end)
end

function Dominant.Launch()
    local env = type(getgenv) == "function" and getgenv() or _G
    if env.DominantSkipKey == true then
        Dominant.Start()
        return
    end
    Dominant.Status("Loading key system (GameId " .. tostring(game.GameId) .. ", PlaceId " .. tostring(game.PlaceId) .. ")")
    local ok, Ophyn = pcall(function()
        return loadstring(game:HttpGet(CONFIG.OphynUrl))()
    end)
    if not ok or type(Ophyn) ~= "table" then
        Dominant.Status("Key system unavailable, starting without it: " .. tostring(Ophyn))
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
    local launched = false
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
            launched = true
            Dominant.Status("Key system opened")
            break
        end
        Dominant.Status("Key system attempt " .. index .. " failed: " .. tostring(attemptErr))
    end
    if not launched then
        Dominant.Status("Key system failed, starting without it")
        Dominant.Start()
    end
end

do
    local env = type(getgenv) == "function" and getgenv() or _G
    local prev = env.DominantInstance
    if prev and prev ~= Dominant and type(prev.Unload) == "function" then
        pcall(prev.Unload)
        task.wait(0.3)
    end
    env.DominantInstance = Dominant
end

Dominant.Status("Script loaded")
Dominant.Launch()
