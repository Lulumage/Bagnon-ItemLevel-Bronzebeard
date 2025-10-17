--========================================================
-- Bagnon ItemInfo - Garbage.lua (Wrath / Ascension compatible)
--========================================================
local Addon, Private = ...
local Module = Bagnon:NewModule("Bagnon_Garbage")

local cache = {}
Private.cache[Module] = cache

-- Gray quality = "poor"
local GARBAGE_QUALITY = 0

Private.AddUpdater(Module, function(button)
    local db = BagnonItemInfo_DB
    if not db or not db.enableGarbage then return end

    -- Detectar bag y slot
    local bag, slot
    if button.GetBag then bag = button:GetBag() elseif button.bag then bag = button.bag end
    if button.GetID then slot = button:GetID() elseif button.slot then slot = button.slot end
    if not bag or not slot then return end

    local texture = button.icon or _G[button:GetName() .. "IconTexture"]
    if not texture then return end

    local link = GetContainerItemLink(bag, slot)
    if not link then
        texture:SetDesaturated(false)
        if cache[button] then cache[button]:Hide() end
        return
    end

    local _, _, quality = GetItemInfo(link)
    if not quality or quality > GARBAGE_QUALITY then
        texture:SetDesaturated(false)
        if cache[button] then cache[button]:Hide() end
        return
    end

    -- Desaturar basura
    texture:SetDesaturated(db.garbageDesaturation)

    -- Capa oscura
    if db.garbageOverlay then
        local overlay = cache[button]
        if not overlay then
            overlay = button:CreateTexture(nil, "OVERLAY")
            overlay:SetAllPoints(texture)
            overlay:SetColorTexture(0, 0, 0, db.garbageOverlayAlpha or 0.5)
            cache[button] = overlay
        end
        overlay:SetAlpha(db.garbageOverlayAlpha or 0.5)
        overlay:Show()
    elseif cache[button] then
        cache[button]:Hide()
    end
end)
