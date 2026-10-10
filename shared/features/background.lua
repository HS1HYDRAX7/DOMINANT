local M = {}

local EXTENSIONS = { png = true, jpg = true, jpeg = true, gif = true }

local function root(ctx)
    return ctx.config.Folder .. "/Backgrounds"
end

local function basename(path)
    return tostring(path or ""):gsub("\\", "/"):match("([^/]+)$") or tostring(path)
end

local function isImage(path)
    local ext = string.lower(tostring(path or "")):match("%.([%w]+)$")
    return ext ~= nil and EXTENSIONS[ext] == true
end

local function isGif(path)
    return string.lower(tostring(path or "")):match("%.gif$") ~= nil
end

function M.list(ctx)
    local files = {}
    if not ctx.caps.files or type(listfiles) ~= "function" then
        return files
    end
    local function walk(path, depth)
        local ok, entries = pcall(listfiles, path)
        if not ok or type(entries) ~= "table" then
            return
        end
        for _, entry in ipairs(entries) do
            local isDir = false
            if type(isfolder) == "function" then
                local okFolder, folder = pcall(isfolder, entry)
                isDir = okFolder and folder == true
            end
            if isDir then
                if depth < 8 then
                    walk(entry, depth + 1)
                end
            elseif isImage(entry) then
                table.insert(files, entry)
            end
        end
    end
    walk(root(ctx), 0)
    table.sort(files)
    return files
end

function M.resolve(ctx, path)
    return ctx.assets.resolve(path)
end

local function collectFrames(ctx, gifPath)
    local stem = basename(gifPath):gsub("%.[^%.]+$", "")
    local candidates = {
        root(ctx) .. "/frames/" .. stem,
        root(ctx) .. "/" .. stem .. "_frames",
        root(ctx) .. "/" .. stem,
    }
    local frames = {}
    for _, folder in ipairs(candidates) do
        local okDir, isDir = pcall(isfolder, folder)
        if okDir and isDir then
            local okList, entries = pcall(listfiles, folder)
            if okList and type(entries) == "table" then
                local ordered = {}
                for _, entry in ipairs(entries) do
                    local lower = string.lower(tostring(entry))
                    if lower:match("%.png$") or lower:match("%.jpe?g$") then
                        table.insert(ordered, entry)
                    end
                end
                table.sort(ordered)
                for _, entry in ipairs(ordered) do
                    local asset = M.resolve(ctx, entry)
                    if asset then
                        table.insert(frames, asset)
                    end
                end
                if #frames > 0 then
                    return frames
                end
            end
        end
    end
    return frames
end

local function setImage(ctx, asset, sourcePath)
    local window = ctx.window
    if not window then
        return false
    end
    local transparency = math.clamp(tonumber(ctx.cfg.bg_transparency) or 0.45, 0, 1)
    local windowTransparency = math.clamp(tonumber(ctx.cfg.bg_window_transparency) or 0.35, 0, 1)

    pcall(function()
        window:SetBackground({ Image = asset or "", Transparency = transparency })
    end)
    pcall(function()
        window:SetBackgroundTransparency(windowTransparency)
    end)
    return true
end

local function playGif(ctx, frames, fps)
    local index = 1
    ctx.startLoop("background_gif", 1 / fps, function()
        local window = ctx.window
        if window and window._BackgroundImage then
            window._BackgroundImage.Image = frames[index]
        end
        index += 1
        if index > #frames then
            index = 1
        end
    end)
end

function M.apply(ctx, path)
    ctx.stopLoop("background_gif")
    if not path or path == "" then
        if ctx.window then
            pcall(function()
                ctx.window:SetBackground({ Image = "" })
            end)
        end
        return true
    end
    if isGif(path) then
        local frames = collectFrames(ctx, path)
        local first = M.resolve(ctx, path) or frames[1]
        if not first then
            ctx.notify(ctx.L("bg_failed"), "error", 4)
            return false
        end
        setImage(ctx, first, path)
        if #frames > 1 then
            playGif(ctx, frames, 12)
        end
        return true
    end
    local asset = M.resolve(ctx, path)
    if not asset then
        ctx.notify(ctx.L("bg_failed"), "error", 4)
        return false
    end
    setImage(ctx, asset, path)
    return true
end

function M.Register(ctx)
    local function reapply()
        if ctx.cfg.bg_enabled then
            M.apply(ctx, ctx.cfg.bg_path)
        end
    end
    ctx.addSetting("bg_enabled", false, function(value)
        if value then
            M.apply(ctx, ctx.cfg.bg_path)
        else
            M.apply(ctx, "")
        end
    end)
    ctx.addSetting("bg_path", "", function()
        reapply()
    end)
    ctx.addSetting("bg_transparency", 0.45, reapply)
    ctx.addSetting("bg_window_transparency", 0.35, reapply)

    ctx.onUnload(function()
        ctx.stopLoop("background_gif")
    end)
end

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_background", "Lucide:image")
    ui.toggle(tab, "bg_enabled", "Lucide:image")
    tab:AddParagraph({
        Title = ctx.L("bg_folder_hint"),
        Icon = "Lucide:folder",
        Text = ctx.L("bg_gif_note"),
    })
    tab:AddTextbox({
        Text = ctx.L("bg_path"),
        Description = ctx.describe("bg_folder_hint"),
        Icon = "Lucide:file-image",
        Flag = "bg_path",
        Default = ctx.cfg.bg_path,
        Placeholder = ctx.config.Folder .. "/Backgrounds/bg.png",
        Callback = function(text, enter)
            if enter then
                ctx.set("bg_path", tostring(text or ""))
            end
        end,
    })

    local files = M.list(ctx)
    ui.dropdown(tab, "bg_browse", #files > 0 and files or { "-" }, "Lucide:folder-tree", nil, function(value)
        if value ~= "-" then
            ctx.set("bg_path", value)
        end
    end)
    ui.slider(tab, "bg_transparency", 0, 1, 0.05, "Lucide:blend")
    ui.slider(tab, "bg_window_transparency", 0, 0.8, 0.05, "Lucide:app-window")

    ui.button(tab, "bg_refresh", "Lucide:refresh-cw", function()
        ctx.notify(ctx.L("bg_refresh"), "info", 2)
    end)
    ui.button(tab, "bg_clear", "Lucide:x", function()
        ctx.set("bg_enabled", false)
        ctx.notify(ctx.L("bg_clear"), "info", 2)
    end)
    ui.button(tab, "bg_apply", "Lucide:check", function()
        ctx.set("bg_enabled", true)
        ctx.set("bg_path", ctx.cfg.bg_path)
        if M.apply(ctx, ctx.cfg.bg_path) then
            ctx.notify(ctx.L("bg_applied"), "success", 3)
        end
    end)
end

return M
