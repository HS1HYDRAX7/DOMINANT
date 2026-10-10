local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local M = {}

local function requestFunction()
    local env = getgenv and getgenv() or {}
    return request or http_request or (env.syn and env.syn.request) or (http and http.request) or nil
end

local function send(method, url, body)
    local fn = requestFunction()
    if not fn then
        return nil
    end
    local ok, response = pcall(fn, {
        Url = url,
        Method = method,
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    if not ok or type(response) ~= "table" or type(response.Body) ~= "string" then
        return nil
    end
    local decoded = nil
    pcall(function()
        decoded = HttpService:JSONDecode(response.Body)
    end)
    return decoded
end

function M.Register(ctx)
    ctx.addSetting("chat_api", "")
    ctx.addSetting("chat_code", "")
end

function M.tab(window, ctx)
    local tab = window:AddTab({ Name = ctx.L("tab_chat"), Icon = "Lucide:message-square" })
    local state = { code = ctx.cfg.chat_code ~= "" and ctx.cfg.chat_code or nil, seen = 0 }
    local name = Players.LocalPlayer.DisplayName

    local function api()
        return ctx.cfg.chat_api
    end

    -- Contract of the relay server (fed by Photon Chat webhooks):
    --   POST {api}/rooms                -> { "code": "..." }
    --   POST {api}/messages             body { code, name, message }
    --   GET  {api}/messages?code=&after= -> { "messages": [ { name, message } ] }
    local function poll()
        if not state.code or api() == "" then
            return
        end
        local data = send("GET", api() .. "/messages?code=" .. HttpService:UrlEncode(state.code) .. "&after=" .. tostring(state.seen))
        local list = type(data) == "table" and data.messages or nil
        if type(list) ~= "table" then
            return
        end
        for _, entry in ipairs(list) do
            if type(entry) == "table" then
                tab:AddParagraph({
                    Title = tostring(entry.name or "?"),
                    Text = tostring(entry.message or ""),
                })
                state.seen += 1
            end
        end
    end

    local function connect(code)
        state.code = code
        state.seen = 0
        ctx.set("chat_code", code)
        ctx.startLoop("chat", 2, poll)
    end

    tab:AddTextbox({
        Text = ctx.L("chat_api"),
        Description = ctx.describe("chat_api"),
        Icon = "Lucide:link",
        Default = ctx.cfg.chat_api,
        Placeholder = "https://",
        Callback = function(text, enter)
            if enter then
                ctx.set("chat_api", tostring(text or ""))
            end
        end,
    })
    tab:AddTextbox({
        Text = ctx.L("chat_code"),
        Description = ctx.describe("chat_code"),
        Icon = "Lucide:hash",
        Default = ctx.cfg.chat_code,
        Callback = function(text, enter)
            if enter and text ~= "" then
                connect(tostring(text))
            end
        end,
    })
    tab:AddButton({
        Text = ctx.L("chat_create"),
        Icon = "Lucide:plus",
        Callback = function()
            if api() == "" then
                ctx.notify(ctx.L("chat_need_api"), "warning", 3)
                return
            end
            local data = send("POST", api() .. "/rooms", "{}")
            local code = type(data) == "table" and data.code or nil
            if not code then
                ctx.notify(ctx.L("chat_failed"), "error", 4)
                return
            end
            connect(tostring(code))
            ctx.notify(ctx.L("chat_created", tostring(code)), "success", 4)
        end,
    })
    tab:AddSection(ctx.L("chat_messages"), "Lucide:messages-square")
    tab:AddTextbox({
        Text = ctx.L("chat_message"),
        Icon = "Lucide:send",
        Placeholder = ctx.L("chat_message"),
        Callback = function(text, enter)
            if not enter or text == "" then
                return
            end
            if not state.code or api() == "" then
                ctx.notify(ctx.L("chat_need_code"), "warning", 3)
                return
            end
            local body = HttpService:JSONEncode({ code = state.code, name = name, message = tostring(text) })
            if not send("POST", api() .. "/messages", body) then
                ctx.notify(ctx.L("chat_failed"), "error", 4)
            end
            poll()
        end,
    })

    if state.code and api() ~= "" then
        ctx.startLoop("chat", 2, poll)
    end
end

return M
