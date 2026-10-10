local M = {}

M.Languages = {
    { Code = "en", Name = "English" },
    { Code = "pt", Name = "Português" },
    { Code = "es", Name = "Español" },
    { Code = "ru", Name = "Русский" },
}

function M.new(ctx)
    ctx.Languages = M.Languages
    local packs = { en = {}, pt = {}, es = {}, ru = {} }
    local current = "en"

    function ctx.addStrings(code, strings)
        local pack = packs[code]
        if not pack then
            return
        end
        for key, value in pairs(strings) do
            pack[key] = value
        end
    end

    function ctx.L(key, ...)
        local pack = packs[current]
        local text = (pack and pack[key]) or packs.en[key] or key
        if select("#", ...) > 0 then
            local ok, formatted = pcall(string.format, text, ...)
            if ok then
                return formatted
            end
        end
        return text
    end

    function ctx.describe(key)
        local text = ctx.L(key .. "_d")
        if text == key .. "_d" then
            return nil
        end
        return text
    end

    function ctx.setLanguage(code)
        if not packs[code] then
            return false
        end
        current = code
        return true
    end

    function ctx.getLanguage()
        return current
    end
end

return M
