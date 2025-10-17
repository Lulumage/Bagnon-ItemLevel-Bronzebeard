------------------------------------------------------------
-- Bagnon_ItemInfo - Defaults.lua (Wrath/Ascension Edition)
------------------------------------------------------------

local Addon, Private = ...
if not Private then Private = {} end

------------------------------------------------------------
-- 🔧 Default settings
------------------------------------------------------------
local defaults = {
    enableItemLevel = true,
    enableItemBind = true,
    enableRarityColoring = true,
    enableGarbage = true,
    garbageDesaturation = true,
    garbageOverlay = true,
    garbageOverlayAlpha = 1,
}

------------------------------------------------------------
-- 🧩 Persistent SavedVariables setup
------------------------------------------------------------
if not BagnonItemInfo_DB or type(BagnonItemInfo_DB) ~= "table" then
    BagnonItemInfo_DB = CopyTable(defaults)
else
    for key, val in pairs(defaults) do
        if BagnonItemInfo_DB[key] == nil then
            BagnonItemInfo_DB[key] = val
        end
    end
end

------------------------------------------------------------
-- 🌍 Make DB accessible everywhere
------------------------------------------------------------
Private.DB = BagnonItemInfo_DB
_G[Addon .. "_DB"] = BagnonItemInfo_DB
