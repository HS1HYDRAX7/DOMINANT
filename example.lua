-- Vind UI Reborn (custombg + widgets) - example
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().CONFIG = {
	Theme = "Dark",
	Intro = {
		Enabled = true,
		Title = "Vind UI Custom",
		Eyebrow = "WELCOME",
		Subtitle = "Backgrounds, widgets e showcase.",
		Logo = "Lucide:sparkles",
		UseBlur = true,
		Transparency = 0.22,
		Shimmer = true,
		Duration = 2.2,
		Skippable = true,
	},
	Integrations = {
		Spotify = false,
		Assistant = false,
		Cloud = false,
		GlobalChat = false,
	},
	MobileScaleReference = 450,
	UserInfo = {
		Enabled = true,
		Avatar = "player",
		NameMode = "display",
	},
	CommunityUrl = "https://github.com/HS1HYDRAX7/DOMINANT",
	-- Background local: coloque PNG/JPG em Dominant/Backgrounds/
	Background = {
		Path = "Dominant/Backgrounds/bg.png",
		Transparency = 0.45,
		ScaleType = "Crop",
		Enabled = false,
	},
}

local VIND_URL = "https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/refs/heads/main/vind-ui/vind-ui.lua"
local VindUI = loadstring(game:HttpGet(VIND_URL))()
VindUI:SetTheme(getgenv().CONFIG.Theme)
VindUI:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
VindUI:SetScaleRange(0.75, 1.35)
VindUI:SetMobileScaleReference(getgenv().CONFIG.MobileScaleReference)
VindUI:ShowIntro(getgenv().CONFIG.Intro):Wait()

local TOGGLE_KEY = Enum.KeyCode.RightShift
local Tabs = {}

local Window = VindUI:CreateWindow({
	Title = "Vind UI Custom",
	Subtitle = "v" .. tostring(VindUI.Version),
	Icon = "Lucide:sparkles",
	Size = UDim2.fromOffset(640, 455),
	MinSize = Vector2.new(500, 360),
	Draggable = true,
	Resizable = true,
	UseBlur = true,
	DefaultTab = "Home",
	TabWidth = 145,
	TabScrollbar = true,
	UserInfo = getgenv().CONFIG.UserInfo,
})

VindUI:Notify({
	Title = "Vind UI Custom",
	Text = "Loaded · widgets + custom backgrounds",
	Type = "success",
	Duration = 4,
})

local Main = Window:AddTabGroup({ Name = "SHOWCASE" })
Tabs.Home = Main:AddTab({ Name = "Home", Icon = "Lucide:house" })
Tabs.Widgets = Main:AddTab({ Name = "Widgets", Icon = "Lucide:layout-grid" })
Tabs.Controls = Main:AddTab({ Name = "Controls", Icon = "Lucide:sliders-horizontal" })
local Tools = Window:AddTabGroup({ Name = "WORKSPACE" })
Tabs.Background = Tools:AddTab({ Name = "Background", Icon = "Lucide:image" })
Tabs.Settings = Tools:AddTab({ Name = "Settings", Icon = "Lucide:settings-2" })

local function notify(title, message, kind)
	VindUI:Notify({ Title = title, Text = message, Type = kind or "info", Duration = 3 })
end

local function section(tab, title, icon, collapsed)
	return tab:AddCollapsibleSection({
		Title = title,
		Icon = "Lucide:" .. icon,
		Collapsed = collapsed == true,
	})
end

-- ==================== HOME ====================
local Overview = Tabs.Home:AddSubTab({ Name = "Overview", Icon = "Lucide:layout-dashboard" })
Overview:AddParagraph({
	Title = "Vind custom build",
	Icon = "Lucide:sparkles",
	Text = "Esta build adiciona SetBackground com path local (png/jpg/jpeg/gif), ScaleType e o elemento AddWidget para cards totalmente customizáveis.",
})
local Quick = section(Overview, "Quick actions", "zap")
Quick:AddButton({
	Text = "Preview notification",
	Icon = "Lucide:bell",
	Callback = function()
		notify("Hello", "Notifications stay inside the screen.")
	end,
})
Quick:AddButton({
	Text = "Open widgets tab",
	Icon = "Lucide:layout-grid",
	Callback = function()
		Window:SelectTab("Widgets")
	end,
})

