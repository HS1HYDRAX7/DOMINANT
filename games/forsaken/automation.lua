local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.Register(ctx)
    local G = ctx.modules:require("games/forsaken/game")
    local originalHold = {}

    local function promptOf(object)
        return object:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    local function pickupStep()
        local root = ctx.state.root
        if not root then
            return
        end
        local range = math.max(1, tonumber(ctx.cfg.pickup_range) or 12)
        for _, tool in ipairs(G.items()) do
            local position = G.position(tool)
            local prompt = promptOf(tool)
            if position and prompt and prompt.Enabled and (position - root.Position).Magnitude <= range then
                pcall(function()
                    if ctx.caps.fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                end)
            end
        end
    end

    local function instantPrompt(prompt)
        if ctx.cfg.instant_prompts and originalHold[prompt] == nil and prompt.HoldDuration > 0 then
            originalHold[prompt] = prompt.HoldDuration
            prompt.HoldDuration = 0
        end
    end

    ctx.addSetting("auto_pickup", false, function(value)
        if value then
            ctx.startLoop("pickup", 0.2, pickupStep)
        else
            ctx.stopLoop("pickup")
        end
    end)
    ctx.addSetting("pickup_range", 12)
    ctx.addSetting("instant_prompts", false, function(value)
        ctx.unbind("prompts")
        if value then
            ctx.bind("prompts", ProximityPromptService.PromptShown, instantPrompt)
        else
            for prompt, hold in pairs(originalHold) do
                if prompt.Parent then
                    prompt.HoldDuration = hold
                end
            end
            originalHold = {}
        end
    end)

    ctx.onUnload(function()
        for prompt, hold in pairs(originalHold) do
            if prompt.Parent then
                prompt.HoldDuration = hold
            end
        end
    end)
end

function M.Build(tab, ctx)
    local ui = ctx.ui
    ui.section(tab, "sec_helpers", "Lucide:hand")
    ui.toggle(tab, "auto_pickup", "Lucide:package")
    ui.slider(tab, "pickup_range", 1, 40, 1, "Lucide:ruler", " studs")
    ui.toggle(tab, "instant_prompts", "Lucide:zap")
end

return M
