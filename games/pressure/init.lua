-- Pressure game module. Feature files register settings and hotkeys in Register,
-- then add their controls to the tabs in Build. Strings are in strings.lua.
local M = {
    Name = "Pressure",
}

-- Feature name -> module path. Movement, screen and misc are shared with every game.
local FEATURES = {
    esp = "games/pressure/features/esp",
    anti = "games/pressure/features/anti",
    movement = "shared/features/movement",
    automation = "games/pressure/features/automation",
    screen = "shared/features/screen",
    misc = "shared/features/misc",
}

-- Tab layout: tab key, title key, icon, features shown in it
local TABS = {
    { "tab_visuals", "Lucide:eye", { "esp" } },
    { "tab_movement", "Lucide:footprints", { "movement" } },
    { "tab_automation", "Lucide:bot", { "automation" } },
    { "tab_anti", "Lucide:shield", { "anti" } },
    { "tab_world", "Lucide:map", { "screen" } },
    { "tab_misc", "Lucide:wrench", { "misc" } },
}

function M.Init(ctx)
    local data = ctx.modules:require("games/pressure/data")
    M.data = data
    M.features = {}
    for name, path in pairs(FEATURES) do
        local feature = ctx.modules:require(path)
        feature.Register(ctx, data)
        M.features[name] = feature
    end
end

function M.Build(window, ctx)
    for _, entry in ipairs(TABS) do
        local tab = window:AddTab({ Name = ctx.L(entry[1]), Icon = entry[2] })
        for _, name in ipairs(entry[3]) do
            M.features[name].Build(tab, ctx, M.data)
        end
    end
end

return M
