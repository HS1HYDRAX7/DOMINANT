-- Home, Credits and Settings tabs. Shared by every game so every script looks the same.
-- Every label is a translation key from shared/strings.lua or shared/strings_extra.lua.
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local M = {}

local function greeting(ctx)
    local hour = tonumber(os.date("%H")) or 12
    if hour < 5 then
        return ctx.L("greet_night")
    elseif hour < 12 then
        return ctx.L("greet_morning")
    elseif hour < 18 then
        return ctx.L("greet_afternoon")
    end
    return ctx.L("greet_evening")
end

local function yes(ctx, flag)
    return flag and ctx.L("home_yes") or ctx.L("home_no")
end

local function fillChangelog(tab, ctx)
    for _, entry in ipairs(ctx.changelog or {}) do
        local changes = {}
        for _, change in ipairs(entry.changes) do
            table.insert(changes, { Type = change.type, Text = ctx.L(change.key) })
        end
        tab:AddChangelogEntry({
            Version = ctx.L(entry.version),
            Date = ctx.L(entry.date),
            Changes = changes,
        })
    end
end

function M.home(window, ctx)
    local home = window:AddTab({ Name = ctx.L("tab_home"), Icon = "Lucide:house" })

    local info = home:AddSubTab({ Name = ctx.L("sub_info"), Icon = "Lucide:layout-dashboard" })
    info:AddCard({
        UserId = LocalPlayer.UserId,
        Title = greeting(ctx) .. ", " .. LocalPlayer.DisplayName,
        Description = ctx.L("home_title"),
    })
    info:AddSystemInfoGrid({ Description = ctx.L("home_executor", ctx.executor) })
    ctx.ui.section(info, "sec_welcome", "Lucide:sparkles")
    info:AddParagraph({
        Title = ctx.L("home_title"),
        Icon = "Lucide:crown",
        Text = ctx.L("home_text", tostring(ctx.cfg.menu_key)) .. "\n\n" .. ctx.L("home_credits"),
    })
    ctx.ui.section(info, "sec_status", "Lucide:activity")
    info:AddParagraph({
        Title = ctx.L("home_executor", ctx.executor),
        Icon = "Lucide:terminal",
        Text = ctx.L("home_caps", yes(ctx, ctx.caps.require), yes(ctx, ctx.caps.hookmetamethod), yes(ctx, ctx.caps.files)),
    })

    local changelog = home:AddSubTab({ Name = ctx.L("sub_changelog"), Icon = "Lucide:file-text" })
    fillChangelog(changelog, ctx)
end

function M.credits(window, ctx)
    local tab = window:AddTab({ Name = ctx.L("tab_credits"), Icon = "Lucide:heart" })

    local function person(key, icon)
        tab:AddParagraph({ Title = ctx.L(key), Icon = icon, Text = ctx.L(key .. "_d") })
    end

    tab:AddSection(ctx.L("credits_section_dominant"), "Lucide:code")
    person("credit_jonathan", "Lucide:crown")
    person("credit_claude", "Lucide:bot")
    person("credit_grok", "Lucide:sparkles")
    person("credit_ana", "Lucide:heart")

    tab:AddSection(ctx.L("credits_section_vind"), "Lucide:heart-handshake")
    tab:AddParagraph({ Title = "Skinny", Icon = "Lucide:palette", Text = ctx.L("credit_vind_skinny_d") })
    tab:AddParagraph({ Title = "Shezz", Icon = "Lucide:layout-grid", Text = ctx.L("credit_vind_shezz_d") })
    tab:AddParagraph({ Title = "NoSkills", Icon = "Lucide:lightbulb", Text = ctx.L("credit_vind_noskills_d") })
    tab:AddParagraph({ Title = "Luxy_00", Icon = "Lucide:smartphone", Text = ctx.L("credit_vind_luxy_d") })
    tab:AddParagraph({ Title = "Elusive", Icon = "Lucide:rocket", Text = ctx.L("credit_vind_elusive_d") })

    tab:AddSection(ctx.L("credits_section_notice"), "Lucide:info")
    tab:AddParagraph({ Title = "Vind UI Reborn", Icon = "Lucide:layout-dashboard", Text = ctx.L("notice_vind") })
    tab:AddParagraph({ Title = "Ophyn", Icon = "Lucide:key", Text = ctx.L("notice_ophyn") })
    tab:AddParagraph({ Title = ctx.L("credits_line"), Icon = "Lucide:scale", Text = ctx.L("notice_disclaimer") })
end

