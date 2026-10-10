local SoundService = game:GetService("SoundService")

local M = {}

local KIND_SOUND = { success = "success", error = "error", critical = "critical", warning = "notification", info = "notification" }

function M.Register(ctx)
    ctx.addSetting("sounds_on", true)
    ctx.addSetting("sound_volume", 0.5)
end

function M.new(ctx)
    local sounds = {}

    function sounds.play(name)
        if not ctx.cfg.sounds_on or not ctx.assets then
            return
        end
        local asset = ctx.assets.get("sound_" .. name)
        if not asset then
            return
        end
        local sound = Instance.new("Sound")
        sound.SoundId = asset
        sound.Volume = ctx.cfg.sound_volume
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end

    function sounds.forKind(kind)
        return KIND_SOUND[kind] or "notification"
    end

    ctx.sounds = sounds
    return sounds
end

function M.Build(tab, ctx)
    ctx.ui.toggle(tab, "sounds_on", "Lucide:volume-2")
    ctx.ui.slider(tab, "sound_volume", 0, 1, 0.05, "Lucide:volume-1")
end

return M
