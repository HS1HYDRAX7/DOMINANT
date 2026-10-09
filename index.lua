-- Game registry. Each entry maps a folder under games/ to a detection check and its IDs.
-- Detection uses GameIds first, then the workspace layout. ids are added to the key system's supported list.
local M = {}

M.games = {
    {
        name = "pressure",
        gameIds = {},
        placeIds = {},
        detect = function()
            return workspace:FindFirstChild("GameplayFolder") ~= nil
        end,
    },
    {
        name = "forsaken",
        gameIds = { 6331902150, 7464167604 },
        placeIds = { 18687417158, 83645629621104 },
        detect = function()
            local map = workspace:FindFirstChild("Map")
            return map ~= nil and map:FindFirstChild("Ingame") ~= nil
        end,
    },
}

-- Returns the folder name of the first matching game, or nil.
function M.detect()
    for _, entry in ipairs(M.games) do
        for _, id in ipairs(entry.gameIds) do
            if game.GameId == id then
                return entry.name
            end
        end
        for _, id in ipairs(entry.placeIds) do
            if game.PlaceId == id then
                return entry.name
            end
        end
        local ok, matched = pcall(entry.detect)
        if ok and matched then
            return entry.name
        end
    end
    return nil
end

function M.supportedIds()
    local ids = {}
    for _, entry in ipairs(M.games) do
        for _, id in ipairs(entry.placeIds) do
            table.insert(ids, id)
        end
    end
    return ids
end

return M
