-- Asset system. Keys come from assets/index.lua. Each file is downloaded once into
-- <Folder>/Assets and turned into an executor asset path with getcustomasset or getsynasset.
-- Usage: ctx.assets.get("logo") -> asset path, or nil when unavailable.
local M = {}

function M.new(ctx)
    local manifest = ctx.modules:require("assets/index")
    local cache = {}
    local assets = {}

    local function assetFolder()
        return ctx.config.Folder .. "/Assets"
    end

    local function ensureFolders()
        pcall(function()
            if not isfolder(ctx.config.Folder) then
                makefolder(ctx.config.Folder)
            end
            if not isfolder(assetFolder()) then
                makefolder(assetFolder())
            end
        end)
    end

    -- Turns a local file path or an asset id into something Roblox can display, or nil.
    function assets.resolve(path)
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
        local getters = {}
        if type(getcustomasset) == "function" then
            table.insert(getters, getcustomasset)
        end
        if type(getsynasset) == "function" then
            table.insert(getters, getsynasset)
        end
        local tries = { path, "workspace/" .. path, "Workspace/" .. path }
        for _, get in ipairs(getters) do
            for _, try in ipairs(tries) do
                local ok, asset = pcall(get, try)
                if ok and type(asset) == "string" and asset ~= "" then
                    return asset
                end
            end
        end
        return nil
    end

    -- Returns the asset path for a manifest key, downloading the file if needed.
    function assets.get(key)
        local cached = cache[key]
        if cached ~= nil then
            return cached or nil
        end
        local file = manifest[key]
        if not file or not ctx.caps.files then
            cache[key] = false
            return nil
        end
        local path = assetFolder() .. "/" .. file
        local okExists, exists = pcall(isfile, path)
        if not (okExists and exists) then
            local okDownload, body = pcall(function()
                return game:HttpGet(ctx.modules.base .. "assets/" .. file)
            end)
            if not okDownload or type(body) ~= "string" or #body == 0 then
                ctx.warn("could not download asset " .. file)
                cache[key] = false
                return nil
            end
            ensureFolders()
            pcall(writefile, path, body)
        end
        local asset = assets.resolve(path)
        cache[key] = asset or false
        return asset
    end

    -- Adds or replaces a manifest entry at runtime (for banners of a single game, for example).
    function assets.add(key, file)
        manifest[key] = file
        cache[key] = nil
    end

    ctx.assets = assets
    return assets
end

return M
