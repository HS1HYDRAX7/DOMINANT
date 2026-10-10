local FLY_URL = "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"

local M = {}

function M.Register(ctx)
end

function M.Build(tab, ctx)
    ctx.ui.section(tab, "sec_fly", "Lucide:plane")
    ctx.ui.button(tab, "btn_fly_gui", "Lucide:plane", function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(FLY_URL))()
        end)
        if not ok then
            ctx.notify(tostring(err), "error", 4)
        end
    end)
end

return M
