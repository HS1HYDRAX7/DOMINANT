-- Dominant loader. This is the only file users execute:
-- loadstring(game:HttpGet("<BASE>/loader.lua"))()
local BASE = "https://raw.githubusercontent.com/USER/dominant/main/"

local env = getgenv and getgenv() or _G
local previous = env.DominantInstance
if previous and type(previous.unload) == "function" then
    pcall(previous.unload)
    task.wait(0.3)
end

local Modules = loadstring(game:HttpGet(BASE .. "core/modules.lua"))()
local modules = Modules.new(BASE)
local config = modules:require("core/config")
local app = modules:require("core/app")
app.run(modules, config)
