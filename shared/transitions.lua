local TweenService = game:GetService("TweenService")

local T = {}

function T.tween(instance, duration, props, style, direction)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

function T.waitAll(tweens)
    for _, tween in ipairs(tweens) do
        tween.Completed:Wait()
    end
end

function T.sequence(steps)
    for _, step in ipairs(steps) do
        local result = step()
        if typeof(result) == "Instance" then
            result.Completed:Wait()
        elseif type(result) == "table" then
            T.waitAll(result)
        end
    end
end

function T.crossfade(outgoing, incoming, duration, style)
    local tweens = {}
    for _, item in ipairs(outgoing) do
        table.insert(tweens, T.tween(item.instance, duration, { [item.property] = item.to }, style))
    end
    for _, item in ipairs(incoming) do
        table.insert(tweens, T.tween(item.instance, duration, { [item.property] = item.to }, style))
    end
    T.waitAll(tweens)
end

return T