-- ==================== WIDGETS ====================
local Basics = section(Tabs.Widgets, "Basic widgets", "box")
local simple = Basics:AddWidget({
	Title = "Simple widget",
	Description = "Title + description + click callback",
	Icon = "Lucide:sparkles",
	Callback = function()
		notify("Widget", "Simple widget clicked")
	end,
})

local withImage = Basics:AddWidget({
	Title = "Widget with media",
	Description = "Suporta rbxassetid, path local ou getcustomasset",
	Icon = "Lucide:image",
	Image = "rbxassetid://6031097226",
	ImageHeight = 110,
	Buttons = {
		{
			Text = "Apply",
			Primary = true,
			Callback = function(widget)
				notify("Media", "Apply pressed on " .. tostring(widget.Instance.Name))
			end,
		},
		{
			Text = "Hide image",
			Callback = function(widget)
				widget:SetImage("")
			end,
		},
	},
})

local Custom = section(Tabs.Widgets, "Custom content", "puzzle")
local live = Custom:AddWidget({
	Title = "Live counter",
	Description = "Content frame livre para montar o que quiser",
	Icon = "Lucide:gauge",
})

local counter = 0
local counterLabel = Instance.new("TextLabel")
counterLabel.BackgroundTransparency = 1
counterLabel.Size = UDim2.new(1, 0, 0, 22)
counterLabel.Font = Enum.Font.GothamMedium
counterLabel.TextSize = 14
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
counterLabel.Text = "Count: 0"
counterLabel.Parent = live.Content

live:AddButton("Increment", function(widget)
	counter += 1
	counterLabel.Text = "Count: " .. counter
	widget:SetDescription("Updated at " .. os.date("%H:%M:%S"))
end, true)

live:AddButton("Reset", function(widget)
	counter = 0
	counterLabel.Text = "Count: 0"
	widget:SetDescription("Counter reset")
end, false)

local Themed = section(Tabs.Widgets, "Styled widget", "palette", true)
local styled = Themed:AddWidget({
	Title = "Accent card",
	Description = "BackgroundColor3 + transparency custom",
	Icon = "Lucide:flame",
	BackgroundColor3 = Color3.fromRGB(40, 18, 22),
	BackgroundTransparency = 0.35,
	Buttons = {
		{
			Text = "Pulse color",
			Primary = true,
			Callback = function(widget)
				widget:SetColor(Color3.fromRGB(math.random(20, 80), math.random(10, 40), math.random(20, 60)))
			end,
		},
	},
})

-- ==================== CONTROLS ====================
local Inputs = section(Tabs.Controls, "Essentials", "sliders-horizontal")
Inputs:AddToggle({ Text = "Enable feature", Flag = "DemoEnabled", Default = false })
Inputs:AddSlider({ Text = "Intensity", Flag = "Intensity", Min = 0, Max = 100, Default = 50 })
Inputs:AddDropdown({
	Text = "Mode",
	Flag = "Mode",
	Options = { "Balanced", "Performance", "Quality" },
	Default = "Balanced",
})
Inputs:AddTextbox({ Text = "Profile name", Flag = "ProfileName", Default = "My workspace" })
local Style = section(Tabs.Controls, "Color and selection", "paintbrush")
Style:AddColorPicker({ Text = "Highlight color", Flag = "Highlight", Default = Color3.fromRGB(120, 180, 255) })
Style:AddDropdown({
	Text = "Visible details",
	Flag = "Details",
	MultiSelect = true,
	Options = { "Names", "Distance", "Status" },
	Default = { "Names", "Status" },
})

