local RunService = game:GetService("RunService")

local M = {}

function M.Register(ctx)
    local G = ctx.modules:require("games/forsaken/game")

    local function antiSlowStep()
        local character = ctx.state.character
        if not character then
            return
        end
        local speed = character:FindFirstChild("SpeedMultipliers")
        if speed then
            for _, child in ipairs(speed:GetChildren()) do
                if child:IsA("NumberValue") then
                    local name = child.Name
                    if name ~= "Sprinting" and name:lower() ~= "emoting" then
                        if name == "DirectionalMovement" or name == "FixingGenerator" or name:upper() == "ENRAGED" then
                            if child.Value < 1 then
                                child.Value = 1
                            end
                        elseif child.Value > 0.05 and child.Value < 1 then
                            child.Value = 1
                        end
                    end
                end
            end
        end
        local fov = character:FindFirstChild("FOVMultipliers")
        local slowed = fov and fov:FindFirstChild("SlowedStatus")
        if slowed and slowed:IsA("NumberValue") and slowed.Value ~= 1 then
            slowed.Value = 1
        end
    end

    ctx.addSetting("anti_slow", false, function(value)
        if value then
            ctx.bind("antislow", RunService.Heartbeat, antiSlowStep)
        else
            ctx.unbind("antislow")
        end
    end)
end

function M.Build(tab, ctx)
    ctx.ui.section(tab, "sec_survival", "Lucide:shield")
    ctx.ui.toggle(tab, "anti_slow", "Lucide:snail")
end

return M
