local M = {}

function M.run(config, supportedIds, onSuccess, status)
    local env = getgenv and getgenv() or _G
    if env.DominantSkipKey == true then
        onSuccess()
        return
    end

    local ok, Ophyn = pcall(function()
        return loadstring(game:HttpGet(config.OphynUrl))()
    end)
    if not ok or type(Ophyn) ~= "table" or type(Ophyn.new) ~= "function" then
        status("Key system unavailable")
        onSuccess()
        return
    end

    local supported = {}
    for _, id in ipairs(supportedIds) do
        supported[id] = true
    end
    supported[game.PlaceId] = true

    local started = false
    local function accept()
        if started then
            return
        end
        started = true
        onSuccess()
    end

    local attempt, attemptError = pcall(function()
        Ophyn.new({
            Title = config.Title,
            Description = config.Description,
            Logo = config.Logo,
            Theme = config.KeyTheme or "Plant-Dark",
            Folder = config.Folder,
            getkey = false,
            Intro = "true",
            startintrosize = 80,
            squareintrotime = 1.2,
            squarecontorn = "true",
            Changelogocolor = true,
            Changeiconscolor = true,
            ChangeTheme = "true",
            discordlink = config.Discord,
            website_link = config.Website,
            Discord = "true",
            Website = "true",
            Informations = "true",
            Keyless = { enabled = false },
            NotifStyle = "1",
            TabsStyle = "1",
            SupportedGames = supported,
            KeySystem = {
                Key = config.Keys,
                SaveKey = config.SaveKey,
            },
            Callback = function()
                accept()
            end,
        })
    end)

    if not attempt then
        status("Key system failed: " .. tostring(attemptError))
        accept()
    end
end

return M
