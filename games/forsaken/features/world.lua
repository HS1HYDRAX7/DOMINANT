local M = {}

function M.Register(ctx)
    local G = ctx.modules:require("games/forsaken/game")

    local function nearest(list, positionOf)
        local root = ctx.state.root
        if not root then
            return nil
        end
        local best, bestDistance = nil, math.huge
        for _, object in ipairs(list) do
            local position = positionOf(object)
            if position then
                local distance = (position - root.Position).Magnitude
                if distance < bestDistance then
                    best, bestDistance = object, distance
                end
            end
        end
        return best
    end

    local function moveTo(position)
        local root = ctx.state.root
        if root and position then
            root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        end
    end

    local function childrenOf(folder)
        return folder and folder:GetChildren() or {}
    end

    local function teleportTo(list)
        local target = nearest(list, G.position)
        if target then
            moveTo(G.position(target))
        else
            ctx.notify(ctx.L("n_no_target"), "warning", 3)
        end
    end

    M.tpGenerator = function()
        teleportTo(G.generators())
    end
    M.tpRandomGenerator = function()
        local list = G.generators()
        if #list == 0 then
            ctx.notify(ctx.L("n_no_target"), "warning", 3)
            return
        end
        moveTo(G.position(list[math.random(1, #list)]))
    end
    M.tpItem = function()
        teleportTo(G.items())
    end
    M.tpKiller = function()
        teleportTo(childrenOf(G.killers()))
    end
    M.tpSurvivor = function()
        teleportTo(childrenOf(G.survivors()))
    end
end

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_teleports", "Lucide:navigation")
    ui.button(tab, "btn_tp_generator", "Lucide:cog", function()
        M.tpGenerator()
    end)
    ui.button(tab, "btn_tp_random_gen", "Lucide:shuffle", function()
        M.tpRandomGenerator()
    end)
    ui.button(tab, "btn_tp_item", "Lucide:package", function()
        M.tpItem()
    end)
    ui.button(tab, "btn_tp_killer", "Lucide:skull", function()
        M.tpKiller()
    end)
    ui.button(tab, "btn_tp_survivor", "Lucide:users", function()
        M.tpSurvivor()
    end)
end

return M
