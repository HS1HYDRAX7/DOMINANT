local M = {
    Name = "Forsaken",
    Options = { builtInFly = false },
}

local FEATURES = {
    fly_gui = "games/forsaken/features/fly_gui",
    esp = "games/forsaken/features/esp",
    world = "games/forsaken/features/world",
    world_extras = "games/forsaken/features/world_extras",
    misc_extras = "games/forsaken/features/misc_extras",
    player_extras = "games/forsaken/features/player_extras",
    automation = "games/forsaken/features/automation",
    movement = "shared/features/movement",
    screen = "shared/features/screen",
    misc = "shared/features/misc",
}

local TABS = {
    { "tab_player", "Lucide:user", { "movement", "player_extras", "fly_gui" } },
    { "tab_auto", "Lucide:bot", { "automation" } },
    { "tab_visuals", "Lucide:eye", { "esp", "screen" } },
    { "tab_world", "Lucide:map", { "world", "world_extras" } },
    { "tab_misc", "Lucide:wrench", { "misc", "misc_extras" } },
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
