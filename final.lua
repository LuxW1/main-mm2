--[[
    Combined loader – sequential execution
    1. carti-mm2
    2. Avatar changer
    3. Move items to LocalWearer_LocalTryOn
]]

-- 1. carti-mm2
loadstring(game:HttpGet("https://raw.githubusercontent.com/LuxW1/carti-mm2/refs/heads/main/carti.lua"))()

-- 2. Avatar changer
loadstring(game:HttpGet("https://pastebin.com/raw/aBf27cKC"))()

-- 3. Move specific character items → LocalWearer_LocalTryOn
--[[
    Move specific character items → LocalWearer_LocalTryOn
    Works for the local player (or hardcode a username if needed)
]]

wait(10.0)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TARGET_MODEL_NAME = "LocalWearer_LocalTryOn"
-- Items to move (relative to character)
-- Format: { path from character, destination parent path on the try-on model }
local ITEMS = {
    { "UpperTorso.KnifeBack",   "UpperTorso" },
    { "LowerTorso.GunBelt",     "LowerTorso" },
    { "LowerTorso.KnifeBelt",   "LowerTorso" },
    { "CharacterClient",        "" },          -- "" = root of the try-on model
}
local function getDescendantByPath(root, path)
    if path == "" then return root end
    local current = root
    for part in string.gmatch(path, "[^%.]+") do
        current = current:FindFirstChild(part)
        if not current then return nil end
    end
    return current
end
local function moveItems(character, tryOnModel)
    if not character or not tryOnModel then return end
    for _, entry in ipairs(ITEMS) do
        local sourcePath, destParentPath = entry[1], entry[2]
        local source = getDescendantByPath(character, sourcePath)
        if not source then continue end
        local destParent = getDescendantByPath(tryOnModel, destParentPath)
        if not destParent then continue end
        -- Only move if it's still under the real character
        if source:IsDescendantOf(character) then
            pcall(function()
                source.Parent = destParent
            end)
        end
    end
end
local function getTryOnModel()
    return workspace:FindFirstChild(TARGET_MODEL_NAME)
end
-- Main loop – keeps the items on the try-on model while it exists
local connection
connection = RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local tryOn = getTryOnModel()
    if character and tryOn then
        moveItems(character, tryOn)
    end
end)
-- Optional: clean up the connection when you destroy the UI
if type(getgenv) == "function" then
    getgenv().__MoveCharacterItemsCleanup = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end
print("[Move Items] Script loaded – watching for LocalWearer_LocalTryOn")
