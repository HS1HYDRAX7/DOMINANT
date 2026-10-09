-- Forsaken game module. Features live in features/; Home, Credits, Settings and the shared
-- movement, screen and misc features come from shared/.
local M = {
    Name = "Forsaken",
}

local FEATURES = {
    esp = "games/forsaken/features/esp",
    world = "games/forsaken/features/world",
    automation = "games/forsaken/features/automation",
    movement = "shared/features/movement",
    screen = "shared/features/screen",
    misc = "shared/features/misc",
}

-- tab key, icon, features shown in it
local TABS = {
    { "tab_player", "Lucide:user", { "movement" } },
    { "tab_auto", "Lucide:bot", { "automation" } },
    { "tab_visuals", "Lucide:eye", { "esp", "screen" } },
    { "tab_world", "Lucide:map", { "world" } },
    { "tab_misc", "Lucide:wrench", { "misc" } },
}

function M.Init(ctx)
    M.features = {}
    for name, path in pairs(FEATURES) do
        local feature = ctx.modules:require(path)
        feature.Register(ctx)
        M.features[name] = feature
    end
end

function M.Build(window, ctx)
    for _, entry in ipairs(TABS) do
        local tab = window:AddTab({ Name = ctx.L(entry[1]), Icon = entry[2] })
        for _, name in ipairs(entry[3]) do
            M.features[name].Build(tab, ctx)
        end
    end
end

return M
