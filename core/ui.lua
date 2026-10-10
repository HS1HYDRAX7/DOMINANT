local M = {}

local function keyFromName(name)
    local ok, key = pcall(function()
        return Enum.KeyCode[name]
    end)
    if ok and key then
        return key
    end
    return Enum.KeyCode.Unknown
end

function M.new(ctx)
    local ui = {}

    function ui.section(tab, key, icon)
        tab:AddSection(ctx.L(key), icon)
    end

    function ui.toggle(tab, key, icon)
        tab:AddToggle({
            Text = ctx.L(key),
            Description = ctx.describe(key),
            Icon = icon,
            Flag = key,
            Default = ctx.cfg[key],
            Callback = function(value)
                ctx.set(key, value)
            end,
        })
    end

    function ui.labelToggle(tab, key, text, description, icon)
        tab:AddToggle({
            Text = text,
            Description = description,
            Icon = icon,
            Flag = key,
            Default = ctx.cfg[key],
            Callback = function(value)
                ctx.set(key, value)
            end,
        })
    end

    function ui.slider(tab, key, minimum, maximum, step, icon, suffix)
        tab:AddSlider({
            Text = ctx.L(key),
            Description = ctx.describe(key),
            Icon = icon,
            Flag = key,
            Min = minimum,
            Max = maximum,
            Default = ctx.cfg[key],
            Increment = step,
            Suffix = suffix,
            Callback = function(value)
                ctx.set(key, value)
            end,
        })
    end

    function ui.dropdown(tab, key, options, icon, current, onChange)
        tab:AddDropdown({
            Text = ctx.L(key),
            Description = ctx.describe(key),
            Icon = icon,
            Options = options,
            Default = current or ctx.cfg[key],
            Flag = key,
            Callback = function(value)
                if type(value) == "table" then
                    value = value[1]
                end
                if onChange then
                    onChange(value)
                else
                    ctx.set(key, value)
                end
            end,
        })
    end

    function ui.number(tab, key, icon, minimum)
        local pending = 0
        tab:AddTextbox({
            Text = ctx.L(key),
            Description = ctx.describe(key),
            Icon = icon,
            Placeholder = ctx.L("number_hint"),
            Default = tostring(ctx.cfg[key]),
            Callback = function(text, enter)
                local cleaned = (tostring(text or ""):gsub(",", "."):gsub("[^%d%.%-]", ""))
                local value = tonumber(cleaned)
                if not value then
                    return
                end
                value = math.max(minimum or 1, value)
                ctx.set(key, value)
                pending += 1
                local ticket = pending
                if enter then
                    ctx.notify(ctx.L("n_value_set", ctx.L(key), tostring(value)), "info", 2)
                else
                    task.delay(0.35, function()
                        if ticket == pending then
                            ctx.notify(ctx.L("n_value_set", ctx.L(key), tostring(value)), "info", 2)
                        end
                    end)
                end
            end,
        })
    end

    function ui.color(tab, key, icon)
        tab:AddColorPicker({
            Text = ctx.L(key),
            Icon = icon,
            Default = ctx.cfg[key],
            Callback = function(color)
                ctx.set(key, color)
            end,
        })
    end

    function ui.button(tab, key, icon, callback)
        tab:AddButton({
            Text = ctx.L(key),
            Description = ctx.describe(key),
            Icon = icon,
            Callback = callback,
        })
    end

    function ui.keybind(tab, labelKey, icon, currentName, onPress, onChange)
        tab:AddKeybind({
            Text = ctx.L(labelKey),
            Description = ctx.describe(labelKey),
            Icon = icon,
            Default = keyFromName(currentName),
            Callback = function(key, kind)
                if kind == "press" then
                    if onPress then
                        onPress()
                    end
                elseif typeof(key) == "EnumItem" then
                    if onChange then
                        onChange(key.Name)
                    end
                end
            end,
        })
    end

    return ui
end

return M
