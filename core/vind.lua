local M = {}

function M.load(config)
    local ok, body = pcall(game.HttpGet, game, config.VindUrl)
    if not ok or type(body) ~= "string" or #body < 100 then
        return nil, "could not download Vind UI"
    end
    local chunk, compileError = loadstring(body)
    if not chunk then
        return nil, compileError
    end
    local okRun, library = pcall(chunk)
    if not okRun or type(library) ~= "table" then
        return nil, library
    end
    pcall(function()
        library:SetTheme(config.Theme)
    end)
    pcall(function()
        library:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
    end)
    pcall(function()
        library:SetScaleRange(0.75, 1.35)
    end)
    return library
end

return M