function M.settings(window, ctx)
    local ui = ctx.ui
    local tab = window:AddTab({ Name = ctx.L("tab_settings"), Icon = "Lucide:settings" })

    -- Language ------------------------------------------------------------------
    ui.section(tab, "sec_language", "Lucide:languages")
    local names, currentName = {}, "English"
    for _, language in ipairs(ctx.Languages) do
        table.insert(names, language.Name)
        if language.Code == ctx.getLanguage() then
            currentName = language.Name
        end
    end
    ui.dropdown(tab, "language", names, "Lucide:languages", currentName, function(value)
        for _, language in ipairs(ctx.Languages) do
            if language.Name == value and language.Code ~= ctx.getLanguage() then
                ctx.setLanguage(language.Code)
                ctx.set("language", language.Code)
                ctx.notify(ctx.L("n_language"), "info", 3)
                break
            end
        end
    end)

    -- Interface -----------------------------------------------------------------
    ui.section(tab, "sec_interface", "Lucide:layout-dashboard")
    ui.toggle(tab, "notifications", "Lucide:bell")

    -- Background ------------------------------------------------------------------
    ctx.modules:require("shared/features/background").Build(tab, ctx)

    ui.keybind(tab, "menu_key", "Lucide:keyboard", ctx.cfg.menu_key, function()
        if ctx.window then
            ctx.window:Toggle()
        end
    end, function(name)
        ctx.set("menu_key", name)
    end)

    -- Hotkeys ---------------------------------------------------------------------
    if #ctx.hotkeys > 0 then
        ui.section(tab, "sec_hotkeys", "Lucide:keyboard")
        for _, hotkey in ipairs(ctx.hotkeys) do
            ui.keybind(tab, hotkey.label, "Lucide:keyboard", ctx.cfg[hotkey.key], hotkey.run, function(name)
                ctx.set(hotkey.key, name)
            end)
        end
    end

    -- Configs ---------------------------------------------------------------------
    ui.section(tab, "sec_config", "Lucide:save")
    local selected = ctx.getAutoload() or "default"
    tab:AddTextbox({
        Text = ctx.L("config_name"),
        Icon = "Lucide:pencil",
        Placeholder = ctx.L("config_name_hint"),
        Default = selected,
        Callback = function(text)
            selected = ctx.sanitizeName(text)
        end,
    })
    local configs = ctx.listConfigs()
    tab:AddDropdown({
        Text = ctx.L("config_pick"),
        Icon = "Lucide:list",
        Options = #configs > 0 and configs or { "-" },
        Default = configs[1] or "-",
        Callback = function(value)
            if type(value) == "table" then
                value = value[1]
            end
            if value ~= "-" then
                selected = ctx.sanitizeName(value)
            end
        end,
    })
    ui.button(tab, "btn_config_save", "Lucide:save", function()
        ctx.notify(ctx.L(ctx.saveConfig(selected) and "n_config_saved" or "n_config_failed"), "info", 3)
    end)
    ui.button(tab, "btn_config_load", "Lucide:folder-open", function()
        if ctx.loadConfig(selected) then
            ctx.applyAll()
            ctx.saveSession()
            ctx.notify(ctx.L("n_config_loaded"), "success", 3)
        else
            ctx.notify(ctx.L("n_config_missing"), "warning", 3)
        end
    end)
    ui.button(tab, "btn_config_delete", "Lucide:trash-2", function()
        ctx.deleteConfig(selected)
        ctx.notify(ctx.L("n_config_deleted"), "info", 3)
    end)
    ui.button(tab, "btn_config_autoload", "Lucide:zap", function()
        ctx.setAutoload(selected)
        ctx.notify(ctx.L("n_autoload_set", selected), "success", 3)
    end)

    -- Reset and unload ------------------------------------------------------------
    ui.button(tab, "btn_reset", "Lucide:rotate-ccw", function()
        ctx.library:Confirm({
            Title = ctx.L("confirm_reset_title"),
            Text = ctx.L("confirm_reset_text"),
            Window = window,
            Callback = function(confirmed)
                if confirmed then
                    ctx.reset()
                    ctx.applyAll()
                    ctx.saveSession()
                    ctx.notify(ctx.L("n_reset"), "warning", 3)
                end
            end,
        })
    end)
    ui.button(tab, "btn_unload", "Lucide:power", function()
        ctx.library:Confirm({
            Title = ctx.L("confirm_unload_title"),
            Text = ctx.L("confirm_unload_text"),
            Window = window,
            Callback = function(confirmed)
                if confirmed then
                    ctx.unload()
                end
            end,
        })
    end)
end

return M
