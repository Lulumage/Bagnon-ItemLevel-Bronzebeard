--[[ 
    Bagnon_ItemInfo (Wrath 3.3.5a / Bronzebeard Edition)
    Safe event-driven updater (no internal Bagnon calls)
    Adapted by LuluMage
--]]

local Addon, Private = ...
if (Private and Private.Incompatible) then return end

local Module = LibStub("AceAddon-3.0"):NewAddon("Bagnon_ItemInfo", "AceEvent-3.0")
if not Module then
    error("Failed to initialize Bagnon_ItemInfo: AceAddon-3.0 missing.")
    return
end

-- Core tables
Private = Private or {}
Private.cache = Private.cache or {}
Private.updates = Private.updates or {}
Private.updatesByModule = Private.updatesByModule or {}

-- Tooltip (used by other modules)
Private.tooltipName = "BAGNON_ITEMINFO_SCANNERTOOLTIP"
Private.tooltip = CreateFrame("GameTooltip", Private.tooltipName, nil, "GameTooltipTemplate")

-- Environment flags
Private.IsWrath = true
Private.IsRetail = false
Private.IsClassic = true
Private.ClientMajor = 3

-- Register updater function
function Private.AddUpdater(module, func)
    if not module or not func then return end
    Private.updates[module] = func
    Private.updatesByModule[module] = func
end

------------------------------------------------------------
-- ?? Universal safe refresh
------------------------------------------------------------
local function UpdateAllBagnonButtons()
    -- Bagnon frames are stored in global _G namespace, scan them
    for name, frame in pairs(_G) do
        if type(frame) == "table" and type(frame.UpdateItems) == "function" and frame.itemFrame and frame.itemFrame.buttons then
            for _, button in pairs(frame.itemFrame.buttons) do
                for _, func in pairs(Private.updates) do
                    pcall(func, button)
                end
            end
        end
    end
end

------------------------------------------------------------
-- ?? Register WoW events
------------------------------------------------------------
Module:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateAllBagnonButtons)
Module:RegisterEvent("BAG_UPDATE", UpdateAllBagnonButtons)
Module:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", UpdateAllBagnonButtons)
Module:RegisterEvent("UNIT_INVENTORY_CHANGED", UpdateAllBagnonButtons)
Module:RegisterEvent("BAG_UPDATE_DELAYED", UpdateAllBagnonButtons)

-- ?? No direct hook to Bagnon (caused your previous errors)
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Bagnon_ItemInfo]|r Active and running (safe event-driven mode).")

----------------------------------------------------------
-- 🔄 Unified real-time updater
----------------------------------------------------------
function Private.ApplyUpdates()
    for name, frame in pairs(_G) do
        if type(frame) == "table" and type(frame.UpdateItems) == "function" and frame.itemFrame and frame.itemFrame.buttons then
            for _, button in pairs(frame.itemFrame.buttons) do
                for _, updater in pairs(Private.updates) do
                    pcall(updater, button)
                end
            end
        end
    end
end

------------------------------------------------------------
-- 🔁 Smart real-time refresh (Bagnon + Ascension)
------------------------------------------------------------
if not Private.Forceupdate then
    local refreshPending = false

    function Private.Forceupdate()
        if refreshPending then return end
        refreshPending = true

        C_Timer.After(0.15, function()
            refreshPending = false

            -- Aplica internamente la lógica de actualización
            if Private.ApplyUpdates then
                pcall(Private.ApplyUpdates)
            end

            -- 🔄 Redibuja frames activos de Bagnon
            if Bagnon and Bagnon.frames then
                for _, frame in pairs(Bagnon.frames) do
                    if frame and frame:IsShown() and frame.UpdateItems then
                        frame:UpdateItems()
                        if frame.itemFrame and frame.itemFrame.UpdateItems then
                            frame.itemFrame:UpdateItems()
                        end
                    end
                end
            end
        end)
    end
end




-- Auto-refresh on bag updates or config changes
local events = CreateFrame("Frame")
events:RegisterEvent("BAG_UPDATE")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

events:SetScript("OnEvent", function()
    Private.ApplyUpdates()
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[Bagnon_ItemInfo]|r Ready – real-time updates enabled.")
