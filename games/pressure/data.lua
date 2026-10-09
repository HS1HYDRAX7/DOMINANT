-- Pressure object names, patterns and colors (from the original Pressure script).
local YELLOW = Color3.fromRGB(255, 230, 0)
local GREEN = Color3.fromRGB(0, 255, 100)
local CYAN = Color3.fromRGB(100, 220, 255)
local RED = Color3.fromRGB(255, 0, 0)
local SOFT_RED = Color3.fromRGB(255, 50, 50)
local BROWN = Color3.fromRGB(180, 120, 40)
local BLUE = Color3.fromRGB(100, 100, 255)
local PURPLE = Color3.fromRGB(200, 0, 255)
local SKY = Color3.fromRGB(0, 180, 255)
local WHITE = Color3.fromRGB(255, 255, 255)

local function set(list)
    local result = {}
    for _, name in ipairs(list) do
        result[name] = true
    end
    return result
end

return {
    -- Each pattern entry: { lua pattern, label, color }
    ItemPatterns = {
        { "Lantern", "Lantern", YELLOW },
        { "Flashlight", "Flashlight", YELLOW },
        { "Blacklight", "Blacklight", YELLOW },
        { "FlashBeacon", "Flash Beacon", YELLOW },
        { "Gummylight", "Gummylight", YELLOW },
        { "WindupLight", "Windup Light", YELLOW },
        { "Battery", "Battery", YELLOW },
        { "Medkit", "Medkit", GREEN },
        { "HealthBoost", "Health Boost", GREEN },
        { "Defib", "Defib", GREEN },
        { "SPRINT", "SPRINT", CYAN },
        { "[Nn]eostyk", "NeoStyk", CYAN },
        { "Scanner", "Scanner", SOFT_RED },
        { "CodeBreacher", "Code Breacher", RED },
        { "^Book$", "Book", BROWN },
        { "ToyRemote", "Toy Remote", BLUE },
    },

    CurrencyPatterns = {
        { "^UCurrency5%-", "~5$", Color3.fromRGB(100, 220, 255) },
        { "^UCurrency10%-", "~10$", Color3.fromRGB(50, 180, 255) },
        { "^UCurrency15%-", "~15$", Color3.fromRGB(0, 150, 255) },
        { "^UCurrency25%-", "~25$", Color3.fromRGB(0, 100, 220) },
        { "^UCurrency50%-", "~50$", Color3.fromRGB(0, 80, 200) },
        { "^UCurrency100%-", "~100$", Color3.fromRGB(0, 50, 180) },
        { "^UCurrency200%-", "~200$", Color3.fromRGB(0, 30, 150) },
        { "^Currency5%-", "5$", Color3.fromRGB(180, 255, 100) },
        { "^Currency10%-", "10$", Color3.fromRGB(100, 220, 50) },
        { "^Currency15%-", "15$", Color3.fromRGB(50, 200, 50) },
        { "^Currency25%-", "25$", Color3.fromRGB(0, 180, 80) },
        { "^Currency50%-", "50$", Color3.fromRGB(0, 150, 255) },
        { "^Currency100%-", "100$", Color3.fromRGB(255, 200, 0) },
        { "^Currency200%-", "200$", Color3.fromRGB(255, 100, 0) },
        { "^Caps$", "Rare: Caps", PURPLE },
        { "^DoorsGold", "Rare: Doors Gold", PURPLE },
        { "^GOLDDD$", "Rare: GOLDDD", PURPLE },
        { "^HypnoCoin$", "Rare: Hypno Coin", PURPLE },
        { "^Regret$", "Rare: Regret", PURPLE },
        { "^Studs$", "Rare: Studs", PURPLE },
        { "^SuperCredits$", "Rare: Super Credits", PURPLE },
        { "^RareCurrency", "RARE$", PURPLE },
        { "^Blueprint$", "Blueprint", SKY },
    },

    KeyCards = {
        NormalKeyCard = { label = "Keycard", color = Color3.fromRGB(0, 0, 255) },
        InnerKeyCard = { label = "Inner Keycard", color = Color3.fromRGB(0, 120, 255) },
        PurpleKeyCard = { label = "Purple Keycard", color = Color3.fromRGB(170, 0, 255) },
        RidgeKeyCard = { label = "Ridge Keycard", color = Color3.fromRGB(255, 160, 0) },
        PasswordPaper = { label = "Password", color = WHITE },
    },

    Monsters = set({
        "A200", "A60", "Angler", "Bleach", "Bottomfeeder", "Bouncers", "CandleBearers", "CandleBrutes",
        "Eyefestation", "Eyefest", "Harbinger", "DeathAngel", "LopeePart", "Pandemonium", "Parasite", "Mirage",
        "Pipsqueak", "Rebarb", "Redeemer", "Skelepede", "Stan", "Divineroot", "TheEducator", "TheMindscape",
        "Painter", "Saboteur", "WitchingHour", "Blitz", "Squiddles", "NaviAI", "RottenCoral", "Searchlights",
        "DefenseSystem", "Froger", "Chainsmoker", "Pinkie", "WallDweller", "MeatWallDweller", "RottenWallDweller",
        "Bouncer", "SkeletonHead", "NoGood", "Coagulant", "TreeBody", "Coagulate", "DiVineRoot", "DwellerModel",
        "StatueHead", "StatueRoot", "RidgeAngler", "RidgeChainsmoker", "RidgePinkie", "RidgeBlitz", "RidgeFroger",
        "RidgePandemonium", "Anglemonium", "Frogermonium", "Blitzemonium", "Pandesmoker", "Pinkimonium", "DamageParts",
    }),

    Pandemonium = set({
        "Pandemonium", "Anglemonium", "Frogermonium", "Blitzemonium", "Pandesmoker", "Pinkimonium", "RidgePandemonium",
    }),

    DoorNames = set({ "NormalDoor", "BigDoor", "DoubleDoorSewer", "DoubleDoor", "Airlock" }),
    PhaseDoorNames = set({ "NormalGatedDoor", "NormalDoor", "BigDoor", "DoubleDoorSewer", "DoubleDoor", "LockedDoor" }),

    Colors = {
        ExitDoor = Color3.fromRGB(0, 200, 100),
        Locker = Color3.fromRGB(0, 255, 0),
        FakeDoor = Color3.fromRGB(180, 0, 0),
    },
}
