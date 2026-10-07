local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/HS1HYDRAX7/DOMINANT/refs/heads/main/vind-ui/vind-ui.lua"))()

local passed = UI:KeySystem({
	Title = "My Script",
	Subtitle = "Enter your key to continue",
	Icon = "wind:key",
	Theme = "Midnight",
	Key = { "1234" },
	Services = {
		{ Name = "Get key (Link 1)", Url = "https://example.com/key1" },
		{ Name = "Get key (Link 2)", Url = "https://example.com/key2" },
	},
	Discord = "https://discord.gg/yourinvite",
	Website = "https://example.com",
	SaveKey = true,
	FileName = "MyScript",
	MaxAttempts = 5,
	LockoutSeconds = 30,
	Background = { Type = "Gradient", Colors = { Color3.fromRGB(20, 24, 60), Color3.fromRGB(70, 40, 120) }, Speed = 10 },
	Sounds = {
		Success = { Id = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.6, Speed = 1.6 },
		Fail = { Id = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.6, Speed = 0.5 },
		Start = { Id = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.7, Speed = 1.2 },
	},
})

if not passed then return end

UI:SetClickSounds(true)

local Window = UI:CreateWindow({
	Title = "My Script",
	Subtitle = "v1.0.0",
	Icon = "wind:house",
})

Window:SetBackground({
	Type = "Image",
	Source = "https://example.com/background.png",
	Transparency = 0.15,
	Overlay = 0.5,
	Parallax = true,
	ParallaxStrength = 10,
	Fade = 0.8,
})

Window:SetAnimatedBorder({ Speed = 50 })

local Main = Window:AddTab({ Name = "Main", Icon = "wind:zap" })

Main:AddButton({
	Text = "Notify",
	Description = "Plays the success notification sound",
	Icon = "wind:bell",
	Callback = function()
		UI:Notify({ Title = "Hello", Text = "Everything works.", Type = "success" })
	end,
})

local Appearance = Window:AddTab({ Name = "Appearance", Icon = "wind:palette" })

Appearance:AddDropdown({
	Text = "Theme",
	Options = UI:GetThemeNames(),
	Default = UI.CurrentTheme,
	Callback = function(name)
		UI:SetTheme(name, 0.5)
	end,
})

Appearance:AddToggle({
	Text = "Click sounds",
	Default = true,
	Callback = function(enabled)
		UI:SetClickSounds(enabled)
	end,
})

Appearance:AddButton({
	Text = "Video background",
	Description = "Needs a .webm or .mp4 link and an executor with getcustomasset",
	Callback = function()
		Window:SetBackground({ Type = "Video", Source = "https://example.com/background.webm", Overlay = 0.55 })
	end,
})

Appearance:AddButton({
	Text = "Animated sprite background",
	Callback = function()
		Window:SetBackground({
			Type = "Spritesheet",
			Source = "https://example.com/spritesheet.png",
			SheetSize = Vector2.new(1024, 1024),
			Columns = 4,
			Rows = 4,
			FPS = 12,
			Overlay = 0.5,
		})
	end,
})

Appearance:AddButton({
	Text = "Remove background",
	Callback = function()
		Window:ClearBackground()
	end,
})
