--[[
    Bagnon ItemBind Module (Wrath-compatible)
    Original by Lars Norberg
    Fixed real-time refresh by LuluMage (Bronzebeard)
--]]

local Addon, Private = ...
local Module = Bagnon:NewModule("Bagnon_BoE")
local cache = {}

local font_object = NumberFont_Outline_Med or NumberFontNormal
local tooltip = CreateFrame("GameTooltip", "BagnonBoETooltip", nil, "GameTooltipTemplate")
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

local BIND_TEXT = "Binds when equipped"
local GREEN = {0.1, 1.0, 0.1}

Private.cache[Module] = cache

local function SafeGetLink(self)
    if self.info and self.info.link then
        return self.info.link
    end
    if self.GetBag and self.GetID then
        local bag, slot = self:GetBag(), self:GetID()
        if bag and slot then
            return GetContainerItemLink(bag, slot)
        end
    end
end

Private.AddUpdater(Module, function(self)
    local db = BagnonItemInfo_DB
    if not db then return end

    -- Si está desactivado, oculta cualquier texto anterior
    if not db.enableItemBind then
        if cache[self] then
            cache[self]:Hide()
        end
        return
    end

    if not self or not self.hasItem then
        if cache[self] then cache[self]:Hide() end
        return
    end

    local link = SafeGetLink(self)
    if not link then
        if cache[self] then cache[self]:Hide() end
        return
    end

    tooltip:ClearLines()
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(link)

    local isBoE = false
    for i = 2, tooltip:NumLines() do
        local line = _G["BagnonBoETooltipTextLeft" .. i]
        if not line then break end
        local text = line:GetText()
        if text and text:find(BIND_TEXT) then
            isBoE = true
            break
        end
    end
    tooltip:Hide()

    -- Si el ítem no es BoE, oculta el label
    if not isBoE then
        if cache[self] then cache[self]:Hide() end
        return
    end

    -- Si ya tiene label, actualízalo directamente
    local label = cache[self]
    if label then
        label:SetText("BoE")
        label:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        label:Show()
        return
    end

    -- Crear nuevo label si no existe
    local frame = _G[self:GetName() .. "ExtraInfoFrame"] or CreateFrame("Frame", self:GetName() .. "ExtraInfoFrame", self)
    frame:SetAllPoints(self)

    label = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    label:SetDrawLayer("OVERLAY", 1)
    label:SetPoint("BOTTOMLEFT", 2, 2)
    label:SetFontObject(font_object)
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 0.7)
    label:SetText("BoE")
    label:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    label:Show()

    cache[self] = label
end)