-- ==================== BACKGROUND ====================
local Bg = section(Tabs.Background, "Window background", "image")
Bg:AddParagraph({
	Title = "Como usar",
	Text = "Coloque arquivos em Dominant/Backgrounds/ (png jpg jpeg gif). Use path local ou rbxassetid. A Vind resolve com getcustomasset.",
})
Bg:AddTextbox({
	Text = "Image path / asset",
	Flag = "BgPath",
	Default = getgenv().CONFIG.Background.Path,
	Placeholder = "Dominant/Backgrounds/bg.png",
})
Bg:AddDropdown({
	Text = "ScaleType",
	Flag = "BgScale",
	Options = { "Crop", "Fit", "Stretch" },
	Default = getgenv().CONFIG.Background.ScaleType,
})
Bg:AddSlider({
	Text = "Transparency",
	Flag = "BgTransparency",
	Min = 0,
	Max = 100,
	Default = math.floor((getgenv().CONFIG.Background.Transparency or 0.45) * 100),
})
Bg:AddButton({
	Text = "Apply background",
	Icon = "Lucide:check",
	Callback = function()
		local path = VindUI.Flags.BgPath and VindUI.Flags.BgPath:Get() or getgenv().CONFIG.Background.Path
		local scale = VindUI.Flags.BgScale and VindUI.Flags.BgScale:Get() or "Crop"
		local tr = VindUI.Flags.BgTransparency and (VindUI.Flags.BgTransparency:Get() / 100) or 0.45
		Window:SetBackground({
			Image = path,
			SourcePath = path,
			Transparency = tr,
			ScaleType = scale,
		})
		notify("Background", "Applied: " .. tostring(path), "success")
	end,
})
Bg:AddButton({
	Text = "Clear background",
	Icon = "Lucide:x",
	Callback = function()
		if Window.ClearBackground then
			Window:ClearBackground()
		else
			Window:SetBackground({ Image = "" })
		end
		notify("Background", "Cleared")
	end,
})
Bg:AddButton({
	Text = "Demo rbxassetid",
	Icon = "Lucide:image",
	Callback = function()
		Window:SetBackground({
			Image = "6031097226",
			Transparency = 0.5,
			ScaleType = "Crop",
		})
		notify("Background", "Demo asset applied", "success")
	end,
})

if getgenv().CONFIG.Background.Enabled and getgenv().CONFIG.Background.Path ~= "" then
	pcall(function()
		Window:SetBackground({
			Image = getgenv().CONFIG.Background.Path,
			SourcePath = getgenv().CONFIG.Background.Path,
			Transparency = getgenv().CONFIG.Background.Transparency,
			ScaleType = getgenv().CONFIG.Background.ScaleType,
		})
	end)
end

-- ==================== SETTINGS ====================
local Storage = section(Tabs.Settings, "Saved setup", "save")
Storage:AddButton({
	Text = "Save controls",
	Icon = "Lucide:save",
	Callback = function()
		local ok, err = VindUI:SaveConfig("vind-custom-showcase")
		notify(ok and "Saved" or "Unable to save", ok and "Controls saved." or tostring(err), ok and "success" or "error")
	end,
})
Storage:AddButton({
	Text = "Load controls",
	Icon = "Lucide:folder-open",
	Callback = function()
		local ok, err = VindUI:LoadConfig("vind-custom-showcase")
		notify(ok and "Loaded" or "Unable to load", ok and "Controls restored." or tostring(err), ok and "success" or "warning")
	end,
})
Window:AddAppearanceTab()
Tabs.Settings:AddKeybind({
	Text = "Toggle UI",
	Flag = "ToggleKey",
	Default = TOGGLE_KEY,
	Callback = function(key, kind)
		if kind == "press" then
			Window:Toggle()
		end
	end,
})

Window:Open()
